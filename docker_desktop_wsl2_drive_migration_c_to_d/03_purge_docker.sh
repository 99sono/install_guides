#!/bin/bash

# --- 03_purge_docker.sh ---
# Stops and deletes all containers, images, volumes to minimize VHDX size

echo "--- Stopping all running containers ---"
docker stop $(docker ps -q) 2>/dev/null

echo "--- Removing all containers ---"
docker rm $(docker ps -aq) 2>/dev/null

echo "--- Removing all images ---"
docker rmi $(docker images -q) 2>/dev/null

echo "--- Removing all volumes ---"
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "--- Pruning unused networks ---"
docker network prune -f

echo "--- Running final cleanup ---"
docker system prune -a --volumes -f

echo "--- Docker cleanup complete ---"
