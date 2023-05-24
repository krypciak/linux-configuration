#!/bin/sh
if [ "$(pgrep gammastep)" != '' ]; then 
    printf ''
    gammastep -p 2> /dev/stdout | grep 'temperature' | awk '{printf $4}' 
fi
