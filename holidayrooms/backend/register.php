<?php

include 'database_connection.php'; 
$conn = create_db_connection();

// Handle form submission
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

    // Return boolean showing successful execution
    echo json_encode(
        ["ok" => $ok]
    );

    $stmt->close();
}

$conn->close();