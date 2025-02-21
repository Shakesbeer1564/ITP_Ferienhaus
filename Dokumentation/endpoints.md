# Endpoints

Hier werden die Endpoints des Backends dokumentiert. Für jeden endpoint wird der HTTP Methoden Typ angegeben, die Datei des endpoints, der benötigte Request Body und die zu erwartende Response.

Jeder Endpoint, der sich mit der Datenbank verbindet, gibt einen Error `500 Internal Server Error` - "Could not connect to database: " mit der Exception-Nachricht zurück, wenn die Verbindung zur Datenbank fehl schlägt. Tritt ein unerwarteter Fehler auf, gibt der Server eine Response mit Status Code `500 Internal Server Error` und dem Fehler als HTML zurück.

## Registrierung

Erstellt den User in der DB und erstellt eine Session mit einem Cookie.

Durch den Session-Cookie kann der Nutzer im Backend identifiziert werden.

Wenn die Email nicht gültig ist oder sie schon in Verwendung, wird ein Fehler zurückgegeben und keine Session erstellt.

### Method: `POST`

### File: `register.php`

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

### Required Role (backend-handled): `Gast` (or higher)

### Body
```JSON
{
    "query": "string",
    "roomCount": number | null,
    "bedCount": number | null,
    "startDate": Date | null,
    "endDate": Date | null
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

### Required Role (backend-handled): `Gast` (or higher)

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

### Required Role (backend-handled): `Registriert` (or higher)

### Body
```JSON
{
    "houseId": number | null,
    "startDate": Date | null,
    "endDate": Date | null,
    "activityIds": number[]
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

`403` Forbidden: "Only registered users can book houses"

---


## Mängelbestand melden

Speichert einen Mängelbestand für das Haus mit der gegebenen ID mit einer Beschreibung. Außerdem wird das Meldedatum gespeichert.

### Method: `POST`

### File: `create_complaint.php`

### Required Role (backend-handled): `Registriert` (or higher)

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


## Haus anbieten 

Nutzer mit der Rolle Vermieter können Häuser anbieten. Dafür muss Adresse, Raumanzahl, Bettenanzahl, eine Beschreibung, die ID der Stadt, in der das Haus steht und der pro Nacht Preis angegeben werden. 

### Method: `POST`

### File: `add_house.php`

### Required Role (backend-handled): `Vermieter` (or higher)

### Body
```JSON
{
    "address": "string",
    "roomCount": number,
    "bedCount": number,
    "description": "string",
    "cityId": number,
    "price": number
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

`404` Not Found: "Could not find the house with the given ID"

`500` Internal Server Error: "Could not create vacation home in database"

---


## Haus löschen

Löscht das Haus mit der gegebenen ID. Dafür muss der User aus der Session der Eigentümer des Hauses oder ein Admin sein.

### Method: `POST`

### File: `delete_house.php`

### Required Role (backend-handled): `Vermieter` (or higher)

### Body
```JSON
{
    "houseId": number
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

`404` Not Found: "No house with that id exists"

`403` Forbidden: "Only the landlord and admins can delete homes"

`500` Internal Server Error: "Could not delete vacation home from database"

---


## Mängelbestand reparieren

Setzt den Status eines Mängelbestands. Valide Werte sind 'Neu', 'In Bearbeitung' und 'Gelöst'.

### Method: `POST`

### File: `repair_complaint.php`

### Required Role (backend-handled): `Vermieter` (or higher)

### Body
```JSON
{
    "complaintId": number,
    "repairStatus": "string" // one of these: 'Neu', 'In Bearbeitung', 'Gelöst'
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

`403` Forbidden: "Only landlords can update complaints"

`404` Not Found: "There is no complaint with the given ID"

`403` Forbidden: "Only the landlord of the house of the complaint can resolve the complaint"

`500` Internal Server Error: "Something went wrong while trying to update the complaint in the database"

---


## Mängelbestande eines Hauses erhalten

Gibt die Mängelbestande des Hauses mit der gegebenen ID zurück. Dafür muss der Nutzer Besitzer des Hauses oder Admin sein.

### Method: `POST`

### File: `get_complaints.php`

### Required Role (backend-handled): `Vermieter` (or higher)

### Body
```JSON
{
    "houseId": "string"
}   
```

### Response
```JSON
complaints: Complaint[]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "The user does not have the required permission"

`404` Not Found: "There is no complaint with the given ID"

`403` Forbidden: "Insufficient permission to see the complaints"

`500` Internal Server Error: "Something went wrong trying to retrieve the complaints from the database"

---


## Rechnungen eines Users erhalten

Gibt die Rechnungen des Users, dessen Email gegeben wird, zurück. Wird keine Mail angegeben, wird die aus der Session verwendet.

Werden die Rechnungen eines anderen Users angefragt, muss die Rolle Admin sein.

### Method: `POST`

### File: `get_invoices.php`

### Required Role (backend-handled): `Registered` (or higher)

### Body
```JSON
{
    "userEmail": "string" | null
}   
```

### Response
```JSON
invoices: Invoice[]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "The requesting has to be at least registered"

`403` Forbidden: "The user does not have the required permission"

`404` Not Found: "There is no user with the given mail"

`404` Not Found: "There is no user with the given ID"

`500` Internal Server Error:  "Something went wrong trying to retrieve the invoices of a user from the database"

---


---
---
# TODO: Fehlende Endpoints für Vermieter und für Admin hinzufügen