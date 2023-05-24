#!/bin/sh
if [ "$(pgrep redshift)" != '' ]; then 
    printf ''
    redshift -p | grep 'temperature' | tail -c +20
fi
