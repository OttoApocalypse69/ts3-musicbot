#!/bin/sh
set -e

# ==============================================================================
# TS3 Music Bot Build Automation Script
# Automates the building of the Java JAR package locally, or compiles and wraps
# it in a production-ready Docker container.
# ==============================================================================

# Check if docker build is requested
DOCKER_BUILD=0
for arg in "$@"; do
  if [ "$arg" = "--docker" ] || [ "$arg" = "docker" ]; then
    DOCKER_BUILD=1
    break
  fi
done

if [ "$DOCKER_BUILD" -eq 1 ]; then
  echo "=================================================="
  echo "Building TS3 Music Bot Docker Container..."
  echo "=================================================="
  # Build the container image. The multi-stage Dockerfile handles compilation.
  docker build -t ts3-musicbot:latest .
  echo ""
  echo "Docker build completed successfully!"
  echo "To start the bot, run: docker-compose up -d"
  echo "=================================================="
else
  echo "=================================================="
  echo "Building TS3 Music Bot JAR locally..."
  echo "=================================================="
  
  # Ensure the output directory for artifacts exists
  mkdir -p out/artifacts/ts3_musicbot
  
  # Clean other arguments and build the JAR using gradlew wrapper
  # Passes remaining arguments directly to Gradle (e.g. --no-daemon)
  ./gradlew assemble "$@"
  
  echo "Copying ts3-musicbot.jar to out/artifacts/ts3_musicbot/"
  cp app/build/libs/ts3-musicbot.jar out/artifacts/ts3_musicbot/.
  
  echo "Done. Local build complete!"
  echo "Artifact location: out/artifacts/ts3_musicbot/ts3-musicbot.jar"
  echo "=================================================="
fi
