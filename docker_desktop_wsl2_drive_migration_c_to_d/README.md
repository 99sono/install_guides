# Docker Desktop WSL2 Storage Migration Scripts

## Overview

This project is both a **guide** and a **collection of scripts** to support the migration of Docker Desktop's WSL2 storage (docker-desktop-data) from one drive to another (e.g., from `C:` to `D:`) on Windows, using Ubuntu WSL2. It is designed for users who want to automate, document, and safely execute the migration process, especially when working with large Docker images or limited system drive space.

## Usage Case

- Free up space on your system drive by moving Docker's storage to a larger secondary drive.
- Automate and document the migration process for reproducibility and safety.
- Minimize risk by backing up images and verifying Docker's state at each step.

## Project Structure

- **metadata/**: Contains the original, detailed instructions and action plan used to create these scripts.
- **01_backup_images.sh**: Backs up all Docker images to a tar archive.
- **02_prepare_d_drive.sh**: Prepares the target directory on the new drive (e.g., `D:`).
- **03_purge_docker.sh**: Stops and removes all containers, images, and volumes to minimize the Docker data footprint.
- **05_verify_docker_clean.sh**: Verifies that Docker is clean and running after the migration.
- **06_restore_images.sh**: Restores Docker images from the backup tar file.

## How to Use

1. **Read the full guide in `metadata/01_instructions_to_make_this_project.md`** for context and manual steps.
2. Run each script in order, following any manual instructions as prompted in the guide.
3. Use the verification script to confirm a successful migration before restoring your images.

## Acknowledgements

- **grok3** and **ChatGPT** for the initial action plan and migration strategy.
- **GitHub Copilot with GPT-4.1** for the execution and automation of the action plan.

---

For detailed, step-by-step instructions and background, see `metadata/01_instructions_to_make_this_project.md`.
