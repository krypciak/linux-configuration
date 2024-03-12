export AT_LOGIN_SOURCED=1

export QT_QPA_PLATFORMTHEME=qt5ct

export LANG='en_US.UTF-8'

export EDITOR='nvim'
export CM_LAUNCHER=rofi

export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

[ "$USER1" == '' ] && export USER1=$USER

export USER_HOME="/home/$USER1"
export PATH="$USER_HOME/home/.local/bin:/home/$USER1/.cargo/bin$PATH:/home/$USER1/home/.config/scripts:$USER_HOME/home/.local/share/cargo/bin"

export XDG_DATA_HOME="$USER_HOME/home/.local/share"
export XDG_STATE_HOME="$USER_HOME/home/.local/state"
export XDG_CONFIG_HOME="$USER_HOME/home/.config"
export XDG_CACHE_HOME="$USER_HOME/home/.cache"
# ~/.gtkrc-2.0
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
# ~/.icons
export XCURSOR_PATH=/usr/share/icons:"$XDG_DATA_HOME"/icons
# ~/.wine
export WINEPREFIX="$XDG_DATA_HOME"/wine
# ~/.android
export ANDROID_HOME="$XDG_DATA_HOME"/android
# ~/.bash_history
mkdir -p "$XDG_STATE_HOME"/bash
export HISTFILE="$XDG_STATE_HOME"/bash/history
# ~/.grupg
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
# ~/.cargo
export CARGO_HOME="$XDG_DATA_HOME"/cargo
# ~/go
export GOPATH="$XDG_DATA_HOME"/go
# ~/.gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
# ~/.ICEauthority
export ICEAUTHORITY="$XDG_CACHE_HOME"/ICEauthority
# ~/.node_repl_history
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history

# unset XDG_RUNTIME_DIR
# shellcheck disable=SC2155
# export XDG_RUNTIME_DIR=$(mktemp -d /tmp/$(id -u)-runtime-dir.XXX)

[ -f "/tmp/keyboard_layout" ] || echo 'qwerty' > /tmp/keyboard_layout

# source /usr/share/nvm/init-nvm.sh

# gentoo specific
export LIBSEAT_BACKEND=logind

export SDL_VIDEODRIVEVER=wayland
