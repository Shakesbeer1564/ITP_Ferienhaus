<?php

function has_permission($roleId)
{
    session_start();

    if (!isset($_SESSION["role"])) {
        return false;
    }

    if ($_SESSION["role"] < $roleId) {
        return false;
    }

    return true;
}