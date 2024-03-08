#!/bin/bash
# Function to get the current volume
get_volume() {
	volume=$(pactl list sinks | awk '/^\s+Volume:/{print $5; exit}')
	echo "$volume"
}
# Function to display a Dunst notification
show_notification() {
	volume=$(get_volume)
	dunstify -r 9999 "Current Volume: $volume"
}
# Function to set the volume
set_volume() {
	direction=$1
	wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$direction"
	show_notification
}
# Bindings
volume_down() {
	set_volume "5%-"
}
volume_up() {
	set_volume "5%+"
}
# Main script
case "$1" in
"up")
	volume_up
	;;
"down")
	volume_down
	;;
*)
	echo "Invalid key binding"
	;;
esac
