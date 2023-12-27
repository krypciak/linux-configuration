source ~/.config/at-login.sh

dbus-update-activation-environment --all
gnome-keyring-daemon --start --components=secrets

export XINITRC=$HOME/.config/awesome/run/xinitrc

# exec dbus-launch --exit-with-session startx
startx
