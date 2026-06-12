#!/bin/bash

# Configuration
USER="root-vpnjantit.com"
PASS="1234567890"
HOST="139.84.227.118"
#HOST="102.208.216.216"
#81
PORT="81"
SOCKS_PORT="1082"
ICON="network-vpn"

case "$1" in
    start)
        # Kill old instances
        fuser -k $SOCKS_PORT/tcp > /dev/null 2>&1
        pkill -f "ssh -D $SOCKS_PORT" > /dev/null 2>&1
        sleep 1

        # Start tunnel
        sshpass -p "$PASS" ssh -o "StrictHostKeyChecking=no" \
            -o "ServerAliveInterval=60" \
            -o "ServerAliveCountMax=3" \
            -o "ExitOnForwardFailure=yes" \
            -D $SOCKS_PORT -N -f $USER@$HOST -p $PORT

        sleep 2
        NEW_IP=$(curl -s --socks5-hostname 127.0.0.1:$SOCKS_PORT https://ifconfig.me)

        if [ -n "$NEW_IP" ]; then
            notify-send -i $ICON "SSH Tunnel" "Connected: $NEW_IP"
        else
            notify-send -u critical -i error "SSH Tunnel" "Connection Failed"
            pkill -f "ssh -D $SOCKS_PORT"
        fi
        ;;

    stop)
        fuser -k $SOCKS_PORT/tcp > /dev/null 2>&1
        pkill -f "ssh -D $SOCKS_PORT"
        notify-send -i $ICON "Tunnel Closed" "Terminated"
        ;;

    status)
        if ss -tulnp | grep -q ":$SOCKS_PORT "; then
            CURRENT_IP=$(curl -s --max-time 3 --socks5-hostname 127.0.0.1:$SOCKS_PORT https://ifconfig.me)
            if [ -n "$CURRENT_IP" ]; then
                notify-send -i $ICON "Status" "🟢 ONLINE\nIP: $CURRENT_IP"
            else
                notify-send -u critical -i error "Status" "🟡 ZOMBIE"
            fi
        else
            notify-send -i error "Status" "🔴 OFFLINE"
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac
