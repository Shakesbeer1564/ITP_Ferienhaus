<?php

include_once '../functions/database_connection.php';
include_once '../functions/permission_check.php';
include_once '../functions/session_check.php';
include_once '../functions/http_communication.php';


if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_REGISTERED)) {
        send_http_status(403, "User from session does not have the required permission");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $house_id = $data["houseId"];
    $description = $data["description"];

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL AddMaengelanzeige(?, ?)");
    $stmt->bind_param("ss", $house_id, $description);
    $ok = $stmt->execute();
    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Something went wrong while trying to execute the database query");
    }

    send_data(["ok" => $ok]);
}
