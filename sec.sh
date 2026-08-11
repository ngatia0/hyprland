
#!/usr/bin/env bash
#set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: Must be run as root." >&2
  exit 1
fi

if [ ! -d /run/runit/service ]; then
  echo "Error: runit service directory (/run/runit/service) not found." >&2
  exit 1
fi

if [ ! -d /sys/kernel/security/apparmor ]; then
  echo "Error: AppArmor is not active in the kernel." >&2
  echo -n "Active LSMs: " >&2
  cat /sys/kernel/security/lsm 2>/dev/null || true
  echo "" >&2
  exit 1
fi

PRIMARY_USER="${SUDO_USER:-}"
if [ -z "$PRIMARY_USER" ] || [ "$PRIMARY_USER" = "root" ]; then
  echo "Error: Run via sudo as your regular user: sudo bash $0" >&2
  exit 1
fi

pacman -S --needed --noconfirm apparmor audit

mkdir -p /etc/runit/sv/apparmor
cat << 'EOF' > /etc/runit/sv/apparmor/run
#!/bin/sh
exec 2>&1
if [ -d /etc/apparmor.d ]; then
    apparmor_parser -r -T /etc/apparmor.d/
fi
exec pause
EOF
chmod +x /etc/runit/sv/apparmor/run
ln -sf /etc/runit/sv/apparmor /run/runit/service/

mkdir -p /etc/runit/sv/auditd
cat << 'EOF' > /etc/runit/sv/auditd/run
#!/bin/sh
exec 2>&1
exec auditd -f
EOF
chmod +x /etc/runit/sv/auditd/run
ln -sf /etc/runit/sv/auditd /run/runit/service/

mkdir -p /etc/audit/rules.d
cat << 'EOF' > /etc/audit/rules.d/10-security.rules
-b 8192
-f 1
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k identity
-w /etc/apparmor.d/ -p wa -k apparmor_changes
-w /usr/bin/sudo -p x -k privileged_exec
-w /usr/bin/doas -p x -k privileged_exec
-a always,exit -F arch=b64 -S execve -F euid=0 -k root_exec
-a always,exit -F arch=b32 -S execve -F euid=0 -k root_exec
EOF

augenrules --load

cat << 'EOF' > /etc/sudoers.d/01-security
Defaults use_pty
Defaults logfile="/var/log/sudo.log"
Defaults passwd_timeout=1
EOF
chmod 0440 /etc/sudoers.d/01-security

cat << 'EOF' > /etc/profile.d/umask.sh
umask 077
EOF

if [ -d /etc/apparmor.d ]; then
  aa-enforce /etc/apparmor.d/*
fi

if visudo -c && sudo -l -U "$PRIMARY_USER" | grep -q '(ALL : ALL)'; then
  passwd -l root
  echo "Security setup applied successfully. Root password locked."
else
  echo "Error: Sudoers check failed or '$PRIMARY_USER' lacks full sudo privileges. Root password NOT locked." >&2
  exit 1
fi
