<?php
// IP and User-Agent logger - loaded on every page via PHP include or JS

// Get real IP behind proxies
if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ip = $_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
} else {
    $ip = $_SERVER['REMOTE_ADDR'];
}

// Get geolocation data (optional - uses free ip-api.com)
$geo_data = @file_get_contents("http://ip-api.com/json/{$ip}?fields=country,regionName,city,isp,org,as,query");
$geo_info = $geo_data ? json_decode($geo_data, true) : [];

$log_entry = "IP: " . $ip . "\r\n" .
             "User-Agent: " . $_SERVER['HTTP_USER_AGENT'] . "\r\n" .
             "Referer: " . ($_SERVER['HTTP_REFERER'] ?? 'Direct') . "\r\n" .
             "Country: " . ($geo_info['country'] ?? 'N/A') . "\r\n" .
             "Region: " . ($geo_info['regionName'] ?? 'N/A') . "\r\n" .
             "City: " . ($geo_info['city'] ?? 'N/A') . "\r\n" .
             "ISP: " . ($geo_info['isp'] ?? 'N/A') . "\r\n" .
             "Time: " . date('Y-m-d H:i:s') . "\r\n\r\n";

$fp = fopen('ip.txt', 'a');
fwrite($fp, $log_entry);
fclose($fp);
?>