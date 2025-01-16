<?php

include 'database_connection.php'; 
$conn = create_db_connection();

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $user = $data["username"];
    $pass = $data["password"];
    $email = $data["email"];

    // Hash the password for security
    $hashed_password = password_hash($pass, PASSWORD_DEFAULT);

    // Prepare and bind
    $stmt = $conn->prepare("INSERT INTO users (username, password, email) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $user, $hashed_password, $email);

    if ($stmt->execute()) {
        echo json_encode(
            [
              "result" => "Success"
            ]
        );
    } else {
        echo json_encode(
            [
              "result" => "Error"
            ]
        );
    }

    $stmt->close();
}

$conn->close();