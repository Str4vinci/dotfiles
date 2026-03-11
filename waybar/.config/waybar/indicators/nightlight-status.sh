#!/bin/bash

TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')

if [[ "$TEMP" == "4000" ]]; then
  echo '{"text": "󰖔", "class": "active", "tooltip": "Night mode ON · click to disable"}'
else
  echo '{"text": "󰖙", "class": "inactive", "tooltip": "Night mode OFF · click to enable"}'
fi
