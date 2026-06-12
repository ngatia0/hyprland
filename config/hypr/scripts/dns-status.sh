#!/usr/bin/env bash

# Get current DNS server and DoT status
CURRENT_DNS=$(resolvectl status | grep "Current DNS Server" | head -n 1 | awk '{print $4}')
DOT_STATUS=$(resolvectl statistics | grep "DNS-over-TLS" | awk '{print $2}')

# 1. Determine IP Stack Icon
if [[ "$CURRENT_DNS" == *":"* ]]; then
    TYPE_ICON="󱚽" # IPv6
else
    TYPE_ICON="󱚼" # IPv4
fi

# 2. Determine Padlock Icon & Class
if [[ "$DOT_STATUS" == "yes" ]]; then
    LOCK_ICON=""  # Closed Padlock (Secure)
    CLASS="secure"
else
    LOCK_ICON=""  # Open Padlock (Bypass/Public)
    CLASS="public"
fi

# Output only the icons to Waybar
printf '{"text": "%s %s", "tooltip": "Server: %s\nStack: %s", "class": "%s"}\n' "$LOCK_ICON" "$TYPE_ICON" "$CURRENT_DNS" "$CLASS"
