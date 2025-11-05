#!/usr/bin/env bash
# Configure Docker with NVIDIA runtime

set -e
echo "[5/7] Configuring Docker with NVIDIA runtime..."

# Ensure docker group exists
sudo groupadd docker || true
sudo usermod -aG docker $USER
newgrp docker

# Paths
DOCKER_DIR="/etc/docker"
DAEMON_FILE="$DOCKER_DIR/daemon.json"
CONFIG_FILE="$(dirname "$0")/config_files/docker_daemon.json"

# Backup original daemon.json if exists
if [[ -f "$DAEMON_FILE" ]]; then
  echo "Backing up existing daemon.json to daemon.json.bak"
  sudo cp "$DAEMON_FILE" "$DAEMON_FILE.bak"
fi

# Ensure /etc/docker exists
sudo mkdir -p "$DOCKER_DIR"

# Copy config
echo "Copying config file docker_daemon.json to $DAEMON_FILE"
sudo cp "$CONFIG_FILE" "$DAEMON_FILE"

sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker configuration done. Verifying NVIDIA Docker setup..."
docker run -it jitteam/devicequery ./deviceQuery

