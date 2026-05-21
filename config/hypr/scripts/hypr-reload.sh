#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
HYPR_DIR="$HOME/.config/hypr"
WLOGOUT_DIR="$HOME/.config/wlogout"
SWAYNC_DIR="$HOME/.config/swaync"

reload_waybar() {
    echo "🔄 Waybar"
    pkill -SIGUSR2 waybar 2>/dev/null || waybar &
    notify-send "RELOADED WAYBAR"
}

reload_swaync() {
    echo "🔔 swaync"
    pkill -SIGUSR2 swaync 2>/dev/null || swaync &
    notify-send "RELOADED SWAYNC"
}

reload_hyprland() {
    echo "🌀 Hyprland"
    hyprctl reload
    notify-send "RELOADED HYPRLAND"
}

reload_hypridle() {
    echo "💤 hypridle"
    pkill -x hypridle
    sleep 0.2
    hypridle &
    notify-send "HYPRIDLE RELOADED"
}

watch() {
    inotifywait -m -r -e close_write,move,create \
        "$WAYBAR_DIR" \
        "$SWAYNC_DIR" \
        "$HYPR_DIR/hyprland.conf" \
        "$HYPR_DIR/hypridle.conf" \
        "$HYPR_DIR/hyprlock.conf" \
        "$WLOGOUT_DIR" |
    while read -r path _ file; do
        full="$path$file"

        case "$full" in
            *waybar*)
                reload_waybar
                ;;
            *swaync*)
                reload_swaync
                ;;
            *hyprland.conf*)
                reload_hyprland
                ;;
            *hypridle.conf*)
                reload_hypridle
                ;;
            *hyprlock.conf*)
                echo "🔐 hyprlock config updated (next lock)"
                ;;
            *wlogout*)
                echo "🚪 wlogout config updated"
                ;;
        esac
    done
}

watch
