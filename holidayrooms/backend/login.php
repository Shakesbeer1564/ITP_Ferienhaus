<?php

include 'database_connection.php';
include 'session_creation.php';

$conn = create_db_connection();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Read data from request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $inp_username = $data["username"];
    $inp_password = $data["password"];

    // Get the password hash for the given user from the DB
    $stmt = $conn->prepare("SELECT password FROM users WHERE username = ?");
    $stmt->bind_param("s", $inp_username);
    $stmt->execute();
    $stmt->bind_result($hashed_user_password);
    $stmt->fetch();

    $stmt->close();

    // Check if the given password corresponds to the password hash in the DB
    $is_valid = password_verify($inp_password, $hashed_user_password);

    if ($is_valid) {
        // Create a session and store as cookie
        create_session($inp_username);
    }

    // Return validity state
    echo json_encode(
        ["isValid" => $is_valid]
    );
}

$conn->close();