#!/usr/bin/env bash

sleep 1

if [ "$1" = "total" ]; then
    nvidia-smi --query-gpu=memory.total --loop=100000 --format=noheader,nounits
elif [ "$1" = "reserved" ]; then
    nvidia-smi --query-gpu=memory.reserved --loop=4 --format=noheader,nounits
elif [ "$1" = "used" ]; then
    nvidia-smi --query-gpu=memory.used --loop=4 --format=noheader,nounits
fi
