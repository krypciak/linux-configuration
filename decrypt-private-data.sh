#!/bin/sh
set -e

[ -z "$REPOHUB" ] && REPOHUB="$(printf "$(dirname $0)/../" | xargs realpath)" && export REPOHUB && . "$REPOHUB"/util.sh

_help() {
    printf "Usage:\n"
    printf "    -h --help                Displays this message\n"
    printf "    -y --noconfim            Skips confirmations\n"
    printf "    -q --quiet               Dont print out gpg output\n"
    printf "    -p --password PASSWORD   Password to auto decrypt\n"
    printf "       --gui                 Preffer gui decryption method\n"
    exit 1
}
handle_args 'y=export YOLO=1,p:=export _passwd=$2; shift,q=export QUIET=1' \
    'noconfirm=export YOLO=1,password:=export _passwd=$2; shift,gui=export _gui=1,quiet=export QUIET=1' "$@"

OUTPUT='/dev/stdout'
[ "$QUIET" = '1' ] && OUTPUT='/dev/null'

# Prepare gnupg
GNUPG_DIR=~/.local/share/gnupg
mkdir -p "$GNUPG_DIR"
find "$GNUPG_DIR" -type f -exec chmod 600 {} \; # Set 600 for files
find "$GNUPG_DIR" -type d -exec chmod 700 {} \; # Set 700 for directories


PRIVATE_ARCHIVE="$REPOHUB"/dotfiles/user/private.tar.gz.gpg
PRIVATE_DIR="$REPOHUB"/dotfiles/user/private

cd "$REPOHUB"/dotfiles/user

# Check archive integrity
sha512sum --check "$PRIVATE_ARCHIVE".sha512 > $OUTPUT 2>&1
if [ "$?" -eq 1 ]; then
	err "Encrypted archive is corrupted!"
	exit 1
fi
info "Private archive is valid"

info_garr "Decrypting private dotfiles..."
# Decrypt
i=0
while [ "$i" != '5' ]; do
    # shellcheck disable=SC2154
    if [ "$_passwd" != '' ]; then
        info_barr 'Trying auto decryption...'
        ( echo "$_passwd"; ) | gpg --batch --yes --passphrase-fd 0 --no-symkey-cache \
            --output "$REPOHUB"/tmp/private.tar.gz --decrypt \
            --pinentry-mode=loopback "$PRIVATE_ARCHIVE" > "$OUTPUT" 2>&1 && break
        err "Auto decryption failed."
        unset _passwd
    fi
    mode='--pinentry-mode=loopback'
    msg=':'
    # shellcheck disable=SC2154
    if [ "$_gui" = '1' ]; then
        mode=''
        msg=' into the gui'
    fi

    info_barr "Enter the password$msg"
    gpg --output "$REPOHUB"/tmp/private.tar.gz "$mode" --decrypt "$PRIVATE_ARCHIVE" > "$OUTPUT" 2>&1 && break
    err "Invalid password"
    _retry=0
    confirm 'Y barr ignore' 'Do you want to retry?' 'export _retry=1' ''

    [ "$_retry" = '0' ] && exit 0
    i=$((i+1))
done
if [ "$i" = '5' ]; then
    err "Reached 5 failed atempts."
    exit 1
fi

# Backup previous private dir if it exists
if [ -d "$PRIVATE_DIR" ]; then
	[ -d "$PRIVATE_DIR".old ] && rm -rf "$PRIVATE_DIR".old
	mv "$PRIVATE_DIR" "$PRIVATE_DIR".old
fi

cd "$REPOHUB"/dotfiles/user
tar -xf "$REPOHUB"/tmp/private.tar.gz 
rm -f "$REPOHUB"/tmp/private.tar.gz
info "Done"

sh "$PRIVATE_DIR"/install.sh

