<?php

include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_REGISTERED)) {
        send_http_status(403, "Publishers of activities have to be registered users");
    }

    // Read data from request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $name = $data["name"];
    $description = $data["description"];
    $price = $data["price"];
    $participant_count = $data["participantCount"];
    $city_id = $data["cityId"];

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL addActivity(?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $name, $description, $price, $participant_count, $city_id);
    $ok = $stmt->execute();
    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Could not create activity in database");
    }

    send_data(["ok" => $ok]);
}