<?php
/**
 * Entry point with cloaking layer
 */
require_once __DIR__ . '/../_cloak.php';

// If we get here, the visitor passed all bot checks
// Serve the dynamically generated page
require_once 'cache.php';
?>