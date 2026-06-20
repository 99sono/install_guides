# Automated Login Setup

## Overview
This guide shows how to automatically load your SSH keys when starting new terminal sessions in WSL2 Ubuntu, eliminating the need to manually run ssh-agent and ssh-add commands.

## The Script

Save this as `~/.ssh/automated_login.sh` and make it executable:

```bash
#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.ssh/agent-env"
KEY_PATH="$HOME/.ssh/id_ed25519"

# 1. Clean up stale state
rm -f "$ENV_FILE"

# 2. Reuse existing agent (only /usr/bin/ssh-agent, not gcr-ssh-agent)
if pgrep -x ssh-agent &>/dev/null && [ -n "${SSH_AUTH_SOCK:-}" ] && ssh-add -l &>/dev/null; then
    # Persist environment variables so the file can be sourced elsewhere
    printf 'export SSH_AUTH_SOCK="%s"\nexport SSH_AGENT_PID="%s"\n' \
        "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" > "$ENV_FILE"
    chmod 600 "$ENV_FILE"
else
    # Start a new agent
    eval "$(ssh-agent -s)"
    # Persist environment variables safely
    printf 'export SSH_AUTH_SOCK="%s"\nexport SSH_AGENT_PID="%s"\n' \
        "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" > "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    echo "✓ Started new SSH agent."
fi

# 3. Add key only if not already loaded
if ssh-add -l 2>/dev/null | grep -qF "$(basename "$KEY_PATH")"; then
    echo "✓ Key already loaded in agent."
elif [[ -f "$KEY_PATH" ]]; then
    ssh-add "$KEY_PATH"
    echo "✓ Added key: $KEY_PATH"
else
    echo "⚠ Warning: Key not found at $KEY_PATH" >&2
fi

echo ""
echo "SSH agent started and key added. To use the agent in your shell, or in another terminal, run:"
echo "  source $ENV_FILE"
```

### Shell Profile Integration

Add to `~/.bashrc` or `~/.zshrc`:

```bash
source ~/.ssh/automated_login.sh
```

### How It Works

1. **`rm -f "$ENV_FILE"`** — cleans stale environment file from dead agents
2. **`pgrep -x ssh-agent`** — checks specifically for `/usr/bin/ssh-agent` (not gcr-ssh-agent)
3. **`ssh-add -l`** — confirms the agent is alive and responsive (not just a stale PID)
4. **Key check** — only adds the key if it's not already loaded (idempotent)
5. **Graceful fallback** — warns if the key file is missing instead of hard-failing

## Testing Your Setup

### 1. Reload Your Shell Configuration
```bash
source ~/.bashrc  # or ~/.zshrc for zsh
```

### 2. Verify SSH Agent Started
```bash
echo $SSH_AUTH_SOCK
```

### 3. Check Loaded Keys
```bash
ssh-add -l
```

### 4. Test Git Operations
```bash
cd /path/to/your/repo
git fetch origin
```

## Troubleshooting

### Issue: Passphrase Prompt on Every Terminal
The agent is not being reused — likely the `ssh-add -l` check is failing. Verify the existing agent check works:
```bash
ssh-add -l 2>/dev/null && echo "agent responsive" || echo "agent not responsive"
```

### Issue: Multiple SSH Agents
The `rm -f "$ENV_FILE"` cleanup and `ssh-add -l` gate prevent duplicate agents. If this still occurs, ensure you're not sourcing the agent start multiple times.

### Issue: "Too many authentication failures"
The script adds the key conditionally on each shell startup (`ssh-add -l | grep -qF`), so re-adding is prevented. If you have additional keys, add them in the script once below the existing key section.

## Security Considerations

- **Memory-only**: Keys reside in the SSH agent's memory, not on disk
- **Stale cleanup**: `rm -f "$ENV_FILE"` prevents connecting to dead agents
- **Environment file**: `chmod 600` on the env file — only readable by you
- **Source required**: External terminals must `source $ENV_FILE` to use the agent
