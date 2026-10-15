# Base image: PyTorch preinstalled for Jetson Orin (JetPack 6.x)
FROM dustynv/pytorch:2.7-r36.4.0-cu128-24.04

# Set working directory
WORKDIR /workspace

# Copy simple inference script
COPY simple_inference.py /workspace/simple_inference.py

# Default command: run inference
ENTRYPOINT ["python3", "simple_inference.py"]
