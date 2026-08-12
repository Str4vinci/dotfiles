#!/bin/bash

set -u

action=${1:-toggle}
interface=proton
service=wg-quick@proton.service

is_connected() {
  [[ -d /sys/class/net/$interface ]]
}

refresh_waybar() {
  pkill -RTMIN+11 waybar 2>/dev/null || true
}

notify_result() {
  local message=$1
  notify-send -u low "Proton VPN" "$message" 2>/dev/null || true
}

connect_vpn() {
  if is_connected; then
    notify_result "Already connected"
    return 0
  fi

  if pkexec /usr/bin/systemctl start "$service"; then
    notify_result "Connected"
  else
    notify_result "Connection failed or authorization was cancelled"
    return 1
  fi
}

disconnect_vpn() {
  if ! is_connected; then
    notify_result "Already disconnected"
    return 0
  fi

  # A tunnel started by systemd must be stopped through systemd so its tracked
  # state stays correct. Fall back to wg-quick for the initial manual session.
  if systemctl is-active --quiet "$service"; then
    command=(/usr/bin/systemctl stop "$service")
  else
    command=(/usr/bin/wg-quick down "$interface")
  fi

  if pkexec "${command[@]}"; then
    notify_result "Disconnected"
  else
    notify_result "Disconnect failed or authorization was cancelled"
    return 1
  fi
}

case $action in
  up)
    connect_vpn
    ;;
  down)
    disconnect_vpn
    ;;
  toggle)
    if is_connected; then
      disconnect_vpn
    else
      connect_vpn
    fi
    ;;
  *)
    printf 'Usage: %s {up|down|toggle}\n' "$0" >&2
    exit 2
    ;;
esac

status=$?
refresh_waybar
exit "$status"
