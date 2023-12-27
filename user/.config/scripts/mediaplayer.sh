#!/bin/sh
ACTION="$1"
PLAYER_INDEX="$2"
PLAYER="$(playerctl -l | head --lines $PLAYER_INDEX | tail --lines 1)"

playerctl --player="$PLAYER" $ACTION
