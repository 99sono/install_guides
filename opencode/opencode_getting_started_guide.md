# 🚀 OpenCode Setup Guide for Dummies

## Author
Qwen 3.6 plus.

## Disclaimer (personal) - untested guide
These notes are not yet verified. My current workflow uses 'cline' via CLI for local development. This guide facilitates experimentation with OpenCode; I’m still deciding if I should try ForgeCode first.

Note: Consider all vll serve calls to be incorrect. Getting a model to be served by vLLM is an art, requires testing, read theam as fillers.

## Dual-Hardware Local + Cloud Workflow (Windows 11 + WSL2)

> **Your Setup**: RTX 5090 (Gemma4 MoE) + DGX Spark (Qwen3.6 35B MoE) + Cloud fallback (OpenRouter)  
> **Goal**: One CLI that routes "brute force" tasks locally, "Einstein" tasks to cloud

---

## 📋 Prerequisites Checklist

```bash
# ✅ Windows 11 with WSL2 installed (Ubuntu 22.04/24.04)
wsl --list --verbose  # Should show Ubuntu as "Running"

# ✅ Node.js 20+ in WSL (for OpenCode CLI)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# ✅ vLLM running on both GPUs (verify endpoints)
curl http://localhost:8080/v1/models  # RTX 5090 endpoint
curl http://dgx-cluster:9000/v1/models  # DGX Spark endpoint

# ✅ OpenRouter API key (for cloud fallback)
# Get one at: https://openrouter.ai/keys
```

---

## 🔧 Step 1: Install OpenCode in WSL2

```bash
# Open your WSL terminal (Ubuntu)

# Method A: Install script (recommended)
curl -fsSL https://opencode.ai/install | bash

# Method B: Via npm (if you prefer)
npm install -g opencode-ai

# Verify installation
opencode --version
# Should output something like: opencode/1.3.0 linux-x64 node-v22.x.x
```

> 💡 **Pro Tip**: Add this alias to `~/.bashrc` for easier access from Windows:
> ```bash
> alias opencode='cd /mnt/c/Users/YourName/project && opencode'
> ```

---

## ⚙️ Step 2: Create Your Multi-Provider Config

OpenCode uses `~/.config/opencode/opencode.json` for global config. Create it:

```bash
mkdir -p ~/.config/opencode
nano ~/.config/opencode/opencode.json
```

Paste this **complete config template** (customize the comments):

```json
{
  "$schema": "https://opencode.ai/config.json",
  
  "model": "local-rtx/gemma4-moe",
  
  "provider": {
    
    "local-rtx": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "RTX 5090 - Gemma4 MoE",
      "options": {
        "baseURL": "http://127.0.0.1:8080/v1",
        "apiKey": "EMPTY"
      },
      "models": {
        "gemma4-moe": {
          "name": "Gemma4 MoE (4-bit, fast)",
          "limit": { "context": 32768, "output": 8192 }
        }
      }
    },
    
    "local-dgx": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "DGX Spark - Qwen3.6 MoE",
      "options": {
        "baseURL": "http://dgx-cluster:9000/v1",
        "apiKey": "EMPTY"
      },
      "models": {
        "qwen3.6-35b-moe": {
          "name": "Qwen3.6 35B MoE (FP16, smart)",
          "limit": { "context": 128000, "output": 32768 }
        }
      }
    },
    
    "openrouter": {
      "name": "OpenRouter - Cloud Fallback",
      "models": {
        "anthropic/claude-opus-4.5": {
          "name": "Claude Opus 4.5 (Einstein mode)"
        },
        "google/gemini-2.5-pro": {
          "name": "Gemini 2.5 Pro (reasoning)"
        },
        "qwen/qwen-3-coder-480b": {
          "name": "Qwen Coder 480B (cloud)"
        }
      }
    }
    
  },
  
  "aliases": {
    "fast": "local-rtx/gemma4-moe",
    "smart": "local-dgx/qwen3.6-35b-moe",
    "einstein": "openrouter/anthropic/claude-opus-4.5",
    "coder": "openrouter/qwen/qwen-3-coder-480b",
    "brute": "local-rtx/gemma4-moe"
  },
  
  "autoRoute": {
    "enabled": true,
    "rules": [
      {
        "pattern": "^(explain|summarize|quick|lint|format)",
        "use": "fast",
        "description": "Simple tasks → RTX 5090"
      },
      {
        "pattern": "^(refactor|optimize|benchmark|analyze|architect)",
        "use": "smart",
        "description": "Complex reasoning → DGX Spark"
      },
      {
        "pattern": "^(solve|prove|research|deep-dive|why)",
        "use": "einstein",
        "description": "Einstein-level → Cloud Claude"
      },
      {
        "pattern": "^(generate|scaffold|boilerplate|test)",
        "use": "coder",
        "description": "Code generation → Cloud Qwen Coder"
      }
    ]
  }
}
```

### 🔑 Critical Notes:
1. **`npm": "@ai-sdk/openai-compatible"`** tells OpenCode to use the OpenAI-compatible API parser (works with vLLM, llama.cpp, NIM) [[45]]
2. **`"apiKey": "EMPTY"`** is required for local endpoints that don't use auth [[45]]
3. **`limit.context`** helps OpenCode manage prompt length for your local models
4. **`aliases`** let you switch models with `/model fast` instead of typing full IDs
5. **`autoRoute`** (if supported in your OpenCode version) auto-selects models based on prompt keywords

---

## 🔐 Step 3: Add Your OpenRouter API Key

```bash
# Start OpenCode interactive mode
opencode

# Inside the TUI, type:
/connect
```

1. Select **OpenRouter** from the list
2. Paste your API key when prompted
3. Press `Enter` to save

> ✅ Your key is stored securely in `~/.local/share/opencode/auth.json` [[15]]

---

## 🖥️ Step 4: Launch Your Local vLLM Endpoints

### RTX 5090 (Gemma4 MoE via vLLM)
```bash
# On your RTX 5090 machine (or WSL with GPU passthrough)
vllm serve google/gemma-3n-e4b-it \
  --port 8080 \
  --host 127.0.0.1 \
  --tensor-parallel-size 1 \
  --max-model-len 32768 \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
```

### DGX Spark (Qwen3.6 35B MoE via NIM/vLLM)
```bash
# Option A: NVIDIA NIM container
docker run --gpus all -p 9000:8000 \
  nvcr.io/nim/qwen/qwen3-32b:latest \
  --tensor-parallel-size 8 \
  --max-num-seqs 256

# Option B: vLLM directly
vllm serve Qwen/Qwen3-32B \
  --port 9000 \
  --host 0.0.0.0 \
  --tensor-parallel-size 8 \
  --max-model-len 128000 \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
```

> 💡 **Network Tip**: If DGX is on a different machine, ensure port 9000 is reachable from your WSL instance. Use `http://<dgx-ip>:9000/v1` in config instead of `localhost`.

---

## 🎮 Step 5: Using OpenCode – Daily Workflow

### Start OpenCode in your project
```bash
cd /mnt/c/Users/YourName/my-project
opencode
```

### Switch models on the fly
```
/models                    # List all available models
/model fast               # Switch to RTX 5090 Gemma4
/model smart              # Switch to DGX Qwen3.6
/model einstein           # Switch to cloud Claude Opus
```

### Example prompts with auto-routing
```
# These will auto-route based on your config rules:

"quick: explain this function"          → RTX 5090 (fast)
"refactor: optimize this database query" → DGX Spark (smart)  
"einstein: why does this race condition happen?" → Cloud Claude
"coder: generate pytest fixtures for auth" → Cloud Qwen Coder
```

### Brute-force code ingestion (local)
```
# When you need to scan tons of code locally:
/model brute
"Analyze these 50 files and find all TODO comments: @src/**/*.ts"

# Gemma4 on RTX 5090 handles large context cheaply + fast
```

### Einstein reasoning (cloud)
```
# When you need deep insight:
/model einstein
"Design a distributed caching strategy for this microservice architecture. Consider consistency, latency, and failure modes."

# Claude Opus on OpenRouter provides top-tier reasoning
```

---

## 🔄 Optional: Project-Specific Overrides

Create `.opencode.json` in your project root to override global settings:

```json
{
  "model": "local-dgx/qwen3.6-35b-moe",
  "autoRoute": {
    "enabled": false
  }
}
```

> This is useful for projects that always need the "smart" model, regardless of prompt keywords.

---

## 🛠️ Troubleshooting Cheat Sheet

| Issue | Solution |
|-------|----------|
| `Connection refused` to local endpoint | Verify vLLM is running: `curl http://localhost:8080/v1/models` |
| Model not appearing in `/models` | Check provider ID matches config; run `opencode auth list` to verify credentials |
| Slow responses from local model | Reduce `--max-model-len` in vLLM; check GPU memory with `nvidia-smi` |
| Cloud model costs too high | Use `autoRoute` rules to limit cloud usage; set `max_tokens` lower in config |
| WSL can't reach DGX IP | Add DGX IP to Windows hosts file; ensure firewall allows port 9000 |
| Tool-calling not working | Add `--enable-auto-tool-choice --tool-call-parser hermes` to vLLM args [[26]] |

---

## 🧪 Test Your Setup (Copy-Paste This)

```bash
# 1. Test RTX 5090 endpoint directly
curl -X POST http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemma4-moe","messages":[{"role":"user","content":"Hello"}]}'

# 2. Test DGX endpoint directly  
curl -X POST http://dgx-cluster:9000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.6-35b-moe","messages":[{"role":"user","content":"Hello"}]}'

# 3. Test OpenCode model listing
opencode --eval "/models"

# 4. Test alias switching
opencode --model fast "What's 2+2?"  # Should use RTX
opencode --model einstein "Explain quantum entanglement"  # Should use cloud
```

---

## 🎯 Pro Tips for Your Workflow

1. **KV-Cache Hint for Local Models**: Add this to your vLLM launch args for better multi-turn performance:
   ```bash
   --enable-prefix-caching --cache-dir /tmp/vllm-cache
   ```

2. **Prompt Prefix for Auto-Route**: If autoRoute isn't working, manually prefix prompts:
   ```
   [fast] Summarize this PR diff...
   [smart] Refactor this module for testability...
   [einstein] What's the optimal algorithm for this NP-hard problem?
   ```

3. **Cost Control for OpenRouter**: In your OpenRouter dashboard, set:
   - Daily spending limit
   - Model allowlist (only enable the 2-3 you actually use)
   - Request logging to audit usage

4. **Backup Config**: Sync your `~/.config/opencode/opencode.json` to git (exclude `auth.json`):
   ```bash
   git add ~/.config/opencode/opencode.json
   git commit -m "feat: opencode multi-provider config"
   ```

---

## 📦 One-Command Setup Script (Optional)

Save this as `setup-opencode.sh` and run once:

```bash
#!/bin/bash
# OpenCode Quick Setup for WSL2 + Dual GPU

echo "🔧 Installing OpenCode..."
curl -fsSL https://opencode.ai/install | bash

echo "📁 Creating config directory..."
mkdir -p ~/.config/opencode

echo "⚙️ Writing multi-provider config..."
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "local-rtx/gemma4-moe",
  "provider": {
    "local-rtx": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "RTX 5090",
      "options": {"baseURL": "http://127.0.0.1:8080/v1", "apiKey": "EMPTY"},
      "models": {"gemma4-moe": {"name": "Gemma4 MoE", "limit": {"context": 32768, "output": 8192}}}
    },
    "local-dgx": {
      "npm": "@ai-sdk/openai-compatible", 
      "name": "DGX Spark",
      "options": {"baseURL": "http://dgx-cluster:9000/v1", "apiKey": "EMPTY"},
      "models": {"qwen3.6-35b-moe": {"name": "Qwen3.6 MoE", "limit": {"context": 128000, "output": 32768}}}
    }
  },
  "aliases": {
    "fast": "local-rtx/gemma4-moe",
    "smart": "local-dgx/qwen3.6-35b-moe",
    "einstein": "openrouter/anthropic/claude-opus-4.5"
  }
}
EOF

echo "✅ Done! Next steps:"
echo "1. Start your vLLM endpoints (RTX 5090 :8080, DGX :9000)"
echo "2. Run 'opencode' and type '/connect' to add your OpenRouter key"
echo "3. Type '/models' to see your configured models"
echo "4. Start coding! Use '/model fast' or '/model einstein' to switch"
```

---

## 🔄 When to Use Which Model

| Task Type | Recommended Model | Why |
|-----------|------------------|-----|
| Code explanation, quick fixes | `fast` (RTX Gemma4/nemotron cascade2) | Low latency 3k prefill, local, fits HBRAM, smart.  |
| Architecture review, refactoring | `smart` (DGX Qwen3.6) | Better reasoning, larger context, slow unified VRAM, slower tokens per second (the DGX 128 GB unified memory is a school bus, not a RTX ferrari) |
| Novel algorithm design, research | `einstein` (Cloud Claude) | State-of-the-art reasoning |
| Boilerplate generation, tests | `coder` (Cloud Qwen Coder) | Optimized for code output |
| Scanning 100+ files for patterns | `brute` (RTX Gemma4) | Local = no API costs, fast ingestion |

---

> 💡 **Final Wisdom**: The OpenAI-compatible API is your true abstraction layer. OpenCode is just a fancy CLI that speaks that language. If OpenCode ever doesn't fit your workflow, you can always drop down to raw `curl` calls to your vLLM endpoints—the config you built today still applies.


