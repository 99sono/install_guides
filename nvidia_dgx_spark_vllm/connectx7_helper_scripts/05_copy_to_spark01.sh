#!/bin/bash
# =============================================================================
# 03_copy_to_spark01.sh
# Copy the helper scripts to spark01 via SCP
# =============================================================================
# Usage:
#   ./03_copy_to_spark01.sh
#
# Edit the USER and IP below if your spark01 credentials differ.
# =============================================================================

USER="sono99"
HOST="192.168.1.55"
REMOTE_DIR="~/connectx7_helper_scripts"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "Copying helper scripts to ${USER}@${HOST}:${REMOTE_DIR} ..."
echo ""

scp -r "${SCRIPT_DIR}" "${USER}@${HOST}:${REMOTE_DIR}"

echo ""
echo "Done. On spark01, run:"
echo "  cd ~/connectx7_helper_scripts"
echo "  ./01_check_connectx7_status.sh"
echo ""
