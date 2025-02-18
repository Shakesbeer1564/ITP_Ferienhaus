<?php

function has_permission($roleId)
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

    if ($_SESSION["role"] < $roleId) {
        return false;
    }

    return true;
}