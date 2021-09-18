#!/bin/bash

# Set theme home

preset="$1"
offset="$2"

DIR=~/.theming

# Check arguments
if [ -z "$preset" ] || [ -z "$offset" ]; then
    echo "Usage: set_and_fetch.sh <preset|set> <offset>"
    exit 1
fi


# Set temporary background and colors

if [ "$preset" = "preset" ]; then
    $DIR/scripts/background.sh $DIR
fi

# Wait for internet

while ! ping -c 1 -W 1 8.8.8.8; do
    sleep 1
done

# Get windows spotlight image

$DIR/scripts/bing.js $DIR $offset

# Set background and colors

$DIR/scripts/background.sh $DIR

# Precompute lock screen big image

/home/niek/.arch-config/bin/dolock -d /home/niek/.arch-config/theming/img/wallpaper.png
