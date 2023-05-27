#!/bin/sh
set -e

REPOHUB="$(printf "$(dirname $0)/../" | xargs realpath)"; . "$REPOHUB"/util.sh

_help() {
    printf "Usage:\n"
    printf "    -h --help       Displays this message\n"
    printf "    -y --noconfim   Skips confirmations\n"
    exit 1
}
handle_args '-y|--noconfirm=export YOLO=1' "$@"


SYMLINK_FROM_TO="\
    .config/at-login.sh \
    .config/aliases.sh \
    .config/.bash-preexec.sh \
    .config/scripts \
    .config/nvim \
    .local/share/nvim \
    .config/fish \
    .config/tealdeer \
    .bashrc \
    .bash_profile \
    .config/xsessions \
    .config/neofetch \
    .config/topgrade.toml \
    .config/ttyper \
    .config/animdl \
    .config/mimeapps.list \
    .shellcheckrc \
    \
    .config/alacritty \
    .config/wallpapers \
    .config/cmus/autosave \
    .config/cmus/red_theme.theme \
    .config/cmus/notify.cfg \
    \
    .config/awesome \
    .config/redshift \
    .config/rofi \
    \
    .config/dwl \
    .config/river \
    .config/gammastep \
    .config/fuzzel \
    .config/swaylock \
    .config/fnott \
    \
    .config/chromium/Default/Extensions \
    .config/chromium/Default/Sync|Extension|Settings \
    .config/chromium/Default/Managed|Extension|Settings \
    .config/chromium/Default/Local|Extension|Settings \
    \
    .config/BetterDiscord/plugins \
    \
    .config/tridactyl \
    \
    .config/gtkrc \
    .config/gtkrc-2.0 \
    .config/krunnerrc \
    .config/plasmarc \
    .config/plasmashellrc \
"

# If path starts with %, will not override
COPY_FROM_TO="\
    .config/gtk-2.0 \
    .config/gtk-3.0 \
    .config/gtk-4.0 \
    .config/qt5ct \
    .config/kdeglobals \
    \
    .config/tutanota-desktop/conf.json \
    \
    .config/discord/settings.json \
    \
    .config/FreeTube/settings.db \
    \
    .local/share/PrismLauncher/multimc.cfg \
    \
    .config/keepassxc \
    \
    .local/share/applications/tutanota-desktop.desktop \
    .local/share/applications/arch-update.desktop \
    \
    .config/chromium/Default/Preferences  \
    %.config/chromium/Default/Cookies \
    .config/chromium/Local|State \
    .config/chromium-flags.conf \
"

LINK_HOME_DIRS="\
    .config \
    .local \
    .cache\
    Documents \
    Downloads \
    Pictures \
    Videos \
    Programming \
    VM \
    Games \
    Temp \
    Music \
    .mozilla \
    .librewolf \
"

cd "$REPOHUB" || exit 1
info "Updating submodules..."
#git submodule update --init --recursive

info "Installing dotfiles for user..."

info_garr "Linking home dirs..."
for dir in $LINK_HOME_DIRS; do
	dest="$REAL_USER_HOME/$dir"
	if [ -h "$dest" ]; then unlink  "$dest"; fi
    if [ -e "$dest" ]; then
        # shellcheck disable=SC2012
        info "<path>$dest</path> contains: $(ls "$dest" | tr '\n' ' ')"
        confirm 'Y barr ignore' "Do you want to override <path>${dest}</path> ? ${RED}${BOLD}(ALL DATA WILL BE WIPED)${NC}" \
            "rm -rf '$dest'" 'err "Cannot continue."; exit 1'
    fi
    mkdir -p "$USER_HOME/$dir"
    info_barr "Linking <path>$dir</path>"
	ln -sfT "$USER_HOME/$dir" "$dest"
done

info_garr "Linking configuration files..."
for path in $SYMLINK_FROM_TO; do
    _continue=0
    path="$(echo "$path" | tr '|' ' ')"
	override=1
    if [ "$(echo "$path" | head -c +1)" = '%' ]; then 
        override=0
        path="$(echo "$path" | tail -c +2)"
    fi

	from="$REPOHUB/dotfiles/user/$path"
	dest="$REAL_USER_HOME/$path"

	if [ $override -eq 1 ] || [ ! -e "$dest" ]; then
        if [ -h "$dest" ]; then unlink "$dest"; fi
        if [ -e "$dest" ]; then 
            [ "$YOLO" -eq 0 ] && confirm 'Y barr' "Do you want to override <path>${dest}</path> ?" "rm -rf $dest" 'export _continue=1'
            # shellcheck disable=SC2154
            [ "$_continue" -eq 1 ] && continue
        fi

        mkdir -p "$(dirname "$dest" | head --lines 1)"
        info_barr "Linking <path>$path</path>"
        ln -sfT "$from" "$dest"
        chown_user "$dest"
    fi
done

info_garr "Copying configuration files..."
for path in $COPY_FROM_TO; do
    _continue=0
    path="$(echo "$path" | tr '|' ' ')"
	override=1
    if [ "$(echo "$path" | head -c +1)" = '%' ]; then 
        override=0; 
        path="$(echo "$path" | tail -c +2)"; 
    fi

	from="$REPOHUB/dotfiles/user/$path"
	dest="$REAL_USER_HOME/$path"

	if [ $override -eq 1 ] || [ ! -e "$dest" ]; then
        if [ -h "$dest" ]; then unlink "$dest"; fi
        if [ -e "$dest" ]; then 
            [ "$YOLO" -eq 0 ] && confirm 'Y barr' "Do you want to override <path>${dest} </path> ?" "rm -rf $dest" 'export _continue=1'
            # shellcheck disable=SC2154
            [ "$_continue" -eq 1 ] && continue
        fi

	    mkdir -p "$(dirname "$dest" | head --lines 1)"
        info_barr "Copying <path>$path</path>"
	    cp -rf "$from" "$dest"
        chown_user "$dest"
    fi
done

path="$USER_HOME"/.local/share/PrismLauncher/multimc.cfg
if [ -f "$path" ]; then
    sed -i "s|USER_HOME|$USER_HOME|g" "$path"
    sed -i "s|HOSTNAME|$(hostname)|g" "$path"
fi


chmod +x "$USER_HOME"/.config/awesome/run/run.sh
chmod +x "$USER_HOME"/.config/at-login.sh
chmod +x "$USER_HOME"/.config/aliases.sh
chmod +x "$USER_HOME"/.config/.bash-preexec.sh
chmod +x "$USER_HOME"/.config/scripts/*.sh
chmod +x "$USER_HOME"/.config/scripts/copy
chmod +x "$USER_HOME"/.config/scripts/pst

# Update nvim plugins if there is internet
if nc -z 8.8.8.8 53 -w 1; then
    info_barr 'Updating neovim plugins...'
    timeout 20s nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerUpdate' > /dev/null 2>&1
    info 'Done'
fi
