#!/bin/bash
LAST_TITLE=""

playerctl --follow metadata 2>/dev/null | while read -r _; do
    TITLE=$(playerctl metadata title 2>/dev/null)
    ARTIST=$(playerctl metadata artist 2>/dev/null)
    PLAYER=$(playerctl -p "$(playerctl metadata --format '{{playerName}}')" metadata --format '{{playerName}}')

    if [[ "$TITLE" != "$LAST_TITLE" && -n "$TITLE" ]]; then
        LAST_TITLE="$TITLE"

        ICON="media-playback-start"
        case "$PLAYER" in
            spotify) ICON="spotify";;
            mpv) ICON="mpv";;
            vlc) ICON="vlc";;
            chrome*|chromium*) ICON="google-chrome";;
        esac

        # Notify on left side (position handled by dunst)
        notify-send -u low -i "$ICON" "$TITLE" "$ARTIST"
    fi
done
