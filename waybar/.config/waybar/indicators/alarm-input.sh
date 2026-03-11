#!/usr/bin/env bash

ALARM_DIR="$HOME/.local/share/waybar-alarm"
ALARM_TS_FILE="$ALARM_DIR/alarm_ts"
FIRED_FILE="$ALARM_DIR/fired"

echo "Set alarm"
echo "---------"
echo "Examples: 30s  5m  1h  1h30m  90m  1h30m45s  16:30  8:00"
echo ""
printf "Enter time: "
read -r input

input="${input// /}"

parse_relative() {
    local str="$1"
    local total_secs=0
    local h m s

    if [[ "$str" =~ ^([0-9]+)h([0-9]+)m([0-9]+)s$ ]]; then
        h="${BASH_REMATCH[1]}"; m="${BASH_REMATCH[2]}"; s="${BASH_REMATCH[3]}"
        total_secs=$(( h * 3600 + m * 60 + s ))
    elif [[ "$str" =~ ^([0-9]+)h([0-9]+)m$ ]]; then
        h="${BASH_REMATCH[1]}"; m="${BASH_REMATCH[2]}"
        total_secs=$(( h * 3600 + m * 60 ))
    elif [[ "$str" =~ ^([0-9]+)h([0-9]+)s$ ]]; then
        h="${BASH_REMATCH[1]}"; s="${BASH_REMATCH[2]}"
        total_secs=$(( h * 3600 + s ))
    elif [[ "$str" =~ ^([0-9]+)h$ ]]; then
        h="${BASH_REMATCH[1]}"
        total_secs=$(( h * 3600 ))
    elif [[ "$str" =~ ^([0-9]+)m([0-9]+)s$ ]]; then
        m="${BASH_REMATCH[1]}"; s="${BASH_REMATCH[2]}"
        total_secs=$(( m * 60 + s ))
    elif [[ "$str" =~ ^([0-9]+)m$ ]]; then
        m="${BASH_REMATCH[1]}"
        total_secs=$(( m * 60 ))
    elif [[ "$str" =~ ^([0-9]+)s$ ]]; then
        s="${BASH_REMATCH[1]}"
        total_secs=$s
    else
        return 1
    fi

    date -d "+${total_secs} seconds" +%s
}

parse_absolute() {
    local str="$1"
    local ts

    if [[ "$str" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
        ts=$(date -d "today $str" +%s)
        local now
        now=$(date +%s)
        if [ "$ts" -le "$now" ]; then
            ts=$(date -d "tomorrow $str" +%s)
        fi
        echo "$ts"
    else
        return 1
    fi
}

alarm_ts=""
if alarm_ts=$(parse_relative "$input") && [ -n "$alarm_ts" ]; then
    :
elif alarm_ts=$(parse_absolute "$input") && [ -n "$alarm_ts" ]; then
    :
else
    echo "Invalid format. Use: 30m, 1h, 1h30m, 16:30, etc."
    sleep 2
    exit 1
fi

mkdir -p "$ALARM_DIR"
echo "$alarm_ts" > "$ALARM_TS_FILE"
rm -f "$FIRED_FILE"

alarm_time=$(date -d "@$alarm_ts" "+%H:%M:%S")
echo "Alarm set for $alarm_time"
sleep 1
