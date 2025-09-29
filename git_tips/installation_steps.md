# Git Installation Steps

This file outlines the basic installation and initial setup of Git, particularly for Unix-like environments such as Ubuntu on WSL2. If Git is already installed, skip to the configuration section. For Windows or macOS, refer to the official Git docs.

## Prerequisites
- Administrative access (sudo on Linux).
- Internet connection for downloading packages.
- For WSL2 users: Ensure WSL2 is installed (see `wsl2/install_and_update.md` in this repo).

## Installation on Ubuntu/WSL2

1. **Update Package List**:
   ```
   sudo apt update
   ```
   - This refreshes the list of available packages.

2. **Install Git**:
   ```
   sudo apt install git
   ```
   - This downloads and installs the latest stable Git version from the Ubuntu repositories.
   - Expected output: Confirmation of installation, e.g., "git is already the newest version" if previously installed.

3. **Verify Installation**:
   ```
   git --version
   ```
   - Output example: `git version 2.34.1` (version may vary).
   - If not found, ensure the package installed correctly and restart your terminal.

## Initial Configuration

After installation, configure Git with your identity (required for commits):

1. **Set Your Name and Email**:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
   - Replace with your actual details. The `--global` flag applies this to all repositories.
   - Use your GitHub email for collaboration.

2. **Set Default Branch Name** (optional, for new repos):
   ```
   git config --global init.defaultBranch main
   ```
   - This sets `main` as the default for new branches (instead of `master`).

3. **Configure SSH for Remotes** (recommended for GitHub):
   - Follow `tips_working_with_ssh_keys/README.md` in this repo to set up SSH keys and avoid password prompts.
   - Add remote: `git remote add origin git@github.com:username/repo.git` (SSH URL).

4. **Verify Configuration**:
   ```
   git config --list
   ```
   - Lists all settings; look for `user.name` and `user.email`.

## Post-Installation Tips
- Clone a repo to test: `git clone git@github.com:99sono/install_guides.git` (SSH URL, assuming SSH keys are set up as per `tips_working_with_ssh_keys/README.md`).
- For advanced setups (e.g., Git LFS, aliases), see the official [Git setup guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
- If issues arise (e.g., permission errors), refer to `troubleshooting.md`.

Git is now ready! Proceed to `common_commands.md` for usage examples.
