<?php

include_once '../functions/permission_check.php';
include_once '../functions/session_check.php';
include_once '../functions/search.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $search_query = $data["query"];
    $room_count = $data["roomCount"];
    $bed_count = $data["bedCount"];
    $inp_start_date = $data["startDate"];
    $inp_end_date = $data["endDate"];

    $start_date = $inp_start_date == null ? null : new DateTime($inp_start_date);
    $end_date = $inp_end_date == null ? null : new DateTime($inp_end_date);

    $homes = search_homes($search_query, $room_count, $bed_count, $start_date, $end_date);

    send_data($homes);
}