# Installing Ubuntu to a USB Pen on Windows 11  
**Guide Version:** 1.0  
**Last Updated:** 2026‑04‑22   

---

## Overview
This guide explains how to create a **bootable Ubuntu USB installation drive** using **Windows 11**.  
The process uses **Rufus**, a lightweight and reliable tool for writing ISO images to USB devices.

---

## Requirements

### Hardware
- USB pen drive (minimum **8 GB** recommended)
- Windows 11 PC with administrator rights

### Software
- Ubuntu ISO (download from: [https://ubuntu.com/download](https://ubuntu.com/download))
- Rufus (download from: [https://rufus.ie](https://rufus.ie))

---

## ⚠️ Important Notes
- **All data on the USB pen will be erased.**  
- Ensure you download Ubuntu only from the official website.  
- This guide assumes a modern UEFI system (default for Windows 11 machines).

---

## 1. Download Ubuntu ISO
1. Visit the official Ubuntu download page.  
2. Choose your preferred version (e.g., Ubuntu Desktop LTS).  
3. Save the `.iso` file to your computer.

---

## 2. Download Rufus
1. Go to [https://rufus.ie](https://rufus.ie)  
2. Download **Rufus Portable** (no installation required).  
3. Run `rufus-x.x.exe`.

---

## 3. Prepare the USB Pen
1. Insert your USB pen into the PC.  
2. Open Rufus — it will automatically detect the USB device.

---

## 4. Configure Rufus

| Setting | Value |
|--------|--------|
| **Device** | Select your USB pen |
| **Boot selection** | *Disk or ISO image* → **Select** → choose Ubuntu ISO |
| **Partition scheme** | **GPT** |
| **Target system** | **UEFI (non‑CSM)** |
| **File system** | **FAT32** |
| **Cluster size** | Default |
| **Volume label** | Optional |

### Additional prompts
- If Rufus asks **ISO mode** vs **DD mode**, choose **ISO mode** unless the USB fails to boot.

---

## 5. Write the ISO to the USB
1. Click **Start**.  
2. Confirm the warning that all data will be destroyed.  
3. Wait 2–5 minutes for the process to complete.  
4. When finished, safely eject the USB pen.

---

## 6. Boot From the USB (Optional: Installing Ubuntu)
To install Ubuntu on a machine:

1. Insert the USB pen into the target PC.  
2. Reboot the system.  
3. Enter the boot menu (common keys: **F12**, **F10**, **Esc**, **Del**).  
4. Select the USB device.  
5. Ubuntu’s installer will load.

---

## Troubleshooting

### USB does not appear in boot menu
- Ensure **Secure Boot** is enabled or disabled depending on Ubuntu version.  
- Try another USB port (preferably USB‑A).  
- Recreate the USB using **DD mode** in Rufus.

### Installer fails to start
- Verify the ISO checksum (Ubuntu provides SHA256 hashes).  
- Re-download the ISO if corrupted.

---

## Appendix

### Verify ISO Checksum (Optional)
Ubuntu publishes SHA256 checksums on their download page.  
To verify on Windows:

```powershell
Get-FileHash .\ubuntu.iso -Algorithm SHA256
```

Compare the output with the official checksum.
