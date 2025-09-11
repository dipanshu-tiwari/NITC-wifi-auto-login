@echo off
SET BASE_DIR=%USERPROFILE%\.wifi_auto_login
SET LOGINFILE=%BASE_DIR%\login.bat
SET LOGFILE=%BASE_DIR%\logs.txt
SET CREDFILE=%BASE_DIR%\creds.txt

echo ==== Wifi Auto Login Uninstall ====

REM --- Remove scheduled task ---
schtasks /delete /tn "WifiAutoLogin" /f >nul 2>&1
if %errorlevel%==0 (
    echo Removed scheduled task: WifiAutoLogin
) else (
    echo No scheduled task found.
)

REM --- Remove files ---
if exist "%LOGINFILE%" del "%LOGINFILE%"
if exist "%LOGFILE%" del "%LOGFILE%"
if exist "%CREDFILE%" del "%CREDFILE%"

REM --- Remove base directory if empty ---
if exist "%BASE_DIR%" (
    rd "%BASE_DIR%" 2>nul
)

echo Uninstall complete!
pause
