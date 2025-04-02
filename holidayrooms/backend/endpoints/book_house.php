<?php

include_once '../functions/database_connection.php';
include_once '../functions/permission_check.php';
include_once '../functions/user_id_retrieval.php';
include_once '../functions/session_check.php';
include_once '../functions/booking_information.php';
include_once '../functions/booking_pdf_creation.php';
include_once '../functions/http_communication.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    http_response_code(500);

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    if (!has_permission(ROLE_REGISTERED)) {
        send_http_status(403, "Only registered users can book houses");
    }

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $house_id = $data["houseId"];
    $inp_start_date = $data["startDate"];
    $inp_end_date = $data["endDate"];
    $activities = $data["activityIds"];

    $start_date = new DateTime($inp_start_date);
    $end_date = new DateTime($inp_end_date);

    $user_id = get_user_id_by_mail($_SESSION["email"]);
    if ($user_id == null) {
        send_http_status(401, "Session invalid: User does not exist");
    }

    $conn = create_db_connection();

    $start_date_str = $start_date->format('Y-m-d H:i:s');
    $end_date_str = $end_date->format('Y-m-d H:i:s');
    $activies_str = implode(",", $activities);

    $stmt = $conn->prepare("CALL CreateBooking(?, ?, ?, ?, ?)");

    $stmt->bind_param("sssss", $user_id, $house_id, $start_date_str, $end_date_str, $activies_str);
    $stmt->execute();

    $result = $stmt->get_result();

    $stmt->close();
    $conn->close();

    // Read information from database result
    $row = $result->fetch_assoc();
    if ($result->num_rows == 0) {
        send_http_status(500, "Could not load database response");
    }

    $booking_id = $row["buchungID"];
    $booking_information = get_booking_information($booking_id);

    if ($booking_information == null) {
        send_http_status(404, "A booking with that id does not exists");
    }

    $address = $booking_information["Adresse"];
    $description = $booking_information["Beschreibung"];
    $activity_description = $booking_information["Aktivitaets_Beschreibung"];
    $price = $booking_information["Rechnungsbetrag"];

    if ($address == null || $description == null || $price == null) {
        send_http_status(500, "Some values in the database response are missing");
    }

    $pdf = create_booking_pdf($booking_id, $address, $description, $activity_description, $start_date_str, $end_date_str, $price);

    send_pdf($pdf);
}