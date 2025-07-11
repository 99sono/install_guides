#!/bin/bash

# --- Prerequisites: Backup Docker Images and List Containers ---
# This script backs up all your Docker images and lists all containers.
# This is an optional but highly recommended step before moving Docker's data.

# Create the folder to hold the backup images
mkdir -p /mnt/d/docker_migration_scripts
cd /mnt/d/docker_migration_scripts

# Define the backup directory and filename
# The backup will be saved in the current directory where this script is run.
BACKUP_FILENAME="backup-images-$(date +%Y%m%d_%H%M%S).tar"

echo "--- Backing up all Docker images ---"
echo "Saving images to: $BACKUP_FILENAME"

# Use -q to get only image IDs, which is sufficient for `docker save`
# Capture image IDs first to handle cases with many images gracefully
IMAGE_IDS=$(docker images -q)

if [ -z "$IMAGE_IDS" ]; then
    echo "No Docker images found to backup."
else
    if docker save -o "$BACKUP_FILENAME" $IMAGE_IDS; then
        echo "✔ Docker images backed up successfully."
    else
        echo "✖ Error: Failed to backup Docker images. Please check Docker status and permissions."
        exit 1
    fi
fi

echo ""
echo "--- Listing all Docker containers (active and stopped) ---"
docker container ls -a
echo "This list helps you confirm containers are present after the move."

echo ""
echo "--- Prerequisite Script Complete ---"
echo "You can now proceed with the Docker Desktop UI steps (Step 1 and 2 in your guide)."