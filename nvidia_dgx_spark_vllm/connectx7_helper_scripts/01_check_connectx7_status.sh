#!/bin/bash
# =============================================================================
# 01_check_connectx7_status.sh
# DGX Spark ConnectX-7 Status Check
# =============================================================================
# Run this script on each DGX Spark node to verify the ConnectX-7 RDMA
# interfaces, link status, speeds, and current IP assignments.
#
# Usage:
#   chmod +x 01_check_connectx7_status.sh
#   sudo ./01_check_connectx7_status.sh    # (recommended for full output)
#   ./01_check_connectx7_status.sh          # (some checks may skip without sudo)
#
# What this checks:
#   1. Mellanox/ConnectX devices visible via lspci
#   2. RDMA device state and link rate (ibstatus or sysfs)
#   3. Network interface carrier, operstate, and current IPs
#   4. PCI bus info and driver details per interface
#   5. Summary table at the end
# =============================================================================

set -e

echo ""
echo "=============================================="
echo " DGX Spark ConnectX-7 Status Check"
echo " Running on: $(hostname)"
echo " Date:       $(date)"
echo "=============================================="
echo ""

# ---- 1. PCI Devices ----
echo "——————————————————————————————————————————————"
echo " [1] Mellanox / ConnectX PCI Devices"
echo "——————————————————————————————————————————————"
lspci 2>/dev/null | grep -i mellanox || echo "  (no Mellanox devices found via lspci)"
echo ""

# ---- 2. RDMA / InfiniBand Devices ----
echo "——————————————————————————————————————————————"
echo " [2] RDMA Device Status (via sysfs)"
echo "——————————————————————————————————————————————"
if [ -d /sys/class/infiniband ]; then
  for rdma in /sys/class/infiniband/*/; do
    name=$(basename "$rdma")
    desc=$(cat "${rdma}node_desc" 2>/dev/null || echo "N/A")
    echo ""
    echo "  Device : $name"
    echo "  Desc   : $desc"
    for port in "${rdma}ports/"*/; do
      p=$(basename "$port")
      state=$(cat "${port}state" 2>/dev/null || echo "?")
      phys=$(cat "${port}phys_state" 2>/dev/null || echo "?")
      rate=$(cat "${port}rate" 2>/dev/null || echo "?")
      link=$(cat "${port}link_layer" 2>/dev/null || echo "?")
      echo "  Port $p : state=$state | phys=$phys | rate=$rate | link_layer=$link"
    done
  done
else
  echo "  (no /sys/class/infiniband — RDMA drivers may not be loaded)"
fi
echo ""

# Also try ibstatus if available
if command -v ibstatus &>/dev/null; then
  echo "  --- ibstatus output ---"
  ibstatus 2>&1 | sed 's/^/  /'
  echo ""
fi

# ---- 3. Network Interfaces ----
echo "——————————————————————————————————————————————————————————————"
echo " [3] ConnectX-7 Network Interfaces (driver=mlx5_core)"
echo "——————————————————————————————————————————————————————————————"
found=0
for dev in /sys/class/net/*/; do
  if [ -f "${dev}device/uevent" ]; then
    driver=$(cat "${dev}device/uevent" 2>/dev/null | grep DRIVER | cut -d= -f2 || echo "")
  else
    driver=""
  fi
  ifname=$(basename "$dev")

  if [ "$driver" = "mlx5_core" ]; then
    found=1
    carrier=$(cat "${dev}carrier" 2>/dev/null || echo "?")
    operstate=$(cat "${dev}operstate" 2>/dev/null || echo "?")
    mac=$(cat "${dev}address" 2>/dev/null || echo "?")
    mtu=$(cat "${dev}mtu" 2>/dev/null || echo "?")
    ipv4=$(ip -4 addr show "$ifname" 2>/dev/null | grep "inet " | awk '{print $2}' | tr '\n' ' ' || echo "(none)")
    bus=$(cat "${dev}device/uevent" 2>/dev/null | grep PCI_SLOT_NAME | cut -d= -f2 || echo "?")

    # Map to RDMA device
    rdma_dev=""
    if [ -d "${dev}device/infiniband" ]; then
      rdma_dev=$(ls "${dev}device/infiniband/" 2>/dev/null | tr '\n' ' ')
    fi

    echo "  Interface : $ifname"
    echo "  PCI Slot  : $bus"
    echo "  MAC       : $mac"
    echo "  MTU       : $mtu"
    echo "  Carrier   : $carrier  (1=link up, 0=link down)"
    echo "  Operstate : $operstate"
    echo "  IPv4      : $ipv4"
    echo "  RDMA dev  : $rdma_dev"
    echo ""
  fi
done

if [ "$found" -eq 0 ]; then
  echo "  (no mlx5_core interfaces found)"
fi

# ---- 4. Summary Table ----
echo "——————————————————————————————————————————————————————————————"
echo " [4] Summary Table"
echo "——————————————————————————————————————————————————————————————"
printf "  %-20s %-8s %-10s %-18s %-20s\n" "Interface" "Carrier" "Speed" "IPv4" "RDMA Device"
printf "  %-20s %-8s %-10s %-18s %-20s\n" "--------------------" "-------" "----------" "-----------------" "--------------------"
for dev in /sys/class/net/*/; do
  driver=$(cat "${dev}device/uevent" 2>/dev/null | grep DRIVER | cut -d= -f2 || echo "")
  if [ "$driver" = "mlx5_core" ]; then
    ifname=$(basename "$dev")
    carrier=$(cat "${dev}carrier" 2>/dev/null || echo "?")
    ipv4=$(ip -4 addr show "$ifname" 2>/dev/null | grep "inet " | awk '{print $2}' | tr '\n' ' ' || echo "-")
    # Get rate from RDMA
    rdma=""
    if [ -d "${dev}device/infiniband" ]; then
      rdma=$(ls "${dev}device/infiniband/" 2>/dev/null | tr '\n' ' ')
      # Try to get rate from first RDMA port
      for r in ${dev}device/infiniband/*/ports/*/rate; do
        sp=$(cat "$r" 2>/dev/null)
        if [ -n "$sp" ]; then
          speed="$sp"
          break
        fi
      done
    fi
    printf "  %-20s %-8s %-10s %-18s %-20s\n" "$ifname" "$carrier" "${speed:-?}" "${ipv4:0-18}" "$rdma"
    speed=""
  fi
done
echo ""

echo "=============================================="
echo " Check complete."
echo "=============================================="
echo ""
echo " Key:"
echo "   Carrier=1  -> Physical link is UP"
echo "   Carrier=0  -> Physical link is DOWN"
echo "   Speed      -> Active link speed (e.g. '200 Gb/sec')"
echo "   state=4    -> PORT_ACTIVE (RDMA link is up)"
echo "   state=1    -> PORT_DOWN (no link)"
echo ""

