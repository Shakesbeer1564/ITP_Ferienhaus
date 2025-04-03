-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 03. Apr 2025 um 08:04
-- Server-Version: 10.4.28-MariaDB
-- PHP-Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `ferienhausverwaltung`
--
CREATE DATABASE IF NOT EXISTS `ferienhausverwaltung` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `ferienhausverwaltung`;

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
        IF NOT EXISTS (SELECT 1 FROM haus WHERE p_HausID = HausID ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Haus existiert nicht.';
        END IF;

        SET p_Naechte = GREATEST(DATEDIFF(p_EndDatum, p_StartDatum), 1);
        SELECT COALESCE(Preis, 0) INTO p_HausPreis FROM haus WHERE p_HausID = HausID;

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
	
    -- Ausgabe der Buchung mit der oben generierten BuchungsID
		SELECT buchungID FROM buchung WHERE p_buchungID = buchungID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreatePDF` (IN `p_bookingID` INT, IN `p_userID` INT)   BEGIN
SELECT * from buchung where p_buchungID = buchungID;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActivityById` (IN `p_ID` INT)   BEGIN
SELECT name FROM freizeitaktivität WHERE p_ID = AktivitätsID;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBookingDetails` (IN `p_buchungid` INT)   BEGIN
    SELECT 
        b.buchungid,
        r.betrag as Rechnungsbetrag,
        h.adresse as Adresse,
        h.beschreibung AS Beschreibung,
        a.beschreibung AS Aktivitaets_Beschreibung
    FROM buchung b
    JOIN rechnung r ON b.buchungid = r.buchungid
    JOIN haus h ON b.hausID = h.hausID  -- Falls es eine andere Beziehung gibt, anpassen!
    LEFT JOIN buchung_aktivitaet ab ON b.buchungid = ab.buchungid
    LEFT JOIN freizeitaktivität a ON ab.aktivitaetsID = a.aktivitätsID
    WHERE b.buchungid = p_buchungid;
    
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getLandlordIDfromUserID` (IN `p_nutzerID` INT)   SELECT EigentümerID as EigentuemerID FROM eigentümer 
    Where nutzerID = p_nutzerID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getLandlordNameFromID` (IN `p_ID` INT)   BEGIN
	SELECT EigentümerName as EigentuemerName FROM eigentümer WHERE p_ID = eigentümerID;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserNameByID` (IN `p_ID` INT)   BEGIN
SELECT name from nutzer WHERe p_ID = NutzerID;
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
    SELECT DISTINCT fa.AktivitätsID as AktivitaetsID, fa.*
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
    SELECT 
    HausID,
    Adresse,
    AnzahlZimmer,
    AnzahlBetten,
    Beschreibung,
    eigentümerID as EigentuemerId,
    OrtID, 
    Preis
    
    
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maengelanzeige existiert nicht.';
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nicht autorisiert: Nur der Eigentümer dieses Hauses oder ein Admin kann die Maengelanzeige aktualisieren.';
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

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `buchung_aktivitaet`
--

CREATE TABLE `buchung_aktivitaet` (
  `BuchungAktivitaetID` int(11) NOT NULL,
  `BuchungID` int(11) NOT NULL,
  `AktivitaetsID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 'Max Mustermann', 'Adresse 1, Testhausen', 9),
(2, 'Anna Schmidt', '', 22),
(3, 'Lukas Meyer', '', 16),
(4, 'Sophie Bauer', '', NULL),
(5, 'Felix Wagner', '', 26),
(6, 'Laura Becker', '', NULL),
(7, 'Jonas Weber', '', NULL),
(8, 'Mia Schulz', '', NULL),
(9, 'Tim Hoffmann', '', NULL),
(10, 'Clara Neumann', '', NULL),
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
(1, 'Surfen', 'Surfkurs für Anfänger', 50.00, 10, 1),
(2, 'Kitesurfen', 'Erlebnis am Strand', 70.00, 8, 2),
(3, 'Wandern', 'Geführte Tour durch die Berge', 30.00, 15, 3),
(4, 'Skifahren', 'Tageskarte für die Piste', 80.00, 20, 4),
(5, 'Bootstour', 'Tagesausflug mit dem Boot', 60.00, 12, 5),
(6, 'Kanu fahren', 'Abenteuer auf dem Fluss', 40.00, 10, 6),
(7, 'Stadtführung', 'Historische Sehenswürdigkeiten', 25.00, 20, 7),
(8, 'Escape Room', 'Lösen Sie das Rätsel', 35.00, 6, 8),
(9, 'Weinverkostung', 'Regionale Weine entdecken', 45.00, 10, 9),
(10, 'Theaterbesuch', 'Aufführung im Stadttheater', 50.00, 15, 10);

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
(1, 'Hauptstraße 1', 3, 5, 'Modernes Ferienhaus mit Meerblick', 1, 1, 120),
(2, 'Hauptstraße 2', 2, 4, 'Kleines gemütliches Haus', 1, 1, 100),
(3, 'Seestraße 3', 4, 6, 'Luxusvilla am Strand', 2, 2, 250),
(4, 'Seestraße 4', 3, 5, 'Ferienhaus mit Garten', 2, 2, 130),
(5, 'Altstadt 5', 2, 4, 'Stilvolles Apartment', 3, 3, 90),
(6, 'Altstadt 6', 3, 6, 'Großes Stadthaus', 3, 3, 150),
(7, 'Bergstraße 7', 3, 5, 'Berghütte mit Kamin', 4, 4, 140),
(8, 'Bergstraße 8', 2, 3, 'Rustikales Chalet', 4, 4, 110),
(9, 'Schwarzwaldstraße 9', 4, 7, 'Luxuriöse Lodge', 5, 5, 200),
(10, 'Schwarzwaldstraße 10', 3, 5, 'Ferienhaus im Grünen', 5, 5, 120),
(11, 'Seeweg 11', 2, 4, 'Apartment mit Seeblick', 6, 6, 95),
(12, 'Seeweg 12', 3, 5, 'Modernes Loft', 6, 6, 130),
(13, 'Elbstraße 13', 4, 6, 'Penthouse mit Dachterrasse', 7, 7, 180),
(14, 'Elbstraße 14', 3, 5, 'Charmantes Stadthaus', 7, 7, 140),
(15, 'Markt 15', 3, 6, 'Elegantes Apartment', 8, 8, 160),
(16, 'Markt 16', 2, 4, 'Gemütliche Ferienwohnung', 8, 8, 100),
(17, 'Domplatz 17', 4, 7, 'Villa mit Pool', 9, 9, 220),
(18, 'Domplatz 18', 3, 5, 'Klassisches Landhaus', 9, 9, 150),
(19, 'Goetheplatz 19', 2, 4, 'Altbauwohnung', 10, 10, 90),
(20, 'Goetheplatz 20', 3, 5, 'Stilvolle Ferienwohnung', 10, 10, 120);

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
(50, 'Test, test@ergeg.de, 124124, 2, passwort);', 'test@erqewgeg.de', '123123123', 3, '$2y$10$y40eWgcuC/Wzy0u6QsRAvucD2Tbq0tQPtXdWN5eyMGWdwbyEjSx.i'),
(51, 'testcase1', 'testcase1.pw@testcase1.com', '+1234562341', 3, '$2y$10$o3GM/oGF/4YhO/6ScUOXjOyk5HDk2n88Lk3Jjx32kV8rWVJHY4N4G'),
(52, 'user', 'user@pw123.com', '+32435678', 3, '$2y$10$GGb.AVTbSOgMcHy6hQFzpe2adJo8ZgrD5NETbhKe.a/9coFHoySwG'),
(53, 'registered123', 'registered-1@pw123.com', '+4918669322471', 3, '$2y$10$rTjPGzbcK1vJZIE7L8hT7OdodXVr4ogPeHcuoWrEhZOFmIxbeDWHC'),
(54, 'dasfg', 'dda.add@pw123.com', '+12345612345', 3, '$2y$10$tSSdFDxOoaoHXrumB0ZAcunrPm8P/niFfw8XbUbwnKcA.ldJwGW2y');

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
(1, 1, 'Insel Sylt'),
(2, 1, 'Cuxhaven'),
(3, 2, 'München'),
(4, 2, 'Garmisch-Partenkirchen'),
(5, 3, 'Freiburg'),
(6, 3, 'Titisee-Neustadt'),
(7, 4, 'Dresden'),
(8, 4, 'Leipzig'),
(9, 5, 'Erfurt'),
(10, 5, 'Weimar');

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
(3, '2025-04-05', 1050.00, NULL);

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
(4, 'Sachsen'),
(5, 'Thüringen');

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
  ADD KEY `haus_ibfk_2` (`EigentümerID`),
  ADD KEY `HausID` (`HausID`);

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
  ADD KEY `nutzer_ibfk_1` (`RolleID`),
  ADD KEY `NutzerID` (`NutzerID`);

--
-- Indizes für die Tabelle `ort`
--
ALTER TABLE `ort`
  ADD PRIMARY KEY (`OrtID`),
  ADD KEY `ort_ibfk_1` (`RegionID`),
  ADD KEY `OrtID` (`OrtID`);

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
  ADD PRIMARY KEY (`RolleID`),
  ADD KEY `RolleID` (`RolleID`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `buchung`
--
ALTER TABLE `buchung`
  MODIFY `BuchungID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=165;

--
-- AUTO_INCREMENT für Tabelle `buchung_aktivitaet`
--
ALTER TABLE `buchung_aktivitaet`
  MODIFY `BuchungAktivitaetID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT für Tabelle `eigentümer`
--
ALTER TABLE `eigentümer`
  MODIFY `EigentümerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `freizeitaktivität`
--
ALTER TABLE `freizeitaktivität`
  MODIFY `AktivitätsID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT für Tabelle `haus`
--
ALTER TABLE `haus`
  MODIFY `HausID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT für Tabelle `mietvertrag`
--
ALTER TABLE `mietvertrag`
  MODIFY `VertragID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT für Tabelle `mängelanzeige`
--
ALTER TABLE `mängelanzeige`
  MODIFY `MangelID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT für Tabelle `nutzer`
--
ALTER TABLE `nutzer`
  MODIFY `NutzerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT für Tabelle `ort`
--
ALTER TABLE `ort`
  MODIFY `OrtID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT für Tabelle `rechnung`
--
ALTER TABLE `rechnung`
  MODIFY `RechnungID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

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
