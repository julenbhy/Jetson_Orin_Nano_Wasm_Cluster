#!/usr/bin/env bash
# Auto-configure /etc/hosts and SSH aliases for Jetson K3s cluster
# Author: cloudlab setup helper

set -e

echo "[*] Configuring local host aliases for Jetson K3s cluster..."

# Step 1: Check for kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    echo "❌ kubectl not found. Please ensure K3s or kubectl is installed."
    exit 1
fi

# Step 2: Retrieve node names and IPs
echo "→ Retrieving node list from cluster..."
NODES=$(kubectl get nodes -o wide --no-headers | awk '{print $1, $6}')

if [[ -z "$NODES" ]]; then
    echo "❌ Could not retrieve node list."
    exit 1
fi

echo "→ Found the following nodes:"
echo "$NODES" | column -t

# Step 3: Update /etc/hosts
HOSTS_BACKUP="/etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"
echo "→ Backing up current /etc/hosts to $HOSTS_BACKUP"
sudo cp /etc/hosts "$HOSTS_BACKUP"

echo "→ Updating /etc/hosts entries..."
TMPFILE=$(mktemp "$HOME/tmp.hosts.XXXXXX")


# Keep all non-jetson lines
sudo grep -vE "jetson-node[0-9]+" /etc/hosts | sudo tee "$TMPFILE" >/dev/null

# Append Jetson entries
while read -r NAME IP; do
    echo "$IP $NAME" | sudo tee -a "$TMPFILE" >/dev/null
done <<< "$(echo "$NODES")"

# Replace hosts file
sudo cp "$TMPFILE" /etc/hosts
sudo rm "$TMPFILE"

echo "✅ /etc/hosts updated successfully."

# Step 4: Update ~/.ssh/config
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"

echo "→ Updating SSH config..."
while read -r NAME IP; do
    echo "Detected $NAME with IP $IP"

    if ! grep -q "Host $NAME" "$SSH_CONFIG"; then
        cat <<EOF >> "$SSH_CONFIG"

Host $NAME
    HostName $IP
    User cloudlab
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF
    else
        # Update IP if already exists
        sed -i "/Host $NAME/{n;s|HostName .*|HostName $IP|}" "$SSH_CONFIG"
    fi
done <<< "$NODES"

chmod 600 "$SSH_CONFIG"
echo "✅ SSH config updated successfully."

# Step 5: Verify connectivity
echo "→ Verifying SSH access..."
while read -r NAME IP; do
    echo -n "   $NAME ($IP): "
    if ssh -o ConnectTimeout=3 "$NAME" "echo ok" 2>/dev/null; then
        echo "✅ reachable"
    else
        echo "⚠️ not reachable"
    fi
done <<< "$(echo "$NODES")"

echo "=============================================="
echo "✅ Host and SSH alias configuration complete!"
echo "You can now SSH into nodes by name, e.g.:"
echo "   ssh jetson-node3"
echo "=============================================="
