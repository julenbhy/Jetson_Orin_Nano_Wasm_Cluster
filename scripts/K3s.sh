#!/usr/bin/env bash
# Kubernetes (K3s) setup for Jetson Orin Nano WASM Cluster

set -e

echo "[5/7] Configuring Kubernetes (K3s)..."

# Step 1: Ask node role
read -p "Is this node the master (control-plane)? [y/n]: " IS_MASTER

if [[ "$IS_MASTER" == "y" || "$IS_MASTER" == "Y" ]]; then
    echo "→ Setting up MASTER node..."

    # Step 2: Ensure .kube directory exists
    mkdir -p $HOME/.kube

    # Step 3: Install K3s as master node using Docker
    echo "→ Installing K3s server..."
    curl -sfL https://get.k3s.io | sh -

    # Step 4: Copy config file and adjust perms
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config

    # Step 5: Retrieve join token for workers
    TOKEN_FILE="/var/lib/rancher/k3s/server/node-token"
    if [[ -f "$TOKEN_FILE" ]]; then
        NODE_TOKEN=$(sudo cat "$TOKEN_FILE")
        MASTER_IP=$(hostname -I | awk '{print $1}')
        echo "=============================================="
        echo " K3s Master Setup Complete!"
        echo " Use this token and IP to join worker nodes:"
        echo "----------------------------------------------"
        echo " MASTER IP:   $MASTER_IP"
        echo " NODE TOKEN:  $NODE_TOKEN"
        echo "----------------------------------------------"
        echo " Example (on worker):"
        echo " curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$NODE_TOKEN sh -"
        echo "=============================================="
    else
        echo "ERROR: Could not find K3s node token!"
        exit 1
    fi

else
    echo "→ Setting up WORKER node..."
    read -p "Enter MASTER node IP (e.g., 192.168.1.100): " MASTER_IP
    read -p "Enter the NODE TOKEN from the master: " NODE_TOKEN

    # Step 2: Install K3s as worker
    echo "→ Installing K3s agent..."
    curl -sfL https://get.k3s.io | K3S_URL="https://$MASTER_IP:6443" K3S_TOKEN="$NODE_TOKEN" INSTALL_K3S_EXEC="--docker" sh -

    echo "→ Waiting for K3s agent to start..."
    sleep 10
    systemctl status k3s-agent.service --no-pager || true

    echo "=============================================="
    echo " K3s Worker Setup Complete!"
    echo " Joined cluster at: https://$MASTER_IP:6443"
    echo "=============================================="
fi

echo "→ Kubernetes (K3s) configuration finished successfully."

