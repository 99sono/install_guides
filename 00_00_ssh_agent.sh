#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.ssh/agent-env"
KEY_PATH="$HOME/.ssh/id_ed25519"

# 1. Clean up stale state
rm -f "$ENV_FILE"

# 2. Reuse existing agent if it's alive and responsive
if [ -n "${SSH_AUTH_SOCK:-}" ] && ssh-add -l &>/dev/null; then
    echo "✓ SSH agent is already running and responsive."
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