#!/bin/bash

DIR=$1

cp $DIR/img/wallpaper.png $DIR/img/lockscreen.png
convert $DIR/img/wallpaper.jpg $DIR/img/wallpaper.png
wal -c
wal -i $DIR/img/wallpaper.png -n --saturate 0.6

echo "Setting wallpapers"
feh --bg-fill $DIR/img/wallpaper.jpg

echo "Updating Firefox colors"
pywalfox update

echo "Updating Intellij colors"
for d in /home/niek/.config/JetBrains/*/ ; do
    echo "    Generating scheme for $d"
    mkdir -p $d/colors
    $DIR/intellijPywal/intellijPywalGen.sh $d
done

echo "Reload dunst"
killall dunst
notify-send "OS colors set"
