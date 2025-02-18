<?php

include_once 'database_connection.php';

function is_mail_taken($mail): bool
{
    $conn = create_db_connection();

    // Prepare and call the stored procedure
    $stmt = $conn->prepare("CALL CheckEmail(?, @p_Vorhanden)");
    $stmt->bind_param("s", $mail);
    $stmt->execute();
    $stmt->close();

    // Retrieve the OUT parameter
    $result = $conn->query("SELECT @p_Vorhanden as taken");
    $row = $result->fetch_assoc();
    $email_exists = $row['taken'];

    $conn->close();

    return $email_exists;
}