#!/bin/bash
# =============================================================================
# 04_verify_connectx7.sh
# Validate ConnectX-7 IP assignments and test ping to the other node
# =============================================================================
# Usage:
#   sudo ./04_verify_connectx7.sh
#
# Run this after assigning IPs on both nodes.
# The script detects which node it is on (from the hostname) and uses
# the opposite IPs as ping targets.
# =============================================================================

HOSTNAME=$(hostname)

# Determine node
case "$HOSTNAME" in
  *1*) OTHER="spark01"; PORT1_IP="10.0.1.1"; PORT2_IP="10.0.2.1"; PING1="10.0.1.2"; PING2="10.0.2.2" ;;
  *2*) OTHER="spark02"; PORT1_IP="10.0.1.2"; PORT2_IP="10.0.2.2"; PING1="10.0.1.1"; PING2="10.0.2.1" ;;
  *)
    echo "Could not detect node from hostname. Run node-specific script:"
    echo "  04_a_verify_connectx7_node1.sh  (on spark01)"
    echo "  04_b_verify_connectx7_node2.sh  (on spark02)"
    exit 1
    ;;
esac

echo "=============================================="
echo " ConnectX-7 Verification on $OTHER"
echo "=============================================="
echo ""

# --- Check IPs ---
echo "--- IP assignments ---"
ip -4 addr show enp1s0f0np0 2>/dev/null | grep inet | sed 's/^/  Port 1: /'
ip -4 addr show enP2p1s0f0np0 2>/dev/null | grep inet | sed 's/^/  Port 2: /'
echo ""

# --- Ping tests ---
echo "--- Testing Port 1 (10.0.1.x) ---"
ping -c 3 -W 2 $PING1 2>&1 | sed 's/^/  /'
echo ""

echo "--- Testing Port 2 (10.0.2.x) ---"
ping -c 3 -W 2 $PING2 2>&1 | sed 's/^/  /'
echo ""

echo "=============================================="
echo " Done. Summary:"
echo "  $OTHER: $PORT1_IP  <->  $PING1 (Port 1)"
echo "  $OTHER: $PORT2_IP  <->  $PING2 (Port 2)"
echo "=============================================="
