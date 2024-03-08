#!/bin/bash

# Replace eDP-2 with your actual screen identifier
SCREEN="eDP-2"

# Use awk to parse the output of wlr-randr and extract the enabled status for the given screen
STATUS=$(wlr-randr | awk -v screen="$SCREEN" '
BEGIN {capture=0; enabled="no"}
/^$/ {capture=0}
$0 ~ screen {capture=1}
capture && /Enabled: yes/ {enabled="yes"}
capture && /Enabled: no/ {enabled="no"}
END {print enabled}
')

if [ "$STATUS" = "yes" ]; then
	# If the screen is enabled, disable it
	wlr-randr --output "$SCREEN" --off
else
	# If the screen is disabled, enable it
	# Adjust the resolution (e.g., 1920x1080) and position (--pos 0x0) as per your setup
	wlr-randr --output "$SCREEN" --on --mode 1920x1080 --pos 0x0
fi
