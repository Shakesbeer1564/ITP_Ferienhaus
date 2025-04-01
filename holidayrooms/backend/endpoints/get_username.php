<?php

include_once '../functions/session_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "GET") {

    http_response_code(500);

    if (!is_session_set()) {
        send_data(["username" => null]);
    }

    $user_mail = $_SESSION["email"];
    $username = get_username_by_mail($user_mail);

    send_data(["username" => $username]);
}