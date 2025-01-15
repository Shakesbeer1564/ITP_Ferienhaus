<?php
  header("Content-Type: application/json");

  echo json_encode(
    [
      [
          "name" => "Max",
          "alter" => "25"
      ],
      [
          "name" => "Justin",
          "alter" => "22"
      ]
    ]
  )
?>