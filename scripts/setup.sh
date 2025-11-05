#!/usr/bin/env bash
# Main setup script for Jetson Orin Nano WASM Cluster
# Run this script as root or with sudo privileges

set -e

echo "=============================================="
echo "   Jetson Orin Nano - WASM Cluster Setup"
echo "=============================================="

SCRIPTS_DIR="$(dirname "$0")"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "Step 1: System configuration"
bash "$SCRIPTS_DIR/system.sh"

echo "Step 2: Network configuration"
bash "$SCRIPTS_DIR/network.sh"

echo "Step 3: Docker configuration"
bash "$SCRIPTS_DIR/docker.sh"

echo "Step 4: Configure Kubernetes (K3s)"
bash "$SCRIPTS_DIR/Kubernetes.sh"

#echo "Step 5: Build libtorch for WASI-NN"
#bash "$SCRIPTS_DIR/libtorch.sh"



# Can't disable swap before building libtorch, as it may require more memory
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

echo "=== Setup complete! Rebooting recommended ==="
