<?php

// --- Choose 'local' or 'remote' database location --- \\ 
// define('DB_LOCATION', 'local');
define('DB_LOCATION', 'local');

if (DB_LOCATION == 'local') {
    define('SERVERNAME', 'localhost');
    define('DB_USERNAME', 'root');
    define('DB_PASSWORD', '');
} else {
    define('SERVERNAME', '10.24.29.109');
    define('DB_USERNAME', 'dbAdmin');
    define('DB_PASSWORD', 'passwort');
}

define('DB_NAME', 'ferienhausverwaltung');

define('ROLE_ADMIN', 1);
define('ROLE_LANDLORD', 2);
define('ROLE_REGISTERED', 3);
define('ROLE_GUEST', 4);

define('CUSTOM_SQL_ERROR_CODE', 1644);

define('SESSION_TIMEOUT', 7 * 24 * 3600);