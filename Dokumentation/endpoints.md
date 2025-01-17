# Endpoints

Hier werden die Endpoints des Backends dokumentiert. Für jeden endpoint wird der HTTP Methoden Typ angegeben, die Datei des endpoints, der benötigte Request Body und die zu erwartende Response. 

## Registrierung

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


## Anmeldedaten verifizieren

### Method: `POST`

### File: `check_credentials.php`

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