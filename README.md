# Jetson Orin Nano WASM Cluster

This project demonstrates how to build and configure a cluster of **Jetson Orin Nano 8GB** boards to run **WebAssembly (WASM)** workloads with **WASI** and GPU acceleration.

---

## Overview

The goal is to set up a small, efficient GPU-enabled cluster capable of running lightweight WebAssembly modules (via WASI or WASI-NN) on ARM64 hardware. This setup is ideal for experimentation with distributed AI inference, edge computing, or embedded GPU-based WASM runtimes.

---

## Hardware Requirements

| Component | Quantity | Notes |
|------------|-----------|-------|
| Jetson Orin Nano 8GB | 5 | Each node in the cluster |
| NVMe SSD 1TB (Gen 3) | 5 | Fast local storage for models and data |
| Gigabit Ethernet Switch | 1 | At least 6 ports with full non-blocking switching |
| Ethernet Cables (Cat 5e or higher) | 5 | Must support 1 Gbps |
| Linux PC | 1 | Used to flash Jetsons using SDK Manager |

---

## Flashing the Jetson System

### Step 1: Install SDK Manager

Install the [NVIDIA JetPack SDK Manager](https://developer.nvidia.com/sdk-manager) on your Linux PC.

### Step 2: Flash Each Jetson Individually

For each board:

1. Install the NVMe drive in the Jetson.
2. Connect the Jetson to your Linux PC using a USB-C cable.
3. While connecting the power supply, **short the “FC REC” and “GND” pins** to boot into recovery mode.
4. Open **SDK Manager**, select your Jetson model, and flash JetPack (uncheck the *Host Machine* option).
5. Set a username and password (you may reuse the same credentials for all devices for convenience).
6. Once flashing completes, reboot the Jetson and connect a monitor and peripherals if needed.

**Reference:** [Jetson Initial Setup (SDK Manager)](https://www.jetson-ai-lab.com/initial_setup_jon_sdkm.html)

---

## System Configuration

Follow this steps **on each Jetson** after the first boot:

### 1. Disable GUI Mode
```bash
sudo systemctl set-default multi-user.target
sudo reboot
```

### 2. Enable MAXN_SUPER Power Mode
```bash
sudo nvpmodel -m 2
sudo nvpmodel -q  # Verify power mode
```

### 3. Update the System
```bash
sudo apt-get update
sudo apt-get dist-upgrade -y
```

### 4. Install jtop for system monitoring
```bash
sudo -H pip install -U jetson-stats
```

### 4. Disable Swap
```bash
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab
```

### 5. Configure Docker for NVIDIA Runtime

Add your user to the Docker group:
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

Edit `/etc/docker/daemon.json`:
```json
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

**Reference:** [Building a GPU-Enabled Kubernetes Cluster on Jetson Nano](https://medium.com/jit-team/building-a-gpu-enabled-kubernets-cluster-for-machine-learning-with-nvidia-jetson-nano-7b67de74172a)

---

## Installing libtorch for WASI-NN

JetPack ships with a preinstalled version of PyTorch, but **WASI-NN currently supports only `libtorch v2.4.0`**. Therefore, you’ll need to build it manually.

### Build Instructions
```bash
cd ~/Downloads
git clone --branch v2.4.0 --recursive https://github.com/pytorch/pytorch.git
cd pytorch
python3 tools/build_libtorch.py
```

> **Note:** The build process requires around **30 GB of RAM or swap**. If the `/include` directory isn’t properly generated, copy it manually from the official release package.

## Install PyTorch (optional)

Follow this tutorial: https://ninjalabo.ai/blogs/jetson_pytorch.html

---

## Future Work

- Automate node provisioning and clustering using Ansible or Kubernetes.
- Deploy and benchmark WASM runtimes such as **Wasmtime**, **Wasmer**, or **WasmEdge**.
- Experiment with **WASI-NN + libtorch** integration for GPU-accelerated inference.
- Evaluate distributed model execution and scheduling across the Jetson cluster.

---

## Documentation & References

- [Jetson Initial Setup (SDK Manager Method)](https://www.jetson-ai-lab.com/initial_setup_jon_sdkm.html)
- [Building a GPU-Enabled Kubernetes Cluster for Jetson Nano](https://medium.com/jit-team/building-a-gpu-enabled-kubernets-cluster-for-machine-learning-with-nvidia-jetson-nano-7b67de74172a)
- [How to Easily Install PyTorch on Jetson Orin Nano running JetPack 6.2](https://ninjalabo.ai/blogs/jetson_pytorch.html)
- [Jetson Orin Nano Specification (PDF)](https://developer.download.nvidia.com/assets/embedded/secure/jetson/orin_nano/docs/Jetson-Orin-Nano-DevKit-Carrier-Board-Specification_SP-11324-001_v1.3.pdf?__token__=exp=1760978813~hmac=dfdf13dfacb034ce507c8e1a466d199d7faabd1d7fd1f9b79e57c2eca3cc4bef&t=eyJscyI6ImdzZW8iLCJsc2QiOiJodHRwczovL3d3dy5nb29nbGUuY29tLyJ9)



## Troubleshooting

- [Browser launching error](https://forums.developer.nvidia.com/t/fresh-jetpack-flash-on-agx-orin-selinux-error-matchpathcon-not-found-prevents-snap-apps-from-running/339022)
- Install vscode: download .deb for Arm64 Ubuntu from https://code.visualstudio.com/download
---
