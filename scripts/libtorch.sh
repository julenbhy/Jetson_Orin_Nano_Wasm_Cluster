# libtorch.sh
#!/bin/bash
# Build libtorch v2.4.0 for WASI-NN and move to /opt

set -e

# Directory for temporary build
BUILD_DIR=$(mktemp -d)
INSTALL_DIR="/opt/pytorch-v2.4.0"

echo "Building libtorch v2.4.0 in temporary directory: $BUILD_DIR"

echo "Installing dependencies..."
sudo apt-get install -y cmake python3-dev python3-pip git build-essential

echo "Cloning PyTorch v2.4.0..."
git clone --branch v2.4.0 --recursive https://github.com/pytorch/pytorch.git "$BUILD_DIR/pytorch"
cd "$BUILD_DIR/pytorch"

echo "Building libtorch..."
python3 tools/build_libtorch.py

echo "Moving libtorch to $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo mv "$BUILD_DIR/pytorch"/* "$INSTALL_DIR"

echo "Setting permissions..."
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"

echo "Libtorch build finished and installed at $INSTALL_DIR."
echo "Reminder: if /include is missing, copy it from the official release."
