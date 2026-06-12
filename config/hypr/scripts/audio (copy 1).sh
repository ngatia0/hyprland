#!/bin/bash
rm -rf ~/.local/state/pipewire/ ~/.local/state/wireplumber/
sleep 1

# kill any existing pipewire instance to restore sound
pkill -u "$USER" -fx /usr/bin/pipewire-pulse 1>/dev/null 2>&1
pkill -u "$USER" -fx /usr/bin/wireplumber 1>/dev/null 2>&1
pkill -u "$USER" -fx /usr/bin/pipewire 1>/dev/null 2>&1

exec /usr/bin/pipewire &

# wait for pipewire to start before attempting to start related daemons
while [ "$(pgrep -f /usr/bin/pipewire)" = "" ] ; do
   sleep 1
done

exec /usr/bin/wireplumber &

# wait for wireplumber to start before attempting to start pipewire-pulse
while [ "$(pgrep -f /usr/bin/wireplumber)" = "" ] ; do
   sleep 1
done

exec /usr/bin/pipewire-pulse &

sleep 2

easyeffects --gapplication-service &

sleep 2

waybar &
