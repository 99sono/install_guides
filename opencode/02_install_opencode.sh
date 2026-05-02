#!/bin/bash
# =============================================================================
# 02_install_opencode.sh
# Installs OpenCode globally via npm inside the conda environment
# =============================================================================

set -euo pipefail

ENV_NAME="opencode"

echo "📦 Installing OpenCode..."

# Check if the conda environment exists
if ! conda env list | grep -q "^$ENV_NAME "; then
    echo "❌ Error: Conda environment '$ENV_NAME' does not exist."
    echo "Please run 01_create_open_code_conda_env.sh first."
    exit 1
fi

# Note: We use 'conda run' instead of 'conda activate' because conda activate
# does not work in non-interactive shell scripts. 'conda run' executes commands
# within the specified environment without needing to activate it.

# Verify Node.js is available in the environment
echo "🔍 Checking Node.js version..."
conda run -n "$ENV_NAME" node --version

# Verify npm is available in the environment
echo "🔍 Checking npm version..."
conda run -n "$ENV_NAME" npm --version

# Install OpenCode globally via npm inside the conda environment
echo "🚀 Installing opencode-ai globally..."
conda run -n "$ENV_NAME" npm install -g opencode-ai

# Verify installation
echo ""
echo "✅ OpenCode installation complete!"
echo ""
echo "To verify, run:"
echo "    conda run -n $ENV_NAME opencode --version"
echo ""
echo "Or activate the environment first:"
echo "    conda activate $ENV_NAME"
echo "    opencode --version"
echo ""
echo "For more info, see: opencode/opencode_getting_started_guide.md"