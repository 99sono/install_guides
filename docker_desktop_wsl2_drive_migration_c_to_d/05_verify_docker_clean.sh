#!/bin/bash

# --- 05_verify_docker_clean.sh ---
# Confirms that Docker is clean and running after VHDX move

echo "--- Verifying Docker info ---"
docker info | grep "Docker Root Dir"

echo "--- Verifying image list ---"
docker images

echo "--- Verifying container list ---"
docker ps -a

echo "--- VHDX file location on D: drive ---"
ls -lh /mnt/d/Docker/wsl/data
