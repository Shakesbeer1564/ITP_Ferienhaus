<?php

include_once '../config.php';
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

    $house_id = $data["houseId"];

    $user_mail = $_SESSION["email"];
    $user_id = get_user_id_by_mail($user_mail);

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL deleteHome(?, ?)");
    $stmt->bind_param("ss", $house_id, $user_id);
    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for a custom error from the procedure
        if ($e->getCode() == 1644) {
            // Check if the house does not exist
            if ($e->getMessage() == "Haus existiert nicht.") {
                send_http_status(404, "No house with that id exists");
            }
            // Otherwise the user does not have the permission by the procedure to delete homes
            send_http_status(403, "Only the landlord and admins can delete homes");
        }
    }
    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Could not delete vacation home from database");
    }

    send_data(["ok" => $ok]);
}