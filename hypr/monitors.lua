require("util")
require("workspaces")

-- Monitor configuration and commands
local preferences = {
    default = {config = { mode = "preferred", scale = 1, disabled=false, mirror=""}},
    left = {config = {position = "auto-left"}, mirrors={"primary", "right"}},
    primary = {config = {position = "0x0"}, mirrors={"right", "left"}},
    right = {config = {position = "auto-right"}, mirrors={"primary", "left"}},
}
-- Laptop screen
preferences["eDP-1"] = {pos = "left"}
-- Home screens
preferences["DP-5"] = {pos = "primary"}
preferences["DP-6"] = {pos = "right"}
-- Work screens
preferences["DP-7"] = {pos = "primary"}
preferences["DP-9"] = {pos = "right"}

local positions = {"left", "primary", "right"}

local position_try = {
    left = {"left", "primary", "right"},
    primary = {"primary", "left", "right"},
    right = {"right", "primary", "left"},
}

local current = {
    left = {},
    primary = {},
    right = {},
}

local function unassign(name)
    for _, pos in ipairs(positions) do
        if (current[pos].name == name) then
            current[pos].name = nil
            current[pos].config = nil
            hl.notification.create({text = "Monitor removed: " .. pos .. "(" .. name .. ")", timeout = 10000, icon="ok"})
        end
    end
end

local function assign(name)
    local prefs = preferences[name]
    local preferred = ""
    if (prefs == nil) then preferred = "primary" else preferred=prefs.pos end
    for _, try in ipairs(position_try[preferred]) do
        if current[try].name == nil then
            current[try] = MergeDeep({preferences.default, preferences[try], preferences[name], {pos = try, name = name, config={output=name}}})
            hl.notification.create({text = "Monitor added: " .. try .. "(" .. name .. ")", timeout = 10000, icon="ok"})
            return
        end
    end
end

local function mirrorof(config)
    for _,pos in ipairs(config.mirrors) do
        if current[pos].name ~= nil then
            return current[pos].name
        end
    end
    return nil
end

local function workspacemon(monpos)
    for _,wspos in ipairs(position_try[monpos]) do
        if (current[wspos].name ~= nil and not current[wspos].mirrored) then return current[wspos].name end
    end
end

local function reconfig()
    for _,pos in ipairs(positions) do
        local config = current[pos].config
        if current[pos].mirrored then config = MergeDeep({config, {mirror = mirrorof(current[pos])}}) end
        hl.monitor(config)
    end
    hl.timer(function() 
        Apply_workspaces(workspacemon("left"), workspacemon("primary"), workspacemon("right"))
    end, {timeout=100, type="oneshot"})
end

local function swap(posa, posb)
    local name = current[posa].name
    current[posa].name = current[posb].name
    current[posb] = name
    local config = current[posa].config
    current[posa].config = current[posb].config
    current[posb] = config
end

hl.on("monitor.removed", function(mon)
    unassign(mon.name)
    reconfig()
end)

hl.on("monitor.added", function(mon)
    assign(mon.name)
    reconfig()
end)

hl.on("config.reloaded", function()
    local mons = hl.get_monitors()
    for _, mon in ipairs(mons) do
        assign(mon.name)
    end
    reconfig()
end)

--hl.bind(Mod .. 'comma', function ()
--    hl.notification.create({text = "Monitor swapped: left", timeout = 10000, icon="ok"})
--    swap("left", "primary")
--    reconfig()
--end)
--hl.bind(Mod .. 'period', function ()
--    hl.notification.create({text = "Monitor swapped: right", timeout = 10000, icon="ok"})
--    swap("right", "primary")
--    reconfig()
--end)
hl.bind(Alt .. 'comma', function ()
    hl.notification.create({text = "Monitor (un)mirrored: left ", timeout = 10000, icon="ok"})
    current.left.mirrored = not current.left.mirrored
    reconfig()
end)
hl.bind(Alt .. 'period', function ()
    hl.notification.create({text = "Monitor (un)mirrored: right", timeout = 10000, icon="ok"})
    current.right.mirrored = not current.right.mirrored
    reconfig()
end)

-- Home
local leftmon = "eDP-1"
local primarymon = "DP-5"
local rightmon = "DP-6"

-- Work
-- local leftmon = "eDP-1"
-- local primarymon = "DP-7"
-- local rightmon = "DP-9"

-- Monitors
--hl.monitor({output = leftmon, mode = "preferred", position = "auto-left", scale=1})
--hl.monitor({output = primarymon, mode = "preferred", position = "0x0", scale=1})
--hl.monitor({output = rightmon, mode = "preferred", position = "auto-right", scale=1})


Apply_workspaces(leftmon, primarymon, rightmon)
