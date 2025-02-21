<?php

function has_permission($role_Id): bool
{
    if (!isset($_SESSION)) {
        session_start();
    }

    if (!isset($_SESSION)) {
        return false;
    }

    if (!isset($_SESSION["role"])) {
        return false;
    }

    if ($_SESSION["role"] > $role_Id) {
        return false;
    }

    return true;
}

function has_role($role_id): bool
{
    if (!isset($_SESSION)) {
        session_start();
    }

    if (!isset($_SESSION)) {
        return false;
    }

    if (!isset($_SESSION["role"])) {
        return false;
    }

    return $_SESSION["role"] == $role_id;
}