#!/bin/sh

set -e

_mode="$1"
shift

if [ -n "$WAYLAND_DISPLAY" ]; then
    _copy_cmd='wl-copy'
    _paste_cmd='wl-paste | head -c -1'

elif [ -n "$DISPLAY" ]; then
    _copy_cmd='xsel -ib'
    _paste_cmd='xsel -ob'
    
else
    _CLIP_PATH="$HOME/.cache/clipboard.txt"
    [ ! -f "$_CLIP_PATH" ] && touch "$_CLIP_PATH"
    _copy_cmd="tee $_CLIP_PATH"
    _paste_cmd="/bin/cat $_CLIP_PATH"
fi

_process_input() {
    if [ "$_mode" = 'copy' ]; then
        echo "$@" | $_copy_cmd
    elif [ "$_mode" = 'paste' ]; then
        eval "$_paste_cmd"
    else
        echo invalid mode
        exit 1
    fi
}


if [ ! -t 0 ]; then
    if [ "$_mode" = 'copy' ]; then
        _input="$(cat)"
    fi
    _process_input "$_input"
else
    _process_input "$@"
fi
