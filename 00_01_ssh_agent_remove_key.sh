#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.ssh/agent-env"
KEY_PATH="$HOME/.ssh/id_ed25519"

# --- 1. Check if env file exists ---
if [[ ! -f "$ENV_FILE" ]]; then
    echo "⚠ No agent-env file found. Nothing to remove."
    exit 0
fi

# --- 2. Load environment variables ---
# shellcheck source=/dev/null
source "$ENV_FILE"

# --- 3. Check if agent process is alive ---
if [[ -z "${SSH_AGENT_PID:-}" ]] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    echo "⚠ SSH agent PID $SSH_AGENT_PID is not running. Cleaning up env file."
    rm -f "$ENV_FILE"
    exit 0
fi

# --- 4. Check if agent is responsive ---
if ! ssh-add -l >/dev/null 2>&1; then
    echo "⚠ SSH agent exists but is unresponsive. Killing it."
    kill "$SSH_AGENT_PID" || true
    rm -f "$ENV_FILE"
    exit 0
fi

echo "✓ SSH agent is running and responsive (PID $SSH_AGENT_PID)."

# --- 5. Remove key if loaded ---
if ssh-add -l 2>/dev/null | grep -qF "$KEY_PATH"; then
    ssh-add -d "$KEY_PATH"
    echo "✓ Removed key: $KEY_PATH"
else
    echo "ℹ Key was not loaded in the agent."
fi

# --- 6. Optional: stop the agent entirely ---
if [[ "${1:-}" == "--kill" ]]; then
    echo "✓ Stopping SSH agent."
    kill "$SSH_AGENT_PID" || true
    rm -f "$ENV_FILE"
else
    echo "ℹ Agent left running. Use '--kill' to stop it."
fi
