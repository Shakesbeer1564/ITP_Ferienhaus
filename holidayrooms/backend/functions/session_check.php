<?php

function is_session_set()
{
    if (!isset($_SESSION)) {
        session_start();
    }

    if (!isset($_SESSION) || !isset($_SESSION["email"])) {
        return false;
    }

    return true;
}