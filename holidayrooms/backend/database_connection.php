<?php

function create_db_connection()
{
    // Database connection settings
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "inventarverwaltung_v0";

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}