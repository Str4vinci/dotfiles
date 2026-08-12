#!/bin/bash

# Show the manual Proton WireGuard tunnel and Tailscale independently so
# simultaneous use is visible. WireGuard interfaces report "unknown" as their
# operstate, so interface presence is the reliable unprivileged status check.
if [[ -d /sys/class/net/proton ]]; then
  proton_connected=true
  proton_rx=$(cat /sys/class/net/proton/statistics/rx_bytes 2>/dev/null || printf '0')
  proton_tx=$(cat /sys/class/net/proton/statistics/tx_bytes 2>/dev/null || printf '0')
  proton_rx=$(numfmt --to=iec-i --suffix=B "$proton_rx" 2>/dev/null || printf '?')
  proton_tx=$(numfmt --to=iec-i --suffix=B "$proton_tx" 2>/dev/null || printf '?')
  proton_tooltip=$(printf 'Status: Connected\n  Protocol: WireGuard\n  Traffic: ↓%s  ↑%s' \
    "$proton_rx" "$proton_tx")
else
  proton_connected=false
  proton_tooltip="Status: Disconnected"
fi

tailscale_state=$(timeout 5 tailscale status --json 2>/dev/null \
  | jq -r '.BackendState // "Stopped"' 2>/dev/null)
tailscale_state=${tailscale_state:-Unavailable}
if [[ $tailscale_state == "Running" ]]; then
  tailscale_connected=true
else
  tailscale_connected=false
fi

if $proton_connected && $tailscale_connected; then
  text="󰖂 P·T"
  class="connected"
elif $proton_connected; then
  text="󰖂 P"
  class="connected"
elif $tailscale_connected; then
  text="󰖂 T"
  class="connected"
else
  text="󰦝"
  class="disconnected"
fi

tooltip=$(printf 'Proton VPN:\n  %s\nTailscale:\n  %s' \
  "$proton_tooltip" "$tailscale_state")
jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
