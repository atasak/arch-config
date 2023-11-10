#! /usr/bin/node

import {exec} from "child_process"
import {createConnection, createServer, Socket} from "net";
import {env} from "process";

const wsNumbers = [3, 7, 3]
const pushTo = [1, 1, 1]
const wsNames = ['~', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '+']
const printTimeout = 50
const reinitTimeout = 3000

class Monitor {
    output: string | null = null
    active = -1
    focus = false
    realPos = 0
    startWs = 0

    constructor(
        public readonly model: string,
        public readonly serial: string,
        public readonly position: number,
        public readonly pushTo: number,
        public readonly pushable = false) {
    }
}

const unconfiguredMonitor = () => new Monitor('other', '', 1, 0);
const configuratedMonitors = [
    // Default extra monitor
    // Work laptop internal display (is pushable)
    new Monitor('0x06B3', '', 1, 1, true),
    // Work screen middle/main (push internal to left)
    new Monitor('PHL 275S1', 'UK02324000792', 1, 0),
    // Work screen right (unused push internal to left)
    new Monitor('PHL 275S1', 'UK02324000783', 2, 0),
]

class Workspace {
    open = false
    monPos = 0
    monitor: Monitor | null = null
    dotsLeft = 0
    dotsRight = 0
    spacesLeft = 0
    spacesRight = 0
    extraMarginRight = false

    constructor(
        public readonly id: number,
        public readonly name: string) {
    }
}

interface HyprMonitor {
    id: number,
    name: string,
    model: string,
    serial: string,
    activeWorkspace: {
        id: number
    },
    focused: boolean
}

interface HyprWorkspace {
    id: number,
}

const hyprConfig: { monitors: HyprMonitor[], workspaces: HyprWorkspace[] } = {monitors: [], workspaces: []}
const monitorConf = new Map<string, Monitor>()
const monitorByOutput = new Map<string, Monitor>()
const monitors: (Monitor | null)[] = []
const workspaces: Workspace[] = []
let focusWs = 0
const errors: string[] = []
let wsJsonCache = ''

class DelayedExecution {
    timer: NodeJS.Timeout | null = null

    constructor(private readonly delayMs: number, private readonly fn: () => void) {
    }

    execute() {
        if (this.timer !== null)
            clearTimeout(this.timer)
        this.timer = setTimeout(() => {
            this.timer = null
            this.fn()
        }, this.delayMs)
    }
}

async function sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(() => resolve(), ms))
}

function dbgVal<T>(val: T): T {
    console.log(val)
    return val
}

function filterNull<T>(array: (T | null)[]): T[] {
    const tArray: T[] = []
    for (const t of array)
        if (t !== null)
            tArray.push(t)
    return tArray
}

function wsId(id: string | number): number {
    return typeof id === 'string' ? parseInt(id) - 1 : id - 1
}

function strCmd(cmd: string): Promise<string> {
    return new Promise((resolve, reject) => {
        exec(cmd, (error, stdout, stderr) => {
            if (error)
                console.warn(error)
            resolve(stdout ? stdout.toString() : stderr.toString())
        })
    })
}

async function jsonCmd<T>(cmd: string): Promise<T> {
    return JSON.parse(await strCmd(cmd))
}


async function initHyprConfig() {
    hyprConfig.monitors = await jsonCmd<HyprMonitor[]>('hyprctl -j monitors')
    hyprConfig.workspaces = await jsonCmd<HyprWorkspace[]>('hyprctl -j workspaces')
}

function monId(hyprMon: HyprMonitor | Monitor): string {
    return `${hyprMon.model}#${hyprMon.serial}`
}

function initScreenConfig() {
    monitorConf.clear()
    for (const monConf of configuratedMonitors)
        monitorConf.set(monId(monConf), monConf)
}

function setMonTo(mon1: Monitor, pos: number, depth = 0) {
    if (monitors[pos] === null) {
        mon1.realPos = pos
        monitors[pos] = mon1
        return
    }
    const mon2 = monitors[pos]
    if (depth > 10) {
        errors.push(`Infinite monitor pushing: ${monId(mon1)} and ${monId(mon2)} on pos ${pos}`)
        return
    }
    if (!mon1.pushable && !mon2.pushable) {
        errors.push(`Double unpushable monitors: ${monId(mon1)} and ${monId(mon2)} on pos ${pos}`)
        return
    }
    if (mon1.pushable && mon2.pushable) {
        errors.push(`Double unpushable monitors: ${monId(mon1)} and ${monId(mon2)} on pos ${pos}`)
        return
    }
    if (mon1.pushable) {
        setMonTo(mon1, mon2.pushTo, depth + 1)
        return
    }
    if (mon2.pushable) {
        mon1.realPos = pos
        monitors[pos] = mon1
        setMonTo(mon2, mon1.pushTo, depth + 1)
        return
    }
}

function initMonitors() {
    monitors.length = 0
    for (let i = 0; i < wsNumbers.length; i++)
        monitors.push(null)
    for (const hyprMon of hyprConfig.monitors) {
        const mon = monitorConf.get(monId(hyprMon)) ?? unconfiguredMonitor()
        mon.output = hyprMon.name
        monitorByOutput.set(mon.output, mon)
        setMonTo(mon, mon.position);
    }
}

function monsLeft(monPos: number): number {
    let mons = 0
    for (let pos = 0; pos < monPos; pos++)
        if (monitors[pos] !== null)
            mons++
    return mons
}

function monsRight(monPos: number): number {
    let mons = 0
    for (let pos = monPos + 1; pos < monitors.length; pos++)
        if (monitors[pos] !== null)
            mons++
    return mons
}

function resolveMonPos(monPos: number): number {
    let resolveDepth = 0
    while (monitors[monPos] === null) {
        if (resolveDepth > 10) {
            errors.push(`Cycle in pushTo`)
            break
        }
        if (pushTo[monPos] === monPos) {
            errors.push(`Cannot place workspace on monitor at position ${monPos}`)
            break
        }
        monPos = pushTo[monPos]
        resolveDepth++
    }
    return monPos
}

function initWorkspaces() {
    workspaces.length = 0
    for (let i = 0; i < wsNumbers.reduce((a, b) => a + b); i++)
        workspaces.push(new Workspace(i + 1, wsNames[i]))
    let start = 0
    for (let monPos = 0; monPos < wsNumbers.length; monPos++) {
        let resolvedMonPos = resolveMonPos(monPos)
        monitors[resolvedMonPos].startWs = start
        for (let wsPos = start; wsPos < start + wsNumbers[monPos]; wsPos++) {
            workspaces[wsPos].monPos = resolvedMonPos
            workspaces[wsPos].monitor = monitors[resolvedMonPos]
            workspaces[wsPos].dotsLeft = wsPos
            workspaces[wsPos].dotsRight = wsNumbers.reduce((a, b) => a + b) - wsPos - 1
            workspaces[wsPos].spacesLeft = monsLeft(resolvedMonPos)
            workspaces[wsPos].spacesRight = monsRight(resolvedMonPos)
        }
        start += wsNumbers[monPos]
    }
    let oldWs = workspaces[0]
    for (const ws of workspaces) {
        if (ws.monPos !== oldWs.monPos)
            oldWs.extraMarginRight = true
        oldWs = ws
    }
}

function initOpenActiveFocus() {
    for (const hyprWs of hyprConfig.workspaces) {
        const id = wsId(hyprWs.id)
        if (id < workspaces.length)
            workspaces[id].open = true
    }
    for (const hyprMon of hyprConfig.monitors) {
        const mon = monitorByOutput.get(hyprMon.name)
        if (mon === null)
            continue
        if (mon.active === -1) {
            const pos = mon.realPos
            let id = wsId(hyprMon.activeWorkspace.id)
            if (id >= workspaces.length)
                id = mon.startWs
            mon.active = id
        }
        if (hyprMon.focused)
            focusWs = mon.active
    }
}

async function restoreWorkspaces() {
    for (const ws of workspaces)
        await strCmd(`hyprctl keyword workspace "${ws.id}, monitor:${ws.monitor.output}"`)
    for (const mon of filterNull(monitors))
        await strCmd(`hyprctl dispatch workspace ${mon.active + 1}`)
    await strCmd(`swww img /home/niek/.arch-config/theming/img/wallpaper.jpg`)
}

function init(print: () => void): () => Promise<void> {
    return async () => {
        errors.length = 0
        await initHyprConfig()
        initScreenConfig()
        initMonitors()
        initWorkspaces()
        initOpenActiveFocus()
        await restoreWorkspaces()
        print()
    }
}


async function* openStream(): AsyncGenerator<string, Socket, string> {
    const socket = createConnection(`/tmp/hypr/${env.HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock`)
    socket.setEncoding('utf-8')
    let linePart = ''
    for await (const chunk of socket) {
        const lines = (chunk as string).split('\n')
        lines[0] = linePart + lines[0]
        linePart = lines.pop()
        for (const line of lines)
            yield line
    }
    return socket
}

function handleCmd(initDE: DelayedExecution, cmd: string, args: string[]): boolean {
    let id = 0
    switch (cmd) {
        case 'destroyworkspace':
            id = wsId(args[0])
            if (id >= workspaces.length)
                return false
            workspaces[id].open = false
            break
        case 'createworkspace':
            id = wsId(args[0])
            if (id >= workspaces.length)
                return false
            workspaces[id].open = true
            break
        case 'focusedmon':
            id = wsId(args[1])
            if (id >= workspaces.length)
                return false
            focusWs = id
            workspaces[id].monitor.active = id
            break
        case 'workspace':
            id = wsId(args[0])
            if (id >= workspaces.length)
                return false
            focusWs = id
            workspaces[id].monitor.active = id
            break
        case 'monitoradded':
            initDE.execute()
            break
        case 'monitorremoved':
            initDE.execute()
            break
        case 'configreloaded':
            initDE.execute()
            break
        default:
            return false
    }
    return true
}

interface JsonWorkspace {
    id: number
    name: string
    cls: string
    spacesRight: number
}

interface JsonMarker {
    cls: string
    dotsLeft: number
    dotsRight: number
    spacesLeft: number
    spacesRight: number
}

interface Json {
    workspaces: JsonWorkspace[]
    markers: JsonMarker[]
    errors: string[]
}

function jsonPrint() {
    const jsonWorkspaces: JsonWorkspace[] = workspaces.map(({id, name, open, extraMarginRight}) => ({
        id, name,
        cls: open ? 'open' : 'closed',
        spacesRight: extraMarginRight ? 1 : 0
    }))
    const activeMarkers: JsonMarker[] = filterNull(monitors)
        .map(({active}) => workspaces[active])
        .map(({dotsLeft, dotsRight, spacesLeft, spacesRight}) =>
            ({cls: 'active', dotsLeft, dotsRight, spacesLeft, spacesRight}))
    const cmpFocus: (ws: Workspace) => JsonMarker = ({dotsLeft, dotsRight, spacesLeft, spacesRight}) =>
        ({cls: 'focus', dotsLeft, dotsRight, spacesLeft, spacesRight})
    const focusMarker = cmpFocus(workspaces[focusWs])
    const json: Json = {
        workspaces: jsonWorkspaces,
        markers: [...activeMarkers, focusMarker],
        errors
    }
    console.log(JSON.stringify(json))
}

function debugPrint() {
    for (const error of errors)
        console.log(error)
    let str = '| '
    for (const ws of workspaces) {
        const name = ws.open ? '-' : ' '
        str += name + ' '
        if (ws.extraMarginRight)
            str += ' '
    }
    console.log(str + '|')
    str = '| '
    for (const ws of workspaces) {
        str += ws.name + ' '
        if (ws.extraMarginRight)
            str += ' '
    }
    console.log(str + '|')
    for (const monitor of monitors) {
        if (monitor === null)
            continue
        const ws = workspaces[monitor.active]
        const left = ' '.repeat(ws.dotsLeft * 2 + ws.spacesLeft + 1)
        const right = ' '.repeat(ws.dotsRight * 2 + ws.spacesRight + 1)
        console.log('|' + left + '*' + right + '|')
    }
    const ws = workspaces[focusWs]
    const left = ' '.repeat(ws.dotsLeft * 2 + ws.spacesLeft + 1)
    const right = ' '.repeat(ws.dotsRight * 2 + ws.spacesRight + 1)
    console.log('|' + left + '^' + right + '|')
}

async function listen(print: () => void) {
    const printDE = new DelayedExecution(printTimeout, print)
    const initDE = new DelayedExecution(reinitTimeout, init(print))
    for await (const line of openStream()) {
        const unpacked = line.split('>>')
        const cmd = unpacked[0]
        const args = unpacked[1].split(',')
        const doPrint = handleCmd(initDE, cmd, args)
        if (doPrint)
            printDE.execute()
    }
}

async function main() {
    const print = process.argv[process.argv.length - 1] === 'debug' ? debugPrint : jsonPrint
    await init(print)()
    await listen(print)
}

main().catch(e => console.error(e))