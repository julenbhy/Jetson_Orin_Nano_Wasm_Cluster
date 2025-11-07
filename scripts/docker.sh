#!/usr/bin/env bash
# Configure Docker with NVIDIA runtime

set -e
echo "[5/7] Configuring Docker with NVIDIA runtime..."

# Ensure docker group exists
if ! getent group docker >/dev/null; then
  echo "Creating docker group..."
  sudo groupadd docker
else
  echo "Docker group already exists."
fi
sudo usermod -aG docker $USER

# Paths
DOCKER_DIR="/etc/docker"
DAEMON_FILE="$DOCKER_DIR/daemon.json"
CONFIG_FILE="./config_files/docker_daemon.json"

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

echo "Docker configuration done."
#echo "Verifying NVIDIA Docker setup..."
#docker run -it jitteam/devicequery ./deviceQuery # Outdated 

