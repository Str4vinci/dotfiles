#!/usr/bin/env bash

ALARM_DIR="$HOME/.local/share/waybar-alarm"
ALARM_TS_FILE="$ALARM_DIR/alarm_ts"
FIRED_FILE="$ALARM_DIR/fired"

fmt_hms() {
    local secs=$1
    [ "$secs" -lt 0 ] && secs=0
    printf "%02d:%02d:%02d" $((secs / 3600)) $(( (secs % 3600) / 60 )) $((secs % 60))
}

json_out() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text:$text,class:$class,tooltip:$tooltip}'
}

if [ ! -f "$ALARM_TS_FILE" ]; then
    json_out "󰂚" "idle" "No alarm
Click to set"
    exit 0
fi

alarm_ts=$(cat "$ALARM_TS_FILE")
now=$(date +%s)
remaining=$(( alarm_ts - now ))

if [ "$remaining" -gt 0 ]; then
    t=$(fmt_hms "$remaining")
    alarm_time=$(date -d "@$alarm_ts" "+%H:%M")
    json_out "󰂞 $t" "counting" "Alarm at $alarm_time (in $t)
Click to cancel"
else
    if [ ! -f "$FIRED_FILE" ]; then
        mkdir -p "$ALARM_DIR"
        touch "$FIRED_FILE"
        notify-send -u critical "Alarm" "Time's up!" 2>/dev/null &
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga &
    fi
    json_out "󰂟" "active" "ALARM!
Click to dismiss"
fi
