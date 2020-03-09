#!/bin/bash

cp /etc/theming/img/wallpaper.png /etc/theming/img/lockscreen.png
convert /etc/theming/img/wallpaper.jpg /etc/theming/img/wallpaper.png
wal -i /etc/theming/img/wallpaper.png -n
feh --bg-fill /etc/theming/img/wallpaper.jpg

/etc/theming/telegram/telegram-palette-gen --wal
