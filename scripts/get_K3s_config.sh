TOKEN_FILE="/var/lib/rancher/k3s/server/node-token"
if sudo [ -f "$TOKEN_FILE" ]; then
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