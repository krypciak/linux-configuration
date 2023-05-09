source ~/.config/at-login.sh


export MOZ_ENABLE_WAYLAND=1
export GDK_BACKEND=wayland

export WLR_NO_HARDWARE_CURSORS=1

export XDG_CURRENT_DESKTOP='dwl'

# launches a session dbus instance
dbuslaunch="$(which dbus-launch 2>/dev/null)"
if [ -n "$dbuslaunch" ] && [ -x "$dbuslaunch" ] && [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $($dbuslaunch --sh-syntax --exit-with-session)
fi

dbus-update-activation-environment --all > /dev/null 2>&1
/usr/bin/gnome-keyring-daemon --start --components=secrets & > /dev/null 2>&1

# simulate a do-while
do=true
while $do ||  [ -f /tmp/restart_dwl ]; do
    do=false
    rm -rf /tmp/restart_dwl > /dev/null 2>&1
    ~/.config/dwl/dwl-dotfiles/dwl -s ~/.config/dwl/somebar/build/somebar > ~/.config/dwl/run/log.txt 2>&1
    [ -f /tmp/restart_dwl ] && echo Restarting dwl...
done


