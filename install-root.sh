#!/bin/sh
set -e

REPOHUB="$(printf "$(dirname $0)/../" | xargs realpath)"; . "$REPOHUB"/util.sh

check_is_root

_help() {
    printf "Usage:\n"
    printf "    -h --help       Displays this message\n"
    printf "    -y --noconfim   Skips confirmations\n"
    exit 1
}
handle_args 'y=export YOLO=1' 'noconfirm=export YOLO=1' "$@"


# If path starts with %, will not override
COPY_FROM_TO="\
    .config/nvim \
    .local/share/nvim \
    .config/fish \
    .bashrc \
    .config/at-login.sh \
    .config/aliases.sh \
    .config/.bash-preexec.sh \
"
info_garr "Installing dotfiles for root..."

for path in $COPY_FROM_TO; do
    _continue=0
    path="$(echo "$path" | tr '|' ' ')"
	override=1
    if [ "$(echo "$path" | head -c +1)" = '%' ]; then 
        override=0; 
        path="$(echo "$path" | tail -c +2)"; 
    fi
    
	from="$REPOHUB/dotfiles/user/$path"
	dest="/root/$path"

	if [ $override -eq 1 ] || [ ! -e "$dest" ]; then
        if [ -h "$dest" ]; then unlink "$dest"; fi
        if [ -e "$dest" ]; then
            [ "$YOLO" -eq 0 ] && confirm 'Y barr' "Do you want to override <path>${dest}</path> ?" "rm -rf $dest" 'export _continue=1'; 
            # shellcheck disable=SC2154
            [ "$_continue" -eq 1 ] && continue
        fi

	    mkdir -p "$(dirname "$dest" | head --lines 1)"
        info_barr "Copying <path>$path</path>"
	    cp -rf "$from" "$dest"
        chown_root "$dest"
    fi
done

# Update nvim plugins if there is internet
if nc -z 8.8.8.8 53 -w 1; then
    info_barr 'Updating neovim plugins...'
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerUpdate' > /dev/null 2>&1
    info 'Done'
fi
