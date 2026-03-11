#!/usr/bin/env bash

ALARM_DIR="$HOME/.local/share/waybar-alarm"
ALARM_TS_FILE="$ALARM_DIR/alarm_ts"
FIRED_FILE="$ALARM_DIR/fired"
WATCHER_PID_FILE="$ALARM_DIR/watcher.pid"

if [ -f "$ALARM_TS_FILE" ]; then
    if [ -f "$WATCHER_PID_FILE" ]; then
        kill "$(cat "$WATCHER_PID_FILE")" 2>/dev/null
        rm -f "$WATCHER_PID_FILE"
    fi
    rm -f "$ALARM_TS_FILE" "$FIRED_FILE"
else
    omarchy-launch-floating-terminal-with-presentation "$HOME/.config/waybar/indicators/alarm-input.sh"
fi
