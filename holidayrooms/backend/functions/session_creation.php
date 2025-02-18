<?php

include_once "../functions/database_connection.php";
include_once "../config.php";

function create_session($email)
{
    $conn = create_db_connection();

    // Get the roleId of the user from the DB
    $stmt = $conn->prepare("SELECT RolleID FROM nutzer WHERE name = ?");
    $stmt->bind_param("s", $email);
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
    $_SESSION['email'] = $email;
    $_SESSION['role'] = $role_id;

    return session_id();
}