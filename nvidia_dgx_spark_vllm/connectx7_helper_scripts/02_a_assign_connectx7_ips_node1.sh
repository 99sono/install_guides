#!/bin/bash
# =============================================================================
# 02_a_assign_connectx7_ips_node1.sh
# Assign ConnectX-7 IPs on spark01
# =============================================================================
# IP assignments:
#   enp1s0f0np0  → 10.0.1.1/24  (Cable 1 — Port 1)
#   enP2p1s0f0np0 → 10.0.2.1/24  (Cable 2 — Port 2)
#
# Usage:
#   sudo ./02_a_assign_connectx7_ips_node1.sh
# =============================================================================

NODE_NAME="spark01"
PORT1_IFACE="enp1s0f0np0"
PORT1_IP="10.0.1.1/24"
PORT2_IFACE="enP2p1s0f0np0"
PORT2_IP="10.0.2.1/24"

echo ""
echo "=============================================="
echo " Assigning ConnectX-7 IPs on $NODE_NAME"
echo "=============================================="
echo ""

assign_ip() {
  local iface="$1"
  local ip="$2"
  local label="$3"
  if ip link show "$iface" &>/dev/null; then
    echo "  [$label] $iface → $ip"
    ip addr add "$ip" dev "$iface"
  else
    echo "  WARNING: Interface $iface not found — skipping."
  fi
}

echo " --- Port 1 (Cable 1) ---"
assign_ip "$PORT1_IFACE" "$PORT1_IP" "Port 1"
echo ""

echo " --- Port 2 (Cable 2) ---"
assign_ip "$PORT2_IFACE" "$PORT2_IP" "Port 2"
echo ""

echo " --- Verification ---"
ip -4 addr show "$PORT1_IFACE" 2>/dev/null | grep inet | sed 's/^/    /'
ip -4 addr show "$PORT2_IFACE" 2>/dev/null | grep inet | sed 's/^/    /'
echo ""

echo " --- Test connectivity ---"
echo "  Run on spark02:"
echo "    ping -c 3 10.0.1.1"
echo "    ping -c 3 10.0.2.1"
echo ""

echo "=============================================="
echo " Done."
echo "=============================================="
