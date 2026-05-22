require("util")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = {colors = {"#33ccffee", "#00ff99ee"}, angle = 45},
            inactive_border = "#595959aa",
        },
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        }
    },

    animations = {
        enabled = true,
    }
})

hl.curve("animate", {type = "bezier", points = {{0.05, 0.9}, {0.1, 1.05}}})
hl.animation({leaf = "windows", enabled = true, speed=4, bezier = "animate"})
hl.animation({leaf = "windowsOut", enabled = true, speed=4, bezier = "default", style = "popin 80%"})
hl.animation({leaf = "windowsIn", enabled = true, speed=4, bezier = "default", style = "popin 80%"})
hl.animation({leaf = "workspaces", enabled = true, speed=4, bezier = "animate"})

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("/home/niek/.theming/scripts/set_and_fetch.sh set 0 hypr")
    hl.exec_cmd("eww open statusbar")
end)

