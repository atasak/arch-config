#!/bin/bash

DIR=$1

cp $DIR/img/wallpaper.png $DIR/img/lockscreen.png
convert $DIR/img/wallpaper.jpg $DIR/img/wallpaper.png
wal -c
wal -i $DIR/img/wallpaper.png -n --saturate 0.8
feh --bg-fill $DIR/img/wallpaper.jpg
pywalfox update

$DIR/telegram/telegram-palette-gen --wal
