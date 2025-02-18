<?php

function is_session_set()
{
    if (!isset($_SESSION)) {
        session_start();
    }

    if (!isset($_SESSION) || !isset($_SESSION["username"])) {
        return false;
    }

    return true;
}