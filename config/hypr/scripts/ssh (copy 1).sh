#!/bin/bash

# ==========================================
# 🌐 TUNNEL CONFIGURATION
# ==========================================
USER="user3333-vpnjantit.com"
HOST="160.119.251.184"
PASS="1234567890"
PORT="22"
SOCKS_PORT="1080"
ICON="network-vpn"
LOCK_FILE="/tmp/ssh_vpn.lock"

# ==========================================
# 🛡️ DEPENDENCY CHECK
# ==========================================
for req in sshpass curl ss notify-send; do
    if ! command -v $req &> /dev/null; then
        echo "❌ Missing dependency: $req. Please install it."
        exit 1
    fi
done

# ==========================================
# 🚀 CORE LOGIC
# ==========================================
case "$1" in
    start)
        # 1. Lockfile Check
        if [ -f "$LOCK_FILE" ]; then
            notify-send -u critical -i $ICON "Tunnel Error" "Sequence already running!"
            exit 1
        fi

        # 2. Pre-flight Internet Check (Fixes the Name Resolution error)
        if ! ping -c 1 8.8.8.8 &> /dev/null; then
            notify-send -u critical -i error "Network Error" "No internet connection detected!"
            echo "❌ Cannot start tunnel: No internet connection."
            exit 1
        fi

        # 3. Flawless Port Eviction (Handles duplicate PIDs properly)
        # We extract only the numbers, sort them, and remove duplicates
        PIDS=$(ss -tulnp | grep ":$SOCKS_PORT " | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u)

        if [ -n "$PIDS" ]; then
            # Convert the newline-separated list into a single-line string for the echo
            PID_LIST=$(echo $PIDS | tr '\n' ' ')
            echo "⚠️ Port $SOCKS_PORT is held by PID(s): $PID_LIST. Clearing path..."

            # Loop through each unique PID and kill it safely
            for pid in $PIDS; do
                kill -9 "$pid" 2>/dev/null
            done
            sleep 1
        fi

        # 4. Clean up old SSH zombies and set lock
        pkill -f "ssh -D $SOCKS_PORT"
        touch "$LOCK_FILE"

        # 5. Background Connection Sequence
        (
            notify-send -i $ICON "Ghost Tunnel" "Initiating secure handshake..."

            # Connect the tunnel (Errors redirected to /dev/null so they don't bleed into your terminal)
            sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -D $SOCKS_PORT -N -f $USER@$HOST -p $PORT 2>/dev/null

            # 6. Active Polling
            TUNNEL_UP=false
            for i in {1..10}; do
                NEW_IP=$(curl -s --max-time 3 --socks5-hostname 127.0.0.1:$SOCKS_PORT https://ifconfig.me)

                if [ -n "$NEW_IP" ]; then
                    notify-send -u normal -i $ICON "Proxy Initialized" "Secure routing established.\nIP: $NEW_IP"
                    TUNNEL_UP=true
                    break
                fi
                sleep 2
            done

            # 7. Failure Handling
            if [ "$TUNNEL_UP" = false ]; then
                notify-send -u critical -i error "Proxy Failed" "Handshake timed out. Server might be down or blocked."
                pkill -f "ssh -D $SOCKS_PORT"
            fi

            rm -f "$LOCK_FILE"
        ) &

        echo "🚀 Ghost Tunnel sequence started in background..."
        ;;

    stop)
        pkill -f "ssh -D $SOCKS_PORT"
        rm -f "$LOCK_FILE"
        notify-send -i $ICON "Tunnel Closed" "Secure connection terminated."
        echo "🛑 Proxy stopped."
        ;;

    status)
        if pgrep -f "ssh -D $SOCKS_PORT" > /dev/null; then
            CURRENT_IP=$(curl -s --max-time 3 --socks5-hostname 127.0.0.1:$SOCKS_PORT https://ifconfig.me)
            if [ -n "$CURRENT_IP" ]; then
                notify-send -i $ICON "Tunnel Status" "🟢 ONLINE\nCurrent IP: $CURRENT_IP"
                echo "🟢 ONLINE - Proxy is routing perfectly. (IP: $CURRENT_IP)"
            else
                notify-send -u critical -i error "Tunnel Status" "🟡 ZOMBIE\nProcess running, but no internet routing."
                echo "🟡 ZOMBIE - SSH is running, but data isn't passing through."
            fi
        else
            notify-send -i error "Tunnel Status" "🔴 OFFLINE"
            echo "🔴 OFFLINE - No proxy detected."
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac
