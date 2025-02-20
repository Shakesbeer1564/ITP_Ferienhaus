<?php

include_once '../functions/database_connection.php';

function search_homes(string $query, int $room_count, int $bed_count, DateTime $start_date, DateTime $end_date): array
{
    $conn = create_db_connection();

    $start_date_str = $start_date->format('Y-m-d H:i:s');
    $end_date_str = $end_date->format('Y-m-d H:i:s');

    // Prepare and call the stored procedure
    $stmt = $conn->prepare("CALL SearchHomes(?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $query, $room_count, $bed_count, $start_date_str, $end_date_str);
    $stmt->execute();

    // Get the result set
    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    $row = $result->fetch_assoc();
    $homes = [];
    while ($row = $result->fetch_assoc()) {
        $homes[] = $row;
    }

    return $homes;
}