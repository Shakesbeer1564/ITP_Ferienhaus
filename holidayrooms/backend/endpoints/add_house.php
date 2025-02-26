<?php

include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_LANDLORD)) {
        send_http_status(403, "User from session does not have the required permission");
    }

    // Read data from request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $address = $data["address"];
    $room_count = $data["roomCount"];
    $bed_count = $data["bedCount"];
    $description = $data["description"];
    $city_id = $data["cityId"];
    $price = $data["price"];

    $user_mail = $_SESSION["email"];
    $user_id = get_user_id_by_mail($user_mail);
    $owner_id = get_landlord_id_by_user_id($user_id);

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL addVacationHome(?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssss", $address, $room_count, $bed_count, $description, $city_id, $owner_id, $price);
    $ok = $stmt->execute();
    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Could not create vacation home in database");
    }

    send_data(["ok" => $ok]);
}