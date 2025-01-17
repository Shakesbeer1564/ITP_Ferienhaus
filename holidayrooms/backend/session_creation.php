<?php

include_once "database_connection.php";
include_once "config.php";

function create_session($username)
{
    $conn = create_db_connection();

    // Gete the roleId of the user from the DB
    $stmt = $conn->prepare("SELECT roleId FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $stmt->bind_result($role_id);
    $stmt->fetch();

    // Set cookie expiration
    session_set_cookie_params(SESSION_TIMEOUT);
    // Start the session
    session_start();
    // Regenerate the session id for improved security
    session_regenerate_id(true);

    // Store session variables
    $_SESSION['username'] = $username;
    $_SESSION['role'] = $role_id;

    return session_id();
}