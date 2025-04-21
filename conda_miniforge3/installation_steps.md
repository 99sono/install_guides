# Installing Miniforge3

This guide provides step-by-step instructions for installing Miniforge3 on Ubuntu (WSL2).

## Prerequisites
- Ubuntu running on WSL2
- Internet connection
- Basic familiarity with terminal commands

## Installation Process

### 1️⃣ Create a directory for installation
```bash
mkdir ~/programs
cd ~/programs
```

### 2️⃣ Download the latest Miniforge3 installer
```bash
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
```

### 3️⃣ Run the installer
```bash
bash Miniforge3-$(uname)-$(uname -m).sh
```
Follow the on-screen prompts and ensure it's installed in `~/programs/miniforge3`.

### 4️⃣ Source `.bashrc` to activate Conda
```bash
source ~/.bashrc
```

### 5️⃣ Verify installation
```bash
conda --version
```

## Post-Installation Setup
After installation, your system will be configured to use Conda environments. The base environment is activated by default, but it's recommended to create separate environments for different projects.