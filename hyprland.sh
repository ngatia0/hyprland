
#!/bin/bash
set -e
#git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git

STATE_FILE="/tmp/install_state"
[ -f "$STATE_FILE" ] && CURRENT_STATE=$(cat "$STATE_FILE") || CURRENT_STATE="2"

if [ "$CURRENT_STATE" = "2" ]; then
  paru -S --needed --noconfirm hyprland-guiutils-git
  paru -S --needed --noconfirm xdg-desktop-portal-hyprland-git
  paru -S --needed --noconfirm hyprpolkitagent-git
  paru -S --needed --noconfirm hyprutils-git

  paru -S --needed --noconfirm mesa-git
  paru -S --needed --noconfirm libva-intel-driver-git
  paru -S --needed --noconfirm libva-utils-git
  paru -S --needed --noconfirm intel-media-driver-git

  chmod +x /home/kvnx/hyprland-de/ffmpeg-depen.sh
  /home/kvnx/hyprland-de/ffmpeg-depen.sh
  cd ~

  echo "Have you installed ffmpeg zst ?"
  read -p "Answer (y/n): " answer
  if [[ "$answer" != [Yy]* ]]; then
    echo "Exiting. Please install ffmpeg zst and rerun the script."
    exit 1
  fi

  echo "3" > "$STATE_FILE"
  sudo reboot
fi

if [ "$CURRENT_STATE" = "3" ]; then
  paru -S --needed --noconfirm hyprwayland-scanner-git
  paru -S --needed --noconfirm aquamarine-git
  paru -S --needed --noconfirm hyprgraphics-git

  # Added rtkit-runit for init integration
  sudo pacman -S --needed --noconfirm pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol-qt rtkit rtkit-runit libnotify inotify-tools

  # Enable rtkit daemon via runit
  sudo ln -sf /etc/runit/sv/rtkit-daemon /etc/runit/runsvdir/default/

  paru -S --needed --noconfirm clipvault hyprlock-git hyprpaper-git hyprland-qt-support-git hyprcursor-git
  paru -S --needed --noconfirm waybar-git --mflags "--nocheck"
  paru -S --needed --noconfirm hyprland-guiutils-git

  echo "4" > "$STATE_FILE"
  sudo reboot
fi

if [ "$CURRENT_STATE" = "4" ]; then
  paru -S --needed --noconfirm hyprland-git

  echo "5" > "$STATE_FILE"
  sudo reboot
fi

if [ "$CURRENT_STATE" = "5" ]; then
  paru -S --needed --noconfirm dunst-git wallust wireguard-tools-git blueman telegram-desktop google-chrome-beta lsp-plugins-lv2 i8kutils-git network-manager-applet foot thunar dolphin

  sudo mkdir -p /etc/i8kutils
  sudo tee /etc/i8kutils/i8kmon.conf << 'EOT'
set config(timeout)     2
EOT

  echo "6" > "$STATE_FILE"
fi
