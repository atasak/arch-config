#!/bin/bash

wal -c -i /etc/theming/img/wallpaper.jpg -n
convert /etc/theming/img/lockscreen.jpg /etc/theming/img/lockscreen.png
feh --bg-fill /etc/theming/img/wallpaper.jpg
