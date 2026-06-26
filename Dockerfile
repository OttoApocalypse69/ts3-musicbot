# ==============================================================================
# STAGE 1: Build the Application
# ==============================================================================
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /workspace

# Copy gradle configuration files first to cache dependencies
COPY gradle/ /workspace/gradle/
COPY gradlew /workspace/
COPY settings.gradle.kts /workspace/
COPY gradle.properties /workspace/

# Copy the app source code
COPY app/ /workspace/app/

# Build the Shadow JAR (fat JAR containing dependencies)
RUN ./gradlew :app:assemble --no-daemon

# ==============================================================================
# STAGE 2: Secure Production-ready Runtime Environment
# ==============================================================================
FROM ubuntu:22.04

# Prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
# - openjdk-17-jre: Java Runtime Environment
# - openjfx: JavaFX libraries (required by the bot's application launcher)
# - xvfb: Headless X11 server for TeamSpeak and Spotify desktop clients
# - tmux: Terminal multiplexer required by the bot to spawn/manage players
# - dbus & dbus-x11: Messaging system to control players via MPRIS interfaces
# - mpv: Media player for playing YouTube, SoundCloud, and Bandcamp streams
# - curl & wget: File downloading utilities
# - pulseaudio & pulseaudio-utils: Virtual sound routing subsystem
# - libglib2.0-0, libnss3, libegl1, libdbus-1-3, libasound2, libpulse0, libxcursor1, libxcomposite1, libxdamage1, libxrandr2, libxtst6, libxi6, libxkbcommon-x11-0, libxcb-image0, libxcb-keysyms1, libxcb-render-util0, libxcb-xinerama0, libxcb-randr0, libfontconfig1, libfreetype6, libx11-xcb1, libgl1, libxft2: TeamSpeak 3 Client dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre \
    openjfx \
    xvfb \
    tmux \
    dbus \
    dbus-x11 \
    mpv \
    curl \
    wget \
    ca-certificates \
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    libglib2.0-0 \
    libnss3 \
    libegl1 \
    libdbus-1-3 \
    libasound2 \
    libpulse0 \
    libxcursor1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxtst6 \
    libxi6 \
    libxkbcommon-x11-0 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-randr0 \
    libfontconfig1 \
    libfreetype6 \
    libx11-xcb1 \
    libgl1 \
    libxft2 \
    && rm -rf /var/lib/apt/lists/*

# Download and install the latest stable version of yt-dlp
# Placing it in PATH and symlinking it to youtube-dl ensures mpv plays YouTube seamlessly
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+rx /usr/local/bin/yt-dlp \
    && ln -s /usr/local/bin/yt-dlp /usr/local/bin/youtube-dl

# Download and install a pinned stable version of ncspot (lightweight CLI Spotify client)
RUN curl -L https://github.com/hrkfdn/ncspot/releases/download/v1.1.2/ncspot-v1.1.2-linux-x86_64.tar.gz -o ncspot.tar.gz \
    && tar -xzf ncspot.tar.gz -C /usr/local/bin/ \
    && rm ncspot.tar.gz \
    && chmod +x /usr/local/bin/ncspot

# Download and install the official TeamSpeak 3 Client (v3.6.2)
# Bypasses the interactive license agreement pager during the extraction process
RUN curl -L https://files.teamspeak-services.com/releases/client/3.6.2/TeamSpeak3-Client-linux_amd64-3.6.2.run -o ts3client.run \
    && chmod +x ts3client.run \
    && yes y | PAGER=cat ./ts3client.run \
    && mv TeamSpeak3-Client-linux_amd64 /opt/teamspeak3 \
    && rm ts3client.run \
    && ln -s /opt/teamspeak3/ts3client_runscript.sh /usr/local/bin/teamspeak3

# Configure PulseAudio for headless operations (system-wide template)
# Disables hardware audio probes and sets up a software null sink
RUN mkdir -p /etc/pulse \
    && echo 'load-module module-native-protocol-unix' > /etc/pulse/default.pa \
    && echo 'load-module module-default-device-restore' >> /etc/pulse/default.pa \
    && echo 'load-module module-rescue-streams' >> /etc/pulse/default.pa \
    && echo 'load-module module-always-sink' >> /etc/pulse/default.pa \
    && echo 'load-module module-intended-roles' >> /etc/pulse/default.pa \
    && echo 'load-module module-null-sink sink_name=VirtualSink sink_properties=device.description="VirtualSink"' >> /etc/pulse/default.pa \
    && echo 'set-default-sink VirtualSink' >> /etc/pulse/default.pa \
    && echo 'set-default-source VirtualSink.monitor' >> /etc/pulse/default.pa \
    && dbus-uuidgen > /var/lib/dbus/machine-id

# Create a non-root system user for security, and add them to the audio group
RUN useradd -m -s /bin/bash ts3bot \
    && usermod -aG audio,pulse-access ts3bot

# Set up the application directories
WORKDIR /app
COPY --from=builder /workspace/app/build/libs/ts3-musicbot.jar /app/ts3-musicbot.jar
COPY entrypoint.sh /app/entrypoint.sh

# Resolve line endings in case entrypoint.sh was copied from a Windows host (CRLF)
RUN sed -i 's/\r$//' /app/entrypoint.sh \
    && chmod +x /app/entrypoint.sh

# Change ownership of directories to non-root user
RUN chown -R ts3bot:ts3bot /app /opt/teamspeak3 /home/ts3bot

# Expose TeamSpeak ClientQuery default TCP port (internal communication)
EXPOSE 25639

# Run as non-root user
USER ts3bot
WORKDIR /home/ts3bot

# Verify container health (checks if Java application process is alive)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD pgrep -f ts3-musicbot.jar || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]
