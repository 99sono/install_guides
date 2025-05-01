# Installation Steps for Aider

This document provides a step-by-step guide to installing Miniforge3 and setting up the necessary environment for Aider.

---

## **1. Install Miniforge3**

To manage the Python environment effectively, we recommend installing **Miniforge3**, which comes pre-configured with Conda. Follow the guide linked below for detailed instructions:

[Miniforge3 Installation Guide](https://github.com/99sono/install_guides/blob/main/conda_miniforge3/README.md)

### Summary of Steps:
1. Download the appropriate installer for your operating system from the Miniforge3 [official repository](https://github.com/conda-forge/miniforge/releases/latest).
2. Run the installer and follow the on-screen instructions.
3. Verify your installation by running:
   ```bash
   conda --version
   ```

---

## **2. Create a Conda Environment for Aider**

After installing Miniforge3, create a dedicated Conda environment for Aider:

```bash
conda create -n aider python=3.13
```

Activate the new environment:

```bash
conda activate aider
```

---

## **3. Install Aider**

Once the environment is set up, install Aider using the following steps:

1. Install the helper package:
   ```bash
   python -m pip install aider-install
   ```

2. Use the helper package to install Aider:
   ```bash
   aider-install
   ```

---

## **4. Configuration**

Ensure you have a properly configured `.aider.conf.yml` file in the root of your project. This file should specify details such as the model to use (`ollama_chat/gemma3:4b`) and the API base URL.

Refer to the `configuration.md` file for more information.

---

## **5. Verify Installation**

Finally, verify the installation by running Aider:

```bash
aider
```

This should start Aider and load the configuration from `.aider.conf.yml`.

Certainly! Here's a proposed acknowledgment section for the documentation:

---

## Acknowledgment

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this installation guide and improving the clarity of documentation. The insights and support provided by this tool have greatly enhanced the usability and quality of the guide.

