<?php

include_once '../config.php';
include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/element_name_retrieval.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "GET") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_ADMIN)) {
        send_http_status(403, "Only admins can see all users");
    }

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL GetCustomers()");
    $ok = $stmt->execute();

    // Get the result set
    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    if (!$ok) {
        send_http_status(500, "Something went wrong trying to retrieve the users from the database");
    }

    // Get customers from the result
    $customers = [];
    while ($row = $result->fetch_assoc()) {
        $role_id = $row["RolleID"];
        $row["NameRolle"] = get_role_name_by_id($role_id);
        $customers[] = $row;
    }

    send_data($customers);
}