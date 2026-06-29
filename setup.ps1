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

function Get-EnvValue {
    param(
        [string[]]$Lines,
        [string]$Key,
        [string]$DefaultValue = ""
    )

    $pattern = "^\s*#?\s*" + [regex]::Escape($Key) + "\s*=(.*)$"
    foreach ($line in $Lines) {
        if ($line -match $pattern) {
            return $Matches[1].Trim()
        }
    }
    return $DefaultValue
}

function Set-EnvValue {
    param(
        [string[]]$Lines,
        [string]$Key,
        [string]$Value
    )

    $pattern = "^\s*#?\s*" + [regex]::Escape($Key) + "\s*="
    $result = New-Object System.Collections.Generic.List[string]
    $found = $false

    foreach ($line in $Lines) {
        if ($line -match $pattern) {
            $result.Add("$Key=$Value")
            $found = $true
        } else {
            $result.Add($line)
        }
    }

    if (-not $found) {
        $result.Add("$Key=$Value")
    }

    return $result.ToArray()
}

function Read-ConfigValue {
    param(
        [string]$Prompt,
        [string]$CurrentValue
    )

    $displayValue = $CurrentValue
    if ([string]::IsNullOrWhiteSpace($displayValue)) {
        $displayValue = "<blank>"
    }

    $value = Read-Host "$Prompt [$displayValue]"
    if ($value -eq "") {
        return $CurrentValue
    }

    return $value.Trim()
}

function Convert-SecureStringToPlainText {
    param([System.Security.SecureString]$SecureString)

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function Read-SecretValue {
    param(
        [string]$Prompt,
        [string]$CurrentValue
    )

    $displayValue = "<blank>"
    if (-not [string]::IsNullOrWhiteSpace($CurrentValue)) {
        $displayValue = "configured, press Enter to keep or type clear to remove"
    }

    $secureValue = Read-Host "$Prompt [$displayValue]" -AsSecureString
    $value = Convert-SecureStringToPlainText $secureValue

    if ($value -eq "") {
        return $CurrentValue
    }
    if ($value -ieq "clear") {
        return ""
    }

    return $value
}

function Split-ServerAddress {
    param(
        [string]$ServerInput,
        [string]$FallbackPort
    )

    $serverAddress = ""
    if (-not [string]::IsNullOrWhiteSpace($ServerInput)) {
        $serverAddress = $ServerInput.Trim()
    }

    $serverPort = "9987"
    if (-not [string]::IsNullOrWhiteSpace($FallbackPort)) {
        $serverPort = $FallbackPort.Trim()
    }

    if ($serverAddress -match "^\[(.+)\]:(\d+)$") {
        $serverAddress = $Matches[1]
        $serverPort = $Matches[2]
    } elseif ($serverAddress -match "^([^:]+):(\d+)$") {
        $serverAddress = $Matches[1]
        $serverPort = $Matches[2]
    }

    return @{
        Address = $serverAddress
        Port = $serverPort
    }
}

$createdEnvFile = $false
if (-not (Test-Path $envFile)) {
    Write-Host "Creating '.env' file from '.env.example'..." -ForegroundColor Gray
    Copy-Item $envTemplateFile $envFile
    $createdEnvFile = $true
}

$runSetupWizard = $createdEnvFile
if (-not $createdEnvFile) {
    Write-Host "$checkmark Existing '.env' file detected." -ForegroundColor Green
    $setupChoice = Read-Host "Update bot nickname, server address, passwords, and channel now? (Y/n)"
    $runSetupWizard = [string]::IsNullOrWhiteSpace($setupChoice) -or $setupChoice -eq "Y" -or $setupChoice -eq "y"
}

if ($runSetupWizard) {
    $envContent = @(Get-Content $envFile)

    $existingNickname = Get-EnvValue $envContent "TS3_NICKNAME" "MusicBot"
    $existingServerAddress = Get-EnvValue $envContent "TS3_SERVER_ADDRESS" "your.teamspeak-server.com"
    $existingServerPort = Get-EnvValue $envContent "TS3_SERVER_PORT" "9987"
    $existingServerPassword = Get-EnvValue $envContent "TS3_SERVER_PASSWORD" ""
    $existingChannelName = Get-EnvValue $envContent "TS3_CHANNEL_NAME" "Music Channel"
    $existingChannelPassword = Get-EnvValue $envContent "TS3_CHANNEL_PASSWORD" ""

    Write-Host "`n--- TeamSpeak Bot Setup ---" -ForegroundColor Cyan
    Write-Host "Press Enter to keep the value shown in brackets. Leave passwords blank if your server/channel has no password." -ForegroundColor Gray
    Write-Host "You can enter a server as host:port, for example viscous-salmon.gl.at.ply.gg:53645." -ForegroundColor Gray

    $nickname = Read-ConfigValue "Bot nickname" $existingNickname
    $serverPromptDefault = $existingServerAddress
    if (-not [string]::IsNullOrWhiteSpace($existingServerPort)) {
        $serverPromptDefault = "$existingServerAddress`:$existingServerPort"
    }
    $serverInput = Read-ConfigValue "TeamSpeak server address" $serverPromptDefault
    $serverParts = Split-ServerAddress $serverInput $existingServerPort
    $serverAddress = $serverParts.Address
    $serverPort = Read-ConfigValue "TeamSpeak server port" $serverParts.Port
    $serverPassword = Read-SecretValue "TeamSpeak server password" $existingServerPassword
    $channelName = Read-ConfigValue "TeamSpeak channel name" $existingChannelName
    $channelPassword = Read-SecretValue "TeamSpeak channel password" $existingChannelPassword

    $envContent = Set-EnvValue $envContent "TS3_NICKNAME" $nickname
    $envContent = Set-EnvValue $envContent "TS3_SERVER_ADDRESS" $serverAddress
    $envContent = Set-EnvValue $envContent "TS3_SERVER_PORT" $serverPort
    $envContent = Set-EnvValue $envContent "TS3_SERVER_PASSWORD" $serverPassword
    $envContent = Set-EnvValue $envContent "TS3_CHANNEL_NAME" $channelName
    $envContent = Set-EnvValue $envContent "TS3_CHANNEL_PASSWORD" $channelPassword
    $envContent = Set-EnvValue $envContent "TS3_ACCEPT_TS_LICENSE" "true"
    $envContent = Set-EnvValue $envContent "TS3_USE_OFFICIAL_TSCLIENT" "true"
    $envContent = Set-EnvValue $envContent "TS3_SPOTIFY_PLAYER" "disabled"
    $envContent = Set-EnvValue $envContent "TS3_COMMAND_PREFIX" "!"

    $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllLines($envFile, [string[]]$envContent, $utf8NoBom)

    if ([string]::IsNullOrWhiteSpace($serverAddress) -or $serverAddress -eq "your.teamspeak-server.com") {
        Write-Host "Warning: TS3_SERVER_ADDRESS still looks like a placeholder. Edit .env before starting the bot." -ForegroundColor Yellow
    }

    Write-Host "$checkmark .env file saved with your TeamSpeak setup." -ForegroundColor Green
} else {
    Write-Host "$checkmark Keeping existing '.env' settings." -ForegroundColor Green
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
