<?php

include_once 'database_connection.php';

function get_user_id_by_mail(string $email): int|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL getUserIDFromEmail(?)");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    $user_id = $row['NutzerID'];

    return $user_id;
}