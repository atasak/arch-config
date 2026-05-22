-- Layout options

hl.config({
    general = {
        layout = "dwindle"
    },
    dwindle = {
        preserve_split = true
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

-- Autoconnect all bluetooth devices (does not happen automatically)
hl.on("hyprland.start", function ()
    local tmpfile = os.tmpname()
    os.execute("bluetoothctl devices | awk '{print $2}' > " .. tmpfile)
    for device in io.lines(tmpfile) do
        hl.exec_cmd ("bluetoothctl connect " .. device)
    end

end)

-- Notify on config reload
hl.on("config.reloaded", function(mon)
    hl.notification.create({text = "Config reloaded", timeout = 10000, icon="ok"})
end)
