# DGX Spark Official Documentation

## Official Links
- [DGX Spark User Guide](https://docs.nvidia.com/dgx/dgx-spark/index.html)
- [System Recovery Guide](https://docs.nvidia.com/dgx/dgx-spark/system-recovery.html)
- [Acer Veriton GN100 AI Workstation Getting Started](https://community.acer.com/en/kb/articles/19556-getting-started-with-the-acer-veriton-gn100-ai-workstation)

## Vendor-Specific Documentation Note
Different vendors of DGX Spark devices may have their own instruction manuals for performing a factory reset. As a reference, Acer provides documentation for their Veriton GN100 AI Workstation [here](https://community.acer.com/en/kb/articles/19556-getting-started-with-the-acer-veriton-gn100-ai-workstation). Always consult the documentation provided by your specific hardware vendor for the most accurate recovery instructions.

## High-Level Workflow Overview

The DGX Spark recovery is a structured, three-phase process designed to transition the system from its current state to a verified, clean, and secure factory-standard environment.

1.  **Preparation Phase**: Downloading the specific recovery archive (`.tar.gz`) and using the provided scripts (e.g., `CreateUSBKey.sh`) to create a bootable recovery drive with administrative privileges.
2.  **Configuration Phase**: Interacting with the UEFI/BIOS settings to reset hardware defaults and enable Secure Boot protocols.
3.  **Execution Phase**: Utilizing a "Boot Override" to launch the recovery environment from the USB drive, which then handles the actual re-flashing of the system-on-a-chip and OS.

## Understanding the "Strange" Steps: Why the multiple reboots?

The recovery process can seem unusual because it requires several reboots and specific interactions with the UEFI settings. This is not a design flaw, but a critical security requirement. To ensure a truly "clean" state, the system must traverse a tiered security hierarchy:

### 1. The Hardware Layer (UEFI Reset)
The first stage involves resetting the UEFI (the "brain" of the computer) to its factory-optimized defaults. This clears out any custom configurations or unofficial settings left by a previous user, ensuring the hardware starts from a known, standard baseline.

### 2. The Security Layer (Secure Boot & Key Restoration)
The second stage is the most critical for security. By prompting the user to "Restore Factory Keys" and "Enable Secure Boot," the system is establishing a **Root of Trust**. 

It tells the hardware to only execute software that is digitally signed and verified. This effectively neutralizes any "hacked" or unauthorized configurations that might have been present, as the system will now reject any code that does not meet these strict, high-level security standards.

### 3. The Boot Control Layer (The USB Handshake)
The final reboots are designed to facilitate a "handshake" between the hardware and your external media. By using the **Boot Override** function, you are telling the system to ignore the internal storage (which may be corrupted or untrusted) and instead hand over control to your trusted USB recovery drive.

**In summary:** The frequent reboots are a deliberate protocol to move the machine through a hierarchy of trust—from a hardware reset, to a security verification, and finally to a controlled execution of the recovery environment.

