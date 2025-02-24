<?php

include_once '../functions/database_connection.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    // Initialize the current session to be able to destroy it
    session_start();

    // Destroy the session and send the success state back
    send_data([
        "ok" => session_destroy()
    ]);
}