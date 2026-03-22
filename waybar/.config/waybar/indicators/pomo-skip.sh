#!/usr/bin/env bash

POMO_SECS=1500
SHORT_SECS=300
LONG_SECS=900
LONG_BREAK_AFTER=4

STATE_DIR="$HOME/.local/share/waybar-pomo"
STATE_FILE="$STATE_DIR/state.json"

[ ! -f "$STATE_FILE" ] && exit 0

phase=$(jq -r '.phase' "$STATE_FILE")
pomodoros_done=$(jq -r '.pomodoros_done' "$STATE_FILE")

if [ "$phase" = "pomodoro" ]; then
    new_done=$((pomodoros_done + 1))
    if [ $((new_done % LONG_BREAK_AFTER)) -eq 0 ]; then
        next_phase="long_break"
        next_dur=$LONG_SECS
    else
        next_phase="short_break"
        next_dur=$SHORT_SECS
    fi
else
    next_phase="pomodoro"
    next_dur=$POMO_SECS
    new_done=$pomodoros_done
fi

tmp=$(mktemp "$STATE_DIR/.state.XXXXXX.json")
jq -n \
    --arg phase "$next_phase" \
    --argjson start_ts "$(date +%s)" \
    --argjson duration "$next_dur" \
    --argjson pomodoros_done "$new_done" \
    '{phase:$phase,start_ts:$start_ts,duration:$duration,paused_remaining:null,pomodoros_done:$pomodoros_done}' \
    > "$tmp" && mv "$tmp" "$STATE_FILE"

paplay --volume=19660 /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
notify-send "Pomodoro" "Skipped to: ${next_phase//_/ }" 2>/dev/null &
