local wskeys = {"grave", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "minus", "equal"}
local defaultworkspaces = {
    left = 1,
    primary = 4,
    right = 11,
}

function Apply_workspaces(left, primary, right)

    -- Determine on which monitor a workspace goes
    local function mon_of_ws(ws)
        if ws < 4 then
            return left
        elseif ws < 11 then
            return primary
        else 
            return right
        end
    end
        
    -- Set the workspace rules (only for new workspaces, does not move existing workspaces)
    for ws = 1,13 do
        local wskey = wskeys[ws]
        local mon = mon_of_ws(ws)
        -- Assign workspaces to monitors
        hl.workspace_rule({workspace=tostring(ws), monitor=mon})
        -- Switch to workspace keybinds
        hl.bind(Mod .. wskey, hl.dsp.focus({workspace=ws}))
        -- Move to workspace keybinds
        hl.bind(Mod .. Shift .. wskey, hl.dsp.window.move({workspace=ws, follow=true}))
    end

    -- Move existing workspaces to correct monitor
    for _,wsobj in pairs(hl.get_workspaces()) do
        local ws = wsobj.id
        local mon = mon_of_ws(ws)
        hl.dispatch(hl.dsp.workspace.move({workspace=tostring(ws), monitor=mon}))
    end

    -- Set default workspaces and correct any illegal workspace
    local currentws = hl.get_active_workspace()
    for pos,mon in pairs({left=left, primary=primary, right=right}) do
        hl.workspace_rule({workspace=tostring(defaultworkspaces[pos]), monitor=mon, default=true})
        local monconf = hl.get_monitor(mon)
        if monconf ~= nil and monconf.active_workspace.id > 13 then
            hl.dispatch(hl.dsp.focus({workspace=defaultworkspaces[pos]}))
        end
    end
    if currentws then
        hl.dispatch(hl.dsp.focus({workspace=currentws.id}))
    end
end
