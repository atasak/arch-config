#! /bin/python

import os
import socket
import json
import sys

wsnumber = 13
wssplits = [2, 9]
normalpadding = 2
extrapadding = 24
dotsize = 29

names = ['~', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '+']


def createStream():
    path = '/tmp/hypr/{signature}/.socket2.sock'\
        .format(signature=os.environ['HYPRLAND_INSTANCE_SIGNATURE'])

    stream = socket.socket(socket.AF_UNIX)
    stream.connect(path)
    return stream


def listen(handleCmd, handlePrint):
    handlePrint()
    stream = createStream()
    while True:
        message = stream.recv(1024).decode('utf-8')
        doPrint = False
        for line in message.splitlines():
            unpacked = line.split('>>')
            cmd = unpacked[0]
            args = unpacked[1].split(',')
            doPrint = handleCmd(cmd, args) or doPrint
        if doPrint:
            handlePrint()


def wsid(ws):
    return int(ws) - 1

def json_cmd(cmd):
    str = os.popen(cmd).read()
    return json.loads(str)

def getWsCfg():
    return json_cmd('hyprctl -j workspaces')

def getMonCfg():
    return json_cmd('hyprctl -j monitors')

def getActiveCfg():
    return json_cmd('hyprctl -j activeworkspace')


def printWsOpen():
    workspaces = []

    margin = 2

    for i in range(13):
        workspaces.append({
            'i': i,
            'open': False,
            'name': names[i],
            'marginRight': normalpadding,
            'totalMarginLeft': 0,
            'totalMarginRight': 0,
        })
    for i in wssplits:
        workspaces[i]['marginRight'] = extrapadding
    for i in range(13):
        workspaces[i]['totalMarginLeft'] = margin
        margin += dotsize + workspaces[i]['marginRight']
    for i in range(13):
        workspaces[i]['totalMarginRight'] = workspaces[12-i]['totalMarginLeft']

    for workspace in getWsCfg():
        workspaces[wsid(workspace['id'])]['Open'] = True

    def handleCmd(cmd, args):
        match (cmd): 
            case 'destroyworkspace':
                workspaces[wsid(args[0])] = False
            case 'createworkspace':
                workspaces[wsid(args[0])] = True
            case _:
                return False
        return True
    
    def handlePrint():
        print(json.dumps(workspaces))

    listen(handleCmd, handlePrint)


def printWsActive():
    monitors = {}
    activeMon = getActiveCfg()['monitor']

    for monitor in getMonCfg():
        monitors[monitor['name']] = wsid(monitor['activeWorkspace']['name'])

    def handleCmd(cmd, args):
        global activeMon
        match (cmd):
            case 'focusedmon':
                activeMon = args[0]
                monitors[activeMon] = wsid(args[1])
            case 'workspace':
                monitors[activeMon] = wsid(args[0])
            case _:
                return False
        return True

    def handlePrint():
        print(json.dumps(list(monitors.values())))

    listen(handleCmd, handlePrint)


def printWsFocus():
    workspace = {'ws': wsid(getActiveCfg()['name'])}

    def handleCmd(cmd, args):
        match (cmd):
            case 'focusedmon':
                workspace['ws'] = wsid(args[1])
            case 'workspace':
                workspace['ws'] = wsid(args[0])
            case 'createworkspace':
                workspace['ws'] = wsid(args[0])
            case '_':
                return False
        return True

    def handlePrint():
        print(workspace['ws'])

    listen(handleCmd, handlePrint)

file = open('output', 'a')
file.write(json.dumps(sys.argv))
file.close()

match (sys.argv[-1]):
    case 'open':
        printWsOpen()
    case 'active':
        printWsActive()
    case 'focus':
        printWsFocus()
