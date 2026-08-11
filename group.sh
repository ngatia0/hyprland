#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: Run with sudo." >&2
  exit 1
fi

PRIMARY_USER="${SUDO_USER:-}"
GUEST_USER="guest"
SHARED_GROUP="shared"

if [ -z "$PRIMARY_USER" ] || [ "$PRIMARY_USER" = "root" ]; then
  echo "Error: Run as normal user with sudo: sudo bash $0" >&2
  exit 1
fi

if ! id "$GUEST_USER" &>/dev/null; then
  useradd -m -G video,audio -s /bin/bash "$GUEST_USER"
fi
passwd -d "$GUEST_USER"

if ! getent group "$SHARED_GROUP" &>/dev/null; then
  groupadd "$SHARED_GROUP"
fi

usermod -aG "$SHARED_GROUP" "$PRIMARY_USER"
usermod -aG "$SHARED_GROUP" "$GUEST_USER"

mkdir -p /etc/security/limits.d
cat <<'EOF' > /etc/security/limits.d/guest.conf
guest    hard    nproc    150
guest    hard    nofile   1024
guest    hard    fsize    2831155
EOF

chmod 700 "/home/$PRIMARY_USER"
chmod 700 /home/* 2>/dev/null || true

chown root:root /home/guest
chmod 755 /home/guest

mkdir -p /home/guest/Documents /home/guest/.config
chown guest:guest /home/guest/Documents /home/guest/.config
chmod 700 /home/guest/Documents /home/guest/.config

TARGET_FOLDERS=("Documents" "Downloads" "Shows")
mkdir -p "/shared"
chmod 2770 "/shared"
chown "$PRIMARY_USER:$SHARED_GROUP" "/shared"

for folder in "${TARGET_FOLDERS[@]}"; do
  SRC="/home/$PRIMARY_USER/$folder"
  DEST="/shared/$folder"

  mkdir -p "$SRC" "$DEST"
  chown "$PRIMARY_USER:$SHARED_GROUP" "$SRC" "$DEST"
  chmod 2770 "$SRC" "$DEST"

  setfacl -R -m g:"$SHARED_GROUP":rwx "$SRC"
  setfacl -d -m g:"$SHARED_GROUP":rwx "$SRC"

  if ! grep -q "$DEST" /etc/fstab; then
    echo "$SRC $DEST none bind,nofail 0 0" >> /etc/fstab
  fi

  mountpoint -q "$DEST" || mount "$DEST"
done

cat <<'EOF' > /usr/local/bin/reset-guest.sh
#!/usr/bin/env bash
cp -r /etc/skel/. /home/guest/
chown root:root /home/guest
chmod 755 /home/guest
mkdir -p /home/guest/Documents /home/guest/.config
chown -R guest:guest /home/guest/Documents /home/guest/.config
chmod 700 /home/guest/Documents /home/guest/.config
EOF

chmod +x /usr/local/bin/reset-guest.sh
/usr/local/bin/reset-guest.sh

if [ -f /etc/rc.local ]; then
  if ! grep -q "reset-guest.sh" /etc/rc.local; then
    sed -i '$i /usr/local/bin/reset-guest.sh\n' /etc/rc.local
  fi
else
  cat <<'EOF' > /etc/rc.local
#!/bin/sh
/usr/local/bin/reset-guest.sh
exit 0
EOF
  chmod +x /etc/rc.local
fi

echo "Setup complete."
