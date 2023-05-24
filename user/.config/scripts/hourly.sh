#!/bin/sh

sh ~/.config/dotfiles/scripts/ttyper.sh

if [ "$(pgrep "League")" == "" ]; then 
    zenity --info --text "break time\n please suspend"
fi
     
