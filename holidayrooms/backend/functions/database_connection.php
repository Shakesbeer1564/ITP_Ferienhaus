<?php

include_once 'config.php';

function create_db_connection()
{
    // Create connection
    $conn = new mysqli(SERVERNAME, DB_USERNAME, DB_PASSWORD, DB_NAME);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}