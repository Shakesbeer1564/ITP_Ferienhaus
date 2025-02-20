<?php

include_once '../functions/database_connection.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/session_check.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $house_id = $data["houseId"];
    $inp_start_date = $data["startDate"];
    $inp_end_date = $data["endDate"];
    $activies = $data["activityIds"];

    $start_date = new DateTime($inp_start_date);
    $end_date = new DateTime($inp_end_date);

    $user_id = get_user_id_by_mail($_SESSION["email"]);
    if ($user_id == null) {
        send_http_status(401, "Session invalid: User does not exist");
    }

    $conn = create_db_connection();

    $start_date_str = $start_date->format('Y-m-d H:i:s');
    $end_date_str = $end_date->format('Y-m-d H:i:s');
    $activies_str = implode(",", $activies);

    $stmt = $conn->prepare("CALL CreateBooking(?, ?, ?, ?, ?)");

    $stmt->bind_param("sssss", $user_id, $house_id, $start_date_str, $end_date_str, $activies_str);
    $stmt->execute();
    $stmt->close();

    $conn->close();

    send_data(["ok" => true]);
}