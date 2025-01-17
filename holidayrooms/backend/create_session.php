<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Read request body
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $username = $data["username"];
    $email = $data["email"];

    session_start();

    // Store session variables
    $_SESSION['username'] = $username;
    $_SESSION['email'] = $email;

    // Return the session id
    echo json_encode(
        ["sessionId" => session_id()]
    );
}