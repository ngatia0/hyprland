#!/bin/bash
set -e

STATE_FILE="$HOME/.install_state"
[ -f "$STATE_FILE" ] && CURRENT_STATE=$(cat "$STATE_FILE") || CURRENT_STATE="1"

# STATE 1: Initial System Configuration
if [ "$CURRENT_STATE" = "1" ]; then
    sudo ln -s /etc/runit/sv/NetworkManager /run/runit/service/
    sudo pacman -S --noconfirm artix-archlinux-support
    sudo pacman-key --populate archlinux
    sudo pacman -S --noconfirm archlinux-mirrorlist

    sudo bash -c 'echo -e "\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch" >> /etc/pacman.conf'
    sudo pacman -Syu --noconfirm

    sudo pacman -S --noconfirm zramen zramen-runit
    sudo tee /etc/zramen.conf << 'EOT'
ZRAM_SIZE=50%
ZRAM_ALGO=lz4
PRIORITY=100
EOT
    sudo ln -sf /etc/sv/zramen /var/service/
    sudo sv restart zramen

    echo "kvnx ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/paru" | sudo tee /etc/sudoers.d/pacman-paru && sudo chmod 440 /etc/sudoers.d/pacman-paru

    [ -d "hyprland" ] && rm -rf hyprland
    git clone https://github.com/ngatia0/hyprland.git
    mkdir -p ~/.config
    sudo cp -r hyprland/etc/makepkg.conf.d /etc/
    sudo cp -r hyprland/etc/makepkg.conf /etc/
    cp -r hyprland/config/* ~/.config/

    if ! command -v paru >/dev/null 2>&1; then
        rm -rf ~/ffmpeg-git ~/paru
        git clone --depth 1 https://aur.archlinux.org/ffmpeg-git.git
        cd ffmpeg-git && makepkg -si --noconfirm && cd
        git clone https://aur.archlinux.org/paru.git
        cd paru && makepkg -si --noconfirm && cd
    fi

    echo "2" > "$STATE_FILE"
    CURRENT_STATE="2"
fi

# STATE 2
if [ "$CURRENT_STATE" = "2" ]; then

    paru -S --needed --noconfirm modprobed-db
    paru -S --needed --noconfirm hyprland-guiutils-git
    paru -S --needed --noconfirm xdg-desktop-portal-hyprland-git
    paru -S --needed --noconfirm hyprpolkitagent-git
    paru -S --needed --noconfirm hyprutils-git

    paru -S --needed --noconfirm mesa-git
    paru -S --needed --noconfirm libva-intel-driver-git
    paru -S --needed --noconfirm libva-utils-git
    paru -S --needed --noconfirm intel-media-driver-git


    chmod +x ~/hyprland/dependencies.sh
    ~/hyprland/dependencies.sh
    cd ~

    echo "Have you installed ffmpeg zst ?"
    read -p "Answer (y/n): " answer
    if [[ "$answer" != [Yy]* ]]; then
        echo "Exiting. Please install ffmpeg zst and rerun."
        exit 1
    fi
    echo "3" > "$STATE_FILE"
    sudo reboot
fi

# STATE 3
if [ "$CURRENT_STATE" = "3" ]; then
   paru -S --needed --noconfirm hyprwayland-scanner-git
   paru -S --needed --noconfirm aquamarine-git
   paru -S --needed --noconfirm hyprgraphics-git

    sudo pacman -S --needed --noconfirm pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol-qt rtkit rtkit-runit libnotify inotify-tools

    paru -S --needed --noconfirm clipvault hyprlock-git hyprpaper-git hyprland-qt-support-git hyprcursor-git

    paru -S --needed --noconfirm waybar-git --mflags "--nocheck"

    paru -S --needed --noconfirm hyprland-guiutils-git

    echo "4" > "$STATE_FILE"
    sudo reboot
fi

# STATE 4
if [ "$CURRENT_STATE" = "4" ]; then
    paru -S --needed --noconfirm hyprland-git
    echo "5" > "$STATE_FILE"
    sudo reboot
fi

# STATE 5
if [ "$CURRENT_STATE" = "5" ]; then
    paru -S --needed --noconfirm dunst-git wallust wireguard-tools-git blueman telegram-desktop google-chrome-beta lsp-plugins-lv2 i8kutils-git network-manager-applet foot thunar dolphin
    echo "6" > "$STATE_FILE"
    echo "Installation Complete!"
fi
