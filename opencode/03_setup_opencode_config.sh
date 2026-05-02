#!/bin/bash
# =============================================================================
# 03_setup_opencode_config.sh
# Deploys OpenCode configuration to the standard location
# =============================================================================

set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
TEMPLATE_FILE="./opencode_config.json.template"

echo "🔧 Setting up OpenCode configuration..."

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Config template not found at '$TEMPLATE_FILE'"
    echo "Make sure to run this script from the opencode/ directory."
    exit 1
fi

# Create config directory if it doesn't exist
echo "📁 Creating config directory: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# Check if a config already exists
if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  Config already exists at '$CONFIG_FILE'"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing config."
        exit 0
    fi
    echo "Backing up old config..."
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    echo "Backup saved to: ${CONFIG_FILE}.backup"
fi

# Copy the template to the config location
echo "📋 Deploying config to: $CONFIG_FILE"
cp "$TEMPLATE_FILE" "$CONFIG_FILE"

echo ""
echo "✅ OpenCode configuration deployed successfully!"
echo ""
echo "Before using OpenCode, make sure to:"
echo ""
echo "1. Update the model endpoint in the config if needed:"
echo "   $CONFIG_FILE"
echo ""
echo "   - Change \"baseURL\" from http://localhost:8080/v1 to your actual vLLM endpoint"
echo "   - Set \"apiKey\" if your endpoint requires authentication"
echo ""
echo "2. Start your local model (vLLM serving Qwen3.6-35B-A3B-NVFP4)"
echo ""
echo "3. Launch OpenCode:"
echo "    conda activate opencode"
echo "    opencode"
echo ""
echo "For more info, see: opencode/opencode_getting_started_guide.md"