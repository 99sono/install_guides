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

After installation, your system will be configured to use Conda environments.  
The base environment is activated by default, but it is recommended to create **separate environments per project**.

### Create a Python Environment

As a first step, try creating a Python environment (example: Python 3.14):

```bash
conda create -n py314 python=3.14
conda activate py314
```

In many **corporate environments**, this step may fail with SSL errors similar to:

    SSLError: certificate verify failed: self-signed certificate in certificate chain

This typically indicates that the enterprise uses **custom or internal Certificate Authorities (CAs)** which Conda does not trust by default.

***

## Corporate Environment: SSL / Certificate Configuration

### Configure Conda to Use the System CA Certificates

On Ubuntu, the system CA certificate bundle is usually located at:

    /etc/ssl/certs/ca-certificates.crt

Configure Conda to explicitly use this bundle:

```bash
conda config --set ssl_verify /etc/ssl/certs/ca-certificates.crt
```

You can verify the setting with:

```bash
conda config --show ssl_verify
```

After this, retry creating the environment:

```bash
conda create -n py314 python=3.14
conda activate py314
```

***

### Configure Python and `pip` for HTTPS Access

Some Python libraries (notably `requests`) do not automatically inherit Conda’s SSL configuration.  
To avoid HTTPS issues during `pip install` or when running Python code, it is recommended to export the CA bundle explicitly.

Add the following line to your `~/.bashrc`:

```bash
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

Apply the change:

```bash
source ~/.bashrc
```

***

### Distribution-Specific Notes

Certificate bundle locations vary by Linux distribution:

*   **Ubuntu / Debian**
        /etc/ssl/certs/ca-certificates.crt

*   **RHEL / Rocky Linux / AlmaLinux**
        /etc/pki/tls/certs/ca-bundle.crt

While paths differ, the principle remains the same:  
Conda, `pip`, and Python must trust the **enterprise CA bundle** used by the system.
