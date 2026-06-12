#!/usr/bin/env bash

export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

ipinfo() {
    curl -s ipinfo.io/{ip,city,country} | paste -sd' ' -
}

if sudo wg show "$IFACE" >/dev/null 2>&1; then
    sudo wg-quick down "$IFACE"
    sudo resolvectl flush-caches
    notify-send "󰒄 WireGuard ($(ipinfo))$IFACE Deactivated"
else
    sudo wg-quick up "$IFACE"
    sudo resolvectl flush-caches
    # A tiny sleep to let the handshake settle on the 500MHz CPU
    sleep 1
    notify-send "󰒘 WireGuard ($(ipinfo))$IFACE Activo "
fi
