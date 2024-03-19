#!/bin/bash
battery_level=$(headsetcontrol -b | grep "Battery" | awk '{print $2}' | tr -d '%')
if [[ $battery_level =~ "Charging" ]]; then
	printf '{"text": "󰂄 %s", "tooltip": "%s"}\n' "$battery_level"
elif [[ $battery_level =~ "Unavailable" ]]; then
	printf '{"text": "", "tooltip": ""}\n'
elif [[ -n $battery_level ]]; then
	printf '{"text": "󰋎 %s%%", "tooltip": "%s"}\n' "$battery_level"
else
	printf '{"text": "", "tooltip": ""}\n'
fi
