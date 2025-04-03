@echo off
set MYSQL_USER=root
set MYSQL_HOST=localhost
set DATABASE_NAME=Ferienhausverwaltung

echo Erstelle die Datenbank...
C:\xampp\mysql\bin\mysql.exe -u %MYSQL_USER% -h %MYSQL_HOST% < db_create.sql

echo Fertig!
pause
