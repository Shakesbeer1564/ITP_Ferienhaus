<?php

include_once '../config.php';
include_once '../functions/session_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/permission_check.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $complaint_id = $data["complaintId"];
    $status = $data["repairStatus"];

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_LANDLORD)) {
        send_http_status(403, "Only landlords can update complaints");
    }

    $mail = $_SESSION["email"];
    $user_id = get_user_id_by_mail($mail);

    $conn = create_db_connection();

    $stmt = $conn->prepare("CALL UpdateMaengelanzeige(?, ?, ?)");
    $stmt->bind_param("sss", $complaint_id, $user_id, $status);

    try {
        $ok = $stmt->execute();
    } catch (Exception $e) {
        // Check for a custom error from the procedure
        if ($e->getCode() == CUSTOM_SQL_ERROR_CODE) {
            // Check if the complaint does not exist
            if ($e->getMessage() == "Maengelanzeige existiert nicht.") {
                send_http_status(404, "There is no complaint with the given ID");
            }
            // Otherwise the user does not have the permission by the procedure to resolve the complaint
            send_http_status(403, "Only the landlord of the house of the complaint can resolve the complaint");
        }

        // Rethrow exception when it is not a custom not found error
        throw $e;
    }
    $stmt->close();

    $conn->close();

    if (!$ok) {
        send_http_status(500, "Something went wrong while trying to update the complaint in the database");
    }

    send_data(["ok" => $ok]);
}
