#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------
# Configuration
# ---------------------------------------------
NODE_VERSION="v25.9.0"
NODE_DIST="node-${NODE_VERSION}-linux-x64"
NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_DIST}.tar.xz"
INSTALL_PREFIX="/usr/local"

# ---------------------------------------------
# 1. Install required system dependency
#    xz-utils is needed to extract .tar.xz files
# ---------------------------------------------
echo "Installing required dependencies..."
sudo apt update
sudo apt install -y xz-utils

# ---------------------------------------------
# 2. Download Node.js binary tarball
# ---------------------------------------------
echo "Downloading Node.js ${NODE_VERSION}..."
cd /tmp
curl -fLO "${NODE_URL}"

# ---------------------------------------------
# 3. Remove any previous Node installation
#    (important if Node was installed via NodeSource or apt)
# ---------------------------------------------
echo "Removing existing Node.js binaries (if any)..."
sudo rm -f  "${INSTALL_PREFIX}/bin/node"
sudo rm -f  "${INSTALL_PREFIX}/bin/npm"
sudo rm -f  "${INSTALL_PREFIX}/bin/npx"
sudo rm -rf "${INSTALL_PREFIX}/lib/node_modules"
sudo rm -rf "${INSTALL_PREFIX}/include/node"
sudo rm -rf "${INSTALL_PREFIX}/share/man/man1/node.1"

# ---------------------------------------------
# 4. Extract Node.js into /usr/local
#    --strip-components=1 removes the top-level folder
# ---------------------------------------------
echo "Installing Node.js to ${INSTALL_PREFIX}..."
sudo tar --strip-components=1 -xJf "${NODE_DIST}.tar.xz" -C "${INSTALL_PREFIX}"

# ---------------------------------------------
# 5. Verify installation
# ---------------------------------------------
echo
echo "Node.js installation complete:"
node -v
npm -v
echo "Node binary path: $(which node)"
