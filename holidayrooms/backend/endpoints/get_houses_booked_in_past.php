<?php

include_once '../config.php';
include_once '../functions/database_connection.php';
include_once '../functions/permission_check.php';
include_once '../functions/session_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/http_communication.php';


if ($_SERVER["REQUEST_METHOD"] == "GET") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_REGISTERED)) {
        send_http_status(403, "User from session does not have the required permission");
    }

    $user_mail = $_SESSION["email"];
    $user_id = get_user_id_by_mail($user_mail);

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL GetHousesBookedByUserInPast(?)");
    $stmt->bind_param("s", $user_id);
    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for custom error from procedure
        if ($e->getCode() == CUSTOM_SQL_ERROR_CODE) {
            send_http_status(404, "Could not find user in db or its role id is null");
        }

        // Rethrow exception when it is not a not found error
        throw $e;
    }

    if (!$ok) {
        send_http_status(500, "Something went wrong while trying to execute the database query");
    }

    // Get the result set
    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    // Extract entries and build array
    $bookings = [];
    while ($row = $result->fetch_assoc()) {
        $bookings[] = $row;
    }

    send_data($bookings);
}