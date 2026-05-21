#!/usr/bin/env bash


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
cd  ~/.config/paru/
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
paru -Syyu
cd ~

paru -S --needed --noconfirm wayland-git
paru -S --needed --noconfirm wayland-protocols-git
paru -S --needed --noconfirm hyprlang-git

  echo "2" > "$STATE_FILE"
  sudo reboot
fi
if [ "$CURRENT_STATE" = "2" ]; then


paru -S hyprland-guiutils-git
paru -S xdg-desktop-portal-hyprland-git
paru -S hyprpolkitagent-git
paru -S --needed --noconfirm hyprutils-git


paru -S mesa-git
paru -S libva-intel-driver-git
paru -S libva-utils-git
paru -S intel-media-driver-git

chmod +x hyprland/dependencies.sh
~/hyprland/dependencies.sh


cd ~/.config/paru/
git clone https://github.com/bus1/dbus-broker.git
cd dbus-broker
meson setup build
meson compile -C build
meson test -C build
meson install -C build
sudo systemctl enable dbus-broker.service
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


sudo pacman -S pipewire
sudo pacman -S wireplumber
sudo pacman -S pipewire-pulse
sudo pacman -S pipewire-alsa
sudo pacman -S pipewire-jack
sudo pacman -S pavucontrol-qt
sudo pacman -S rtkit
sudo pacman -S libnotify inotify-tools


sudo systemctl enable --now rtkit-daemon
systemctl --user enable --now pipewire pipewire-pulse wireplumber


paru -S clipvault
paru -S hyprlock-git
paru -S hyprpaper-git
paru -S hyprland-qt-support-git
paru -S --needed --noconfirm hyprcursor-git
paru -S waybar-git --mflags "--nocheck"
paru -S hyprland-guiutils-git

  echo "4" > "$STATE_FILE"
  sudo reboot
fi
if [ "$CURRENT_STATE" = "4" ]; then

paru -S --needed --noconfirm hyprland-git

  echo "5" > "$STATE_FILE"
  sudo reboot
fi
if [ "$CURRENT_STATE" = "5" ]; then
paru -S dunst-git
paru -S wallust wireguard-tools-git
paru -S  blueman
paru -S telegram-desktop
paru -S --needed --noconfirm google-chrome-beta


paru -S --needed --noconfirm hyprland-git


paru -S hyprpolkitagent-git
paru -S lsp-plugins-lv2
paru -S i8kutils-git



paru -S network-manager-applet
paru -S  blueman
paru -S telegram-desktop
paru -S foot thunar dolphin


echo ":: Installing Google Chrome..."
paru -S --needed --noconfirm google-chrome-beta
