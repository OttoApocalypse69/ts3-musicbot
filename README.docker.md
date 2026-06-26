# TS3 Music Bot Docker Guide & Tutorial

This guide provides a comprehensive tutorial on deploying the TS3 Music Bot using Docker. By utilizing containerization, you can run the bot headlessly on any platform (including Windows hosts, Linux servers, and macOS) without manually installing complex dependencies such as PulseAudio virtual soundcards, Xvfb, Java, or the TeamSpeak client.

---

## Prerequisites

Before setting up, ensure you have the following installed on your host system:
1. **Docker Desktop** (for Windows or macOS) or **Docker Engine** (for Linux).
2. **Docker Compose** (included in Docker Desktop; available separately for Linux).

---

## How It Works Under the Hood

The container operates in a fully isolated sandbox using the following architecture:
- **Audio Routing:** PulseAudio runs inside the container and creates a software-based `VirtualSink` (null-device). All audio outputs (`mpv` for YouTube/SoundCloud, `ncspot` for Spotify) are directed to it, and its monitoring source is routed directly into the TeamSpeak 3 Client microphone input.
- **Headless GUI Display:** An X Virtual Framebuffer (`xvfb-run`) runs in the background. It simulates a monitor, which is required because the official TeamSpeak 3 Client is a GUI application.
- **D-Bus Session:** The `entrypoint.sh` script launches a D-Bus session. This session handles MPRIS communication protocols, allowing the bot to interactively control players like `ncspot` and `mpv` (play, pause, track query) via system D-Bus.

---

## Step-by-Step Setup Tutorial

### Option A: Windows Users (Automated Script)

1. Open **PowerShell** as an Administrator.
2. Navigate to the project root directory.
3. Execute the automated setup script:
   ```powershell
   ./setup.ps1
   ```
4. Follow the interactive prompts to enter your TeamSpeak server address, target channel, and bot nickname.
5. Once the build completes, boot the container with:
   ```powershell
   docker-compose up -d
   ```

---

### Option B: Manual Setup (All Platforms - Windows, Linux, macOS)

#### 1. Configure the Environment
Create your custom environment configuration file from the template:
```bash
cp .env.example .env
```
Open `.env` in a text editor and fill in your connection variables:
```env
# Connection info
TS3_SERVER_ADDRESS=your.ts3server.com
TS3_NICKNAME=MusicBot
TS3_CHANNEL_NAME=Music Channel
TS3_ACCEPT_TS_LICENSE=true

# Spotify settings (Optional - requires Premium)
TS3_SPOTIFY_PLAYER=ncspot
TS3_SPOTIFY_USERNAME=your_username
TS3_SPOTIFY_PASSWORD=your_password
```

#### 2. Build the Docker Image
You can use the provided build script or run Docker directly:
* **Using build.sh:**
  ```bash
  chmod +x build.sh
  ./build.sh --docker
  ```
* **Using Docker directly:**
  ```bash
  docker build -t ts3-musicbot:latest .
  ```

#### 3. Run the Container
Launch the containerized application in background (detached) mode:
```bash
docker-compose up -d
```

---

## Control & Monitoring Commands

Use the following commands to manage the container:

* **View Logs:** Keep track of connection processes or check for startup errors:
  ```bash
  docker logs -f ts3-musicbot
  ```
* **Stop the Bot:** Terminate and clear the containers:
  ```bash
  docker-compose down
  ```
* **Restart the Bot:** Apply environment changes without rebuilding:
  ```bash
  docker-compose restart
  ```
* **Rebuild the Container:** Necessary if you modified the application source code:
  ```bash
  docker-compose up -d --build
  ```

---

## Spotify & YouTube Integration Details

### 1. Spotify Integration (`ncspot`)
To use Spotify playback, you must have a **Spotify Premium** account.
- In your `.env` file, configure `TS3_SPOTIFY_PLAYER=ncspot`.
- Provide your `TS3_SPOTIFY_USERNAME` and `TS3_SPOTIFY_PASSWORD`.
- *Note:* Upon first connection, the bot will automatically generate the config for `ncspot` and cache the session credentials inside the mounted volume. This persists your login details on subsequent restarts.

### 2. YouTube, SoundCloud, & Bandcamp Integration (`mpv`)
Streaming from these websites uses `mpv` backed by the latest `yt-dlp` extractor.
- To prevent API quota errors or HTTP 403 blocks from YouTube, you can supply your own YouTube API Key under `TS3_YT_API_KEY` in the `.env` file.

---

## Troubleshooting Guide

### 1. The Bot connects but plays no audio
- **Root Cause:** PulseAudio virtual sink routing might have lagged on boot.
- **Fix:** Connect to the TeamSpeak channel and check if the bot is muted. You can restart the audio sub-daemon by running:
  ```bash
  docker-compose restart
  ```

### 2. EULA Elicitation Fails
- **Root Cause:** If `TS3_ACCEPT_TS_LICENSE` is set to `false`, the bot will pause expecting interactive terminal input.
- **Fix:** Ensure you set `TS3_ACCEPT_TS_LICENSE=true` in your `.env` file before running the container.

### 3. Permissions/WSL2 issues on Windows
- **Root Cause:** WSL2 directory sharing permissions.
- **Fix:** Ensure Docker Desktop has permission to access the project folder and that Linux file paths are converted cleanly (handled automatically by `sed` in the Dockerfile).
