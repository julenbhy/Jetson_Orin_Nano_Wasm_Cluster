#!/usr/bin/env bash
# Build libtorch v2.4.0 from source for WASI-NN
# Creates a 40GB temporary swapfile to prevent OOM

set -e

SWAPFILE="/mnt/torch_swapfile"
SWAPSIZE="40G"

echo "[7/7] Preparing to build libtorch v2.4.0 (this may take several hours)..."

# Step 1: Create temporary swap
echo "Creating temporary ${SWAPSIZE} swapfile at ${SWAPFILE}..."
sudo fallocate -l ${SWAPSIZE} ${SWAPFILE} || sudo dd if=/dev/zero of=${SWAPFILE} bs=1G count=40
sudo chmod 600 ${SWAPFILE}
sudo mkswap ${SWAPFILE}
sudo swapon ${SWAPFILE}

echo "Temporary swap enabled:"
swapon --show

# Step 2: Build libtorch
cd ~/Downloads

if [[ ! -d pytorch ]]; then
  echo "Cloning PyTorch repository (v2.4.0)..."
  git clone --branch v2.4.0 --recursive https://github.com/pytorch/pytorch.git
else
  echo "PyTorch repo already exists, pulling latest commits for v2.4.0..."
  cd pytorch
  git fetch --all
  git checkout v2.4.0
  git submodule update --init --recursive
fi

cd pytorch
echo "Starting libtorch build..."
python3 tools/build_libtorch.py

echo "libtorch build complete."

# Step 3: Disable and remove temporary swap
echo "Removing temporary swapfile..."
sudo swapoff ${SWAPFILE}
sudo rm -f ${SWAPFILE}

echo "Temporary swap removed."
swapon --show

echo "[6/6] libtorch build finished successfully. System restored."
