# docker.sh
#!/bin/bash
# Docker configuration script

echo "Adding current user to docker group..."
sudo groupadd -f docker
sudo usermod -aG docker $USER
newgrp docker

echo "Configuring NVIDIA runtime for Docker..."
DOCKER_JSON='/etc/docker/daemon.json'

sudo tee $DOCKER_JSON > /dev/null <<EOF
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
EOF

echo "Docker configuration done."
