<?php

include_once '../functions/permission_check.php';
include_once '../functions/session_check.php';
include_once '../functions/search.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    $role_id = $_SESSION["role"];

    if (!has_permission(ROLE_GUEST)) {
        send_http_status(403, "Role from session, therefore the user, has insuficient permission");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $search_query = $data["query"];
    $room_count = $data["roomCount"];
    $bed_count = $data["bedCount"];
    $inp_start_date = $data["startDate"];
    $inp_end_date = $data["endDate"];

    $start_date = new DateTime($inp_start_date);
    $end_date = new DateTime($inp_end_date);

    $homes = search_homes($search_query, $room_count, $bed_count, $start_date, $end_date);

    send_data($homes);
}