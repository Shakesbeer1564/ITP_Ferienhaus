<?php

include_once '../functions/database_connection.php';
include_once '../functions/permission_check.php';
include_once '../functions/session_check.php';
include_once '../functions/search.php';
include_once '../functions/http_communication.php';

$conn = create_db_connection();

if ($_SERVER["REQUEST_METHOD"] == "GET") {

    if (!is_session_set()) {
        send_http_status(401, "No session");
    }

    $role_id = $_SESSION["role"];

    if (!has_permission(ROLE_GUEST)) {
        send_http_status(403, "Role from session, therefore the user, has insuficient permission");
    }

    $search_query = $_GET["query"];
    $cities = search_cities($search_query);

    send_data($cities);
}