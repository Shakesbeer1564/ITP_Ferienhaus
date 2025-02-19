<?php

include_once '../functions/database_connection.php';
include_once '../functions/session_creation.php';
include_once '../functions/mail_check.php';
include_once '../functions/http_communication.php';

$conn = create_db_connection();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $username = $data["username"];
    $email = $data["email"];
    $phone = $data["phone"];
    $password = $data["password"];


    if (is_mail_taken($email)) {
        send_http_status(409, "Mail is already taken");
    }

    // Hash the password for security
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Create user using sql query
    $stmt = $conn->prepare("CALL AddUser(?, ?, ?, ?)");
    $stmt->bind_param("ssss", $username, $email, $phone, $hashed_password);

    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for custom error occuring from mail address validation
        if ($e->getCode() == 1644) {
            send_http_status(400, "Invalid mail address");
        }

        // Rethrow exception when it is not a validation error
        throw $e;
    }

    $stmt->close();

    if ($ok) {
        // Create a session and stores as cookie
        create_session($email);
        send_data(["ok" => $ok]);
    }

    send_http_status(500, "Something went wrong while trying to execute the database query");
}

$conn->close();