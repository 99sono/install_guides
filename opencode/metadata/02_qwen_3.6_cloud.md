Yes, exactly! That's the missing piece. 

Looking at your original Docker Compose config, you have:
```yaml
- "--tool-call-parser"
- "qwen3_coder"
```

But you're **missing**:
```yaml
- "--enable-auto-tool-choice"
```

## ✅ Fix: Update Your Docker Compose

Add this line to your `command` section in the docker-compose.yml:

```yaml
# --- TOOL CALLING (Required for OpenCode) ---
- "--enable-auto-tool-choice"
- "--tool-call-parser"
- "qwen3_coder"
```

Then restart:
```bash
docker compose down
docker compose up -d
```

## 🔍 Why This Happens

- **Cline works** because it likely uses `tool_choice="none"` or handles tool calls differently—more forgiving
- **OpenCode fails** because it sends `tool_choice="auto"` by default, which requires explicit server-side enablement
- The **400 Bad Request** in your logs (IP `172.18.0.1:58280`) is OpenCode hitting this exact error

## 📝 Full Recommended Additions

For completeness, your tool-calling section should look like:

```yaml
# --- TOOL CALLING ---
- "--enable-auto-tool-choice"
- "--tool-call-parser"
- "qwen3_coder"
- "--reasoning-parser"
- "qwen3"
```

You already have `--reasoning-parser` and `--tool-call-parser`, so you just need to add `--enable-auto-tool-choice`.

Go ahead and restart vLLM with that flag—OpenCode should start working immediately after! 🚀