#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  exec su -c "bash '$0'"
fi

set -e

ping -c 1 artixlinux.org >/dev/null 2>&1 || {
    connmanctl
}

lsblk -d -e 7,11 -o NAME,SIZE,MODEL
read -p "[?] Enter target disk: " DISK
[[ "$DISK" != /dev/* ]] && DISK="/dev/$DISK"
[ ! -b "$DISK" ] && exit 1

cfdisk "$DISK"

P=; [[ "$DISK" == *"nvme"* || "$DISK" == *"mmcblk"* ]] && P="p"
EFI_DEV="${DISK}${P}1"
BOOT_DEV="${DISK}${P}2"
ROOT_DEV="${DISK}${P}3"

mkfs.fat -F 32 -n UEFI "$EFI_DEV"
mkfs.ext4 -F -L BOOT "$BOOT_DEV"
mkfs.f2fs -f -l ROOT -O extra_attr,inode_checksum,inode_crtime,sb_checksum,compression "$ROOT_DEV"

mount -t f2fs -o rw,noatime,background_gc=sync,gc_merge,discard,discard_unit=block,flush_merge,extent_cache,age_extent_cache,alloc_mode=default,checkpoint_merge,compress_algorithm=zstd:3,compress_chksum,atgc,errors=remount-ro,lookup_mode=auto,lazytime,inline_xattr "$ROOT_DEV" /mnt

mkdir -p /mnt/boot
mount "$BOOT_DEV" /mnt/boot

mkdir -p /mnt/efi
mount "$EFI_DEV" /mnt/efi

basestrap -i /mnt base base-devel linux-zen linux-zen-headers linux-firmware f2fs-tools intel-ucode git vim networkmanager networkmanager-runit runit runit-rc elogind elogind-runit efibootmgr bash-completion nano sudo grub

fstabgen -U /mnt >> /mnt/etc/fstab

cat > /mnt/setup.sh << 'EOF'
#!/bin/bash
set -e

USERNAME="kvnx"
HOSTNAME="archiso"

ln -sf /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc

sed -i '/en_GB.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "$HOSTNAME" > /etc/hostname


sudo pacman -S --noconfirm artix-archlinux-support
sudo pacman-key --populate archlinux
sudo pacman -S --noconfirm archlinux-mirrorlist
sudo bash -c 'echo -e "\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch" >> /etc/pacman.conf'
sudo pacman -Sy --noconfirm

cat <<EOH > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOH

echo "[+] Set root password:"
passwd

useradd -m -G wheel,audio,video -s /bin/bash "$USERNAME"
echo "[+] Set password for $USERNAME:"
passwd "$USERNAME"

#echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
EDITOR=nano visudo

cat <<EOT > /etc/mkinitcpio.conf
MODULES=(f2fs i915)
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf kms keyboard keymap block filesystems fsck)
EOT

mkinitcpio -P

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default/
EOF

chmod +x /mnt/setup.sh
artix-chroot /mnt /setup.sh
rm /mnt/setup.sh

umount -R /mnt
echo "[✓] Installation complete with GRUB configuration."
