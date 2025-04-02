<?php

include_once 'database_connection.php';

function get_username_by_id(int $user_id): string|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL getUserNameByID(?)");
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    $username = $row['name'];

    return $username;
}

function get_username_by_mail(string $email): string|null
{
    $user_id = get_user_id_by_mail($email);
    $username = get_username_by_id($user_id);

    return $username;
}

function get_user_id_by_mail(string $email): int|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL getUserIDFromEmail(?)");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    $user_id = $row['NutzerID'];

    return $user_id;
}

function get_landlord_id_by_user_id(int $landlord_id): int|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL getlandlordIDFromUserID(?)");
    $stmt->bind_param("s", $landlord_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    $landlord_id = $row['EigentuemerID'];

    return $landlord_id;
}