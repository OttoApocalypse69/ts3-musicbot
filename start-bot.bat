@echo off
:: ============================================================
:: TS3 MusicBot - Universal Windows Startup Launcher
:: Works on ANY PC regardless of username or folder location.
::
:: Just keep this file inside the ts3-musicbot folder.
:: It will always find the project relative to itself.
::
:: To auto-start on boot:
::   1. Press Win+R, type: shell:startup, press Enter
::   2. Copy this file (or a shortcut to it) into that folder
:: ============================================================

:: Auto-detect the bot folder — always the same folder as this bat file
set "BOT_DIR=%~dp0"
:: Remove trailing backslash if present
if "%BOT_DIR:~-1%"=="\" set "BOT_DIR=%BOT_DIR:~0,-1%"

echo ============================================================
echo  TS3 MusicBot Launcher
echo  Bot folder: %BOT_DIR%
echo ============================================================
echo.

:: --- Check the .env file exists ---
if not exist "%BOT_DIR%\.env" (
    echo ERROR: No .env file found in:
    echo   %BOT_DIR%
    echo.
    echo To fix this, run the setup wizard first:
    echo   1. Open PowerShell in the bot folder
    echo   2. Run: .\setup.ps1
    echo.
    echo Or manually copy the example file:
    echo   Copy-Item .env.example .env
    echo   Then edit .env with your TeamSpeak server details.
    echo.
    pause
    exit /b 1
)

:: --- Wait for Docker Desktop to be fully ready ---
echo Waiting for Docker Desktop to be ready...
set /a DOCKER_WAIT=0
:wait_docker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if errorlevel 1 (
    set /a DOCKER_WAIT+=5
    echo Docker not ready yet ^(waited %DOCKER_WAIT%s^), retrying...
    if %DOCKER_WAIT% geq 120 (
        echo.
        echo ERROR: Docker Desktop did not start within 2 minutes.
        echo Please start Docker Desktop manually and try again.
        pause
        exit /b 1
    )
    goto wait_docker
)
echo Docker is ready.
echo.

:: --- Start the bot ---
echo Starting TS3 MusicBot...
cd /d "%BOT_DIR%"
docker compose up -d ts3-musicbot

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start the bot.
    echo.
    echo Common causes:
    echo   - Docker Desktop is not running
    echo   - The image has never been built ^(run setup.ps1 first^)
    echo   - The .env file has invalid settings
    echo.
    echo Try running this in PowerShell from the bot folder:
    echo   docker compose up -d --build ts3-musicbot
    echo.
    pause
    exit /b 1
) else (
    echo.
    echo TS3 MusicBot started successfully!
    echo To follow the logs, open PowerShell and run:
    echo   docker logs -f ts3-musicbot
    timeout /t 4 /nobreak >nul
)
