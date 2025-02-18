<?php

include_once '../functions/database_connection.php';
include_once '../functions/session_creation.php';
include_once '../functions/mail_check.php';

$conn = create_db_connection();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $username = $data["username"];
    $email = $data["email"];
    $phone = $data["phone"];
    $role_id = $data["role"];
    $password = $data["password"];


    if (is_mail_taken($email)) {
        echo json_encode(
            [
                "ok" => false,
                "reason" => "Mail is already taken"
            ]
        );
        exit;
    }

    // Hash the password for security
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Create user using sql query
    $stmt = $conn->prepare("CALL AddUser(?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $username, $email, $phone, $role_id, $hashed_password);

    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for custom error occuring from mail address validation
        if ($e->getCode() == 1644) {
            echo json_encode(
                [
                    "ok" => false,
                    "reason" => "Invalid mail address"
                ]
            );
            exit;
        }

        // Rethrow exception when it is not a validation error
        throw $e;
    }

    $stmt->close();

    if ($ok) {
        // Create a session and stores as cookie
        create_session($email);
    }

    // Return boolean showing successful execution
    echo json_encode(
        ["ok" => $ok]
    );
}

$conn->close();