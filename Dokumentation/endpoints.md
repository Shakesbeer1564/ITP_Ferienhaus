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