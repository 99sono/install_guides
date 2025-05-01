# Aider Configuration (`aider.conf.yml`)

## Overview

Aider relies on a YAML-based configuration file (`.aider.conf.yml`) to define essential settings, including **model selection**, **API configurations**, and **Git settings**. This guide provides an example configuration and key explanations to help users set up Aider correctly.

## **Configuration Details**

### **Model Selection**
The `model` parameter specifies which **LLM model** to use for Aider's main chat functionality. For **optimal performance with Ollama**, ensure the provider is explicitly set to `"ollama_chat"` to prevent hallucinations of non-existent files.

```yaml
model: ollama_chat/gemma3:4b
```

### **Commit Message Model**
Aider can use a separate model for commit message generation and chat history summarization.

```yaml
weak-model: ollama/qwen2.5:7b
```

### **API Base URL**
Aider interacts with a **local Ollama server**, and it's crucial to specify the correct API base URL in the configuration.

```yaml
openai-api-base: http://localhost:11434
# ollama-api-base: http://localhost:11434
```

### **Git Settings**
Aider integrates with **Git repositories**, allowing automated version control and structured project workflows.

```yaml
git: true      # Enable Git tracking
gitignore: false  # Prevent automatic ignoring of Aider-related files
aiderignore: .aiderignore  # Specify the ignore file for Aider
auto-commits: false  # Disable automatic LLM-driven Git commits
```

### **Setting Environment Variables in Configuration**
To ensure **Ollama API connection**, it's recommended to set environment variables directly in the configuration file, avoiding manual exports.

```yaml
set-env:
  - OLLAMA_API_BASE=http://127.0.0.1:11434
```

---

## **Example `.aider.conf.yml` Configuration**

Below is a sample configuration file based on the recommended settings:

```yaml
## Specify the model to use for the main chat
# model: ollama_chat/qwen2.5:7b
# model: ollama_chat/gemma3:12b
model: ollama_chat/gemma3:4b

## Specify the model to use for commit messages and chat history summarization
weak-model: ollama/qwen2.5:7b

## API Base URL Configuration
openai-api-base: http://localhost:11434
# ollama-api-base: http://localhost:11434

###############
# Git Settings:

git: true
gitignore: false
aiderignore: .aiderignore
auto-commits: false

## Run aider in your browser
#gui: false

## Enable/disable suggesting shell commands
#suggest-shell-commands: true

## Set environment variables within configuration
set-env:
  - OLLAMA_API_BASE=http://127.0.0.1:11434
```

---

## **Reference Configuration**

For a **full Aider configuration sample**, visit the official repository:
🔗 [Sample Aider Configuration](https://github.com/Aider-AI/aider/blob/main/aider/website/assets/sample.aider.conf.yml)

---

## **Acknowledgment**

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this guide and improving the clarity of documentation. The support provided by this tool has greatly enhanced the usability and quality of this guide.
