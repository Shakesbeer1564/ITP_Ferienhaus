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
        send_http_status(403, "Only admins can delete users");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $user_id = $data["userId"];

    $conn = create_db_connection();

    // Delete user using procedure
    $stmt = $conn->prepare("CALL DeleteUser(?)");
    $stmt->bind_param("s", $user_id);

    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for custom error occuring when the user does not exist
        if ($e->getCode() == CUSTOM_SQL_ERROR_CODE) {
            send_http_status(404, "User with the given ID not found");
        }

        // Rethrow exception when it is not a validation error
        throw $e;
    }

    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Something went wrong while trying to delete the user from the database");
    }

    send_data(["ok" => $ok]);
}