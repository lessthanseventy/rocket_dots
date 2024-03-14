#!/bin/bash
# Function to get the current volume
get_volume() {
  default_sink=$(pactl get-default-sink)
  volume=$(pactl list sinks | awk -v sink="$default_sink" '$0 ~ sink {inblock=1} inblock && /^\s+Volume:/{print $5; exit}')
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

# Function to toggle mute for the active sink
toggle_mute_sink() {
  default_sink=$(pactl get-default-sink)
  pactl set-sink-mute "$default_sink" toggle
  is_muted=$(pactl list sinks | awk -v sink="$default_sink" '$0 ~ sink {inblock=1} inblock && /Mute:/{print $2; exit}')
  if [ "$is_muted" = "yes" ]; then
    dunstify -r 9999 "Muted"
  else
    dunstify -r 9999 "Unmuted"
  fi
}

# Function to toggle mute for the active source (microphone)
toggle_mute_source() {
  default_source=$(pactl get-default-source)
  pactl set-source-mute "$default_source" toggle
  is_muted=$(pactl list sources | grep 'Mute:' | awk '{print $2}')
  dunstify -r 9999 "Microphone Muted: $is_muted"
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
"mute")
  toggle_mute_sink
  ;;
"mute-mic")
  toggle_mute_source
  ;;
*)
	echo "Invalid key binding"
	;;
esac
