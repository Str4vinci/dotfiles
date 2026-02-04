#!/bin/bash

# Check if VPN is connected
VPN_CONNECTION=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep proton)

if [ -n "$VPN_CONNECTION" ]; then
    # Extract connection name
    CONNECTION_NAME=$(echo "$VPN_CONNECTION" | cut -d':' -f1)
    
    # Connected - show icon and tooltip
    printf '{"text": "󰖂", "tooltip": "%s", "class": "connected"}\n' "$CONNECTION_NAME"
else
    # Disconnected - show open lock icon
    echo '{"text": "󰌾", "tooltip": "VPN Disconnected", "class": "disconnected"}'
fi
