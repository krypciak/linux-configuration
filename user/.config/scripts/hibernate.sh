#!/bin/sh
if command -v systemctl; then
    systemctl hibernate 
elif command -v loginctl; then
    loginctl hibernate
fi
