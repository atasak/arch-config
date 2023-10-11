#! bash

workspaces=13
normalpadding=2
extrapadding=24

focusws=0
activewss='{}'
existwss='[]'
focusmon=''

initialize() {
    existswss=$(for i in {0..12}; do
        echo '{"num": '$i', "exist": 0}';
    done | jq )
}

socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r line; do
    

