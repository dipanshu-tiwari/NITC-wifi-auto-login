@echo off
SET BASE_DIR=%USERPROFILE%\.wifi_auto_login
SET LOGINFILE=%BASE_DIR%\login.bat
SET LOGFILE=%BASE_DIR%\logs.txt
SET CREDFILE=%BASE_DIR%\creds.txt

echo ==== Wifi Auto Login Setup ====

REM --- Check for curl ---
where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo curl not found. Installing...

    REM Prefer winget
    where winget >nul 2>nul
    if %errorlevel%==0 (
        winget install --id curl.curl -e --source winget -h
    ) else (
        REM Fallback to choco if available
        where choco >nul 2>nul
        if %errorlevel%==0 (
            choco install curl -y
        ) else (
            echo Neither winget nor chocolatey found. Please install curl manually and re-run setup.
            pause
            exit /b 1
        )
    )
) else (
    echo curl is already installed.
)

REM --- Ask for credentials ---
set /p USERNAME=Enter your user ID: 
set /p PASSWORD=Enter your password: 

REM --- Save credentials ---
mkdir "%BASE_DIR%" 2>nul
echo USERNAME=%USERNAME%> "%CREDFILE%"
echo PASSWORD=%PASSWORD%>> "%CREDFILE%"

REM --- Copy login script ---
copy login.bat "%LOGINFILE%" /Y >nul

REM --- Create log file ---
if not exist "%LOGFILE%" type nul > "%LOGFILE%"

REM --- Add to Task Scheduler ---
schtasks /create /tn "WifiAutoLogin" /tr "\"%LOGINFILE%\"" /sc onlogon /rl highest /f >nul

echo.
echo ==== Setup complete! ====
echo The script will now auto-run every time you log in.
