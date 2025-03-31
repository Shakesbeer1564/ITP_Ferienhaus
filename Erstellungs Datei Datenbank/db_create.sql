-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 28. Feb 2025 um 12:40
-- Server-Version: 10.4.28-MariaDB
-- PHP-Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS Ferienhausverwaltung_Gruppe5;
USE Ferienhausverwaltung_Gruppe5;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `Ferienhausverwaltung_Gruppe5`
--

DELIMITER $$
--
-- Prozeduren
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddActivity` (IN `p_Name` VARCHAR(255), IN `p_Beschreibung` TEXT, IN `p_Preis` INT, IN `p_AnzahlTeilnehmer` INT, IN `p_OrtID` INT)   BEGIN
    IF NOT EXISTS (SELECT 1 FROM ort WHERE OrtID = p_OrtID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ort does not exist.';
    END IF;

    -- Insert the new activity
    INSERT INTO freizeitaktivität (Name, Beschreibung, Preis, AnzahlTeilnehmer, OrtID)
    VALUES (p_Name, p_Beschreibung, p_Preis, p_AnzahlTeilnehmer, p_OrtID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddMaengelanzeige` (IN `p_HausID` INT, IN `p_Beschreibung` TEXT)   BEGIN
	 IF NOT EXISTS (SELECT 1 FROM haus WHERE HausID = p_HausID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Haus existiert nicht.';
    END IF;

    INSERT INTO mängelanzeige (HausID, MeldeDatum, Beschreibung)
    VALUES (p_HausID, NOW(), p_Beschreibung);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddUser` (IN `p_Name` VARCHAR(100), IN `p_Email` VARCHAR(100), IN `p_Telefonnummer` VARCHAR(20), IN `p_Passwort` VARCHAR(255))   BEGIN
	IF NOT EmailIsValid(p_Email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
    END IF;

    IF EXISTS (SELECT 1 FROM nutzer WHERE Email = p_Email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Die E-Mail-Adresse ist bereits registriert.';
    END IF;

    INSERT INTO nutzer (Name, Email, Telefonnummer, RolleID, Passwort)
    VALUES (p_Name, p_Email, p_Telefonnummer, 3 , p_Passwort);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddVacationHome` (IN `p_Adresse` VARCHAR(255), IN `p_AnzahlZimmer` INT, IN `p_AnzahlBetten` INT, IN `p_Beschreibung` TEXT, IN `p_OrtID` INT, IN `p_EigentuemerID` INT, IN `p_preis` INT)   BEGIN
    INSERT INTO haus (Adresse, AnzahlZimmer, AnzahlBetten, Beschreibung, OrtID, EigentümerID, Preis)
    VALUES (p_Adresse, p_AnzahlZimmer, p_AnzahlBetten, p_Beschreibung, p_OrtID, p_EigentuemerID, p_preis);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckEmail` (IN `p_Email` VARCHAR(100), OUT `p_Vorhanden` BOOLEAN)   BEGIN
    DECLARE v_Count INT;

    SELECT COUNT(*) INTO v_Count
    FROM nutzer
    WHERE Email = p_Email;

    SET p_Vorhanden = (v_Count > 0);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBooking` (IN `p_nutzerID` INT, IN `p_HausID` INT, IN `p_StartDatum` DATE, IN `p_EndDatum` DATE, IN `p_AktivitaetIDs` VARCHAR(255))   BEGIN
    DECLARE p_Preis DECIMAL(10,2) DEFAULT 0;
    DECLARE p_HausPreis DECIMAL(10,2) DEFAULT 0;
    DECLARE p_AktivitaetPreis DECIMAL(10,2) DEFAULT 0;
    DECLARE p_Naechte INT DEFAULT 1;
    DECLARE p_BuchungID INT;
    DECLARE v_AktivitaetID VARCHAR(255);
    DECLARE v_Position INT DEFAULT 1;
    DECLARE v_OneAktivitaetID VARCHAR(10);
    DECLARE p_Vertragsdetails TEXT;

    -- Überprüfen, ob der Nutzer existiert
    IF NOT EXISTS (SELECT 1 FROM nutzer WHERE NutzerID = p_nutzerID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nutzer existiert nicht.';
    END IF;

    -- Buchung mit Platzhalter-Werten erstellen (Preis = 0, da er später berechnet wird)
    INSERT INTO buchung (NutzerID, HausID, StartDatum, EndDatum, Preis)  
    VALUES (p_nutzerID, p_HausID, p_StartDatum, p_EndDatum, 0);
    
    SET p_BuchungID = LAST_INSERT_ID(); -- Speichert die generierte BuchungID

    -- Wenn ein Haus gebucht wird
    IF p_HausID IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM haus WHERE HausID = p_HausID) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Haus existiert nicht.';
        END IF;

        SET p_Naechte = GREATEST(DATEDIFF(p_EndDatum, p_StartDatum), 1);
        SELECT COALESCE(Preis, 0) INTO p_HausPreis FROM haus WHERE HausID = p_HausID;

        IF p_HausPreis = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hauspreis ist nicht definiert.';
        END IF;

        SET p_HausPreis = p_HausPreis * p_Naechte;
        
    END IF;

    -- Aktivitäten verarbeiten
    IF p_AktivitaetIDs IS NOT NULL THEN
        SET v_AktivitaetID = p_AktivitaetIDs;

        WHILE LENGTH(v_AktivitaetID) > 0 DO
            SET v_Position = LOCATE(',', v_AktivitaetID);
            
            IF v_Position > 0 THEN
                SET v_OneAktivitaetID = LEFT(v_AktivitaetID, v_Position - 1);
                SET v_AktivitaetID = SUBSTRING(v_AktivitaetID FROM v_Position + 1);
            ELSE
                SET v_OneAktivitaetID = v_AktivitaetID;
                SET v_AktivitaetID = '';
            END IF;

            IF NOT EXISTS (SELECT 1 FROM freizeitaktivität WHERE AktivitätsID = v_OneAktivitaetID) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eine oder mehrere Aktivitäten existieren nicht.';
            END IF;

            SELECT COALESCE(Preis, 0) INTO p_AktivitaetPreis FROM freizeitaktivität WHERE AktivitätsID = v_OneAktivitaetID;
            
            IF p_AktivitaetPreis = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Preis für eine der Aktivitäten ist nicht definiert.';
            END IF;

            -- Preis aufsummieren
            SET p_Preis = p_Preis + p_AktivitaetPreis;

            -- Aktivität zur Buchung speichern
            INSERT INTO buchung_aktivitaet (BuchungID, AktivitaetsID)  
            VALUES (p_BuchungID, v_OneAktivitaetID);
        END WHILE;
    END IF;

    -- Gesamtpreis berechnen
    SET p_Preis = p_Preis + p_HausPreis;

    IF p_Preis = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gesamtpreis kann nicht NULL oder 0 sein.';
    END IF;

    -- Finalen Preis in die Buchung eintragen
    UPDATE buchung SET Preis = p_Preis WHERE BuchungID = p_BuchungID;

    -- Rechnung erstellen
    INSERT INTO rechnung (BuchungID, Rechnungsdatum, Betrag)  
    VALUES (p_BuchungID, CURDATE(), p_Preis);

    -- Vertragsdetails erstellen
    SET p_Vertragsdetails = CONCAT('Buchungsdauer: ', p_Naechte, ' Nächte, Gesamtpreis: ', p_Preis, ' EUR');

    -- Mietvertrag einfügen
    INSERT INTO mietvertrag (Vertragsdatum, Vertragsdetails, BuchungID)  
    VALUES (CURDATE(), p_Vertragsdetails, p_BuchungID);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateVacationHome` (IN `p_Adresse` VARCHAR(255), IN `p_AnzahlZimmer` INT, IN `p_AnzahlBetten` INT, IN `p_Beschreibung` TEXT, IN `p_OrtName` VARCHAR(255), IN `p_EigentümerName` VARCHAR(255))   BEGIN
    DECLARE v_OrtID INT;
    DECLARE v_EigentümerID INT;

    -- Check if the region already exists
    SELECT OrtID INTO v_OrtID
    FROM ort
    WHERE OrtName = p_OrtName
    LIMIT 1;

    -- Check if the Eigentümer already exists
    SELECT EigentümerID INTO v_EigentümerID
    FROM Eigentümer
    WHERE EigentümerName = p_EigentümerName
    LIMIT 1;

    -- If Eigentümer doesn't exist, ask for user input (inserting manually here as an example)
    IF v_EigentümerID IS NULL THEN
        -- Insert the new Eigentümer and get the EigentümerID
        INSERT INTO Eigentümer (EigentümerName)
        VALUES (p_EigentümerName);
        SET v_EigentümerID = LAST_INSERT_ID();
    END IF;

    -- Now insert the new house record with assigned IDs
    INSERT INTO Haus (Adresse, AnzahlZimmer, AnzahlBetten, Beschreibung, OrtID, EigentümerID)
    VALUES (p_Adresse, p_AnzahlZimmer, p_AnzahlBetten, p_Beschreibung, v_OrtID, v_EigentümerID);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteActivity` (IN `p_activityID` INT)   BEGIN

	IF NOT EXISTS (SELECT 1 FROM freizeitaktivität WHERE AktivitätsID = p_activityID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aktivität existiert nicht.';
    END IF;
	
    DELETE FROM freizeitaktivität WHERE p_activityID = AktivitätsID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteHome` (IN `p_HausID` INT, IN `p_UserID` INT)   BEGIN
    DECLARE v_UserRole VARCHAR(50);
    DECLARE v_EigentuemerID INT;
    DECLARE v_OwnerID INT;

    -- Check if the house exists
    IF NOT EXISTS (SELECT 1 FROM haus WHERE HausID = p_HausID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Haus existiert nicht.';
    END IF;

    -- Get the user's role
    SELECT RolleID INTO v_UserRole FROM nutzer WHERE NutzerID = p_UserID;

	-- Get the EigentümerID from the haus table
    SELECT EigentümerID INTO v_EigentuemerID FROM haus WHERE HausID = p_HausID;

    -- Get the house owner
    SELECT NutzerID INTO v_OwnerID FROM eigentümer WHERE EigentümerID = v_EigentuemerID;

    -- Check if the user is an admin or the owner
    IF v_UserRole != 1 AND v_OwnerID != p_UserID THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zugriff verweigert: Nur Admins oder Eigentümer können das Haus löschen.';
    END IF;

    -- Delete the house
    DELETE FROM haus WHERE HausID = p_HausID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteUser` (IN `p_NutzerID` INT)   BEGIN

		IF NOT EXISTS (SELECT 1 FROM nutzer WHERE NutzerID = p_NutzerID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nutzer existiert nicht.';
    END IF;



    DELETE FROM nutzer WHERE NutzerID = p_NutzerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getActivitys` (IN `p_OrtID` INT)   SELECT * FROM freizeitaktivität WHERE OrtID = p_OrtID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllUsers` ()   BEGIN
	SELECT * FROM nutzer;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getBookingbyHome` (IN `p_UserID` INT, IN `p_HausID` INT)   BEGIN
    DECLARE v_rolleID INT DEFAULT NULL;
    DECLARE v_ownerID INT DEFAULT NULL;

    -- Fetch RolleID of the user
    SELECT RolleID INTO v_rolleID 
    FROM nutzer 
    WHERE NutzerID = p_UserID;

    -- Debugging: Falls Rolle nicht gefunden wird
    IF v_rolleID IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fehler: Nutzer nicht gefunden oder RolleID ist NULL';
    END IF;

    -- Fetch Eigentümer (Owner) of the house
  SELECT e.NutzerID INTO v_ownerID
FROM eigentümer e
JOIN haus h ON e.EigentümerID = h.EigentümerID
WHERE h.HausID = p_HausID;

    -- Debugging: Falls Haus nicht gefunden wird oder kein Eigentümer existiert
    IF v_ownerID IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fehler: Haus nicht gefunden oder hat keinen Eigentümer';
    END IF;

    -- Check permission (Admin oder Eigentümer des Hauses)
    IF NOT (v_rolleID = 1 OR v_ownerID = p_UserID) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'User ist nicht berechtigt, diese Buchung anzuzeigen';
    ELSE 
        -- Select bookings if the user is authorized
        SELECT * FROM buchung WHERE HausID = p_HausID;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBookingByUser` (IN `p_eingabeID` INT, IN `p_nutzerID` INT)   BEGIN
    DECLARE v_rolleID INT;

    -- Fetch RolleID of the user
    SELECT RolleID INTO v_rolleID 
    FROM nutzer 
    WHERE NutzerID = p_eingabeID;

	 -- Debugging: Falls Rolle nicht gefunden wird
    IF v_rolleID IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fehler: Nutzer nicht gefunden oder RolleID ist NULL';
    END IF;
	
    -- Check permission
    IF NOT (p_eingabeID = p_nutzerID OR v_rolleID = 1) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'User ist nicht berechtigt, diese Buchung anzuzeigen';
    ELSE 
    -- Select bookings if the user is authorized
    SELECT * FROM buchung WHERE NutzerID = p_nutzerID;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCityFromRegion` (IN `p_regionID` INT)   SELECT Distinct OrtName FROM ort Where regionID = p_regionID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCityIDByName` (IN `input_name` VARCHAR(100))   BEGIN
    SELECT ortID 
    FROM ort 
    WHERE OrtName LIKE CONCAT('%', input_name, '%') 
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCustomers` ()   BEGIN
   SELECT * FROM nutzer WHERE RolleID = 3;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetHomeFromOwner` (IN `p_eigentümerID` INT)   BEGIN
    SELECT * FROM haus WHERE p_eigentümerID = eigentümerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getHomeID` (IN `p_Adresse` VARCHAR(255), OUT `p_HausID` INT)   BEGIN
    -- Fetch HausID based on Adresse and assign it to p_HausID
    SELECT HausID INTO p_HausID
    FROM haus
    WHERE Adresse = p_Adresse
    LIMIT 1;  -- To ensure only one value is returned, avoid multiple results

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getHouseBookingPrice` (IN `p_HausID` INT, IN `p_Startdatum` DATE, IN `p_Enddatum` DATE)   BEGIN
    DECLARE v_PreisProNacht DECIMAL(10,2);
    DECLARE v_AnzahlNaechte INT;
    DECLARE v_Gesamtpreis DECIMAL(10,2);

    -- Preis pro Nacht abrufen
    SELECT Preis INTO v_PreisProNacht 
    FROM haus 
    WHERE HausID = p_HausID
    LIMIT 1;  -- Falls doppelte Einträge existieren

    -- Fehlerbehandlung: Prüfen, ob das Haus existiert
    IF v_PreisProNacht IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Haus nicht gefunden oder Preis ist NULL';
    END IF;

    -- Anzahl der Nächte berechnen (mindestens 1 Nacht)
    SET v_AnzahlNaechte = DATEDIFF(p_EndDatum, p_StartDatum);

    -- Gesamtpreis berechnen
    SET v_Gesamtpreis = v_AnzahlNaechte * v_PreisProNacht;

    -- Ergebnis ausgeben
    SELECT v_Gesamtpreis AS Gesamtpreis;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetHousesBookedByUserInPast` (IN `p_UserID` INT)   BEGIN
    DECLARE v_RolleID INT;

    -- Rolle des Nutzers abrufen
    SELECT RolleID INTO v_RolleID 
    FROM nutzer 
    WHERE NutzerID = p_UserID;

    -- Falls die Rolle nicht gefunden wird
    IF v_RolleID IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fehler: Nutzer nicht gefunden oder RolleID ist NULL';
    END IF;

    -- Szenario 1: User (Rolle = 3) → Zeige nur vergangene Buchungen
    IF v_RolleID = 3 THEN
        SELECT DISTINCT h.*
        FROM buchung b
        JOIN haus h ON b.HausID = h.HausID
        WHERE b.NutzerID = p_UserID
        AND b.StartDatum < NOW();  -- Nur vergangene Buchungen

    -- Szenario 2: Admin (Rolle = 1) → Zeige alle Häuser
    ELSEIF v_RolleID = 1 THEN
        SELECT * FROM haus;

    -- Szenario 3: Vermieter (Rolle = 2) → Zeige alle Häuser, die ihm gehören (über `eigentümer`-Tabelle)
    ELSEIF v_RolleID = 2 THEN
        SELECT DISTINCT h.*
        FROM haus h
        JOIN eigentümer e ON h.EigentümerID = e.EigentümerID
        WHERE e.NutzerID = p_UserID;  -- Verbindung über `eigentümer`

    -- Falls Rolle unbekannt
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fehler: Unbekannte Rolle';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetInvoicesByUser` (IN `p_UserID` INT)   BEGIN
    -- Check if the user exists
    IF NOT EXISTS (SELECT 1 FROM nutzer WHERE NutzerID = p_UserID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not exist.';
    END IF;

    -- Retrieve invoices for the given user
    SELECT r.RechnungID, r.BuchungID, r.Rechnungsdatum, r.Betrag
    FROM rechnung r
    JOIN buchung b ON r.BuchungID = b.BuchungID
    WHERE b.NutzerID = p_UserID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getLandlordIDfromUserID` (IN `p_nutzerID` INT)   SELECT EigentümerID FROM eigentümer 
    Where nutzerID = p_nutzerID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getLandlordNameFromID` (IN `p_ID` INT)   BEGIN
	SELECT EigentümerName FROM eigentümer WHERE p_ID = eigentümerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getMaengelanzeige` (IN `p_mangelID` INT)   SELECT * FROM mängelanzeige WHERE mangelID = p_mangelID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getMaengelanzeigeforHome` (IN `p_HausID` INT)   SELECT * FROM mängelanzeige where hausID = p_HausID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrtNameFromID` (IN `p_ID` INT)   BEGIN
	SELECT OrtName FROM ort WHERE p_ID = OrtID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRegionIDByName` (IN `p_input_name` VARCHAR(100))   BEGIN
    SELECT RegionID 
    FROM region 
    WHERE RegionName LIKE CONCAT('%', p_input_name, '%') 
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRoleNameFromID` (IN `p_ID` INT)   BEGIN
   SELECT NameRolle FROM rolle WHERE p_ID = RolleID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUser` (IN `p_NutzerID` INT)   BEGIN
	IF NOT EXISTS (SELECT 1 FROM nutzer WHERE NUtzerID = p_NUtzerID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nutzer existiert nicht.';
    END IF;


    SELECT * FROM nutzer WHERE NutzerID = p_NutzerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserIDFromEmail` (IN `p_email` VARCHAR(100))   BEGIN
   
    SELECT NutzerID 
    FROM nutzer
    WHERE Email = p_email
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isHouseFree` (IN `p_HausID` INT, OUT `p_vorhanden` TINYINT)   BEGIN
	DECLARE columnVAlue TINYINT;
    
    SELECT isFree into columnValue
    FROM haus
    WHERE hausID = p_HausID;
   
   SET p_vorhanden = IF(columnValue = 1, 1, 0);
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReportIssue` (IN `p_HausID` INT, IN `p_UserID` INT, IN `p_Beschreibung` TEXT)   BEGIN
    -- Prüfen, ob das Haus existiert
    IF NOT EXISTS (SELECT 1 FROM haus WHERE HausID = p_HausID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Haus existiert nicht.';
    END IF;

    -- Prüfen, ob der Nutzer das Haus gebucht hat und der Buchungsstart in der Vergangenheit liegt
    IF NOT EXISTS (
        SELECT 1 
        FROM buchung 
        WHERE HausID = p_HausID 
          AND NutzerID = p_UserID 
          AND Startdatum <= NOW()
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nutzer hat das Haus nicht gebucht oder die Buchung hat noch nicht begonnen.';
    END IF;

    -- Mängelanzeige eintragen
    INSERT INTO mängelanzeige (HausID, MeldeDatum, Beschreibung)
    VALUES (p_HausID, NOW(), p_Beschreibung);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ResetPasswort` (IN `p_NutzerID` INT, IN `p_NeuesPasswort` VARCHAR(255))   BEGIN
    UPDATE nutzer
    SET Passwort = p_NeuesPasswort
    WHERE NutzerID = p_NutzerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchActivities` (IN `p_search` VARCHAR(255))   BEGIN
    -- Ensure the temporary table does not exist
    DROP TEMPORARY TABLE IF EXISTS TempWords;
    CREATE TEMPORARY TABLE TempWords (word VARCHAR(100));

    -- Extract words using a derived table approach
    INSERT INTO TempWords (word)
    SELECT DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(p_search, ' ', n), ' ', -1)
    FROM (
        SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    ) numbers
    WHERE CHAR_LENGTH(p_search) - CHAR_LENGTH(REPLACE(p_search, ' ', '')) >= n-1;

    -- Select activities where either Name or City (Ort) matches any extracted word
    SELECT DISTINCT fa.* 
    FROM freizeitaktivität fa
    JOIN ort o ON fa.OrtID = o.OrtID
    WHERE EXISTS (
        SELECT 1 FROM TempWords t 
        WHERE fa.Name LIKE CONCAT('%', t.word, '%')
           OR o.OrtName LIKE CONCAT('%', t.word, '%')
    );

    -- Cleanup temporary table
    DROP TEMPORARY TABLE IF EXISTS TempWords;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchHomes` (IN `p_location_name` VARCHAR(100), IN `p_anzahlZimmer` INT, IN `p_anzahlBetten` INT, IN `p_startDatum` DATE, IN `p_endDatum` DATE)   BEGIN
    SELECT *
FROM haus h
WHERE
(
-- 1) LOCATION FILTER (Region or Ort):
-- If p_location_name is empty, skip; else match region/ort (case-insensitive).
p_location_name IS NULL
OR p_location_name = ''
OR h.OrtID IN (
SELECT OrtID FROM ort
WHERE LOWER(OrtName) LIKE LOWER(CONCAT('%', p_location_name, '%'))
)
OR h.OrtID IN (
SELECT OrtID FROM region
WHERE LOWER(RegionName) LIKE LOWER(CONCAT('%', p_location_name, '%'))
)
)
    AND
    (
        -- 2) ROOMS/BEDS FILTER:
        -- If both p_anzahlZimmer & p_anzahlBetten = 0, skip filter (return all).
        -- Otherwise, apply whichever is non-zero.
        
        -- "No filter" scenario:
        (p_anzahlZimmer = 0 AND p_anzahlBetten = 0)
        
        -- Only beds filter:
        OR (p_anzahlZimmer = 0 AND p_anzahlBetten > 0 AND h.AnzahlBetten >= p_anzahlBetten)
        
        -- Only rooms filter:
        OR (p_anzahlBetten = 0 AND p_anzahlZimmer > 0 AND h.AnzahlZimmer >= p_anzahlZimmer)
        
        -- Both rooms & beds:
        OR (
            p_anzahlZimmer > 0 
            AND p_anzahlBetten > 0
            AND h.AnzahlZimmer >= p_anzahlZimmer
            AND h.AnzahlBetten >= p_anzahlBetten
        )
    )
   AND
    (
        -- 3) DATE FILTER (Verfügbarkeit)
        -- Häuser ausschließen, die im gewählten Zeitraum bereits gebucht sind
        (p_startDatum IS NULL OR p_endDatum IS NULL)
        OR h.HausID NOT IN (
            SELECT DISTINCT b.HausID
            FROM buchung b
            WHERE 
                b.Startdatum < p_endDatum  -- Buchung startet vor dem Ende der Suche
                AND b.Enddatum > p_startDatum  -- Buchung endet nach dem Start der Suche
        )
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SetRollforUser` (IN `p_nutzerID` INT, IN `p_rollID` INT)   BEGIN
    UPDATE nutzer
    SET RolleID = p_rollID
    WHERE nutzerID = p_nutzerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateMaengelanzeige` (IN `p_MaengelID` INT, IN `p_UserID` INT, IN `p_Status` VARCHAR(50))   BEGIN
    DECLARE v_HausID INT;
    DECLARE v_EigentuemerID INT;
    DECLARE v_UserRollID INT;

    -- Prüfe, ob die Mängelanzeige existiert und speichere die zugehörige HausID
    SELECT HausID INTO v_HausID FROM mängelanzeige WHERE MangelID = p_MaengelID;
    IF v_HausID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mängelanzeige existiert nicht.';
    END IF;

    -- Prüfe, ob der Nutzer ein Admin ist
    SELECT RolleID INTO v_UserRollID FROM nutzer WHERE NutzerID = p_UserID;
    IF v_UserRollID = 1 THEN
        -- Admin darf alles
        UPDATE mängelanzeige SET state = p_Status WHERE MangelID = p_MaengelID;
        
    END IF;

    -- Bestimme den Eigentümer des Hauses
    SELECT EigentümerID INTO v_EigentuemerID FROM haus WHERE HausID = v_HausID;

    -- Prüfe, ob der Nutzer der Eigentümer dieses Hauses ist
    IF NOT EXISTS (
        SELECT 1 FROM eigentümer WHERE EigentümerID = v_EigentuemerID AND nutzerID = p_UserID
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nicht autorisiert: Nur der Eigentümer dieses Hauses oder ein Admin kann die Mängelanzeige aktualisieren.';
    END IF;

    -- Falls Berechtigung vorhanden, Status aktualisieren
    UPDATE mängelanzeige SET state = p_Status WHERE MangelID = p_MaengelID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateMaengelanzeige23424` (IN `p_MaengelID` INT, IN `p_UserID` INT, IN `p_status` VARCHAR(20))   BEGIN
    -- Prüfe, ob die Mängelanzeige existiert
    IF NOT EXISTS (SELECT 1 FROM mängelanzeige WHERE MangelID = p_MaengelID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mängelanzeige does not exist.';
    END IF;

    -- Prüfe, ob der Nutzer der Eigentümer des Hauses dieser Mängelanzeige ist oder Adminrechte hat
    IF NOT EXISTS (
        SELECT 1 
        FROM nutzer n
        LEFT JOIN eigentümer e ON n.NutzerID = e.nutzerID
        LEFT JOIN haus h ON e.EigentümerID = h.EigentümerID
        LEFT JOIN mängelanzeige ma ON h.HausID = ma.HausID
        WHERE ma.MangelID = p_MaengelID
        AND (h.EigentümerID = e.EigentümerID)  -- Nur der Eigentümer dieses Hauses oder Admins
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unauthorized: Only the owner of this house or an admin can update this entry.';
    END IF;

    -- Falls Berechtigung vorhanden, Status aktualisieren
    UPDATE mängelanzeige 
    SET status = p_status
    WHERE MangelID = p_MaengelID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUser` (IN `p_UserID` INT, IN `p_NewName` VARCHAR(255), IN `p_NewEmail` VARCHAR(255), IN `p_NewPhone` VARCHAR(20))   BEGIN
 IF NOT EmailIsValid(p_NewEmail) THEN
 	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid Email adress.';
 ELSE
 	IF EXISTS (SELECT 1 FROM nutzer WHERE Email = p_Email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Die E-Mail-Adresse ist bereits registriert.';
    END IF;
    UPDATE Nutzer
    SET
        Name = p_NewName,
        Email = p_NewEmail,
        Telefonnummer = p_NewPhone
       
    WHERE NutzerID = p_UserID;
  END if;
END$$

--
-- Funktionen
--
CREATE DEFINER=`root`@`localhost` FUNCTION `EmailIsValid` (`p_Email` VARCHAR(100)) RETURNS TINYINT(1)  BEGIN
    RETURN p_Email REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$';
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `buchung`
--

CREATE TABLE `buchung` (
  `BuchungID` int(11) NOT NULL,
  `NutzerID` int(11) NOT NULL,
  `HausID` int(11) DEFAULT NULL,
  `Startdatum` date NOT NULL,
  `Enddatum` date NOT NULL,
  `Preis` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `buchung`
--

INSERT INTO `buchung` (`BuchungID`, `NutzerID`, `HausID`, `Startdatum`, `Enddatum`, `Preis`) VALUES
(1, 22, 4, '2025-02-19', '2026-02-18', 120.00),
(6, 9, 4, '2026-04-24', '2027-04-26', 18470.00),
(7, 9, 4, '2026-04-24', '2027-04-26', 18470.00),
(8, 9, 4, '2026-04-24', '2027-04-26', 18470.00),
(9, 9, 12, '2026-04-24', '2027-04-26', 18470.00),
(36, 14, NULL, '2025-02-20', '2025-02-20', 200.00),
(38, 14, NULL, '2025-02-20', '2025-02-20', 120.00),
(39, 14, NULL, '1893-06-15', '2026-01-29', 120.00),
(41, 14, NULL, '1893-06-15', '2026-01-29', 120.00),
(42, 14, NULL, '1069-06-15', '2026-01-29', 120.00),
(43, 14, NULL, '0569-06-15', '2026-01-29', 120.00),
(44, 14, NULL, '2009-06-15', '2026-01-29', 120.00),
(51, 22, 6, '2025-04-24', '2025-07-26', 0.00),
(52, 22, 6, '2025-04-24', '2025-07-26', 0.00),
(54, 21, 6, '2025-02-24', '2025-02-26', 2.00),
(55, 23, 5, '0004-03-02', '0005-03-02', 3285.00),
(56, 23, 5, '5555-01-01', '5555-01-02', 129.00);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `buchung_aktivitaet`
--

CREATE TABLE `buchung_aktivitaet` (
  `BuchungAktivitaetID` int(11) NOT NULL,
  `BuchungID` int(11) NOT NULL,
  `AktivitaetsID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `buchung_aktivitaet`
--

INSERT INTO `buchung_aktivitaet` (`BuchungAktivitaetID`, `BuchungID`, `AktivitaetsID`) VALUES
(66, 36, 4),
(67, 38, 4),
(68, 39, 4),
(72, 41, 4),
(73, 42, 4),
(74, 43, 4),
(75, 44, 4),
(82, 56, 4);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `eigentümer`
--

CREATE TABLE `eigentümer` (
  `EigentümerID` int(11) NOT NULL,
  `EigentümerName` varchar(100) DEFAULT NULL,
  `EigentümerAdresse` varchar(100) NOT NULL,
  `nutzerID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `eigentümer`
--

INSERT INTO `eigentümer` (`EigentümerID`, `EigentümerName`, `EigentümerAdresse`, `nutzerID`) VALUES
(1, 'TestEigentümer', 'Adresse 1, Testhausen', 9),
(2, 'Test', '', 22),
(3, 'test', '', 16),
(4, 'test', '', NULL),
(5, 'test', '', 26),
(6, 'test', '', NULL),
(7, 'test', '', NULL),
(8, 't', '', NULL),
(9, 'e', '', NULL),
(10, 's', '', NULL),
(11, NULL, '', NULL);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `freizeitaktivität`
--

CREATE TABLE `freizeitaktivität` (
  `AktivitätsID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Beschreibung` text DEFAULT NULL,
  `Preis` decimal(10,2) NOT NULL,
  `AnzahlTeilnehmer` int(11) DEFAULT NULL,
  `OrtID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `freizeitaktivität`
--

INSERT INTO `freizeitaktivität` (`AktivitätsID`, `Name`, `Beschreibung`, `Preis`, `AnzahlTeilnehmer`, `OrtID`) VALUES
(1, 'Nordsee-Segeltour', 'Segeln entlang der Nordseeküste', 150.00, 5, 1),
(3, 'Weinverkostung', 'Weinprobe im Schwarzwald', 50.00, 2, 3),
(4, 'Ostsee-Segeltour', 'Segeln entlang der Ostseeküste', 120.00, 4, 1),
(6, 'spast', 'test', 12.00, 4, 1),
(7, 'Raketenflug_Activity123', '95% Explosionwahrscheinlichkeit, 3% Überlebenswahrscheinlichkeit; Genießen sie wenige Minuten in einer SpaceGate-Rakete', 99999999.99, 1, 1);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `haus`
--

CREATE TABLE `haus` (
  `HausID` int(11) NOT NULL,
  `Adresse` varchar(255) NOT NULL,
  `AnzahlZimmer` int(11) NOT NULL,
  `AnzahlBetten` int(11) NOT NULL,
  `Beschreibung` text DEFAULT NULL,
  `EigentümerID` int(11) DEFAULT NULL,
  `OrtID` int(11) DEFAULT NULL,
  `Preis` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `haus`
--

INSERT INTO `haus` (`HausID`, `Adresse`, `AnzahlZimmer`, `AnzahlBetten`, `Beschreibung`, `EigentümerID`, `OrtID`, `Preis`) VALUES
(4, 'Strandweg 1, Sylt', 4, 8, 'Ein Strandhaus mit Blick auf die Nordsee', 3, 1, 50),
(5, 'Bergstraße 12, München', 6, 12, 'Modernes Haus in Zentrallage', 2, 4, 9),
(6, 'Waldweg 5, Freiburg', 3, 5, 'Gemütliches Haus in der Nähe des Schwarzwaldes', 2, 4, 1),
(7, 'Strandweg 2, Sylt', 2, 1, 'test', 3, 3, 45),
(8, 'Strandweg 3, Sylt', 2, 1, 'test', 4, 7, 876),
(12, 'string', 1, 2, 'string', 1, 2, 123),
(13, 'stringadasdasd', 1, 2, 'asdadasd1d1 ', 5, 1, 123),
(14, 'string', 1, 2, 'string', 2, 1, 123),
(15, 'address bllb', 1, 2, 'descs cc', 2, 1, 123),
(16, 'Test', 12, 9, '12131231231231', 9, 1, 67),
(17, 'Test13124', 12, 9, '12131231231231', 10, 1, 10),
(21, 'dasisteine Testadresse', 100, 100, 'Nils stinkt', 11, 3, NULL);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mietvertrag`
--

CREATE TABLE `mietvertrag` (
  `VertragID` int(11) NOT NULL,
  `Vertragsdatum` date NOT NULL,
  `Vertragsdetails` text DEFAULT NULL,
  `BuchungID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `mietvertrag`
--

INSERT INTO `mietvertrag` (`VertragID`, `Vertragsdatum`, `Vertragsdetails`, `BuchungID`) VALUES
(5, '2025-02-19', 'Buchungsdauer: 93 Nächte, Gesamtpreis: 3800.00 EUR', 1),
(8, '2025-02-19', 'Buchungsdauer: 2 Nächte, Gesamtpreis: 210.00 EUR', 6),
(17, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 200.00 EUR', 36),
(19, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 120.00 EUR', 38),
(20, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 120.00 EUR', 39),
(22, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 120.00 EUR', 41),
(23, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 120.00 EUR', 42),
(24, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 120.00 EUR', 43),
(25, '2025-02-20', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 120.00 EUR', 44),
(32, '2025-02-25', 'Buchungsdauer: 2 Nächte, Gesamtpreis: 2.00 EUR', 54),
(33, '2025-02-28', 'Buchungsdauer: 365 Nächte, Gesamtpreis: 3285.00 EUR', 55),
(34, '2025-02-28', 'Buchungsdauer: 1 Nächte, Gesamtpreis: 129.00 EUR', 56);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `mängelanzeige`
--

CREATE TABLE `mängelanzeige` (
  `MangelID` int(11) NOT NULL,
  `HausID` int(11) NOT NULL,
  `MeldeDatum` date NOT NULL,
  `Beschreibung` text NOT NULL,
  `state` enum('Neu','In Bearbeitung','Gelöst') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `mängelanzeige`
--

INSERT INTO `mängelanzeige` (`MangelID`, `HausID`, `MeldeDatum`, `Beschreibung`, `state`) VALUES
(12, 5, '2025-02-21', 'Das Haus ist umgefallen. Konnten nicht drinne wohnen. 5/5 Sterne', 'Neu'),
(13, 4, '2025-02-21', 'test', 'Neu'),
(14, 4, '2025-02-25', 'TEstbeschreibung', 'Neu'),
(15, 4, '2025-02-27', 'description', 'Neu'),
(16, 4, '2025-02-27', 'description', 'Neu'),
(17, 4, '2025-02-27', 'test123424', 'Neu'),
(18, 13, '2025-02-27', 'eretr', 'Neu'),
(19, 13, '2025-02-27', 'testeergaegaqfrgvb', 'Neu'),
(20, 12, '2025-02-27', 'was für ein haus bist du?', 'Neu'),
(21, 6, '2025-02-27', 'strandweg 5 freiburg ist scheiße', 'Neu'),
(22, 16, '2025-02-27', 'ad', 'Neu'),
(23, 5, '2025-02-28', 'Gas ist ausgetreten. Haus ist explodiert', 'Neu');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `nutzer`
--

CREATE TABLE `nutzer` (
  `NutzerID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Telefonnummer` varchar(20) DEFAULT NULL,
  `RolleID` int(11) NOT NULL,
  `Passwort` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `nutzer`
--

INSERT INTO `nutzer` (`NutzerID`, `Name`, `Email`, `Telefonnummer`, `RolleID`, `Passwort`) VALUES
(9, 'Test', 'test@test.de', '01293', 1, 'passwort'),
(10, 'TestNAme', 'testsdae@test.de', '45000', 2, 'passwort'),
(11, 'TestNAme121412', 'testsdae@test.de', '45000', 2, 'passwort'),
(14, 'ConnectionTest', 'connection@test.com', '+4917649825448', 1, '$2y$10$bhVgVKi2vHnSLS7U1Hb2KuMvZsk4zG2c/bQY9yTXZpm55n6xiXkqG'),
(15, 'spast', 'sp@st.te', '+124124', 3, 'qerqwe'),
(16, 'ConnectionTest', 'connection1@test.com', '+4917649825448', 1, '$2y$10$7qR6hIgOiHzfYLTgAPXDgutgPYcjHgGCpDav/k5tlSOxq3p6E.s6S'),
(17, 'abc', 't.est@test.com', '+199519', 2, '$2y$10$Hp8jhkDA//6svwpMAQoc5.08L/EowKy1yfI1L199okI.c9uBSPpbq'),
(18, 'ConnectionTest', 'connection1@test1.com', '+4917649825448', 2, '$2y$10$RxoMVteHpyM01pZ0V3prCukM0ljlJmiTZG4RkTrY.a27cSNJYD3nC'),
(19, 'ConnectionTest', 'connection1@test2.com', '+4917649825448', 2, '$2y$10$1Y4yMWuwO0DInuMb6Jjaj.d2EQWthHC5bp/1mV4bKLPRD6DAtYYS6'),
(20, 'Guest69', 'guest@pw123.com', '+4917649825448', 4, '$2y$10$hQP/ulwRleuMiuuteIf0Uuy0Gtx5gsqK.6jBND.zFngIyTl6Qwihi'),
(21, 'Registered420', 'registered@pw123.com', '+4917649825448', 3, '$2y$10$pgV049aX50Fidt18jbjS1.DechLjDPjr/CveoWkTdx/etksi7dDoe'),
(22, 'Landlord_babo', 'landlord@pw123.com', '+4917649825448', 2, '$2y$10$1sDqb/Iev.ongJxsp75tX.BBlJrDWQzyK4WzpwKBqu8UUBe.yJP6q'),
(23, 'Admin1337', 'admin@pw123.com', '+4917649825448', 1, '$2y$10$Pw/jOBrQ.R74LBrHFVOq9e9/8/DBuly5YqHBF0.mwY2ifZwCTXBRW'),
(25, 'from frontend', 'from.frontend@test.de', NULL, 2, '$2y$10$Qw0GJpq7Cy4KclcjK.Rct.m9FEwBWjsIdKr1IqiBSFn./nsfTX/XW'),
(26, 'TestUserTom', 'Tom.Test@test.com', '+12412412412', 2, '$2y$10$FroE2EHIq8HawBRwuCIy4eZNaIEPqYomr7PjrURTTgKvnjE0PJmr6'),
(27, 'user', 'user2@pw123.com', '+4917649825448', 2, '$2y$10$diqftLUKMjXCqo7vp69UJOKhfKD.fbsECX7D46XyphHF4inJhljsy'),
(37, 'usser', 'userspam5@pw123.com', '+4917649825448', 3, '$2y$10$Lp0g620ffgs83bqLucDfFujHxt.xiuGt2iEzO7mtp7gjYLYQHiLae'),
(38, 'usser', 'userspam4@pw123.com', '+4917649825448', 3, '$2y$10$QnQ4RTJ.tAnsZAsXQl.E5OFU4.VG8AwfXYmonohFR0cGwJdt8XmLy'),
(43, 'guest123', 'guest123@pw123.com', '+4918669322471', 3, '$2y$10$G4jmzcZh18LRhGnW4qHBMu0Zb/5U80PFduWAq6H4gKi0cfoteB.6m'),
(49, 'Tom; DROP TABLES', 'teste123@test.de', '123123123', 3, '$2y$10$rKHlz8xX9EMd/YSMZjDOr.aCbTBl22Af7jYKvwTdL5qGKW2dwKXjq'),
(50, 'Test, test@ergeg.de, 124124, 2, passwort);', 'test@erqewgeg.de', '123123123', 3, '$2y$10$y40eWgcuC/Wzy0u6QsRAvucD2Tbq0tQPtXdWN5eyMGWdwbyEjSx.i');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `ort`
--

CREATE TABLE `ort` (
  `OrtID` int(11) NOT NULL,
  `RegionID` int(11) NOT NULL,
  `OrtName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `ort`
--

INSERT INTO `ort` (`OrtID`, `RegionID`, `OrtName`) VALUES
(1, 1, 'Sylt'),
(2, 2, 'München'),
(3, 3, 'Freiburg'),
(4, 1, 'Sylt'),
(5, 2, 'München'),
(6, 3, 'Freiburg'),
(7, 1, 'Testname'),
(10, 1, 'Testname');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `rechnung`
--

CREATE TABLE `rechnung` (
  `RechnungID` int(11) NOT NULL,
  `Rechnungsdatum` date NOT NULL,
  `Betrag` decimal(10,2) NOT NULL,
  `BuchungID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `rechnung`
--

INSERT INTO `rechnung` (`RechnungID`, `Rechnungsdatum`, `Betrag`, `BuchungID`) VALUES
(1, '2025-01-25', 1350.00, NULL),
(2, '2025-03-01', 1580.00, NULL),
(3, '2025-04-05', 1050.00, NULL),
(4, '2025-02-18', 18470.00, 9),
(6, '2025-02-19', 3800.00, 1),
(9, '2025-02-19', 210.00, 6),
(27, '2025-02-20', 200.00, 36),
(29, '2025-02-20', 120.00, 38),
(30, '2025-02-20', 120.00, 39),
(32, '2025-02-20', 120.00, 41),
(33, '2025-02-20', 120.00, 42),
(34, '2025-02-20', 120.00, 43),
(35, '2025-02-20', 120.00, 44),
(42, '2025-02-25', 2.00, 54),
(43, '2025-02-28', 3285.00, 55),
(44, '2025-02-28', 129.00, 56);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `region`
--

CREATE TABLE `region` (
  `RegionID` int(11) NOT NULL,
  `RegionName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `region`
--

INSERT INTO `region` (`RegionID`, `RegionName`) VALUES
(1, 'Nordsee'),
(2, 'Bayern'),
(3, 'Schwarzwald'),
(4, 'Harz'),
(7, 'Baden Württemberg'),
(8, 'Schwazwald'),
(9, 'Schwa');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `rolle`
--

CREATE TABLE `rolle` (
  `RolleID` int(11) NOT NULL,
  `NameRolle` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `rolle`
--

INSERT INTO `rolle` (`RolleID`, `NameRolle`) VALUES
(1, 'Admin'),
(2, 'Vermieter'),
(3, 'Registriert'),
(4, 'Gast');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `buchung`
--
ALTER TABLE `buchung`
  ADD PRIMARY KEY (`BuchungID`),
  ADD KEY `buchung_ibfk_1` (`NutzerID`),
  ADD KEY `buchung_ibfk_2` (`HausID`);

--
-- Indizes für die Tabelle `buchung_aktivitaet`
--
ALTER TABLE `buchung_aktivitaet`
  ADD PRIMARY KEY (`BuchungAktivitaetID`),
  ADD KEY `buchung_aktivitaet_ibfk_1` (`BuchungID`),
  ADD KEY `buchung_aktivitaet_ibfk_2` (`AktivitaetsID`);

--
-- Indizes für die Tabelle `eigentümer`
--
ALTER TABLE `eigentümer`
  ADD PRIMARY KEY (`EigentümerID`),
  ADD KEY `fk_eigentümer_nutzer` (`nutzerID`);

--
-- Indizes für die Tabelle `freizeitaktivität`
--
ALTER TABLE `freizeitaktivität`
  ADD PRIMARY KEY (`AktivitätsID`),
  ADD KEY `freizeitaktivität_ibfk_2` (`OrtID`);

--
-- Indizes für die Tabelle `haus`
--
ALTER TABLE `haus`
  ADD PRIMARY KEY (`HausID`),
  ADD KEY `fk_ort_haus` (`OrtID`),
  ADD KEY `haus_ibfk_2` (`EigentümerID`);

--
-- Indizes für die Tabelle `mietvertrag`
--
ALTER TABLE `mietvertrag`
  ADD PRIMARY KEY (`VertragID`),
  ADD KEY `fk_buchung` (`BuchungID`);

--
-- Indizes für die Tabelle `mängelanzeige`
--
ALTER TABLE `mängelanzeige`
  ADD PRIMARY KEY (`MangelID`),
  ADD KEY `mängelanzeige_ibfk_2` (`HausID`);

--
-- Indizes für die Tabelle `nutzer`
--
ALTER TABLE `nutzer`
  ADD PRIMARY KEY (`NutzerID`),
  ADD KEY `nutzer_ibfk_1` (`RolleID`);

--
-- Indizes für die Tabelle `ort`
--
ALTER TABLE `ort`
  ADD PRIMARY KEY (`OrtID`),
  ADD KEY `ort_ibfk_1` (`RegionID`);

--
-- Indizes für die Tabelle `rechnung`
--
ALTER TABLE `rechnung`
  ADD PRIMARY KEY (`RechnungID`),
  ADD KEY `fk_rechnung_buchung` (`BuchungID`);

--
-- Indizes für die Tabelle `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`RegionID`);

--
-- Indizes für die Tabelle `rolle`
--
ALTER TABLE `rolle`
  ADD PRIMARY KEY (`RolleID`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `buchung`
--
ALTER TABLE `buchung`
  MODIFY `BuchungID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT für Tabelle `buchung_aktivitaet`
--
ALTER TABLE `buchung_aktivitaet`
  MODIFY `BuchungAktivitaetID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT für Tabelle `eigentümer`
--
ALTER TABLE `eigentümer`
  MODIFY `EigentümerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT für Tabelle `freizeitaktivität`
--
ALTER TABLE `freizeitaktivität`
  MODIFY `AktivitätsID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT für Tabelle `haus`
--
ALTER TABLE `haus`
  MODIFY `HausID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `mietvertrag`
--
ALTER TABLE `mietvertrag`
  MODIFY `VertragID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT für Tabelle `mängelanzeige`
--
ALTER TABLE `mängelanzeige`
  MODIFY `MangelID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT für Tabelle `nutzer`
--
ALTER TABLE `nutzer`
  MODIFY `NutzerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT für Tabelle `ort`
--
ALTER TABLE `ort`
  MODIFY `OrtID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT für Tabelle `rechnung`
--
ALTER TABLE `rechnung`
  MODIFY `RechnungID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT für Tabelle `region`
--
ALTER TABLE `region`
  MODIFY `RegionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT für Tabelle `rolle`
--
ALTER TABLE `rolle`
  MODIFY `RolleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `buchung`
--
ALTER TABLE `buchung`
  ADD CONSTRAINT `buchung_ibfk_1` FOREIGN KEY (`NutzerID`) REFERENCES `nutzer` (`NutzerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `buchung_ibfk_2` FOREIGN KEY (`HausID`) REFERENCES `haus` (`HausID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `buchung_aktivitaet`
--
ALTER TABLE `buchung_aktivitaet`
  ADD CONSTRAINT `buchung_aktivitaet_ibfk_1` FOREIGN KEY (`BuchungID`) REFERENCES `buchung` (`BuchungID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `buchung_aktivitaet_ibfk_2` FOREIGN KEY (`AktivitaetsID`) REFERENCES `freizeitaktivität` (`AktivitätsID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `eigentümer`
--
ALTER TABLE `eigentümer`
  ADD CONSTRAINT `fk_eigentümer_nutzer` FOREIGN KEY (`nutzerID`) REFERENCES `nutzer` (`NutzerID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `freizeitaktivität`
--
ALTER TABLE `freizeitaktivität`
  ADD CONSTRAINT `freizeitaktivität_ibfk_2` FOREIGN KEY (`OrtID`) REFERENCES `ort` (`OrtID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `haus`
--
ALTER TABLE `haus`
  ADD CONSTRAINT `fk_ort_haus` FOREIGN KEY (`OrtID`) REFERENCES `ort` (`OrtID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `haus_ibfk_2` FOREIGN KEY (`EigentümerID`) REFERENCES `eigentümer` (`EigentümerID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `mietvertrag`
--
ALTER TABLE `mietvertrag`
  ADD CONSTRAINT `fk_buchung` FOREIGN KEY (`BuchungID`) REFERENCES `buchung` (`BuchungID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `mängelanzeige`
--
ALTER TABLE `mängelanzeige`
  ADD CONSTRAINT `fk_Haus_maengel` FOREIGN KEY (`HausID`) REFERENCES `haus` (`HausID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mängelanzeige_ibfk_1` FOREIGN KEY (`HausID`) REFERENCES `haus` (`HausID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `mängelanzeige_ibfk_2` FOREIGN KEY (`HausID`) REFERENCES `haus` (`HausID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `nutzer`
--
ALTER TABLE `nutzer`
  ADD CONSTRAINT `nutzer_ibfk_1` FOREIGN KEY (`RolleID`) REFERENCES `rolle` (`RolleID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `ort`
--
ALTER TABLE `ort`
  ADD CONSTRAINT `ort_ibfk_1` FOREIGN KEY (`RegionID`) REFERENCES `region` (`RegionID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `rechnung`
--
ALTER TABLE `rechnung`
  ADD CONSTRAINT `fk_rechnung_buchung` FOREIGN KEY (`BuchungID`) REFERENCES `buchung` (`BuchungID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
