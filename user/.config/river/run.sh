#!/bin/sh
. ~/.config/at-login.sh

gsettings set org.gnome.desktop.wm.preferences button-layout "" > /dev/null 2>&1 &

export MOZ_ENABLE_WAYLAND=1
export GDK_BACKEND=wayland

# launches a session dbus instance
dbuslaunch="$(which dbus-launch 2>/dev/null)"
if [ -n "$dbuslaunch" ] && [ -x "$dbuslaunch" ] && [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $($dbuslaunch --sh-syntax --exit-with-session)
fi

dbus-update-activation-environment --all > /dev/null 2>&1
/usr/bin/gnome-keyring-daemon --start --components=secrets > /dev/null 2>&1 &

# simulate a do-while
do=true
while $do || [ -f /tmp/restart_river ]; do
    do=false
    rm -rf /tmp/restart_river > /dev/null 2>&1
    river > ~/.config/river/log.txt 2>&1
    [ -f /tmp/restart_river ] && echo Restarting river...
done
