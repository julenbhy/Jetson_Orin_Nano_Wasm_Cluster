#!/usr/bin/env bash
# Configure static IP for Jetson using Netplan and a template

set -e

TEMPLATE_DIR="$(dirname "$0")/templates"
NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

echo "[4/7] Configuring network..."

# Step 1: Install netplan
echo "Installing netplan.io if not present..."
sudo apt-get update
sudo apt-get install -y netplan.io

# Step 2: Show current IP
CURRENT_IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1)
echo "Current IP: $CURRENT_IP"

# Step 3: Ask user for new static IP
read -p "Enter the new static IP to assign (e.g., 192.168.1.100/24): " NEW_IP

# Step 4: Copy template
if [[ ! -f "$TEMPLATE_DIR/netplan_template.yaml" ]]; then
    echo "ERROR: Netplan template not found in $TEMPLATE_DIR"
    exit 1
fi

echo "Copying template to $NETPLAN_FILE"
sudo cp "$TEMPLATE_DIR/netplan_template.yaml" "$NETPLAN_FILE"

# Step 5: Replace placeholder with actual IP
sudo sed -i "s/{{IP_ADDRESS}}/${NEW_IP}/g" "$NETPLAN_FILE"

# Step 6: Apply netplan
echo "→ Applying netplan configuration..."
sudo netplan apply

echo "Network configured successfully with IP: $NEW_IP"
