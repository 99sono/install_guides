# OpenCode Setup Guide — Qwen3.6-35B-A3B-NVFP4 via vLLM

## Prerequisites

```bash
# ✅ WSL2 with Ubuntu 22.04/24.04
wsl --list --verbose

# ✅ conda/mamba and Docker + NVIDIA Container Toolkit installed
which conda
nvidia-smi  # Should work inside WSL
```

---

## Step 1: Launch vLLM with Docker Compose

Create a `docker-compose.yml` (see below) to serve the model. The key thing that makes OpenCode work — and that Cline didn't need — is the `--enable-auto-tool-choice` flag.

```yaml
version: "3.9"

services:
  qwen3-6-moe-nvfp4:
    image: vllm/vllm-openai:v0.20.0-cu130-ubuntu2404
    container_name: qwen3-6-moe-35b-a3b-nvfp4
    platform: linux/amd64
    ports:
      - "8000:8000"
    volumes:
      - ~/.cache/huggingface:/root/.cache/huggingface
      - /dev/shm:/dev/shm
    shm_size: "32g"
    ipc: host

    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]

    environment:
      VLLM_WORKER_MULTIPROC_METHOD: spawn
      PYTORCH_CUDA_ALLOC_CONF: "expandable_segments:True"
      HF_HUB_ENABLE_HF_TRANSFER: "1"

    command:
      - "--model"
      - "RedHatAI/Qwen3.6-35B-A3B-NVFP4"
      - "--served-model-name"
      - "Qwen3.6-35B-A3B-NVFP4"
      - "--trust-remote-code"
      - "--host"
      - "0.0.0.0"
      - "--port"
      - "8000"
      - "--gpu-memory-utilization"
      - "0.90"
      - "--max-model-len"
      - "65536"
      - "--max-num-seqs"
      - "1"
      - "--max-num-batched-tokens"
      - "8192"
      - "--kv-cache-dtype"
      - "fp8_e4m3"
      - "--quantization"
      - "compressed-tensors"
      - "--reasoning-parser"
      - "qwen3"
      - "--tool-call-parser"
      - "qwen3_coder"
      # ⚠️ CRITICAL: OpenCode sends tool_choice="auto" by default.
      #   This flag tells vLLM to auto-select tools. Cline does NOT need this,
      #   but OpenCode does — without it, you get HTTP 400 errors.
      - "--enable-auto-tool-choice"
      - "--moe-backend"
      - "cutlass"
      - "--enable-prefix-caching"
      - "--enable-chunked-prefill"
      - "--safetensors-load-strategy"
      - "prefetch"
      - "--max-cudagraph-capture-size"
      - "1"
```

Then start it:

```bash
docker compose up -d
```

Verify it's working:

```bash
curl -s http://localhost:8000/v1/models | jq '.data[].id'
# Expect: "Qwen3.6-35B-A3B-NVFP4"
```

---

## Step 2: Create a Conda Environment and Install OpenCode

OpenCode is a Node.js-based CLI. Don't pollute your base conda env — create a dedicated one:

```bash
# Create the environment with Node.js bundled
conda create -n opencode nodejs -y

# Activate it
conda activate opencode

# Install OpenCode globally inside this env
npm install -g opencode-ai

# Verify
opencode --version
# Should output something like: opencode/1.x.x linux-x64 node-v24.x.x
```

> 💡 If you prefer automation, run the provided scripts from the `opencode/` directory:
> ```bash
> chmod +x 01_create_open_code_conda_env.sh 02_install_opencode.sh 03_setup_opencode_config.sh
> bash 01_create_open_code_conda_env.sh
> bash 02_install_opencode.sh
> bash 03_setup_opencode_config.sh
> ```

---

## Step 3: Create the OpenCode Config

```bash
mkdir -p ~/.config/opencode
nano ~/.config/opencode/opencode.json
```

Paste this single-provider config:

```json
{
  "$schema": "https://opencode.ai/config.json",

  "model": "local/Qwen3.6-35B-A3B-NVFP4",

  "provider": {

    "local": {
      "name": "Qwen3.6-35B-A3B-NVFP4",
      "options": {
        "baseURL": "http://localhost:8000/v1",
        "apiKey": "EMPTY"
      },
      "models": {
        "Qwen3.6-35B-A3B-NVFP4": {
          "name": "Qwen3.6-35B-A3B-NVFP4",
          "limit": { "context": 65536, "output": 8192 }
        }
      }
    }

  }

}
```

Key points:
- `"model"` uses the `provider/model` format: `local/Qwen3.6-35B-A3B-NVFP4`
- The key under `"models"` (`Qwen3.6-35B-A3B-NVFP4`) must **exactly match** what vLLM reports from `/v1/models`
- `"limit.context"` and `"limit.output"` help OpenCode manage prompt length
- `"apiKey": "EMPTY"` is the standard for local endpoints with no auth

---

## Step 4: Start OpenCode

```bash
cd your-project-directory
opencode
```

Inside the TUI, use `/models` to list available models. With only one model configured, there's nothing to switch — OpenCode will use the one you configured.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Connection refused` to localhost:8000 | Verify vLLM is running: `curl http://localhost:8000/v1/models` |
| Model not listing in `/models` | Check the model key in the config matches vLLM's `/v1/models` output exactly |
| HTTP 400 Bad Request | You are missing `--enable-auto-tool-choice` in your vLLM command. OpenCode sends `tool_choice="auto"` by default. Cline does not, which is why Cline worked without this flag. |
| Tool-calling not working | Ensure both `--tool-call-parser qwen3_coder` and `--enable-auto-tool-choice` are in the vLLM args |
| Slow responses | Check GPU memory with `nvidia-smi`; reduce `--max-model-len` if VRAM is full |
| Token limit errors | Verify `"limit": {"context": 65536, "output": 8192"` matches your vLLM `--max-model-len` and `--max-num-batched-tokens`/output settings |

---

## Test Your Setup

```bash
# 1. Test vLLM endpoint directly
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3.6-35B-A3B-NVFP4",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }'

# 2. Test tool calling (with a simple tool definition)
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3.6-35B-A3B-NVFP4",
    "messages": [{"role": "user", "content": "What is 2+2?"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "add",
        "description": "Add two numbers",
        "parameters": {
          "type": "object",
          "properties": {
            "a": {"type": "number"},
            "b": {"type": "number"}
          },
          "required": ["a", "b"]
        }
      }
    }],
    "tool_choice": "auto",
    "max_tokens": 100
  }'
```

The tool-calling test above should return a tool call response — if it returns a 400, go back and check that `--enable-auto-tool-choice` is present.
