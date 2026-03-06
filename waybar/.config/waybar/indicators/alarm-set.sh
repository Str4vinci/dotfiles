#!/usr/bin/env bash

ALARM_DIR="$HOME/.local/share/waybar-alarm"
ALARM_TS_FILE="$ALARM_DIR/alarm_ts"
FIRED_FILE="$ALARM_DIR/fired"

if [ -f "$ALARM_TS_FILE" ]; then
    rm -f "$ALARM_TS_FILE" "$FIRED_FILE"
else
    omarchy-launch-floating-terminal-with-presentation "$HOME/.config/waybar/indicators/alarm-input.sh"
fi
