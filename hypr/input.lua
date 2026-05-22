hl.config ({
    input = {
        kb_layout = "us",
        kb_variant = "altgr-intl",
        kb_options = "caps:escape",

        follow_mouse = 2,

        touchpad = {
            natural_scroll = false,
            disable_while_typing = true,
        },

        sensitivity = 0,
    },
    gestures = {
        workspace_swipe_forever = true,
        workspace_swipe_distance = 600,
    },
})

-- Three finger workspace scrolling
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
