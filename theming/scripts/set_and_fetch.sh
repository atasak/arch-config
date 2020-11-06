#!/bin/bash

# Set theme home

DIR=~/.theming

# Set background and colors

$DIR/scripts/background.sh $DIR

# Wait for internet

while ! ping -c 1 -W 1 8.8.8.8; do
    sleep 1
done

# Get windows spotlight image

$DIR/scripts/bing.js $DIR
