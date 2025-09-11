@echo off
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
curl -s -o nul http://www.gstatic.com/generate_204
IF ERRORLEVEL 1 (
    SET TIMESTAMP=%DATE% %TIME%
    echo %TIMESTAMP% (-) Captive portal detected. Attempting login... >> "%LOGFILE%"

    curl -s -X POST "http://172.20.28.1:8002/index.php?zone=hostelzone" ^
         -d "auth_user=%USERNAME%" ^
         -d "auth_pass=%PASSWORD%" ^
         -d "accept=Login" > nul

    echo %TIMESTAMP% (+) Login attempt finished >> "%LOGFILE%"
)

timeout /t 10 /nobreak > nul
goto loop
