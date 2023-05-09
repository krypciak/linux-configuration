#!/bin/sh
set -e

[ -z "$REPOHUB" ] && REPOHUB="$(printf "$(dirname $0)/../" | xargs realpath)" && export REPOHUB && . "$REPOHUB"/util.sh

# Prepare gnupg
GNUPG_DIR=~/.local/share/gnupg
mkdir -p ~/.local/share/gnupg
find $GNUPG_DIR -type f -exec chmod 600 {} \; # Set 600 for files
find $GNUPG_DIR -type d -exec chmod 700 {} \; # Set 700 for directories


PRIVATE_ARCHIVE="$REPOHUB"/dotfiles/user/private.tar.gz.gpg
PRIVATE_DIR="$REPOHUB"/dotfiles/user/private

PRIVATE_ARCHIVE="$REPOHUB"/dotfiles/user/private.tar.gz.gpg
PRIVATE_DIR="$REPOHUB"/dotfiles/user/private


[ -f "$REPOHUB"/dotfiles/user/private/sync.sh ] && \
    sh "$REPOHUB"/dotfiles/user/private/sync.sh

cd "$REPOHUB"/dotfiles/user

info_barr "Encrypting private dotfiles..."
info_garr "Enter the password into the gui"
tar -cz private | gpg --batch --yes --symmetric --output "$PRIVATE_ARCHIVE"

sha512sum private.tar.gz.gpg > "$PRIVATE_ARCHIVE".sha512

info "Done"


