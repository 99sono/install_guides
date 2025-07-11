# 📦 Guide: Migrating Docker Desktop WSL2 Storage to the D: Drive via Ubuntu WSL2

## 🧭 Overview

This guide walks you through the process of **moving Docker Desktop's WSL2 storage (`docker-desktop-data`) from your system C: drive to a larger secondary D: drive**, while maintaining complete control from your **WSL2 Ubuntu terminal**.

This is particularly useful if:
- You have limited space on your C: drive.
- You work with large Docker images or volumes.
- You want to explicitly control and minimize your Docker Desktop VHDX footprint.
- You prefer to automate and document system-level changes via scripts for reproducibility.

---

## 🧱 Assumptions

This guide assumes the following:

- You are using **Docker Desktop** on **Windows 10/11** with the **WSL2 backend**.
- You are managing Docker from **Ubuntu inside WSL2**.
- Your D: drive is **formatted as NTFS** and has sufficient free space.
- You are familiar with basic Bash scripting and comfortable executing commands that affect system-level components like containers and VHDX files.

---

## 📋 Summary of Action Plan

The migration consists of **7 phases**, some of which are fully scriptable from within WSL2, and others which require manual interaction with the Docker Desktop UI.

| Phase | Description |
|-------|-------------|
| ✅ Phase 1 | Back up Docker images (already completed) |
| ✅ Phase 2 | Prepare the D: drive target folder |
| 🔁 Phase 3 | Purge all Docker containers, images, volumes (to minimize VHDX) |
| 🖥️ Phase 4 | Use Docker Desktop UI to move storage |
| 🔎 Phase 5 | Post-migration verification |
| 📦 Phase 6 | Restore Docker images (optional) |
| 🧹 Phase 7 | Clean up old C: drive Docker data (optional) |

---

## 🧰 Directory Structure (Recommended)

We recommend organizing your migration resources like so:

```

D:
│
├── docker\_backup\_images
│   └── backup-images-20250711\_XXXXXX.tar
│
└── docker\_migration\_scripts
├── 01\_backup\_images.sh
├── 02\_prepare\_d\_drive.sh
├── 03\_purge\_docker.sh
├── 05\_verify\_docker\_clean.sh
└── 06\_restore\_images.sh

````

---

## 🔧 Phase 1: Back Up Docker Images

📄 **Script: `01_backup_images.sh`**

You already ran this script, but for reference:

```bash
#!/bin/bash

# --- 01_backup_images.sh ---
# Backup all Docker images into a single .tar archive.
# Run from inside Ubuntu WSL2. Backup is stored in the current directory.

BACKUP_FILENAME="backup-images-$(date +%Y%m%d_%H%M%S).tar"
echo "--- Backing up all Docker images to: $BACKUP_FILENAME ---"

IMAGE_IDS=$(docker images -q)
if [ -z "$IMAGE_IDS" ]; then
    echo "No Docker images found to back up."
else
    docker save -o "$BACKUP_FILENAME" $IMAGE_IDS && \
    echo "✔ Backup successful: $BACKUP_FILENAME" || \
    echo "✖ Backup failed."
fi

echo "--- Listing all Docker containers ---"
docker container ls -a
````

📌 Run from:

```bash
cd /mnt/d/docker_backup_images
bash 01_backup_images.sh
```

---

## 📁 Phase 2: Prepare D: Drive Target Folder

📄 **Script: `02_prepare_d_drive.sh`**

```bash
#!/bin/bash

# --- 02_prepare_d_drive.sh ---
# Create the target folder on the D: drive for Docker's VHDX file

echo "--- Creating D:/Docker/wsl/data ---"
mkdir -p /mnt/d/Docker/wsl/data

if [ -d /mnt/d/Docker/wsl/data ]; then
    echo "✔ Target directory created successfully."
else
    echo "✖ Failed to create target directory. Check D: drive status."
    exit 1
fi
```

📌 Run from:

```bash
cd /mnt/d/docker_migration_scripts
bash 02_prepare_d_drive.sh
```

---

## 🧹 Phase 3: Purge Docker Containers, Images, Volumes

📄 **Script: `03_purge_docker.sh`**

```bash
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
```

📌 Run from:

```bash
cd /mnt/d/docker_migration_scripts
bash 03_purge_docker.sh
```

---

## 🖥️ Phase 4: Move Docker Data via Docker Desktop UI

📌 This step **must be done manually** in the Docker Desktop UI.

### 🧭 Instructions:

1. **Open Docker Desktop**
2. Click the **gear icon ⚙️** to open Settings
3. Go to **Resources > Advanced**
4. Under **Disk image location**, click **Browse**
5. Choose: `D:\Docker\wsl\data`
6. Click **Apply & Restart**

💡 If prompted:

* Choose to **move existing disk** (not create new)
* Docker will relocate `ext4.vhdx` to the D: drive and restart automatically

---

## 🔎 Phase 5: Post-Move Verification

📄 **Script: `05_verify_docker_clean.sh`**

```bash
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
```

📌 Run from:

```bash
cd /mnt/d/docker_migration_scripts
bash 05_verify_docker_clean.sh
```

---

## 📦 Phase 6: Restore Docker Images (Optional)

📄 **Script: `06_restore_images.sh`**

```bash
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
```

📌 Run from:

```bash
cd /mnt/d/docker_migration_scripts
bash 06_restore_images.sh
```

---

## 🧹 Phase 7: Clean Up Old C: Drive Docker Files (Optional)

📌 Only do this **after verifying** that Docker is fully functional on the D: drive.

Navigate to:

```
C:\Users\<YourUsername>\AppData\Local\Docker\wsl\data
```

Delete:

```
ext4.vhdx
```

Ensure that no background process is still accessing the file before deleting. You can stop Docker Desktop first to be safe.

---

## ✅ Final Notes

* Docker Desktop may still maintain small config files on the C: drive (`docker-desktop`), but they are negligible in size.
* Always monitor the VHDX size on `D:`. If it becomes large again, use `docker system prune` periodically.
* You can repeat this backup-restore-cleanup cycle in the future to move WSL2-based workloads across machines.

---

## 📎 Appendix: Useful Docker Commands

```bash
# Save all images
docker save -o backup.tar $(docker images -q)

# Restore images
docker load -i backup.tar

# Stop all containers
docker stop $(docker ps -q)

# Remove all containers/images/volumes
docker rm $(docker ps -aq)
docker rmi $(docker images -q)
docker volume rm $(docker volume ls -q)
```

---

*Guide prepared for developers managing Docker Desktop from WSL2 Ubuntu, prioritizing disk hygiene and reproducibility.*
