<?php

include_once 'database_connection.php';

function retrieve_houses(int $): array
{
    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL GetHousesByOrt(?, @p_Matches)");
    $stmt->bind_param("s", $ort_id);
    $stmt->execute();
    $stmt->close();

    $result = $conn->query("SELECT @p_Matches as matches");
    $row = $result->fetch_assoc();
    $houses = [];
    while ($row = $result->fetch_assoc()) {
        $houses[] = $row;
    }

    $conn->close();

    return $houses;
}

function retrieve_houses_by_region(int $region_id): array
{
    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL GetHousesByRegion(?, @p_Matches)");
    $stmt->bind_param("s", $region_id);
    $stmt->execute();
    $stmt->close();

    $result = $conn->query("SELECT @p_Matches as matches");
    $row = $result->fetch_assoc();
    $houses = [];
    while ($row = $result->fetch_assoc()) {
        $houses[] = $row;
    }

    $conn->close();

    return $houses;
}