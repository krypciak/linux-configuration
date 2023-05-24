#!/bin/sh
MODULE='eth0'
TIME='4'
MULTI='1'

function format_KiB() {
    KiB=$((($2 - $1) / 1024 / $TIME))
    if [ $KiB -gt 100 ]; then
        echo "scale = 1; $KiB / 1024" | bc | tr -d '\n'; printf 'MiB'
    else
        printf "${KiB}KiB"
    fi
}

if nc -z 8.8.8.8 53 -w 1; then
    rx1=$(cat /sys/class/net/$MODULE/statistics/rx_bytes)
    tx1=$(cat /sys/class/net/$MODULE/statistics/tx_bytes)
    sleep $TIME
    rx2=$(cat /sys/class/net/$MODULE/statistics/rx_bytes)
    tx2=$(cat /sys/class/net/$MODULE/statistics/tx_bytes)

    printf ''
    format_KiB $rx1 $rx2 
    
    printf ' '
    format_KiB $tx1 $tx2
else 
    printf '󰈂'
fi
