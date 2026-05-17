<?php
// Device detection - serve mobile or desktop version
include 'ip.php'; // Log the visitor

$user_agent = $_SERVER['HTTP_USER_AGENT'];
$is_mobile = preg_match('/(android|iphone|ipad|ipod|blackberry|windows phone|opera mini|iemobile|mobile)/i', $user_agent);

if ($is_mobile) {
    header('Location: mobile.html');
} else {
    header('Location: login.html');
}
exit();
?>