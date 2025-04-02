<?php

include_once '../functions/database_connection.php';
include_once '../functions/element_name_retrieval.php';

function search_homes(string $query, int|null $room_count, int|null $bed_count, DateTime|null $start_date, DateTime|null $end_date): array
{
    if ($room_count == null)
        $room_count = "";
    if ($bed_count == null)
        $bed_count = "";
    $start_date_str = $start_date == null ? "" : $start_date->format('Y-m-d H:i:s');
    $end_date_str = $end_date == null ? "" : $end_date->format('Y-m-d H:i:s');

    $conn = create_db_connection();

    // Prepare and call the stored procedure
    $stmt = $conn->prepare("CALL SearchHomes(?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $query, $room_count, $bed_count, $start_date_str, $end_date_str);
    $stmt->execute();

    // Get the result set
    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    // Read homes from the query result
    $homes = [];
    while ($row = $result->fetch_assoc()) {
        $owner_id = $row["EigentuemerId"];
        var_dump($row);
        $row["EigentuemerName"] = get_landlord_name($owner_id);

        $homes[] = $row;
    }

    return $homes;
}

function search_activities(string $query): array
{
    $conn = create_db_connection();

    // Prepare and call the stored procedure
    $stmt = $conn->prepare("CALL SearchActivities(?)");
    $stmt->bind_param("s", $query);
    $stmt->execute();

    // Get the result set
    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    // Read activities from the query result
    $activities = [];
    while ($row = $result->fetch_assoc()) {
        $ort_id = $row["OrtID"];
        $row["OrtName"] = get_city_name($ort_id);

        $activities[] = $row;
    }

    return $activities;
}