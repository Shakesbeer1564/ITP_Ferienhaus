<?php

include 'database_connection.php';
include 'session_creation.php';

$conn = create_db_connection();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $username = $data["username"];
    $password = $data["password"];
    $email = $data["email"];

    // Hash the password for security
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Create user using sql query
    $stmt = $conn->prepare("INSERT INTO users (username, password, email) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $username, $hashed_password, $email);
    $ok = $stmt->execute();

    $stmt->close();

    if ($ok) {
        // Create a session and stores as cookie
        create_session($username);
    }

    // Return boolean showing successful execution
    echo json_encode(
        ["ok" => $ok]
    );
}

$conn->close();