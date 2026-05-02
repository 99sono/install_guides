#!/bin/bash
# =============================================================================
# 01_create_open_code_conda_env.sh
# Creates a clean conda environment for OpenCode (Node.js-based CLI tool)
# =============================================================================

set -euo pipefail

ENV_NAME="opencode"

echo "🚀 Creating conda environment: $ENV_NAME"

# Check if environment already exists
if conda env list | grep -q "^$ENV_NAME "; then
    echo "⚠️  Environment '$ENV_NAME' already exists."
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing environment."
        exit 0
    fi
    echo "Removing old environment..."
    conda env remove -n "$ENV_NAME" -y
fi

# Create new environment (Node.js version is left to conda's discretion)
conda create -n "$ENV_NAME" -y

echo "✅ Environment '$ENV_NAME' created successfully."
echo ""
echo "To activate it, run:"
echo "    conda activate $ENV_NAME"
echo ""
echo "Next step: Install OpenCode with 02_install_opencode.sh"