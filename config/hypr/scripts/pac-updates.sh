#!/bin/sh

# Count official repo updates
PAC_COUNT=$(checkupdates 2>/dev/null | wc -l)

# Count AUR updates using paru
# -Qua: Q=query, u=upgradable, a=aur
YAY_COUNT=$(/usr/bin/paru -Qua 2>/dev/null | wc -l)

# If no updates, exit silently to save space on your bar
[ "$PAC_COUNT" -eq 0 ] && [ "$YAY_COUNT" -eq 0 ] && exit 0

CLASS="has-updates"

# Set classes for Waybar styling
[ "$PAC_COUNT" -gt 0 ] && CLASS="$CLASS pacman"
[ "$YAY_COUNT" -gt 0 ] && CLASS="$CLASS aur"

# Output format for the bar: 󰮯 12|󰣇 5
printf '{"text":" %s|%s","tooltip":"Pacman: %s\\nAUR: %s","class":"%s"}\n' \
"$PAC_COUNT" "$YAY_COUNT" "$PAC_COUNT" "$YAY_COUNT" "$CLASS"
