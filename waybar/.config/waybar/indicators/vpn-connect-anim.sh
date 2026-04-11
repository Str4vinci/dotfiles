#!/bin/bash

set -u

set_terminal_title() {
  printf '\033]0;Omarchy\007'
}

find_saved_vpn_connection() {
  nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '
    $2 == "wireguard" && $1 ~ /(ProtonVPN|proton|pvpn)/ { print $1; exit }
  '
}

find_active_vpn_connection() {
  nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '
    $2 == "wireguard" && $1 ~ /(ProtonVPN|proton|pvpn)/ { print $1; exit }
  '
}

print_shield() {
  cat <<'EOF'

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣤⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣤⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
}

show_connecting_screen() {
  local connection_name="$1"

  set_terminal_title
  clear
  print_shield
  printf '\n'
  printf '  Connecting to VPN'
  if [[ -n "$connection_name" ]]; then
    printf ': %s' "$connection_name"
  fi
  printf '\n'
}

show_result() {
  local exit_code="$1"
  local connection_name="$2"
  local nmcli_output="$3"

  set_terminal_title
  clear

  if (( exit_code == 0 )); then
    print_shield
    printf '\n  VPN connected: %s\n' "$connection_name"
    sleep 1
    return
  fi

  cat <<'EOF'

        x

  VPN connection failed
EOF

  if [[ -n "$nmcli_output" ]]; then
    printf '\n%s\n' "$nmcli_output"
  fi

  printf '\nPress any key to close...'
  read -r -n 1 -s
  printf '\n'
}

connect_with_animation() {
  local connection_name="${1:-}"
  local nmcli_output
  local exit_code
  local start_ms
  local end_ms
  local elapsed_ms
  local min_visible_ms=900

  if [[ -z "$connection_name" ]]; then
    connection_name=$(find_saved_vpn_connection)
  fi

  if [[ -z "$connection_name" ]]; then
    clear
    printf 'No Proton VPN NetworkManager profile found.\n'
    printf '\nPress any key to close...'
    read -r -n 1 -s
    printf '\n'
    return 1
  fi

  show_connecting_screen "$connection_name"
  start_ms=$(( $(date +%s%N) / 1000000 ))

  nmcli_output=$(nmcli connection up id "$connection_name" 2>&1)
  exit_code=$?
  end_ms=$(( $(date +%s%N) / 1000000 ))
  elapsed_ms=$(( end_ms - start_ms ))

  if (( elapsed_ms < min_visible_ms )); then
    sleep "$(awk "BEGIN { printf \"%.3f\", (${min_visible_ms} - ${elapsed_ms}) / 1000 }")"
  fi

  show_result "$exit_code" "$connection_name" "$nmcli_output"
}

if [[ "${1:-}" == "--connect" ]]; then
  connect_with_animation "${2:-}"
  exit $?
fi

VPN_CONNECTION=$(find_active_vpn_connection || true)

if [[ -n "$VPN_CONNECTION" ]]; then
  nmcli connection down id "$VPN_CONNECTION"
  exit $?
fi

LAST_CONNECTION=$(find_saved_vpn_connection || true)

if [[ -n "$LAST_CONNECTION" ]]; then
  setsid uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.terminal --title=Omarchy -e bash "$0" --connect >/dev/null 2>&1 &
else
  omarchy-launch-floating-terminal-with-presentation protonvpn connect
fi
