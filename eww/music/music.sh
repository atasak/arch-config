#!/usr/bin/env bash

if [ "$1" = "time" ]; then
    echo '{"time":0,"length":1}'
    playerctl -F metadata -f '{"time":{{position}},"length":{{mpris:length}}}'
elif [ "$1" = "meta" ]; then
    echo '{"title":"", "artist":"", "cover":""}'
    playerctl -F metadata -f '{"title":"{{title}}", "artist":"{{artist}}", "cover":"{{mpris:artUrl}}"}'
elif [ "$1" = "cover" ]; then
    echo 'eww_covers/cover_art_default'
    playerctl -F metadata mpris:artUrl | while read -r cover; do
        curl $cover -o eww_covers/cover_art -s > /dev/null
        echo 'eww_covers/cover_art'
    done
fi
