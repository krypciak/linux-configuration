#!/bin/sh
UPDATES="$(cat ~/.config/update)" 2> /dev/null
i[ "$UPDATES" != '' ] && printf "󰘍$UPDATES"
