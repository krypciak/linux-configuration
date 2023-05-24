#!/bin/sh
wlr-randr | grep -E '"*"|Enabled|preferred' | awk '{if ($1 ~ "Enabled") print $2 " "; else if ($1 ~ /[0-9]+x[0-9]+/) print $1 "@"; else print $1 " "}' | tr -d '\n' | tr '@' '\n' | fuzzel -d --log-level none --width 25 --lines 5 | awk '{print $1}' | xargs -I _ wlr-randr --output _ --toggle
