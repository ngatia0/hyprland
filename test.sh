#!/usr/bin/env bash
set -e

USERNAME="kvnx"
HOSTNAME="archiso"
DISK="/dev/sda"

if [[ "$DISK" == *nvme* ]]; then
  BOOT_DEV="${DISK}p1"
  ROOT_DEV="${DISK}p2"
else
  BOOT_DEV="${DISK}1"
  ROOT_DEV="${DISK}2"
fi

echo "== Starting Arch Linux Installation for $USERNAME =="

pacman -Sy --needed --noconfirm efibootmgr networkmanager f2fs-tools dosfstools
cfdisk "$DISK"

echo "Formatting $BOOT_DEV (FAT32) and $ROOT_DEV (F2FS)..."
mkfs.fat -F 32 -n UEFI "$BOOT_DEV"
mkfs.f2fs -f -l ROOT -O extra_attr,inode_checksum,sb_checksum,compression "$ROOT_DEV"

mount -t f2fs -o rw,noatime,lazytime,background_gc=on,atgc,gc_merge,discard,discard_unit=block,inline_xattr,inline_data,inline_dentry,flush_merge,barrier,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,compress_algorithm=lz4,compress_log_size=2,compress_chksum,compress_mode=fs,memory=normal,errors=remount-ro,lookup_mode=perf "$ROOT_DEV" /mnt
mkdir -p /mnt/boot
mount "$BOOT_DEV" /mnt/boot
