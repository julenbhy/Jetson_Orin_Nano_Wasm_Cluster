#!/bin/bash
# System configuration script

set -e
echo "[1/7] Disabling GUI mode... Will take effect after reboot."
#sudo systemctl set-default multi-user.target

echo "[2/7] Setting MAXN_SUPER power mode..."
sudo nvpmodel -m 2
sudo nvpmodel -q # Verify current power mode

echo "[3/7] Updating and upgrading system packages..."
sudo apt-get update
sudo apt-get full-upgrade -y

# Can't disable swap before building libtorch, as it may require more memory
#echo "Disabling swap..."
#sudo swapoff -a
#sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

echo "System configuration done."
