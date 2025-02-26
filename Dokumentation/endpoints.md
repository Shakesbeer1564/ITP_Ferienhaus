# Endpoints

- [Registrierung](#registrierung)
- [Login](#login)
- [Abmelden](#abmelden)
- [Reset Password](#reset-password)
- [Delete User](#delete-user)
- [Suche nach Ferienhaus](#suche-nach-ferienhaus)
- [Suche nach Freizeitaktivität](#suche-nach-freizeitaktivität)
- [Buchung](#buchung)
- [Häuser vergangener Buchungen anzeigen](#häuser-vergangener-buchungen-anzeigen)
- [Mängelbestand melden](#mängelbestand-melden)
- [Haus anbieten](#haus-anbieten)
- [Haus löschen](#haus-löschen)
- [Mängelbestande eines Hauses erhalten](#mängelbestande-eines-hauses-erhalten)
- [Mängelbestand reparieren](#mängelbestand-reparieren)
- [Aktivität anbieten](#aktivität-anbieten)
- [Aktivität löschen](#aktivität-löschen)
- [Rechnungen eines Users erhalten](#rechnungen-eines-users-erhalten)
- [Buchungen eines Users erhalten](#buchungen-eines-users-erhalten)
- [Buchungen eines Hauses erhalten](#buchungen-eines-hauses-erhalten)
- [Kunden erhalten](#kunden-erhalten)

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


## Abmelden

Löscht die aktuelle Session des Users. Das funktioniert auch, wenn der User keine Session hat.

### Method: `POST`

### File: `sign_out.php`

### Body
```JSON
{}
```

### Response
```JSON
{
    "ok": boolean
}
```
---


## Reset Password

Changes the password hash of the user from the session. The given new password is hashed and then written into the database.

### Method: `POST`

### File: `reset_password.php`

### Body
```JSON
{
    "newPassword": "string"
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

`404` Not Found: "User from session not found"

`500` Internal Server Error: "Something went wrong while trying to update the password hash in the database"

---


## Delete User

Deletes the user with the given ID from the database.

### Method: `POST`

### File: `delete_user.php`

### Required Role (backend-handled): `Admin`

### Body
```JSON
{
    "userId": number
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

`403` Forbidden: "Only admins can delete users"

`404` Not Found: "User with the given ID not found"

`500` Internal Server Error: "Something went wrong while trying to delete the user from the database"

---


## Suche nach Ferienhaus

Sucht mit dem gegebenen Query-String Ferienhäuser, die die Mindestanzahl an Räumen und Betten erfüllen und in dem angegebenen Zeitraum frei sind. Dabei werden alle Häuser genommen, dessen Region oder Ort (City) den Query-String beinhalten. 

Alle Parameter müssen vorhanden sein, können aber (ausgenommen 'query') `null` sein. Der Parameter query kann auch ein leerer String (`""`) sein.

### Method: `POST`

### File: `get_houses.php`

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


# Häuser vergangener Buchungen anzeigen

### Method: `GET`

### File: `get_houses_booked_in_past.php`

### Required Role (backend-handled): `Registriert` (or higher)

### Response
```JSON
houses: House[]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "User from session does not have the required permission"

`404` Not Found: "Could not find user in db or its role id is null"

`500` Internal Server Error: "Something went wrong while trying to execute the database query"

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


## Aktivität anbieten

Registrierte Nutzer können Aktivitäten anbieten. Dafür muss Aktivitätsname, Beschreibung, Preis, Teilnehmeranzahl und die ID der Stadt, in der die Aktivität stattfindet angegeben werden. 

### Method: `POST`

### File: `add_activity.php`

### Required Role (backend-handled): `Registriert` (or higher)

### Body
```JSON
{
    "name": "string",
    "description": "string",
    "price": number,
    "participantCount": number,
    "cityId": number
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

`403` Forbidden: "Publishers of activities have to be registered users"

`500` Internal Server Error: "Could not create activity in database"

---


## Aktivität löschen

Löscht die Aktivität mit der gegebenen ID. Der User muss dafür Admin sein.

### Method: `POST`

### File: `delete_activity.php`

### Required Role (backend-handled): `Admin`

### Body
```JSON
{
    "activityId": number
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

`403` Forbidden: "Only admins can delete activities"

`404` Not Found: "No activity with that id exists"

`500` Internal Server Error: "Could not delete activity from database"

---


## Rechnungen eines Users erhalten

Gibt die Rechnungen des Users, dessen Email gegeben wird, zurück. Wird keine Mail angegeben, wird die aus der Session verwendet.

Werden die Rechnungen eines anderen Users angefragt, muss die Rolle Admin sein.

### Method: `POST`

### File: `get_invoices.php`

### Required Role (backend-handled): `Registriert` (or higher)

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

`403` Forbidden: "The requesting user has to be at least registered"

`403` Forbidden: "The user does not have the required permission"

`404` Not Found: "There is no user with the given mail"

`404` Not Found: "There is no user with the given ID"

`500` Internal Server Error:  "Something went wrong trying to retrieve the invoices of a user from the database"

---


## Buchungen eines Users erhalten

Gibt die Buchungen des Users, dessen Email gegeben wird, zurück. Wird keine Mail angegeben, wird die aus der Session verwendet.

Werden die Buchungen eines anderen Users angefragt, muss die Rolle Admin sein.

### Method: `POST`

### File: `get_users_bookings.php`

### Required Role (backend-handled): `Registriert` (or higher)

### Body
```JSON
{
    "userEmail": "string" | null
}   
```

### Response
```JSON
bookings: Booking[]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "the requesting user has to be at least registered"

`403` Forbidden: "The user does not have the required permission"

`404` Not Found: "There is no user with the given mail"

`403` Forbidden: "Insufficient permission to show bookings of this user"

`404` Not Found: "User with ID not found in the database"

`500` Internal Server Error:  "Something went wrong trying to retrieve the bookings of a user from the database"

---

## Buchungen eines Hauses erhalten

Gibt die Buchungen des Hauses, dessen ID gegeben wird, zurück.

Der anfragende User muss dafür entweder der Eigentümer des Hauses sein oder die Rolle Admin haben.

### Method: `POST`

### File: `get_users_bookings.php`

### Required Role (backend-handled): `Vermieter` (or higher)

### Body
```JSON
{
    "houseId": "string"
}   
```

### Response
```JSON
bookings: Booking[]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "The requesting user has to be a landlord or an admin"

`403` Forbidden: "The user does not have the required permission"

`404` Not Found: "There is no user with the given mail"

`403` Forbidden: "Insufficient permission"

`500` Internal Server Error:  "Something went wrong trying to retrieve the bookings of a home from the database"

---


# Kunden erhalten

Gibt alle Kunden zurück.

### Method: `GET`

### File: `get_customers.php`

### Required Role (backend-handled): `Admin`

### Response
```JSON
customers:
[
    {
        "NutzerID": number,
        "Name": "string",
        "Email": "string",
        "Telefonnummer": "string",
        "RolleID": number,
        "Passwort": "string",
        "NameRolle": "string"
    }
]
```

### Errors
`401` Unauthorized: "No session"

`403` Forbidden: "Only admins can see all users"

`500` Internal Server Error:  "Something went wrong trying to retrieve the users from the database"

---


---
---
# TODO: Fehlende Endpoints für Vermieter und für Admin hinzufügen