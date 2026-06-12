#!/bin/bash

# Configuration: how long to wait between checks (1 hour = 3600 seconds)
INTERVAL=3600

while true; do
    # 1. Check if we actually have updates to avoid unnecessary notifications
    # 'paru -Qu' lists updates; we count the lines
    UPDATE_COUNT=$(paru -Qu | wc -l)

    if [ "$UPDATE_COUNT" -gt 0 ]; then
        notify-send "System Update" "Found $UPDATE_COUNT updates. Starting background sync..." -i system-software-update

        # 2. Run the update process silently
        if paru -Syyu --ignore ffmpeg-git --noconfirm > /dev/null 2>&1; then
            notify-send "Update Complete" "System is now current 🤓" -i checked
        else
            notify-send "Update Failed" "Background update encountered an error." -u critical -i error
        fi
    fi

    # 3. Wait for 1 hour before checking again
    sleep $INTERVAL
done
