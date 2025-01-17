<?php

include "database_connection.php";

function create_session($username)
{
    $conn = create_db_connection();

    // Gete the roleId of the user from the DB
    $stmt = $conn->prepare("SELECT roleId FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $stmt->bind_result($role_id);
    $stmt->fetch();

    session_start();

    // Store session variables
    $_SESSION['username'] = $username;
    $_SESSION['role'] = $role_id;

    return session_id();
}