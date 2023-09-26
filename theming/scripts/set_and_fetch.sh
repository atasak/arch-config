#!/bin/bash

# Set theme home

preset="$1"
offset="$2"
compos="$3"

DIR=~/.theming

# Check arguments
if [ -z "$preset" ] || [ -z "$offset" ] || [ -z "$compos" ]; then
    echo "Usage: set_and_fetch.sh <preset|set> <offset> <i3|hypr>"
    exit 1
fi


# Set temporary background and colors

if [ "$preset" = "preset" ]; then
    $DIR/scripts/background.sh $DIR $compos
fi

# Wait for internet

while ! ping -c 1 -W 1 8.8.8.8; do
    sleep 1
done

# Get windows spotlight image

$DIR/scripts/bing.js $DIR $offset

# Set background and colors

$DIR/scripts/background.sh $DIR $compos

# Precompute lock screen big image
if [ "$compos" = "i3" ]; then
    /home/niek/.arch-config/bin/dolock -d /home/niek/.arch-config/theming/img/wallpaper.png
fi
