#!/bin/bash
# =============================================================================
# 02_assign_connectx7_ips.sh — Top-level IP assignment script
# =============================================================================
# Detects which node this is and delegates to the correct sub-script.
#
# Usage:
#   sudo ./02_assign_connectx7_ips.sh
#
# Detection logic:
#   - Checks the hostname for "1" or "2" (spark01, spark02, node1, node2, etc.)
#   - Falls back to interactive prompt if ambiguous
# =============================================================================

set -e

echo ""
echo "=============================================="
echo " ConnectX-7 IP Assignment"
echo "=============================================="
echo ""

HOSTNAME=$(hostname)

# Auto-detect node from hostname
case "$HOSTNAME" in
  *1*)
    NODE=1
    ;;
  *2*)
    NODE=2
    ;;
  *)
    echo "  Could not auto-detect node from hostname '$HOSTNAME'."
    echo ""
    echo "  Which node is this?"
    echo "    1) spark01 (Port 1: 10.0.1.1  | Port 2: 10.0.2.1)"
    echo "    2) spark02 (Port 1: 10.0.1.2  | Port 2: 10.0.2.2)"
    read -p "  Enter 1 or 2: " NODE
    echo ""
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$NODE" in
  1)
    echo "  Detected: spark01"
    echo "  Running: 02_a_assign_connectx7_ips_node1.sh"
    echo ""
    exec sudo "${SCRIPT_DIR}/02_a_assign_connectx7_ips_node1.sh"
    ;;
  2)
    echo "  Detected: spark02"
    echo "  Running: 02_b_assign_connectx7_ips_node2.sh"
    echo ""
    exec sudo "${SCRIPT_DIR}/02_b_assign_connectx7_ips_node2.sh"
    ;;
  *)
    echo "  Invalid choice. Please run again and enter 1 or 2."
    exit 1
    ;;
esac
