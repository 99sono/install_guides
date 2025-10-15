# Installation Guides Repository

## Introduction
This repository contains **installation guides** for various tools and technologies, providing structured steps and best practices for setting up software efficiently. Each tool has its own dedicated directory, ensuring easy navigation and separation of concerns.

### Available Guides
- **aider/**: Guide for installing, configuring, and troubleshooting Aider (an LLM-powered development tool), including integration with Ollama and Docker.
- **conda_miniforge3/**: Installation and usage of Miniforge3 (Conda) for Python environments, with common commands and troubleshooting.
- **docker_desktop_wsl2_drive_migration_c_to_d/**: Guide and scripts for migrating Docker Desktop's WSL2 storage from the C: drive to the D: drive on Windows, including backup, purge, verification, and restore steps.
- **docker-push-to-github/**: Guide for pushing Docker images to GitHub-linked Docker Hub repositories, including tagging strategies and troubleshooting.
- **git_tips/**: Guide for common Git commands, installation steps, and troubleshooting tips.
- **heic_to_jpeg/**: Instructions for converting HEIC images to JPEG on WSL2 Ubuntu, including installation, conversion steps, and troubleshooting.
- **self_signed_certificate/**: Guide for generating and installing self-signed certificates, especially for ASUS routers, with scripts and troubleshooting.
- **wsl2/**: Documentation for installing, updating, and troubleshooting Windows Subsystem for Linux 2 (WSL2).
- **tips_working_with_ssh_keys/**: Guide for managing SSH keys with passphrases in WSL2 Ubuntu, eliminating repeated password prompts for Git operations.
- **scripts/**: Utility scripts to support the other guides (e.g., launching Aider).

## Repository Structure
All installation guides follow the same **organizational structure**, ensuring consistency across different technologies.

### Folder Organization
Each tool's installation guide is stored in a separate directory inside `install_guides/`, following this example structure:

```
install_guides/
├── conda_miniforge3/
│   ├── README.md
│   ├── installation_steps.md
│   ├── common_commands.md
│   └── troubleshooting.md
├── docker_desktop_wsl2_drive_migration_c_to_d/
│   ├── README.md
│   ├── 01_backup_images.sh
│   ├── 02_prepare_d_drive.sh
│   ├── 03_purge_docker.sh
│   ├── 05_verify_docker_clean.sh
│   ├── 06_restore_images.sh
│   └── metadata/
│       └── 01_instructions_to_make_this_project.md
├── nodejs/
│   ├── README.md
│   ├── installation_guide.md
│   ├── package_management.md
│   └── best_practices.md
├── java/
│   ├── README.md
│   ├── installation_steps.md
│   ├── environment_setup.md
│   ├── common_commands.md
│   └── advanced_topics.md
└── maven/
    ├── README.md
    ├── setup_guide.md
    ├── project_structure.md
    ├── dependency_management.md
    └── troubleshooting.md
```

## Core Guidelines & Best Practices

### 🛠 Directory Naming
- Each tool gets its own directory (`conda_miniforge3/`, `nodejs/`, `java/`, `maven/`).
- Use **lowercase and underscores** for directory names to maintain consistency.

### 📖 Documentation Structure
- Each directory contains a `README.md` providing an overview of that tool’s installation guide.
- Supplementary markdown files break down installation, commands, and troubleshooting.

### 🔄 Consistency in Installation Steps
- Installation steps should be **clear, structured, and minimal**.
- Ensure guides follow **step-by-step instructions** that users can replicate.

### 📦 Package Management Recommendations
- Provide guidance on **best practices for managing dependencies** (e.g., pip vs conda, npm vs yarn, Maven dependency resolution).
- Avoid unnecessary complexity—each guide should **focus on practical usage**.

### ❓ Troubleshooting Section
- Each installation guide should include **common issues and their fixes**.
- Ensure troubleshooting steps reference **error messages users might encounter**.

## Recognition
Special thanks to **Microsoft Copilot, Kimi K2** for assisting in structuring this repository and improving installation documentation. 😊
