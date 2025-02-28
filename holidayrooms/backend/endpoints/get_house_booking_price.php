<?php

include_once '../config.php';
include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/http_communication.php';


if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_REGISTERED)) {
        send_http_status(403, "Only registered users can view the price of a house booking");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $house_id = $data["houseId"];
    $start_date = $data["startDate"];
    $end_date = $data["endDate"];

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL GetHouseBookingPrice(?, ?, ?)");
    $stmt->bind_param("sss", $house_id, $start_date, $end_date);
    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for custom error from procedure
        if ($e->getCode() == CUSTOM_SQL_ERROR_CODE) {
            send_http_status(404, "Could not find the house with the given ID");
        }

        // Rethrow exception when it is not a not found error
        throw $e;
    }

    if (!$ok) {
        send_http_status(500, "Something went wrong while trying to execute the database query");
    }

    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    $row = $result->fetch_assoc();
    // When end date is after start date the price is negative. In that case treat them like they would be reversed.
    $price = abs($row["Gesamtpreis"]);

    send_data(["price" => $price]);
}
