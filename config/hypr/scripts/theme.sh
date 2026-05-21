#!/bin/sh

# Ensure the directory exists to avoid errors
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

while true; do
    # 1. Find a random wallpaper
    # Note: Using $HOME is slightly cleaner than /home/$USER
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

    if [ -n "$WALLPAPER" ]; then
        # 2. Run wallust to generate the palette
        wallust run --backend fast-resize "$WALLPAPER" --threshold 15

        # 3. Reload Waybar without killing it
        # This sends a signal to waybar to refresh its CSS/Config
        pkill -SIGUSR2 waybar

        # 4. Notify the desktop
        #notify-send "WALLUST" "SUCCESSFULLY GENERATED PALETTE" -i "$WALLPAPER"
    else
        notify-send "WALLUST" "FAILED TO GENERATE THEME: NO WALLPAPER FOUND" -u critical
    fi

    # 5. Wait for 1 hour
    sleep 7200
done
