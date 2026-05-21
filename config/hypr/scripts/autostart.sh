#!/usr/bin/env bash
#!/usr/bin/env bash

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP



sleep 1

hyprpaper &
sleep 0.18

waybar &
sleep 0.24

dunst &
sleep 0.18
hypridle &

sleep 0.23
 #systemctl --user start --now easyeffects.service

sleep 0.5
blueman-applet &
sleep 0.23
systemctl --user start hyprpolkitagent
wl-paste --watch clipvault store --min-entry-length 0 --max-entries 20000 --max-entry-age 5d &
wl-paste -p --watch wl-copy &

sleep 0.3







sleep 1

sleep 0.18

sleep 0.24


sleep 0.18


sleep 0.23
 #systemctl --user start --now easyeffects.service

sleep 0.5

sleep 0.23
wl-paste --watch clipvault store --min-entry-length 0 --max-entries 20000 --max-entry-age 5d &

sleep 0.3


