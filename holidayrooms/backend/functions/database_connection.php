<?php

include_once '../config.php';
include_once '../functions/http_communication.php';

function create_db_connection()
{
    try {
        // Create connection
        $conn = new mysqli(SERVERNAME, DB_USERNAME, DB_PASSWORD, DB_NAME);
        $conn->set_charset("utf8mb4");
    } catch (Exception $e) {
        send_http_status(500, "Could not connect to database: " . $e->getMessage());
    }

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}