## ❌ Claude Code CLI + vLLM = Not Directly Compatible

**Claude Code** (Anthropic's official CLI agent) is tightly coupled to **Anthropic's API format**, not OpenAI's. Key differences:

| Aspect | Anthropic API | OpenAI API (vLLM) |
|--------|--------------|-------------------|
| Endpoint | `POST /v1/messages` | `POST /v1/chat/completions` |
| Auth header | `x-api-key` | `Authorization: Bearer` |
| Tool format | `tools: [{name, description, input_schema}]` | `tools: [{type: "function", function: {...}}]` |
| Thinking blocks | Native `<thinking>` XML support | Requires model-specific parsers (e.g., `--reasoning-parser qwen3`) |

Claude Code expects Anthropic-style responses and will fail to parse OpenAI-formatted outputs from vLLM [[30]][[41]]. While some community projects wrap Claude Code to expose an *OpenAI-compatible* API [[1]][[9]], that's the *reverse* of what you need—you'd need an *Anthropic-compatible* proxy in front of vLLM, which doesn't exist in a stable, production-ready form.

> 🚫 Bottom line: You cannot simply point `claude` CLI at `http://localhost:8000/v1` and expect it to work.

---

## ✅ What *Does* Work with vLLM's OpenAI Endpoint

vLLM implements the OpenAI Completions/Chat API spec [[13]][[53]], so any client built for OpenAI-compatible endpoints will work—*if configured correctly*:

| Agent/Client | Works with vLLM? | Notes |
|--------------|------------------|-------|
| **Cline** (VSCode/CLI) | ✅ Yes | You've confirmed this—Cline is flexible with model outputs [[50]] |
| **OpenCode** | ✅ Yes (with config fixes) | Needs exact model name match + parser flags [[52]] |
| **Aider** | ✅ Yes | `--model local/... --openai-api-base http://localhost:8000/v1` |
| **Continue.dev** | ✅ Yes | Configure `provider: openai, baseURL: http://localhost:8000/v1` |
| **Roo Code** | ✅ Yes | Built for OpenAI-compatible local endpoints [[50]] |
| **Codex CLI** | ⚠️ Deprecated | OpenAI deprecated the original Codex API in 2023; "Codex" now refers to ChatGPT's code features, not a standalone API [[21]][[28]] |

---

## 🔁 About "Codex"

Just to clarify terminology:  
- **Codex** was OpenAI's 2021 code-generation model API, **deprecated in March 2023** [[21]].  
- In 2025, OpenAI reused the "Codex" name for agentic coding features inside ChatGPT subscriptions—but this is **not a public API** you can point at vLLM [[27]][[28]].  
- What you likely want is **any OpenAI-compatible client** (not "Codex") that can talk to vLLM's `/v1` endpoint.

---

## 🎯 Practical Recommendation

Since **Cline already works** with your Qwen3.6-35B vLLM setup, you have two clean paths:

1. **Stick with Cline** for tool-heavy workflows (it's forgiving with model output formats)  
2. **Fix OpenCode config** using the parser flags and model-name alignment we discussed earlier, then use it for lighter tasks

If you *really* want Claude Code in the loop, you'd need an **Anthropic-to-OpenAI translation proxy** (like [CLIPROXY](https://github.com/anthropics/claude-code-proxy) or [NewAPI](https://newapi.pro)), but that adds complexity and potential latency—usually not worth it when Cline already delivers.

---

## 🔍 Quick Diagnostic

To confirm vLLM is serving OpenAI-compatible responses:
```bash
curl -s http://localhost:8000/v1/models | jq '.data[].id'
# Should return: "Qwen3.6-35B-A3B-NVFP4"

curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen3.6-35B-A3B-NVFP4",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }' | jq '.choices[0].message.content'
```
If that returns text, your endpoint is OpenAI-compatible—and any properly configured OpenAI client *should* work.

Let me know if you'd like help testing a specific agent against your endpoint! 🛠️