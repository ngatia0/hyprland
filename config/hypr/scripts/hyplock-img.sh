#!/bin/bash

# --- CONFIGURATION ---
# Your source folders
WALL_DIR="$HOME/Pictures/wallpapers"
AVATAR_DIR="$HOME/Pictures/wallpapers"

# The "Fixed" paths your hyprlock.conf will point to
FIXED_WALL="$HOME/HyprLand/temp/current_wallpaper.png"
FIXED_AVATAR="$HOME//HyprLand/temp/current_avatar.png"

# --- LOGIC ---
# 1. Pick a random file from each folder
RAND_WALL=$(find "$WALL_DIR" -type f | shuf -n 1)
RAND_AVATAR=$(find "$AVATAR_DIR" -type f | shuf -n 1)

# 2. Create symlinks (this "renames" them to the fixed path without moving the original)
ln -sf "$RAND_WALL" "$FIXED_WALL"
ln -sf "$RAND_AVATAR" "$FIXED_AVATAR"
