
# Aider Installation Guide

## Overview

Welcome to the **Aider Installation Guide**, a structured approach to setting up and configuring **Aider** alongside **Ollama**. This repository provides modular documentation to guide users through installation, configuration, and troubleshooting.

### What is Aider?
Aider is an **LLM-powered development tool** that integrates with code repositories, helping users generate and edit code interactively. Proper setup and configuration are required to ensure seamless integration with **Ollama**, a local LLM runtime.

---

## Repository Structure

This installation guide follows a modular approach:

| **File** | **Purpose** |
|----------|------------|
| [installation_steps.md](installation_steps.md) | Step-by-step instructions for installing **Miniforge3**, setting up a Conda environment, and installing Aider. |
| [common_commands.md](common_commands.md) | Essential Aider commands for interacting with code and managing sessions. |
| [troubleshooting.md](troubleshooting.md) | Summary of common Aider issues and possible solutions. |
| [model_metadata.md](model_metadata.md) | Explanation of model metadata and configuration requirements for running Ollama optimally. |
| [aider_conf.md](aider_conf.md) | Sample Aider configuration (`.aider.conf.yml`) for seamless integration with Ollama. |
| [sample_docker_compose_for_ollama.md](sample_docker_compose_for_ollama.md) | Example **Docker Compose** configuration for running **Ollama** alongside **Aider**. |

---

## Installation Instructions

For complete installation details, refer to **[installation_steps.md](installation_steps.md)**, which provides a structured guide for setting up Aider.

### **High-Level Summary**
- **Install Miniforge3** to manage Python environments efficiently.
- Use **Conda** to create a **dedicated environment for Aider**, ensuring a clean and isolated workspace.
- The environment should include **Python 3.13 or later** for compatibility.
- Once the environment is ready, follow **[installation_steps.md](installation_steps.md)** for Aider setup and configuration.

---

## Configuration Guide

To ensure proper functionality, Aider requires a **correctly configured model metadata file and `.aider.conf.yml`**.

- **Model Metadata:**  
  Aider must be configured with appropriate token limits and model specifications. See **[model_metadata.md](model_metadata.md)** for details.
  
- **Aider Configuration:**  
  The `.aider.conf.yml` file provides essential settings such as **API endpoints, model choices, and Git integration**. Refer to **[aider_conf.md](aider_conf.md)** for an example configuration.

- **Docker Deployment (Optional):**  
  Running Ollama via Docker ensures a stable LLM runtime. See **[sample_docker_compose_for_ollama.md](sample_docker_compose_for_ollama.md)** for a ready-to-use Docker Compose setup.

---

## Preparing Your Project Structure

Before running Aider, it is important to ensure that your project follows a well-organized structure. A properly set up project might look like this:

```
 tree
.
.aider.conf.yml
├── README.md
├── aider
│   ├── README.md
│   ├── aider_conf.md
│   ├── common_commands.md
│   ├── installation_steps.md
│   ├── model_metadata.md
│   ├── sample.aider.conf.yml
│   ├── sample_docker_compose_for_ollama.md
│   └── troubleshooting.md
├── conda_miniforge3
│   ├── README.md
│   ├── common_commands.md
│   └── installation_steps.md
├── heic_to_jpeg
│   ├── README.md
│   ├── installation_steps.md
│   └── troubleshooting.md
├── scripts
│   └── 00_launch_aider.sh
```

Key components:
- **Root-Level `.aider.conf.yml` File**  
  Ensure that your **`.aider.conf.yml`** is placed at the root of the project and contains the correct model and API configurations. Refer to **[aider_conf.md](aider_conf.md)** for guidance.

- **Dedicated `scripts/` Directory**  
  A `scripts/` folder can house useful helper scripts, such as **`00_launch_aider.sh`**, which automates launching Aider with the correct context.  
  See **[common_commands.md](common_commands.md)** for details on running Aider.

---

## Running Aider

Once your project is structured correctly, you can launch Aider using:
```bash
aider
```
For further interaction details and commands, refer to **[common_commands.md](common_commands.md)**.

---

## Troubleshooting

If you encounter any issues, **[troubleshooting.md](troubleshooting.md)** contains examples of common problems and possible solutions, such as:
- Aider hallucinating non-existent files (`greeting.py`) and how specifying `"ollama_chat"` as the model provider helps mitigate this.
- Connection problems with Ollama, including missing environment variables like `OLLAMA_API_BASE`.

For more details, refer to the full troubleshooting document.

---

## Additional Resources

- **Official Aider Documentation:** [Aider Docs](https://aider.chat/docs/)
- **Full Aider Configuration Example:** [Sample `.aider.conf.yml`](https://github.com/Aider-AI/aider/blob/main/aider/website/assets/sample.aider.conf.yml)
- **Ollama Configuration Guide:** [Ollama Docs](https://aider.chat/docs/llms/ollama.html)

---

## Acknowledgment

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this guide and improving the clarity of documentation. The support provided by this tool has greatly enhanced the usability and quality of this guide.
