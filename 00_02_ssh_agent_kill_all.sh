#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.ssh/agent-env"

echo "ℹ Killing all running ssh-agent processes..."

if pkill -x ssh-agent 2>/dev/null; then
    echo "✓ ssh-agent process(es) terminated successfully."
else
    echo "ℹ No ssh-agent processes found (already stopped)."
fi

# --- Clean up stale environment file ---
if [[ -f "$ENV_FILE" ]]; then
    rm -f "$ENV_FILE"
    echo "✓ Removed stale agent env file: $ENV_FILE"
else
    echo "ℹ No agent env file found at $ENV_FILE."
fi

echo ""
echo "Done. All ssh-agent processes have been stopped."