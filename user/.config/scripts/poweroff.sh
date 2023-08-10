#!/bin/sh
if command -v systemctl; then
    systemctl poweroff
elif command -v loginctl; then
    loginctl poweroff
fi
