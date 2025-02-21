<?php

include_once '../functions/database_connection.php';
include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_LANDLORD)) {
        send_http_status(403, "The user does not have the required permission");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $house_id = $data["houseId"];

    $mail = $_SESSION["email"];
    $user_id = get_user_id_by_mail($mail);

    $conn = create_db_connection();

    // Prepare and call the stored procedure
    $stmt = $conn->prepare("CALL GetMaengelanzeigeForHome(?, ?)");
    $stmt->bind_param("ss", $house_id, $user_id);
    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for custom sql error from procedure
        if ($e->getCode() == CUSTOM_SQL_ERROR_CODE) {
            // Check for not found error
            if ($e->getMessage() == "TODO") {
                send_http_status(404, "There is no complaint with the given ID");
            }
            // Otherwise the user has insufficient permission
            send_http_status(403, "Insufficient permission to see the complaints");
        }

        // Rethrow the exception if it is not a custom error
        throw $e;
    }

    if (!$ok) {
        send_http_status(500, "Something went wrong trying to retrieve the complaints from the database");
    }

    // Get the result set
    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    // Extract entries and build array
    $row = $result->fetch_assoc();
    $complaints = [];
    while ($row = $result->fetch_assoc()) {
        $complaints[] = $row;
    }

    send_data($complaints);
}