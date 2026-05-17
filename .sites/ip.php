'IPEOF'
<?php
$log_dir = __DIR__;
if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ip = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
} else {
    $ip = $_SERVER['REMOTE_ADDR'];
}
$log_entry = "IP: " . $ip . "\r\n" .
             "User-Agent: " . $_SERVER['HTTP_USER_AGENT'] . "\r\n" .
             "Time: " . date('Y-m-d H:i:s') . "\r\n\r\n";
$fp = fopen($log_dir . '/ip.txt', 'a');
fwrite($fp, $log_entry);
fclose($fp);
IPEOF