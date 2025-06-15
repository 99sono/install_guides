# WSL2: Installation and Update Guide

## Introduction

Windows Subsystem for Linux 2 (WSL2) enables you to run a full Linux environment on Windows. Keeping WSL2 up to date ensures better performance, compatibility, and stability.

---

## Installation

To install WSL2, open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

This command installs the latest version of WSL and a default Linux distribution. For more details and advanced options, see the [official Microsoft documentation](https://learn.microsoft.com/en-us/windows/wsl/install).

---

## Updating WSL2

It is recommended to frequently update WSL2 to benefit from the latest features and fixes. To update, run:

```powershell
wsl --update
```

Also, ensure your Windows system is up to date via Windows Update.

---

## Preventive Measures

- **Exclude WSL Folders from Antivirus Scans:**
  Antivirus scans can cause WSL to freeze or slow down. Exclude your WSL folders from antivirus scans for better stability.

- **Keep Both WSL and Windows Updated:**
  Regularly update both WSL and your Windows OS to minimize issues.

For more information, see the [official WSL troubleshooting documentation](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting).
