#!/bin/sh
source ~/.config/at_login.sh
export QT_QPA_PLATFORMTHEME=
dbus-run-session startplasma-wayland
