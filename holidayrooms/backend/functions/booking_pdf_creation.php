<?php

include_once '../resources/fpdf/fpdf.php';

function create_booking_pdf($booking_id, $address, $description, $activity_description, $start_date_str, $end_date_str, $price): FPDF
{
    // Define constants
    $font_family = 'Helvetica';
    $title_font_size = 36;
    $content_font_size = 20;
    $content_line_space = 12;
    $after_content_space = 6;

    // Convert input strings to ensure usage of correct encoding (support for ä, ö, ü, ...)
    $address = mb_convert_encoding($address, 'ISO-8859-15', 'UTF-8');
    $description = mb_convert_encoding($description, 'ISO-8859-15', 'UTF-8');
    $activity_description = mb_convert_encoding($activity_description, 'ISO-8859-15', 'UTF-8');
    $price = mb_convert_encoding($price . ' Euro', 'ISO-8859-15', 'UTF-8');
    $activity_description_header = mb_convert_encoding("Aktivitäts Beschreibung:", 'ISO-8859-15', 'UTF-8');

    // Initialize pdf
    $pdf = new FPDF();
    $pdf->AddPage();

    // Add a line break above the title
    $pdf->Ln(12);

    // Add a title
    $pdf->SetFont($font_family, 'B', $title_font_size);
    $pdf->Cell(40, 10, 'Buchung ' . $booking_id);

    // Add a line break below the title
    $pdf->Ln(24);

    // Content
    // Address
    $pdf->SetFont($font_family, 'B', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, 'Adresse:');
    $pdf->SetFont($font_family, '', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, $address);
    $pdf->Ln($after_content_space);

    // House description
    $pdf->SetFont($font_family, 'B', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, 'Beschreibung:');
    $pdf->SetFont($font_family, '', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, $description);
    $pdf->Ln($after_content_space);

    // Activity description
    if ($activity_description != null) {
        $pdf->SetFont($font_family, 'B', $content_font_size);
        $pdf->MultiCell(0, $content_line_space, $activity_description_header);
        $pdf->SetFont($font_family, '', $content_font_size);
        $pdf->MultiCell(0, $content_line_space, $activity_description);
        $pdf->Ln($after_content_space);
    }

    // Start date
    $pdf->SetFont($font_family, 'B', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, 'Startdatum:');
    $pdf->SetFont($font_family, '', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, $start_date_str);
    $pdf->Ln($after_content_space);

    // End date
    $pdf->SetFont($font_family, 'B', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, 'Enddatum:');
    $pdf->SetFont($font_family, '', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, $end_date_str);
    $pdf->Ln($after_content_space);

    // Price
    $pdf->SetFont($font_family, 'B', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, 'Preis:');
    $pdf->SetFont($font_family, '', $content_font_size);
    $pdf->MultiCell(0, $content_line_space, $price);

    return $pdf;
}