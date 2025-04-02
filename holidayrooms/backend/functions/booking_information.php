<?php

function get_booking_information(int $booking_id): array|null
{
    $conn = create_db_connection();
    $stmt = $conn->prepare("CALL GetBookingDetails(?)");
    $stmt->bind_param("s", $booking_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($result->num_rows == 0) {
        return null;
    }

    return $row;
}