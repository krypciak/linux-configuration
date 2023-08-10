#!/bin/sh
if command -v systemctl; then
    systemctl reboot
elif command -v loginctl; then
    loginctl reboot
fi
