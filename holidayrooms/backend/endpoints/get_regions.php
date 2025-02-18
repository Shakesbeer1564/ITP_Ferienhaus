<?php

include_once '../functions/database_connection.php';
include_once '../functions/permission_check.php';
include_once '../functions/session_check.php';
include_once '../functions/search.php';

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


    $search_query = $_GET["query"];
    $regions = search_regions($search_query);

    echo json_encode(
        $regions
    );
    exit;
}