#!/usr/bin/env bash

ALARM_DIR="$HOME/.local/share/waybar-alarm"
ALARM_TS_FILE="$ALARM_DIR/alarm_ts"
FIRED_FILE="$ALARM_DIR/fired"
WATCHER_PID_FILE="$ALARM_DIR/watcher.pid"

echo $$ > "$WATCHER_PID_FILE"
trap 'rm -f "$WATCHER_PID_FILE"' EXIT

# Wait until alarm time
while true; do
    [ ! -f "$ALARM_TS_FILE" ] && exit 0
    alarm_ts=$(cat "$ALARM_TS_FILE")
    now=$(date +%s)
    [ $(( alarm_ts - now )) -le 0 ] && break
    sleep 1
done

# Fire
touch "$FIRED_FILE"
paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga &

# Send notification and wait for dismissal
notify-send -u critical --wait "Alarm" "Time's up!" 2>/dev/null

rm -f "$ALARM_TS_FILE" "$FIRED_FILE"
