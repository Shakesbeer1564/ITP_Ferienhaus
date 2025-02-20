# Endpoints

Hier werden die Endpoints des Backends dokumentiert. Für jeden endpoint wird der HTTP Methoden Typ angegeben, die Datei des endpoints, der benötigte Request Body und die zu erwartende Response.

Jeder Endpoint, der sich mit der Datenbank verbindet, gibt einen Error `500 Internal Server Error` - "Could not connect to database: " mit der Exception-Nachricht zurück, wenn die Verbindung zur Datenbank fehl schlägt. Tritt ein unerwarteter Fehler auf, gibt der Server eine Response mit Status Code `500 Internal Server Error` und dem Fehler als HTML zurück.

## Registrierung

Erstellt den User in der DB und erstellt eine Session mit einem Cookie.

Durch den Session-Cookie kann der Nutzer im Backend identifiziert werden.

Wenn die Email nicht gültig ist oder sie schon in Verwendung, wird ein Fehler zurückgegeben und keine Session erstellt.

### Method: `POST`

### File: `register.php`

### Required Role (backend-handled): `Gast`

### Body: 
```JSON
{
    "username": "string",
    "email": "string",
    "phone": "string",
    "password": "string"
}
```
### Response:
```JSON
{
    "ok": boolean
}
```

### Errors
`409` Conflict: "Mail is already taken"

`400` Bad Request: "Invalid mail address"

`500` Internal Server Error: "Something went wrong while trying to execute the database query"

---


## Login

Prüft die gegebenen Anmeldedaten und erstellt eine Session mit einem Cookie.

Durch den Session-Cookie kann der Nutzer im Backend identifiziert werden.

Sind die Anmeldedaten invalide, wird keine Session erstellt und ein Fehler zurückgegeben.

### Method: `POST`

### File: `login.php`

### Required Role (backend-handled): `Gast`

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

### Errors
`401` Unauthorized: "Invalid credentials"

---


## Suche nach Ferienhaus

Sucht mit dem gegebenen Query-String Ferienhäuser, die die Mindestanzahl an Räumen und Betten erfüllen und in dem angegebenen Zeitraum frei sind. Dabei werden alle Häuser genommen, dessen Region oder Ort (City) den Query-String beinhalten. 

### Method: `POST`

### File: `get_houses.php`

### Required Role (backend-handled): `Gast`

### Body
```JSON
{
    "query": "string",
    "roomCount": number,
    "bedCount": number,
    "startDate": Date,
    "endDate": Date
}
```

### Response:
```JSON
houses: House[]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "Role from session, therefore the user, has insuficient permission"

---


## Suche nach Freizeitaktivität

Sucht mit dem gegebenen Query-String Freizeitaktivitäten. Dabei werden alle Aktivitäten genommen, die den Query-String im Namen enthalten oder dessen Ort (City) den Query-String beinhaltet. 

### Method: `POST`

### File: `get_activities.php`

### Required Role (backend-handled): `Gast`

### Body
```JSON
{
    "query": "string"
}
```

### Response:
```JSON
activities: Activity[]
```
---


## Buchung

Erstellt eine Buchung in der Datenbank für das Haus mit der gegebenen ID in dem gegebenen Zeitraum (Start- und Enddatum) mit den Aktivitäten, deren IDs gegeben wurden.

Es können auch nur Aktivitäten gebucht werden. Somit sind ID des Hauses und Zeitraum optional. 

Der Nutzer wird aus der Session genommen.
Der Preis wird aus der Dauer und dem pro Nacht Preises des Hauses errechnet.

### Method: `POST`

### File: `book_house.php`

### Required Role (backend-handled): `Registriert`

### Body
```JSON
{
    "houseId": number | null,
    "startDate": Date | null,
    "endDate": Date | null,
    "activities": number[] // the IDs of the selected activities
}
```

### Response
```JSON
{
    "ok": boolean
}
```

### Errors
`401` Unauthorized: "No session"

`401` Unauthorized: "Session invalid: User does not exist"

---


## Mängelbestand melden

Speichert einen Mängelbestand für das Haus mit der gegebenen ID mit einer Beschreibung. Außerdem wird das Meldedatum gespeichert.

### Method: `POST`

### File: `create_complaint.php`

### Required Role (backend-handled): `Registriert`

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

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "User from session does not have the required permission"

`500` Internal Server Error: "Something went wrong while trying to execute the database query"

---


---
---
# TODO: Fehlende Endpoints für Vermieter und für Admin hinzufügen