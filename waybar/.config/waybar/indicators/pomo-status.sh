#!/usr/bin/env bash

POMO_SECS=1500   # 25 min
SHORT_SECS=300   # 5 min
LONG_SECS=900    # 15 min
LONG_BREAK_AFTER=4

STATE_DIR="$HOME/.local/share/waybar-pomo"
STATE_FILE="$STATE_DIR/state.json"

fmt_time() {
    local secs=$1
    [ "$secs" -lt 0 ] && secs=0
    printf "%02d:%02d" $((secs / 60)) $((secs % 60))
}

next_phase_info() {
    local cur_phase="$1" cur_done="$2" new_done
    if [ "$cur_phase" = "pomodoro" ]; then
        new_done=$((cur_done + 1))
        if [ $((new_done % LONG_BREAK_AFTER)) -eq 0 ]; then
            echo "long_break $LONG_SECS $new_done"
        else
            echo "short_break $SHORT_SECS $new_done"
        fi
    else
        echo "pomodoro $POMO_SECS $cur_done"
    fi
}

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

# Use jq to safely build JSON (handles escaping automatically)
json_out() {
    jq -cn --arg text "$1" --arg class "$2" --arg tooltip "$3" \
        '{text:$text,class:$class,tooltip:$tooltip}'
}

if [ ! -f "$STATE_FILE" ]; then
    json_out "󰔛" "idle" "Pomodoro
Click to start"
    exit 0
fi

phase=$(jq -r '.phase' "$STATE_FILE")
start_ts=$(jq -r '.start_ts' "$STATE_FILE")
duration=$(jq -r '.duration' "$STATE_FILE")
paused_remaining=$(jq -r '.paused_remaining' "$STATE_FILE")
pomodoros_done=$(jq -r '.pomodoros_done' "$STATE_FILE")

if [ "$paused_remaining" != "null" ]; then
    remaining=$(printf "%.0f" "$paused_remaining")
    t=$(fmt_time "$remaining")
    json_out "󰏤 $t" "paused" "Paused — $t remaining
$pomodoros_done done
Click: resume | Right: reset | Middle: skip"
else
    now=$(date +%s)
    remaining=$(( start_ts + duration - now ))

    if [ "$remaining" -le 0 ]; then
        read -r next_phase next_dur new_done <<< "$(next_phase_info "$phase" "$pomodoros_done")"
        write_state "$next_phase" "$(date +%s)" "$next_dur" "null" "$new_done"
        notify-send "Pomodoro" "Phase complete! Starting: ${next_phase//_/ }" 2>/dev/null &
        phase="$next_phase"
        remaining=$next_dur
        pomodoros_done="$new_done"
    fi

    t=$(fmt_time "$remaining")

    case "$phase" in
        pomodoro)
            json_out "󰔡 $t" "running" "Pomodoro — $t remaining
$pomodoros_done done
Right: reset | Middle: skip" ;;
        short_break)
            json_out "󰒲 $t" "short-break" "Short break — $t remaining
$pomodoros_done done
Right: reset | Middle: skip" ;;
        long_break)
            json_out "󰒳 $t" "long-break" "Long break — $t remaining
$pomodoros_done done
Right: reset | Middle: skip" ;;
    esac
fi
