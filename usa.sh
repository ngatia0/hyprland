#!/usr/bin/env bash

G="\033[1;32m"; C="\033[1;36m"; Y="\033[1;33m"; R="\033[1;31m"; RESET="\033[0m"; BOLD="\033[1m"

SERVERS=(
    "usa1.vpnjantit.com"
    "usa2.vpnjantit.com"
    "usa3.vpnjantit.com"
    "usa4.vpnjantit.com"
    "usa5.vpnjantit.com"
    "usa6.vpnjantit.com"
    "usa7.vpnjantit.com"
    "usa8.vpnjantit.com"
    "usa10.vpnjantit.com"
    "usa11.vpnjantit.com"
    "usa12.vpnjantit.com"
    "premiusat.vpnjantit.com"
    "premiusa2.vpnjantit.com"
    "premiusa3.vpnjantit.com"
)

echo -e "\n${C}${BOLD}󱑔 Testing VPN Jantit USA Servers...${RESET}\n"

RESULTS=()

for server in "${SERVERS[@]}"; do
    echo -ne "  ${Y}󰓅 Pinging ${server}...${RESET}\r"
    PING_OUT=$(ping -c 3 -W 2 "$server" 2>/dev/null)
    if [ $? -eq 0 ]; then
        AVG=$(echo "$PING_OUT" | tail -n 1 | awk -F '/' '{print $5}')
        RESULTS+=("$AVG:$server")
        echo -e "  ${G}󰄬 ${server}:${RESET} ${AVG} ms                   "
    else
        echo -e "  ${R}󰅖 ${server}:${RESET} Offline/Timeout              "
    fi
done

echo -e "\n${C}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [ ${#RESULTS[@]} -gt 0 ]; then
    FASTEST=$(printf "%s\n" "${RESULTS[@]}" | sort -n | head -n 1)
    FAST_PING=$(echo "$FASTEST" | cut -d':' -f1)
    FAST_SERVER=$(echo "$FASTEST" | cut -d':' -f2)

    echo -e "${G}${BOLD}󰄬 FASTEST SERVER:${RESET} ${C}${FAST_SERVER}${RESET} (${FAST_PING} ms)"
else
    echo -e "${R}${BOLD}󰅖 No servers responded.${RESET}"
fi
echo -e "${C}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
