#!/bin/bash
# System configuration script

set -e

CURRENT_NAME=$(hostnamectl --static)
echo "Current hostname: $CURRENT_NAME"
read -p "Enter new device name (e.g., jetson-node1): " DEVICE_NAME

if [ -n "$DEVICE_NAME" ]; then
    echo "Setting hostname to '$DEVICE_NAME'..."
    sudo hostnamectl set-hostname "$DEVICE_NAME"

    # Update /etc/hosts if necessary
    if ! grep -q "$DEVICE_NAME" /etc/hosts; then
        echo "127.0.1.1    $DEVICE_NAME" | sudo tee -a /etc/hosts > /dev/null
    fi
else
    echo "Keeping current hostname: $CURRENT_NAME"
fi


echo "[1/4] Disabling GUI mode... Will take effect after reboot."
sudo systemctl set-default multi-user.target

echo "[2/4] Setting MAXN_SUPER power mode..."
sudo nvpmodel -m 2
sudo nvpmodel -q # Verify current power mode

echo "[3/4] Updating and upgrading system packages..."
sudo apt-get update
sudo apt-get full-upgrade -y

echo "[4/4] Installing jtop..."
sudo pip3 install -U jetson-stats

# Can't disable swap before building libtorch, as it may require more memory
echo "[4/4] Disabling swap..."
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

echo "System configuration done"
