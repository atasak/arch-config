#!/bin/bash

DIR=$1
compos=$2

convert $DIR/img/wallpaper.jpg $DIR/img/wallpaper.png
cp $DIR/img/wallpaper.jpg $DIR/img/lockscreen.jpg
cp $DIR/img/wallpaper.png $DIR/img/lockscreen.png
#wal -c
#wal -i $DIR/img/wallpaper.png -n --saturate 0.6

echo "Setting wallpapers"
if [ "$compos" = "i3" ]; then
    feh --bg-fill $DIR/img/wallpaper.jpg
fi
if [ "$compos" = "hypr" ]; then
    echo "executing swww"
    swww img $DIR/img/wallpaper.jpg --transition-step 15 --transition-fps 30
fi

echo "Updating Firefox colors"
#pywalfox update

echo "Updating Intellij colors"
#for d in /home/niek/.config/JetBrains/*/ ; do
#    echo "    Generating scheme for $d"
#    mkdir -p $d/colors
#    $DIR/intellijPywal/intellijPywalGen.sh $d
#done

echo "Reload dunst"
#killall dunst
#notify-send "OS colors set"
