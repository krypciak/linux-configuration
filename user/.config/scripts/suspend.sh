#!/bin/sh
if command -v systemctl; then
    systemctl suspend
elif command -v loginctl; then
    loginctl suspend
fi
