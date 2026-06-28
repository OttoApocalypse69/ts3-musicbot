# ==============================================================================
# TS3 Music Bot Docker Automated Setup Script for Windows
# ==============================================================================

$ErrorActionPreference = "Stop"
$checkmark = [char]0x2714

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    TS3 Music Bot - Automated Docker Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check if Docker is installed and running
Write-Host "[1/4] Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerCheck = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCheck) {
        Write-Host "Docker command-line tool not found." -ForegroundColor Yellow
        $installChoice = Read-Host "Would you like to install Docker Desktop automatically via Windows Package Manager (winget)? (Y/N)"
        if ($installChoice -eq 'Y' -or $installChoice -eq 'y') {
            Write-Host "Starting Docker Desktop installation via winget..." -ForegroundColor Gray
            # Run winget install (may trigger UAC prompt)
            Start-Process winget -ArgumentList "install --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
            Write-Host "$checkmark Installation command completed. Please launch Docker Desktop from your Start menu and restart this script." -ForegroundColor Green
            Exit 0
        } else {
            Write-Error "Docker command-line tool not found. Please install Docker Desktop for Windows: https://www.docker.com/products/docker-desktop"
        }
    }
    
    # Check if Docker daemon is running
    $dockerInfo = docker info --format '{{.Name}}' 2>$null
    if ($LastExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($dockerInfo)) {
        Write-Host "Docker is installed but the Docker daemon is not running." -ForegroundColor Yellow
        $startChoice = Read-Host "Would you like to start Docker Desktop automatically? (Y/N)"
        if ($startChoice -eq 'Y' -or $startChoice -eq 'y') {
            $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
            if (Test-Path $dockerPath) {
                Write-Host "Launching Docker Desktop..." -ForegroundColor Gray
                Start-Process $dockerPath
                Write-Host "Waiting for Docker daemon to start (this may take up to a minute)..." -ForegroundColor Gray
                $daemonStarted = $false
                for ($i = 1; $i -le 30; $i++) {
                    Start-Sleep -Seconds 2
                    $dockerInfo = docker info --format '{{.Name}}' 2>$null
                    if ($LastExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($dockerInfo)) {
                        $daemonStarted = $true
                        break
                    }
                }
                if (-not $daemonStarted) {
                    Write-Error "Docker daemon failed to start in time. Please open Docker Desktop manually."
                }
            } else {
                Write-Error "Docker Desktop executable not found at '$dockerPath'. Please start it manually."
            }
        } else {
            Write-Error "Docker Desktop is not running. Please start Docker Desktop and try again."
        }
    }
    Write-Host "$checkmark Docker is installed and running." -ForegroundColor Green
}
catch {
    Write-Host "Error checking Docker: $_" -ForegroundColor Red
    Exit 1
}

# 2. Setup the .env file
Write-Host "`n[2/4] Configuring environment variables..." -ForegroundColor Yellow
$envFile = Join-Path $PSScriptRoot ".env"
$envTemplateFile = Join-Path $PSScriptRoot ".env.example"

if (-not (Test-Path $envTemplateFile)) {
    Write-Error "Missing template environment file: .env.example"
}

if (-not (Test-Path $envFile)) {
    Write-Host "Creating '.env' file from '.env.example'..." -ForegroundColor Gray
    Copy-Item $envTemplateFile $envFile
    
    # Prompt the user for basic configurations to get started quickly
    Write-Host "`n--- Quick Configuration ---" -ForegroundColor Cyan
    $server = Read-Host "Enter TeamSpeak Server Address (e.g., ts.example.com)"
    $nickname = Read-Host "Enter Bot Nickname [MusicBot]"
    $channel = Read-Host "Enter Target Channel Name"
    
    if ([string]::IsNullOrWhiteSpace($nickname)) { $nickname = "MusicBot" }
    
    # Replace the values in the .env file
    $envContent = Get-Content $envFile
    $envContent = $envContent -replace 'TS3_SERVER_ADDRESS=.*', "TS3_SERVER_ADDRESS=$server"
    $envContent = $envContent -replace 'TS3_NICKNAME=.*', "TS3_NICKNAME=$nickname"
    $envContent = $envContent -replace 'TS3_CHANNEL_NAME=.*', "TS3_CHANNEL_NAME=$channel"
    $envContent | Set-Content $envFile
    
    Write-Host "$checkmark .env file initialized with your quick settings." -ForegroundColor Green
} else {
    Write-Host "$checkmark Existing '.env' file detected. Skipping quick config. (Modify manually if needed)" -ForegroundColor Green
}

# 3. Build the Docker Image
Write-Host "`n[3/4] Building TS3 Music Bot Docker image..." -ForegroundColor Yellow
Write-Host "This compiles the Kotlin code and downloads dependencies in an isolated container. Please wait..." -ForegroundColor Gray

try {
    # Run the docker compose build, falling back to docker-compose if needed
    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        docker-compose build
    } else {
        docker compose build
    }
    if ($LastExitCode -ne 0) {
        throw "Docker build failed with exit code $LastExitCode."
    }
    Write-Host "$checkmark Docker image built successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error building Docker image: $_" -ForegroundColor Red
    Write-Host "Ensure your internet connection is active and Docker has enough resources." -ForegroundColor Red
    Exit 1
}

# 4. Instructions for startup
Write-Host "`n[4/4] Setup complete!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "To apply changes and launch your bot, run:" -ForegroundColor White
Write-Host "  docker compose down" -ForegroundColor Yellow
Write-Host "  docker compose up -d" -ForegroundColor Green
Write-Host ""
Write-Host "To monitor execution logs, run:" -ForegroundColor White
Write-Host "  docker logs -f ts3-musicbot" -ForegroundColor Green
Write-Host ""
Write-Host "To stop the bot, run:" -ForegroundColor White
Write-Host "  docker compose down" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
