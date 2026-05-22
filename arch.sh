#!/usr/bin/env bash
set -e

USERNAME="kvnx"
HOSTNAME="archiso"
DISK="/dev/sda"

if [[ "$DISK" == *nvme* ]]; then
  EFI_DEV="${DISK}p1"
  BOOT_DEV="${DISK}p2"
  ROOT_DEV="${DISK}p3"
else
  EFI_DEV="${DISK}1"
  BOOT_DEV="${DISK}2"
  ROOT_DEV="${DISK}3"
fi

echo "== Starting Arch Linux Installation for $USERNAME =="

#systemctl enable systemd-timesyncd.service


reflector --country 'South Africa,Kenya' --latest 10 --protocol https --sort rate --download-timeout 3 --save /etc/pacman.d/mirrorlist
pacman -Sy

pacman -Sy --needed --noconfirm efibootmgr networkmanager f2fs-tools dosfstools
cfdisk "$DISK"

echo "Formatting $EFI_DEV (FAT32), $BOOT_DEV (EXT4), and $ROOT_DEV (F2FS)..."
mkfs.fat -F 32 -n UEFI "$EFI_DEV"
mkfs.ext4 -F -L BOOT "$BOOT_DEV"
mkfs.f2fs -f -l ROOT -O extra_attr,inode_checksum,sb_checksum,compression "$ROOT_DEV"

mount -t f2fs -o rw,noatime,lazytime,background_gc=on,atgc,gc_merge,discard,discard_unit=block,inline_xattr,inline_data,inline_dentry,flush_merge,barrier,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,compress_algorithm=lz4,compress_log_size=2,compress_chksum,compress_mode=fs,memory=normal,errors=remount-ro,lookup_mode=perf "$ROOT_DEV" /mnt

mkdir -p /mnt/boot
mount "$BOOT_DEV" /mnt/boot

mkdir -p /mnt/efi
mount "$EFI_DEV" /mnt/efi

pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware f2fs-tools intel-ucode git nano networkmanager sudo efibootmgr reflector zram-generator

genfstab -U /mnt >> /mnt/etc/fstab

cat << 'EOF' > /mnt/setup.sh
#!/usr/bin/env bash
set -e

USERNAME="kvnx"
HOSTNAME="archiso"

echo "Setting up $HOSTNAME..."

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

bootctl install --esp-path=/efi --boot-path=/boot

ROOT_UUID=$(blkid -t LABEL=ROOT -s UUID -o value)

cat << EOT > /boot/loader/loader.conf
default zen.conf
timeout 3
console-mode max
editor no
EOT

cat << EOT > /boot/loader/entries/linux.conf
title   Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/zen.conf
title   Zen
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/cachyos.conf
title   Cachyos
linux   /vmlinuz-linux-cachyos
initrd  /intel-ucode.img
initrd  /initramfs-linux-cachyos.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/bore-lto.conf
title   BORE
linux   /vmlinuz-linux-cachyos-bore-lto
initrd  /intel-ucode.img
initrd  /initramfs-linux-cachyos-bore-lto.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/bore.conf
title   Bore
linux   /vmlinuz-linux-cachyos-bore
initrd  /intel-ucode.img
initrd  /initramfs-linux-cachyos-bore.img
options root=UUID=$ROOT_UUID rw rootfstype=f2fs quiet
EOT

cat << EOT > /boot/loader/entries/bmq.conf
title    BMQ
linux   /vmlinuz-linux-cachyos-bmq-lto
initrd  /intel-ucode.img
initrd  /initramfs-linux-cachyos-bmq-lto.img
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
arch-chroot /mnt ./setup.sh
rm /mnt/setup.sh

echo "Unmounting filesystems..."
umount -R /mnt

echo "------------------------------------------"
echo " ✅ INSTALLATION COMPLETE"
echo " You can safely reboot now."
echo "------------------------------------------"
