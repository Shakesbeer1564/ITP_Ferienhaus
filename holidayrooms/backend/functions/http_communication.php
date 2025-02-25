<?php

function send_http_status(int $status_code, string $message): void
{
    header("Content-Type: application/json");
    http_response_code($status_code);
    echo json_encode([
        "message" => $message
    ]);
    exit;
}

function send_data(array $data): void
{
    header("Content-Type: application/json");
    http_response_code(200);
    echo json_encode($data);
    exit;
}