<?php
header('Content-type: application/json');

require_once 'NikeFuelApi.php';
// Please insert here your nike.com username and password
$object = new NikeplusFuelbandAPI('user@username.com', 'PASSWORD');
$object->login();

$my_full_activity = $object->getMyLastFullActivity();
echo json_encode($my_full_activity,0);
