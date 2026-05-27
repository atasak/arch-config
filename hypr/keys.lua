-- System binds
hl.bind(Mod .. "end",               hl.dsp.exec_cmd("hyprshutdown -t 'Exit'"))
hl.bind(Mod .. "q",                 hl.dsp.window.close("activewindow"))
hl.bind(Mod .. "g",                 hl.dsp.window.float({window="activewindow"}))
hl.bind(Mod .. Shift .. "g",        hl.dsp.window.fullscreen({Mode="fullscreen", window="activewindow"}))

-- Directional movement commands
local dirkeys = {"h", "j", "k", "l"}
local dirnames = {"l", "d", "u", "r"}
local dirdxs = {-10, 0, 0, 10}
local dirdys = {-10, 10, -10, 0}

for i = 1,4 do
    local dirkey = dirkeys[i]
    local dirname = dirnames[i]
    local dirdx = dirdxs[i]
    local dirdy = dirdys[i]
    -- Move focus
    hl.bind(Mod .. dirkey,          hl.dsp.focus({direction=dirname}))
    -- Move focussed window
    hl.bind(Mod .. Shift .. dirkey, hl.dsp.window.move({direction=dirname}))
    -- Resize focussed window
    hl.bind(Alt .. dirkey,          hl.dsp.window.resize({x=dirdx, y=dirdy, window="acrivewindow"}))
end

-- Resize with mouse
hl.bind(Alt .. "control_l", hl.dsp.window.resize(), {mouse=true})

-- Bound applications
hl.bind(Mod .. "d",                 hl.dsp.exec_cmd("fuzzel"))
hl.bind(Mod .. "pause",             hl.dsp.exec_cmd("swaylock --image ~/.theming/img/lockscreen.jpg"))
hl.bind(Mod .. "return",            hl.dsp.exec_cmd("kitty"))
hl.bind(Mod .. "f",                 hl.dsp.exec_cmd("firefox"))
hl.bind(Mod .. "s",                 hl.dsp.exec_cmd("spotify-launcher", {workspace=10}))
hl.bind(Mod .. "t",                 hl.dsp.exec_cmd("thunderbird", {workspace=9}))
hl.bind(Mod .. "c",                 hl.dsp.exec_cmd("code"))

-- Theming control
for i = 0,7 do
    hl.bind(Alt .. "F" .. (i+1),    hl.dsp.exec_cmd("~/.theming/scripts/set_and_fetch.sh set " .. i .. " hypr"))
end

-- Playback control
local playFs = {"F2", "F3", "F4"}
local playXs = {"XF86AudioPrev", "XF86AudioPlay", "XF86AudioNext"}
local playCmds = {"previous", "play-pause", "next"}
for i =1,3 do
    local playF = playFs[i]
    local playX = playXs[i]
    local playCmd = playCmds[i]
    hl.bind(Mod .. playF,           hl.dsp.exec_cmd("playerctl -p spotify " .. playCmd), {locked=true})
    hl.bind(Mod .. playX,           hl.dsp.exec_cmd("playerctl -p spotify " .. playCmd), {locked=true})
    hl.bind(Mod .. Shift .. playF,  hl.dsp.exec_cmd("playerctl -i spotify " .. playCmd), {locked=true})
    hl.bind(Mod .. Shift .. playX,  hl.dsp.exec_cmd("playerctl -i spotify " .. playCmd), {locked=true})
end

-- Audio control
hl.bind(Mod          .. "F9",       hl.dsp.exec_cmd("pactl set-sink-mute 0 toggle"), {locked=true})
hl.bind(Mod          .. "F10",      hl.dsp.exec_cmd("pactl set-sink-volume 0 -10%"), {locked=true})
hl.bind(Mod          .. "F11",      hl.dsp.exec_cmd("pactl set-sink-volume 0 +10%"), {locked=true})
hl.bind(Mod .. Shift .. "F10",      hl.dsp.exec_cmd("pactl set-sink-volume 0 -10%"), {locked=true})
hl.bind(Mod .. Shift .. "F11",      hl.dsp.exec_cmd("pactl set-sink-volume 0 +10%"), {locked=true})
hl.bind(Mod          .. "XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute 0 toggle"), {locked=true})
hl.bind(Mod          .. "XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume 0 -10%"), {locked=true})
hl.bind(Mod          .. "XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume 0 +10%"), {locked=true})
hl.bind(Mod .. Shift .. "XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume 0 -10%"), {locked=true})
hl.bind(Mod .. Shift .. "XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume 0 +10%"), {locked=true})

-- Brightness

hl.bind(Mod .. "F7",                hl.dsp.exec_cmd("brightnessctl set 10%-"))
hl.bind(Mod .. "F8",                hl.dsp.exec_cmd("brightnessctl set 10%+"))
hl.bind(Mod .. "XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))
hl.bind(Mod .. "XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"))

-- Print screen
hl.bind("Print",                    hl.dsp.exec_cmd("grim -g $(slurp)"))
hl.bind(Shift .. "Print",           hl.dsp.exec_cmd("grim -g $(slurp -d) - | wl-copy"))
