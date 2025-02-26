<?php

include_once '../config.php';
include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_ADMIN)) {
        send_http_status(403, "Only admins can delete activities");
    }

    // Read data from request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $activity_id = $data["activityId"];

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL deleteActivity(?)");
    $stmt->bind_param("s", $activity_id);
    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        echo $e->getMessage();
        // Check for a custom error from the procedure
        if ($e->getCode() == CUSTOM_SQL_ERROR_CODE) {
            send_http_status(404, "No activity with that id exists");
        }

        // Rethrow exception when it is not a custom error
        throw $e;
    }
    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Could not delete activity from database");
    }

    send_data(["ok" => $ok]);
}