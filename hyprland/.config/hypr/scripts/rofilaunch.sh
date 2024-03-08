#!/usr/bin/env bash

dir="$HOME/.config/rofi/"
theme='style-1'

case $1 in
d) r_mode="drun" ;;
w) r_mode="window" ;;
f) r_mode="filebrowser" ;;
h)
	echo -e "rofilaunch.sh [action]\nwhere action,"
	echo "d :  drun mode"
	exit 0
	;;
*) r_mode="drun" ;;
esac

## Run
rofi \
	-show "$r_mode" \
	-config "$dir"/config.rasi \
	-theme "$dir"/styles/"$theme".rasi
