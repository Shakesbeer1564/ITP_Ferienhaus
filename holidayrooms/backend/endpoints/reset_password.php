<?php

include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    $user_mail = $_SESSION["email"];
    $user_id = get_user_id_by_mail($user_mail);
    if ($user_id == null) {
        send_http_status(404, "User from session not found");
    }

    // Read data from request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $new_password = $data["newPassword"];

    // Hash the password for security
    $new_password_hash = password_hash($new_password, PASSWORD_DEFAULT);

    $conn = create_db_connection();

    // Create user using sql query
    $stmt = $conn->prepare("CALL ResetPasswort(?, ?)");
    $stmt->bind_param("ss", $user_id, $new_password_hash);
    $ok = $stmt->execute();

    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Something went wrong while trying to update the password hash in the database");
    }

    send_data(["ok" => $ok]);
}