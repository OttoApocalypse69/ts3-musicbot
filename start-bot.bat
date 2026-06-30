@echo off
:: ============================================================
:: TS3 MusicBot - Windows Startup Launcher
:: Place this file in your Windows Startup folder to have the
:: bot start automatically when Windows boots.
::
:: Startup folder location (paste in Run dialog / Win+R):
::   shell:startup
:: ============================================================

:: Change this to the actual path of your ts3-musicbot folder
set "BOT_DIR=C:\Users\hmiku3\Desktop\ts3-musicbot"

:: --- Wait for Docker Desktop to be fully ready ---
echo Waiting for Docker Desktop to be ready...
:wait_docker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker not ready yet, retrying...
    goto wait_docker
)
echo Docker is ready.

:: --- Start the bot ---
echo Starting TS3 MusicBot...
cd /d "%BOT_DIR%"
docker compose up -d ts3-musicbot

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start the bot. Check that Docker is running
    echo and that the BOT_DIR path in this script is correct.
    echo BOT_DIR is currently set to: %BOT_DIR%
    pause
) else (
    echo.
    echo TS3 MusicBot started successfully!
    echo Use "docker logs -f ts3-musicbot" to view logs.
    timeout /t 3 /nobreak >nul
)
