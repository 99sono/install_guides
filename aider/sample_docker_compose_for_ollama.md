# Sample Docker Compose Configuration for Ollama

## Overview

This document provides a **Docker Compose setup** for running Ollama alongside Aider. The following configuration ensures that Ollama is correctly initialized with necessary environment variables, GPU acceleration, and persistent storage.

## Why Use Docker Compose?

Docker Compose simplifies the deployment of **Ollama** and other related services. It allows you to:
- Define the entire environment in a single YAML file.
- Ensure consistent configurations across development environments.
- Easily modify variables like **context length** and **API keys**.

---

## Example Docker Compose Configuration

Below is an example **`docker-compose.yml`** file that was used while setting up Aider:

```yaml
version: '3.8'

services:
  # Ollama service configuration
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    environment:
      # See: https://aider.chat/docs/llms/ollama.html
      - OLLAMA_CONTEXT_LENGTH=8192
      - OLLAMA_API_KEY=Irrelevant
      - OLLAMA_KEEP_ALIVE=3h
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
    restart: no

  # Open-WebUI service configuration
  open-webui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: open-webui
    ports:
      - "11435:8080"
    volumes:
      - open-webui:/app/backend/data
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434
      - WEBUI_AUTH=false
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: no

volumes:
  ollama:
  open-webui:
```

---

## Key Configuration Details

### **Context Length Configuration**
This setup ensures **context length consistency**:
```yaml
- OLLAMA_CONTEXT_LENGTH=8192
```
It is crucial to match this value with **Aider's model metadata settings** (`max_tokens`, `max_input_tokens`, and `max_output_tokens`) for optimal performance.

### **Persistent Storage**
- Ollama's volume is mapped to `/root/.ollama`, ensuring that downloaded models persist across container restarts.
- Open-WebUI’s data is stored in `/app/backend/data`.

### **GPU Acceleration**
- The deployment configuration specifies GPU reservations:
  ```yaml
  deploy:
    resources:
      reservations:
        devices:
          - capabilities: [gpu]
  ```
  This enables **hardware acceleration**, improving performance when running **large models**.

---

## Running the Configuration

To start Ollama with this setup, **navigate to the directory** containing `docker-compose.yml` and execute:
```bash
docker compose up -d
```
To shut down the containers, use:
```bash
docker compose down
```

---

## Acknowledgment

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this guide and improving the clarity of documentation. The support provided by this tool has greatly enhanced the usability and quality of this guide.
