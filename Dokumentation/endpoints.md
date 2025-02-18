# Endpoints

Hier werden die Endpoints des Backends dokumentiert. Für jeden endpoint wird der HTTP Methoden Typ angegeben, die Datei des endpoints, der benötigte Request Body und die zu erwartende Response. 

## Registrierung

Erstellt den User in der DB und erstellt eine Session mit einem Cookie.

Durch den Session-Cookie kann der Nutzer im Backend identifiziert werden.

Wenn die Email nicht gültig ist oder sie schon in Verwendung, wird ein Fehler zurückgegeben und keine Session erstellt.

### Method: `POST`

### File: `register.php`

### Required Role: `Gast`

### Body: 
```JSON
{
    "username": "string",
    "password": "string",
    "email": "string"
}
```
### Response:
```JSON
{
    "ok": boolean
}
```
---


## Login

Prüft die gegebenen Anmeldedaten und erstellt eine Session mit einem Cookie.

Durch den Session-Cookie kann der Nutzer im Backend identifiziert werden.

Sind die Anmeldedaten invalide, wird keine Session erstellt und ein Fehler zurückgegeben.

### Method: `POST`

### File: `login.php`

### Required Role: `Gast`

### Body: 
```JSON
{
    "email": "string",
    "password": "string"
}
```

### Response:
```JSON
{
    "isValid": boolean
}
```
---


## Suche nach Ferienhaus

Sucht mit dem gegebenen Query-String Ferienhäuser. Dabei werden alle Häuser genommen, dessen Region oder Ort (City) den Query-String beinhalten. 

### Method: `GET`

### File: `get_houses.php`

### Required Role: `Gast`

### Parameter: `"query": string`

### Response:
```JSON
houses: House[]
```
---


## Suche nach Freizeitaktivität

Sucht mit dem gegebenen Query-String Freizeitaktivitäten. Dabei werden alle Aktivitäten genommen, dessen Ort (City) den Query-String beinhaltet. 

### Method: `GET`

### File: `get_activities.php`

### Required Role: `Gast`

### Parameter: `"query": string`

### Response:
```JSON
activities: Activity[]
```
---


## Buchung Ferienhaus

Erstellt eine Buchung in der Datenbank für das Haus mit der gegebenen ID in dem gegebenen Zeitraum (Start- und Enddatum).

Der Nutzer wird aus der Session genommen.
Der Preis wird aus der Dauer und dem pro Nacht Preises des Hauses errechnet.

### Method: `POST`

### File: `book_house.php`

### Required Role: `Registriert`

### Body
```JSON
{
    "houseId": number,
    "startDate": Date,
    "endDate": Date
}
```

### Response
```JSON
{
    "ok": boolean
}
```
---


## Buchung Aktivität
TODO Beschreibung hinzufügen
---


## Mängelbestand melden

Speichert einen Mängelbestand für das Haus mit der gegebenen ID mit einer Beschreibung. Außerdem wird das Meldedatum gespeichert.

### Method: `POST`

### File: TODO not implemented

### Required Role: `Registriert`

### Body
```JSON
{
    "houseId": number,
    "description": "string"
}
```

### Response
```JSON
{
    "ok": boolean
}
```
---



# TODO: Fehlende Endpoints für Vermieter und für Admin hinzufügen