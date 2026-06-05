
#!/bin/bash

# Minimalist Artix Linux Install Script (No Encryption, Suckless Philosophy)

# If not running as root, re-execute as root using su
if [ "$EUID" -ne 0 ]; then
  echo "[!] Not running as root. Asking for root password..."
  exec su -c "bash '$0'"
fi

set -e

echo "[+] Running as root. Continuing..."

echo "[+] Checking internet connection..."
ping -c 1 archlinux.org >/dev/null 2>&1 || {
    echo "[!] No internet. Launching connmanctl to connect WiFi..."
    nmtui
}

echo "[+] Internet connected."

# Disk selection
lsblk -d -e 7,11 -o NAME,SIZE,MODEL
read -p "[?] Enter your target disk (e.g., /dev/nvme0n1, /dev/sda, /dev/vda): " DISK
[ ! -b "$DISK" ] && echo "[!] Invalid disk." && exit 1

echo "[!] Partitioning $DISK (EFI: 400M, Root: 128G, Home: remaining)"
read -p "    Press Enter to launch cfdisk..." _ && cfdisk "$DISK"

# Handle partition suffix (p for nvme)
P=; [[ "$DISK" == *"nvme"* ]] && P="p"
EFI="${DISK}${P}1"
ROOT="${DISK}${P}2"

sudo pacman -Sy f2fs-tools dosfstools

echo "[+] Formatting partitions..."
mkfs.fat -F32 "$EFI"
mkfs.f2fs -f -l ROOT -O extra_attr,inode_checksum,inode_crtime,sb_checksum,compression "$ROOT"

echo "[+] Mounting filesystems..."

mount -t f2fs -o rw,noatime,background_gc=sync,gc_merge,discard,\
discard_unit=block,flush_merge,extent_cache,age_extent_cache,\
alloc_mode=default,checkpoint_merge,compress_algorithm=lz4:3,\
compress_chksum,atgc,errors=remount-ro,lookup_mode=auto,lazytime,\
inline_xattr "$ROOT" /mnt

mkdir -p /mnt/boot/efi
mount "$EFI" /mnt/boot/efi

# Base install
echo "[+] Installing base system..."
basestrap -i /mnt base base-devel linux linux-firmware grub \
  networkmanager networkmanager-runit runit elogind-runit git \
  efibootmgr bash-completion sudo runit-rc intel-ucode f2fs-tools dosfstools

fstabgen -U /mnt >> /mnt/etc/fstab

# Get user info
read -s -p "[?] Enter root password: " ROOTPASS && echo
read -p "[?] Enter new username: " USERNAME
read -s -p "[?] Enter password for user '$USERNAME': " USERPASS && echo

# Write chroot config script
cat > /mnt/setup_inside_chroot.sh <<EOF
#!/bin/bash
set -e

pacman -S --noconfirm artix-archlinux-support
pacman-key --populate archlinux
pacman -S --noconfirm archlinux-mirrorlist
echo -e "\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch" >> /etc/pacman.conf
pacman -Sy --noconfirm

ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc

sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "archiso" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       archiso.localdomain archiso
EOL

echo "[+] Setting root password..."
echo "root:$ROOTPASS" | chpasswd

echo "[+] Creating user '$USERNAME'..."
useradd -m -G wheel "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd

echo "[+] Enabling sudo for wheel group..."
sed -i 's/^# %wheel/%wheel/' /etc/sudoers

sudo EDITOR=nano visudo
echo "[+] Installing fonts..."
pacman -S --noconfirm ttf-hack ttf-hack-nerd

echo "[+] Installing liked packages..."
pacman -S --noconfirm neofetch

echo "[+] Installing GRUB bootloader..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "[✓] Setup complete inside chroot."
EOF

chmod +x /mnt/setup_inside_chroot.sh

# Run chroot setup
echo "[+] Entering chroot to complete installation..."
artix-chroot /mnt /setup_inside_chroot.sh

# Clean up
rm /mnt/setup_inside_chroot.sh

echo "[✓] Installation complete."
echo "Exit the live environment and run:"
echo "umount -R /mnt"
echo "reboot"

