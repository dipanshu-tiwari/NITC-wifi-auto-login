@echo off
setlocal EnableDelayedExpansion

SET BASE_DIR=%USERPROFILE%\.wifi_auto_login
SET CREDFILE=%BASE_DIR%\creds.txt
SET LOGFILE=%BASE_DIR%\logs.txt

REM Check if creds file exists
IF NOT EXIST "%CREDFILE%" (
    echo Credentials file not found at %CREDFILE%
    pause
    exit /b
)

REM Load credentials
FOR /F "tokens=1,2 delims==" %%A IN (%CREDFILE%) DO (
    IF "%%A"=="USERNAME" SET USERNAME=%%B
    IF "%%A"=="PASSWORD" SET PASSWORD=%%B
)

:loop
REM Check internet connection
for /f %%a in ('curl -s -o nul -w "%%{http_code}" http://www.gstatic.com/generate_204') do set "HTTP_CODE=%%a"

set "is_portal=0"
if "!HTTP_CODE!" EQU "200" set "is_portal=1"
if "!HTTP_CODE!" EQU "302" set "is_portal=1"

IF "!is_portal!" EQU "1" (
    SET TIMESTAMP=!DATE! !TIME!
    echo "!TIMESTAMP! (-) Captive portal detected. Attempting login..." >> "%LOGFILE%"

    curl -s -X POST "http://172.20.28.1:8002/index.php?zone=hostelzone" -d "auth_user=%USERNAME%" -d "auth_pass=%PASSWORD%" -d "accept=Login" > nul

    echo "!TIMESTAMP! (+) Login attempt finished" >> "%LOGFILE%"
)

timeout /t 10 /nobreak > nul
goto loop
