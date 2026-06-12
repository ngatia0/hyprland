#!/bin/sh

pkill  waybar

waybar &
hyprctl reload
#notify-send "waybar reloaded"

