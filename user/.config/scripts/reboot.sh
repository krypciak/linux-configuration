#!/bin/sh
if command -v systemctl; then
    echo a
    systemctl reboot
elif command -v loginctl; then
    loginctl reboot
fi
