# Troubleshooting WSL2 Screen Freezes

If WSL2 becomes unresponsive or freezes, follow these steps to recover your environment:

---

## 1. Attempt WSL Shutdown
Open a Windows terminal (Command Prompt or PowerShell) and run:
```powershell
wsl --shutdown
```
Wait a few seconds, then try launching your WSL terminal again.

---

## 2. Kill WSL Processes
If `wsl --shutdown` does not resolve the issue, manually kill the WSL service process:

Open **PowerShell as Administrator** and run:
```powershell
taskkill /f /im wslservice.exe
```
After killing the process, restart WSL:
```powershell
wsl
```

---

## 3. Restart Windows Service
If WSL remains unresponsive, restart the Hyper-V Host Compute Service:
```powershell
net stop vmcompute
net start vmcompute
```

---

## 4. Preventive Measures
- **Update WSL and Windows:**
  Regularly run `wsl --update` and keep Windows updated to minimize issues.
- **Exclude WSL Folders from Antivirus Scans:**
  Antivirus scans can cause WSL to freeze. Exclude your WSL folders from antivirus scans.

---

## 5. Additional Resources
- [Official WSL Troubleshooting Documentation](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting)

If you continue to experience issues, consult the official documentation or seek help from the community.
