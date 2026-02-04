#!/bin/bash

# Toggle VPN connection
VPN_CONNECTION=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep proton)

if [ -n "$VPN_CONNECTION" ]; then
    # VPN is connected - disconnect it
    CONNECTION_NAME=$(echo "$VPN_CONNECTION" | cut -d':' -f1)
    nmcli connection down "$CONNECTION_NAME"
else
    # VPN is disconnected - connect to last used or show menu
    # Try to find the most recently used ProtonVPN connection
    LAST_CONNECTION=$(nmcli -t -f NAME,TYPE connection show | grep -E "ProtonVPN|proton" | head -1 | cut -d':' -f1)
    
    if [ -n "$LAST_CONNECTION" ]; then
        nmcli connection up "$LAST_CONNECTION"
    else
        # No previous connection found - open menu
        omarchy-launch-floating-terminal-with-presentation protonvpn connect
    fi
fi
