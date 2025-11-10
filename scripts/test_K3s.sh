#!/usr/bin/env bash
# Kubernetes (K3s) cluster test for Jetson Orin Nano WASM Cluster
# Deploys a DaemonSet from ./config_files/daemonset-test.yaml to validate all worker nodes.

set -e

echo "[6/7] Testing Kubernetes (K3s) cluster across all worker nodes..."

# Step 1: Ensure kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl not found. Ensure K3s or kubectl is installed and in PATH."
    exit 1
fi

# Step 2: Verify kubeconfig
if [ ! -f "$HOME/.kube/config" ]; then
    echo "ERROR: No kubeconfig found in ~/.kube/config."
    echo "→ Copy it from master node: scp user@master:~/.kube/config ~/.kube/config"
    exit 1
fi

echo "→ Using kubeconfig at: $HOME/.kube/config"

# Step 3: Check cluster info
echo "→ Checking cluster info..."
kubectl cluster-info || {
    echo "ERROR: Could not connect to cluster. Verify that K3s services are running."
    exit 1
}

# Step 4: List cluster nodes
echo "→ Listing cluster nodes..."
kubectl get nodes -o wide

# Step 5: Deploy the DaemonSet
TEST_NAMESPACE="cluster-test"
TEST_FILE="./config_files/K3s_daemonset_test.yaml"

if [ ! -f "$TEST_FILE" ]; then
    echo "ERROR: YAML file not found at $TEST_FILE"
    exit 1
fi

echo "→ Creating namespace '$TEST_NAMESPACE'..."
kubectl create namespace $TEST_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "→ Applying DaemonSet from $TEST_FILE..."
kubectl apply -n $TEST_NAMESPACE -f "$TEST_FILE"

# Step 6: Wait for DaemonSet pods to be ready
echo "→ Waiting for all DaemonSet pods to become Ready..."
for i in {1..10}; do
    READY=$(kubectl get daemonset nginx-test -n $TEST_NAMESPACE -o jsonpath='{.status.numberReady}' 2>/dev/null || echo "0")
    DESIRED=$(kubectl get daemonset nginx-test -n $TEST_NAMESPACE -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null || echo "0")
    if [[ "$READY" == "$DESIRED" && "$READY" != "0" ]]; then
        echo "✅ All $READY/$DESIRED pods are Ready!"
        break
    fi
    echo "   Waiting... ($i/10) - Ready: $READY/$DESIRED"
    sleep 3
done

if [[ "$READY" != "$DESIRED" || "$READY" == "0" ]]; then
    echo "❌ Some pods failed to start correctly."
    kubectl describe daemonset nginx-test -n $TEST_NAMESPACE
    kubectl get pods -n $TEST_NAMESPACE -o wide
    exit 1
fi

# Step 7: Display pod details
echo "→ DaemonSet pod status:"
kubectl get pods -n $TEST_NAMESPACE -o wide

# Step 8: Test nginx inside all pods
echo "→ Testing nginx response inside all pods..."
for POD in $(kubectl get pod -n $TEST_NAMESPACE -o name); do
    echo "   Checking $POD ..."
    kubectl exec -n $TEST_NAMESPACE $POD -- wget -qO- localhost:80 | grep -q "Welcome to nginx" \
      && echo "   ✅ $POD: Nginx OK" \
      || echo "   ⚠️ $POD: Nginx FAILED"
done


# Step 9: Cleanup
read -p "Do you want to delete the DaemonSet and namespace? [Y/n]: " CLEAN
if [[ "$CLEAN" != "n" && "$CLEAN" != "N" ]]; then
    echo "→ Cleaning up test resources..."
    kubectl delete namespace $TEST_NAMESPACE
    echo "✅ Cleanup complete."
else
    echo "→ Keeping test DaemonSet for inspection."
fi

echo "=============================================="
echo " K3s Cluster Test Completed Successfully!"
echo " Verified all worker nodes."
echo "=============================================="
