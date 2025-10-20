# system.sh
#!/bin/bash
# System configuration script

echo "Disabling GUI mode..."
sudo systemctl set-default multi-user.target

echo "Setting MAXN_SUPER power mode..."
sudo nvpmodel -m 2
sudo nvpmodel -q # Verify current power mode

echo "Updating system packages..."
sudo apt-get update
sudo apt-get dist-upgrade -y

# Can't disable swap before building libtorch, as it may require more memory
#echo "Disabling swap..."
#sudo swapoff -a
#sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab

echo "System configuration done."
