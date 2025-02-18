<?php

include_once '../functions/database_connection.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/session_check.php';
include_once '../functions/price_fetch.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    if (!is_session_set()) {
        echo json_encode(
            [
                "accessAllowed" => false,
                "reason" => "No session"
            ]
        );
        exit;
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $house_id = $data["houseId"];
    $inp_start_date = $data["startDate"];
    $inp_end_date = $data["endDate"];

    $start_date = new DateTime($inp_start_date);
    $end_date = new DateTime($inp_end_date);

    $user_id = get_user_id_by_mail($_SESSION["email"]);
    if ($user_id == null) {
        echo json_encode(
            [
                "accessAllowed" => false,
                "reason" => "Session invalid: User does not exist"
            ]
        );
        exit;
    }

    $price = calculate_booking_price($start_date, $end_date, $house_id);

    $conn = create_db_connection();

    $start_date_str = $start_date->format('Y-m-d H:i:s');
    $end_date_str = $end_date->format('Y-m-d H:i:s');

    $stmt = $conn->prepare("CALL CreateBooking(?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $user_id, $house_id, $start_date_str, $end_date_str, $price);
    $stmt->execute();
    $stmt->close();

    $conn->close();
}