#!/usr/bin/env bash
set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "[!] This script must be run as root."
  exit 1
fi

USERNAME="kvnx"
HOSTNAME="archiso"
DISK="/dev/sda"

if [[ "$DISK" == *nvme* || "$DISK" == *mmcblk* ]]; then
  EFI_DEV="${DISK}p1"
  ROOT_DEV="${DISK}p2"
else
  EFI_DEV="${DISK}1"
  ROOT_DEV="${DISK}2"
fi

echo "== Starting Arch Linux Installation for $USERNAME =="

reflector --country 'South Africa,Kenya' --latest 10 --protocol https --sort rate --download-timeout 3 --save /etc/pacman.d/mirrorlist
pacman -Sy

pacman -Sy --needed --noconfirm efibootmgr networkmanager f2fs-tools dosfstools
cfdisk "$DISK"

echo "Formatting $EFI_DEV (FAT32) and $ROOT_DEV (F2FS)..."
mkfs.fat -F 32 -n UEFI "$EFI_DEV"
mkfs.f2fs -f -l ROOT -O extra_attr,inode_checksum,inode_crtime,sb_checksum,compression "$ROOT_DEV"

mount -t f2fs -o rw,noatime,background_gc=sync,gc_merge,discard,\
discard_unit=block,flush_merge,extent_cache,age_extent_cache,\
alloc_mode=default,checkpoint_merge,compress_algorithm=lz4:3,\
compress_chksum,atgc,errors=remount-ro,lookup_mode=auto,lazytime,\
inline_xattr "$ROOT_DEV" /mnt

mkdir -p /mnt/boot
mount "$EFI_DEV" /mnt/boot

pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware \
  f2fs-tools intel-ucode git nano networkmanager sudo efibootmgr reflector zram-generator

genfstab -U /mnt >> /mnt/etc/fstab

cat << 'EOF' > /mnt/setup.sh
#!/usr/bin/env bash
set -e

USERNAME="kvnx"
HOSTNAME="archiso"

ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc
echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "$HOSTNAME" > /etc/hostname

cat << EOH > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOH

useradd -m -G wheel,audio,video -s /bin/bash "$USERNAME"
echo "Set password for $USERNAME:"
passwd "$USERNAME"
echo "Set root password:"
passwd

echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel

mkdir -p /etc/systemd
cat << 'EOT' > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = lz4
swap-priority = 100
fs-type = swap
EOT

bootctl install

ROOT_UUID=$(blkid -s UUID -o value /dev/disk/by-label/ROOT)

cat << EOT > /boot/loader/loader.conf
default zen.conf
timeout 3
console-mode max
editor no
EOT

cat << EOT > /boot/loader/entries/linux.conf
title    Linux
linux    /vmlinuz-linux
initrd   /intel-ucode.img
initrd   /initramfs-linux.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/zen.conf
title    Zen
linux    /vmlinuz-linux-zen
initrd   /intel-ucode.img
initrd   /initramfs-linux-zen.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/cachyos.conf
title    Cachyos
linux    /vmlinuz-linux-cachyos
initrd   /intel-ucode.img
initrd   /initramfs-linux-cachyos.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/bore-lto.conf
title    BORE
linux    /vmlinuz-linux-cachyos-bore-lto
initrd   /intel-ucode.img
initrd   /initramfs-linux-cachyos-bore-lto.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/bore.conf
title    Bore
linux    /vmlinuz-linux-cachyos-bore
initrd   /intel-ucode.img
initrd   /initramfs-linux-cachyos-bore.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/bmq.conf
title     BMQ
linux    /vmlinuz-linux-cachyos-bmq-lto
initrd   /intel-ucode.img
initrd   /initramfs-linux-cachyos-bmq-lto.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /etc/mkinitcpio.conf
MODULES=(f2fs i915)
BINARIES=()
FILES=()
HOOKS=(base systemd autodetect modconf kms sd-vconsole block filesystems fsck)
EOT

mkinitcpio -P

systemctl enable NetworkManager
EOF

chmod +x /mnt/setup.sh
arch-chroot /mnt /setup.sh
rm /mnt/setup.sh

echo "Unmounting filesystems..."
exit
umount -R /mnt

echo "------------------------------------------"
echo " ✅ INSTALLATION COMPLETE"
echo " You can safely reboot now."
echo "------------------------------------------"
