<?php

include_once '../functions/database_connection.php';

function search(string $procedure, string $query): array
{
    $conn = create_db_connection();

    // Prepare and call the stored procedure
    $stmt = $conn->prepare("CALL " . $procedure . "(?, @p_Matches)");
    $stmt->bind_param("s", $query);
    $stmt->execute();
    $stmt->close();

    // Retrieve the OUT parameter
    $result = $conn->query("SELECT @p_Matches as matches");
    $row = $result->fetch_assoc();
    $entries = [];
    while ($row = $result->fetch_assoc()) {
        $entries[] = $row;
    }

    $conn->close();

    return $entries;
}

function search_orte(string $query): array
{
    return search("SearchOrte", $query);
}

function search_regions(string $query): array
{
    return search("SearchRegions", $query);
}