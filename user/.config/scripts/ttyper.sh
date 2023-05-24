#!/bin/sh

if [ ! -z $1 ] && [ $1 == "ignore" ]; then 
    alacritty --class 'ttyper','ttyper' -e ttyper
elif [ "$(pgrep "League")" == "" ]; then 
    zenity --info --text="ttyper time!" && alacritty --class 'ttyper','ttyper' -e ttyper
fi
