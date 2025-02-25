<?php

function get_landlord_name(int $landlord_id): string|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL getLandlordNameFromID(?)");
    $stmt->bind_param("s", $landlord_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    $landlord_name = $row['EigentümerName'];

    return $landlord_name;
}

function get_city_name(int $city_id): string|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL getOrtNameFromID(?)");
    $stmt->bind_param("s", $city_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    $city_name = $row['OrtName'];

    return $city_name;
}

function get_role_name_by_id(int $role_id): string|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL GetRoleNameFromID(?)");
    $stmt->bind_param("s", $role_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    $role_name = $row['NameRolle'];

    return $role_name;
}