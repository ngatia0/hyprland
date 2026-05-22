#!/usr/bin/env bash
set -e

SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")
STATE_FILE="$HOME/.install_state"
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "1")

if [ "$CURRENT_STATE" = "1" ]; then

sudo pacman -S --needed --noconfirm base-devel git

git clone https://github.com/ngatia0/hyprland.git
cd ~/hyprland/etc
sudo cp -r makepkg.conf /etc/
sudo cp -r makepkg.conf.d /etc/
cd ~

# 0. Clone configuration
mkdir -p ~/.config
mkdir -p ~/.config/paru

cp -rn ~/hyprland/config/* ~/.config/
cd ~

mkdir -p ~/.config/paru
cd ~/.config/paru/
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
paru -Syyu --noconfirm
cd ~

paru -S --needed --noconfirm wayland-git
paru -S --needed --noconfirm wayland-protocols-git
paru -S --needed --noconfirm hyprlang-git

  echo "2" > "$STATE_FILE"
  sudo reboot
fi
if [ "$CURRENT_STATE" = "2" ]; then


paru -S --needed --noconfirm hyprland-guiutils-git
paru -S --needed --noconfirm xdg-desktop-portal-hyprland-git
paru -S --needed --noconfirm hyprpolkitagent-git
paru -S --needed --noconfirm hyprutils-git


cd ~/.config/paru/
git clone https://github.com/bus1/dbus-broker.git
cd dbus-broker
sudo pacman -S --needed --noconfirm meson
meson setup build
meson compile -C build
meson test -C build
sudo meson install -C build
sudo systemctl enable dbus-broker.service
cd ~

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


sudo pacman -S --needed --noconfirm pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol-qt rtkit libnotify inotify-tools


sudo systemctl enable --now rtkit-daemon
systemctl --user enable --now pipewire pipewire-pulse wireplumber


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

  # Write i8kmon configuration and enable its daemon service
  sudo mkdir -p /etc/i8kutils
  sudo tee /etc/i8kutils/i8kmon.conf << 'EOT'
# Status check timeout (seconds), override with --timeout option
set config(timeout)     2

# Temperature threshold at which the temperature is displayed in red
set config(t_high)      80

# Number of temperature configurations
set config(num_configs)  3

# Temperature thresholds: {fan_speeds low_ac high_ac low_batt high_batt}

set config(0)   {{0 0}  -1  45  -1  45}
set config(1)   {{1 0}  44  55  44  55}
set config(2)   {{2 0}  50 128  50 128}

# Speed values are set here to avoid i8kmon probe them at every time it starts.
set status(leftspeed)   "0 2500 5000 5000"
set status(rightspeed)  "0 2500 5000 5000"
EOT

  sudo systemctl enable i8kmon.service

rm -f "$STATE_FILE"
echo ":: System configuration setup fully complete!"
fi
