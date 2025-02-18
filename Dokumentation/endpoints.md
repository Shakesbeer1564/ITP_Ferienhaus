# Endpoints

Hier werden die Endpoints des Backends dokumentiert. Für jeden endpoint wird der HTTP Methoden Typ angegeben, die Datei des endpoints, der benötigte Request Body und die zu erwartende Response. 

## Registrierung

Erstellt den User in der DB und erstellt eine Session mit einem Cookie.

### Method: `POST`

### File: `register.php`

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

Prüft die Anmeldedaten und erstellt eine Session.

### Method: `POST`

### File: `login.php`

### Body: 
```JSON
{
    "username": "string",
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


## Suche nach Region

Sucht nach Regionen mit dem gegebenen Query-string und gibt diese zurück.

TODO procedure not implemented

### Method: `GET`

### File: `get_regions.php`

### Parameter: `"query": string`

### Response:
```JSON
regions: Region[]
```
---


## Suche nach Ort

Sucht nach Orten mit dem gegebenen Query-string und gibt diese zurück.

TODO procedure not implemented

### Method: `GET`

### File: `get_orte.php`

### Parameter: `"query": string`

### Response:
```JSON
orte: Ort[]
```
---


## Häuser von einem Ort bekommen

Gibt die Häuser zurück, die die gegebene OrtId haben.

### Method: `GET`

### File: `get_houses_by_ort.php`

### Parameter: `OrtId: number`

### Response:
```JSON
häuser: Haus[]
```
---


## Häuser aus einer Region bekommen

Gibt die Häuser zurück, die die gegebene RegionId haben.

### Method: `GET`

### File: `get_houses_by_region.php`

### Parameter: `RegionId: number`

### Response:
```JSON
häuser: Haus[]
```
---