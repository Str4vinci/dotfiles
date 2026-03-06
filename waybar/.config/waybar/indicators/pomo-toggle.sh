#!/usr/bin/env bash

POMO_SECS=1500

STATE_DIR="$HOME/.local/share/waybar-pomo"
STATE_FILE="$STATE_DIR/state.json"

write_state() {
    local phase="$1" start_ts="$2" duration="$3" paused_remaining="$4" pomodoros_done="$5"
    mkdir -p "$STATE_DIR"
    local tmp
    tmp=$(mktemp "$STATE_DIR/.state.XXXXXX.json")
    if [ "$paused_remaining" = "null" ]; then
        jq -n \
            --arg phase "$phase" \
            --argjson start_ts "$start_ts" \
            --argjson duration "$duration" \
            --argjson pomodoros_done "$pomodoros_done" \
            '{phase:$phase,start_ts:$start_ts,duration:$duration,paused_remaining:null,pomodoros_done:$pomodoros_done}' \
            > "$tmp" && mv "$tmp" "$STATE_FILE"
    else
        jq -n \
            --arg phase "$phase" \
            --argjson start_ts "$start_ts" \
            --argjson duration "$duration" \
            --argjson paused_remaining "$paused_remaining" \
            --argjson pomodoros_done "$pomodoros_done" \
            '{phase:$phase,start_ts:$start_ts,duration:$duration,paused_remaining:$paused_remaining,pomodoros_done:$pomodoros_done}' \
            > "$tmp" && mv "$tmp" "$STATE_FILE"
    fi
}

if [ ! -f "$STATE_FILE" ]; then
    # Idle → start pomodoro
    write_state "pomodoro" "$(date +%s)" "$POMO_SECS" "null" "0"
    exit 0
fi

paused_remaining=$(jq -r '.paused_remaining' "$STATE_FILE")
phase=$(jq -r '.phase' "$STATE_FILE")
start_ts=$(jq -r '.start_ts' "$STATE_FILE")
duration=$(jq -r '.duration' "$STATE_FILE")
pomodoros_done=$(jq -r '.pomodoros_done' "$STATE_FILE")

if [ "$paused_remaining" = "null" ]; then
    # Running → pause
    now=$(date +%s)
    remaining=$(( start_ts + duration - now ))
    [ "$remaining" -lt 0 ] && remaining=0
    write_state "$phase" "0" "$duration" "$remaining" "$pomodoros_done"
else
    # Paused → resume
    write_state "$phase" "$(date +%s)" "$paused_remaining" "null" "$pomodoros_done"
fi
