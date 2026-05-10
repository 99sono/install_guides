# Git Installation

This guides the basic installation and setup. Skip if Git is already installed.

## Ubuntu/WSL2

1. Update package list:
```bash
sudo apt update
```

2. Install git:
```bash
  sudo apt install git
```

3. Verify:
```bash
  git --version
```

## Configure Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

## Configure SSH

Follow `../tips_working_with_ssh_keys/` in this repo for SSH key setup and remote.
