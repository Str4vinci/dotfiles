#!/bin/bash

# Show Proton VPN and Tailscale independently so simultaneous use is visible.
proton_status=$(timeout 8 protonvpn status 2>/dev/null || true)
if grep -q '^Status: Connected' <<< "$proton_status"; then
  proton_connected=true
  proton_tooltip=${proton_status//$'\n'/$'\n  '}
else
  proton_connected=false
  proton_tooltip="Status: Disconnected"
fi

tailscale_state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState // "Stopped"' 2>/dev/null)
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
  "$proton_tooltip" "${tailscale_state:-Unavailable}")
jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
