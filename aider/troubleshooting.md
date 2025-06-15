# Troubleshooting Guide for Aider

This document provides solutions to common issues encountered while using Aider, along with helpful tips for ensuring a smooth experience.

---

## **1. Hallucinations in Context**

### Issue:
Aider may hallucinate files or references that do not exist within the project's context, such as a non-existent `greeting.py` file.

### Solution:
This issue can be mitigated by explicitly specifying the model provider as `ollama_chat` instead of `ollama` in the `.aider.conf.yml` file. Update the configuration as shown below:
```yaml
model: ollama_chat/gemma3:4b
```

For more details, refer to the [GitHub issue](https://github.com/Aider-AI/aider/issues/3921#issuecomment-2844367421).

---

## **2. Local Development Ollama Connection**

### Issue:
Aider may fail to connect to the local Ollama server due to missing or incorrectly configured environment variables.

### Solution:
Ensure the environment variable `OLLAMA_API_BASE` is set to point to your local development server:
```bash
export OLLAMA_API_BASE=http://127.0.0.1:11434
```

Alternatively, you can define this environment variable directly in the `.aider.conf.yml` file. Add the following configuration:
```yaml
set-env:
  - OLLAMA_API_BASE=http://127.0.0.1:11434
```

This ensures that the environment variable is automatically set whenever Aider runs.

---

## **3. General Troubleshooting Tips**

### Verify Configuration File
Double-check that your `.aider.conf.yml` file includes all required settings, such as:
- Model selection (`ollama_chat/gemma3:4b`)
- Environment variables (`OLLAMA_API_BASE`)

### Check Server Status
Ensure your local Ollama server is running and accessible at the specified API base URL.

### Reinstall Dependencies
If errors persist, try reinstalling Aider and its dependencies:
```bash
python -m pip install --upgrade aider-install
```

---

## **4. WSL2 Freezing Issues & Recovery Steps**

If you are running Aider or Ollama inside Windows Subsystem for Linux 2 (WSL2) and encounter freezing or unresponsive behavior, follow these steps to recover your environment:

### 1. Attempt WSL Shutdown
Open a Windows terminal (such as Command Prompt or PowerShell) and run:
```powershell
wsl --shutdown
```
This command stops all running WSL instances. Wait a few seconds, then try launching your WSL terminal again.

### 2. Restart Windows Service
If WSL remains unresponsive or terminals do not open, restart the Hyper-V Host Compute Service:
- Open **PowerShell as Administrator** (right-click PowerShell and select "Run as administrator").
- Run the following commands:
```powershell
net stop vmcompute
net start vmcompute
```
This will restart the service responsible for managing WSL2 virtual machines.

### 3. Verify Recovery
After restarting, open a new terminal and run:
```powershell
wsl
```
If WSL launches successfully, your environment should be restored.

---

**Related Issues:**
- If you encounter persistent problems with WSL2, see the [General Troubleshooting Tips](#3-general-troubleshooting-tips) above for additional steps, such as verifying configuration files and reinstalling dependencies.
- For issues specific to Ollama or Aider inside WSL2, ensure that all environment variables and network configurations are set correctly as described in previous sections.

---

## Acknowledgment

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this guide and improving the clarity of documentation. The support provided by this tool has greatly enhanced the usability and quality of this guide.
