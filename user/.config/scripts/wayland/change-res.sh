#!/bin/sh
set -a
MONITORS="$(wlr-randr | grep -E '"*"|Enabled|preferred' | awk '{if ($1 ~ "Enabled") print $2 " "; else if ($1 ~ /[0-9]+x[0-9]+/) print $1 "@"; else print $1 " "}' | tr -d '\n' | tr '@' '\n')"
echo "$MONITORS"
MONITOR_COUNT="$(echo "$MONITORS" | wc -l)"
echo "$MONITOR_COUNT"

if [ "$MONITOR_COUNT" != '1' ]; then
    OUTPUT="$(echo "$MONITORS" | fuzzel -d --log-level none --width 25 --lines 5 | awk '{print $1}')"
else
    OUTPUT="$(echo "$MONITORS" | awk '{print $1}')"
fi

RES_TO_SORT="$(wlr-randr --output HDMI-A-1 | awk '/px/ {print $1 "@" $3 "@" int($3+0.5) }' | tr '\n' ' ')"
prev_res=''
prev_ref=''
prev_refr=''
RES_TO_SEL="$RES_TO_SORT"
for inp in $RES_TO_SORT; do
    inp="$(echo $inp | tr '@' ' ')"
    res="$(echo $inp | awk '{print $1}')"
    ref="$(echo $inp | awk '{print $2}')"
    refr="$(echo $inp | awk '{print $3}')"
    if [ "$res" = "$prev_res" ]; then
        if [ "$refr" -gt "$prev_refr" ]; then
            prev_ref="$ref"
            prev_refr="$refr"
        fi
    else
        if [ "$RES_TO_SEL" = '' ]; then
            [ "$prev_res" != '' ] && RES_TO_SEL="$prev_res @ $prev_refr \t\t\t\t\t\t\t $prev_ref"
        else
            RES_TO_SEL="$RES_TO_SEL\n$prev_res @ $prev_refr \t\t\t\t\t\t\t $prev_ref"
        fi
        prev_res="$res"
        prev_ref="$ref"
        prev_refr="$refr"
    fi
done

printf "$RES_TO_SEL"
SEL="$(printf "$RES_TO_SEL" | sort --general-numeric-sort --reverse | fuzzel -d --log-level none --width 17)"
[ $? -eq 1 ] && exit
RES="$(echo $SEL | awk '{print $1}')"
REFRESH="$(echo $SEL | awk '{print $4}')"
echo wlr-randr --output $OUTPUT --mode "$RES@$REFRESH"
wlr-randr --output $OUTPUT --mode "$RES@$REFRESH"
