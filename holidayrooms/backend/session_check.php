<?php

function is_session_set()
{
    session_start();

    if (isset($_SESSION) || !isset($_SESSION["username"])) {
        return false;
    }

    return true;
}