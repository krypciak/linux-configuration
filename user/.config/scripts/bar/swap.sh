#!/bin/sh
_out="$(free -h | awk '/^Swap/ {print $3}' | sed 's/i//g')"
[ "$_out" != '0B' ] && echo "󰓡$_out"

