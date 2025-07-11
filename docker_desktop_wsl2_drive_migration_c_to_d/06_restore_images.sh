#!/bin/bash

# --- 06_restore_images.sh ---
# Restore Docker images from backup tar file

BACKUP_FILE="/mnt/d/docker_backup_images/backup-images-*.tar"

echo "--- Looking for Docker image backups in: $BACKUP_FILE ---"
LATEST_BACKUP=$(ls -t $BACKUP_FILE 2>/dev/null | head -n1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "✖ No backup .tar file found in backup directory."
    exit 1
fi

echo "--- Restoring images from: $LATEST_BACKUP ---"
docker load -i "$LATEST_BACKUP" && \
echo "✔ Images restored." || \
echo "✖ Failed to restore Docker images."
