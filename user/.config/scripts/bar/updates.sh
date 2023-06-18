#!/bin/sh
UPDATES="$(cat ~/.cache/update)" 2> /dev/null
[ "$UPDATES" != '' ] && printf "󰘍$UPDATES"
