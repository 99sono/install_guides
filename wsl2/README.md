# WSL2 Guide

## Introduction

Windows Subsystem for Linux 2 (WSL2) allows you to run a full Linux environment on Windows, making it easier to use Linux-based tools and workflows. This guide covers installation and troubleshooting steps for WSL2 users.

---

## Installation

To install WSL2 on Windows, open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

This command will install the latest version of WSL and a default Linux distribution. For detailed instructions and advanced options, refer to the official Microsoft documentation:

- [Install WSL on Windows (Microsoft Docs)](https://learn.microsoft.com/en-us/windows/wsl/install)

---

## Troubleshooting WSL2 Issues

### WSL2 Freezing Issues & Recovery Steps

If WSL2 becomes unresponsive or freezes, try the following recovery steps:

1. **Attempt WSL Shutdown**
   - Open a Windows terminal (Command Prompt or PowerShell) and run:
     ```powershell
     wsl --shutdown
     ```
   - Wait a few seconds, then try launching your WSL terminal again.

2. **Restart Windows Service**
   - If WSL remains unresponsive, open **PowerShell as Administrator** and run:
     ```powershell
     net stop vmcompute
     net start vmcompute
     ```
   - This restarts the Hyper-V Host Compute Service, which manages WSL2.

3. **Verify Recovery**
   - Open a new terminal and run:
     ```powershell
     wsl
     ```
   - If WSL launches successfully, your environment should be restored.

---

**Note:**
- For issues running specific tools (like Aider or Ollama) inside WSL2, refer to their respective troubleshooting guides and ensure all environment variables and network settings are correct.
- For more advanced troubleshooting, see the [official WSL troubleshooting documentation](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting).
