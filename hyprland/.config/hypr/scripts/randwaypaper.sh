#!/bin/bash

# Function to restore wallpaper using waypaper
function restore_wallpaper() {
	waypaper --random --restore
}

# Function to set interval and call waypaper --random
function set_interval() {
	local interval=$1
	while true; do
		waypaper --random --restore
		sleep "$interval"
	done
}

# Check if interval is provided as an argument
restore_wallpaper
if [[ $# -gt 0 ]]; then
	interval=$1
	set_interval "$interval"
fi
