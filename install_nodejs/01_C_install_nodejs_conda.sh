#!/usr/bin/env bash
# =============================================================================
# 01_C_install_nodejs_conda.sh
# Install Node.js into a dedicated Conda (conda-forge) environment.
#
# Prerequisite: Miniforge3 / Miniconda3 / Anaconda must be installed and
#               available on PATH. See ../conda_miniforge3/ for setup.
#
# Why this method?
#   - No root / sudo required.
#   - Node.js lives in an isolated environment, so it never clashes with a
#     system Node installed via apt / NodeSource / the official tarball.
#   - Easy to pin or swap versions, and trivial to remove.
#
# Usage:
#   ./01_C_install_nodejs_conda.sh
#   NODE_VERSION=24.19 ./01_C_install_nodejs_conda.sh   # pin a specific version
# =============================================================================

set -euo pipefail

# ---------------------------------------------
# Configuration
# ---------------------------------------------
NODE_VERSION="${NODE_VERSION:-24.19}"                  # any conda-forge Node.js build (major.minor)
ENV_NAME="${ENV_NAME:-nodejs_${NODE_VERSION//./_}}"     # e.g. nodejs_24_19
CHANNEL="conda-forge"

echo "🚀 Installing Node.js ${NODE_VERSION} via Conda (${CHANNEL})"

# ---------------------------------------------
# 0. Sanity checks
# ---------------------------------------------
if ! command -v conda >/dev/null 2>&1; then
    echo "❌ 'conda' not found on PATH." >&2
    echo "   Install Miniforge3 first (see ../conda_miniforge3/) and open a new shell." >&2
    exit 1
fi
echo "Using conda: $(conda --version)"

# ---------------------------------------------
# 1. Show which Node.js builds are available
# ---------------------------------------------
echo
echo "Available Node.js builds on ${CHANNEL} for ${NODE_VERSION}:"
conda search -c "${CHANNEL}" "nodejs=${NODE_VERSION}" 2>/dev/null | grep '^nodejs' || \
    echo "   ⚠️  No 'nodejs=${NODE_VERSION}' build found on ${CHANNEL}."

# ---------------------------------------------
# 2. Handle an environment that already exists
# ---------------------------------------------
if conda env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
    echo
    read -r -p "⚠️  Environment '${ENV_NAME}' already exists. Recreate it? [y/N]: " REPLY
    if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
        echo "Keeping existing environment '${ENV_NAME}'."
    else
        echo "Removing old environment '${ENV_NAME}'..."
        conda env remove -n "${ENV_NAME}" -y
        conda create -n "${ENV_NAME}" -c "${CHANNEL}" "nodejs=${NODE_VERSION}" -y
    fi
else
    # ---------------------------------------------
    # 3. Create the environment with a pinned Node.js version
    # ---------------------------------------------
    conda create -n "${ENV_NAME}" -c "${CHANNEL}" "nodejs=${NODE_VERSION}" -y
fi

# ---------------------------------------------
# 4. Verify & print next steps
# ---------------------------------------------
echo
echo "✅ Node.js ${NODE_VERSION} is available in environment '${ENV_NAME}'."
echo
echo "To use it:"
echo "    conda activate ${ENV_NAME}"
echo "    node -v"
echo "    npm -v"
echo
echo "To remove it later:"
echo "    conda env remove -n ${ENV_NAME} -y"