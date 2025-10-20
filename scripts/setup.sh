# setup.sh
#!/bin/bash
# Main setup script for Jetson Orin Nano WASM cluster

set -e

echo "=== Starting Jetson Orin Nano setup ==="

echo "Step 1: System configuration"
bash ./system.sh

echo "Step 2: Docker configuration"
bash ./docker.sh

echo "Step 3: Build libtorch for WASI-NN"
bash ./libtorch.sh

# Can't disable swap before building libtorch, as it may require more memory
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

echo "=== Setup complete! Rebooting recommended ==="
