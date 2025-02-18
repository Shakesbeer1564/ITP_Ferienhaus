<?php

include_once '../functions/session_check.php';
include_once '../functions/permission_check.php';
include_once '../functions/house_retrieval.php';

$conn = create_db_connection();

if ($_SERVER["REQUEST_METHOD"] == "GET") {

    if (!is_session_set()) {
        echo json_encode(
            [
                "accessAllowed" => false,
                "reason" => "No session"
            ]
        );
        exit;
    }

    $role_id = $_SESSION["role"];
    echo $_SESSION["username"];
    echo $_SESSION["role"];

    if (!has_permission($role_id)) {
        echo json_encode(
            [
                "accessAllowed" => false,
                "reason" => "Role from session has insuficient permission"
            ]
        );
        exit;
    }


    $ort_id = $_GET["ortId"];
    $houses = retrieve_houses_by_ort($ort_id);

    echo json_encode(
        $houses
    );
    exit;
}