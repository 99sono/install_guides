#!/bin/bash
# =============================================================================
# 05_disable_nm_for_connectx7.sh
# Tell NetworkManager to stop managing ConnectX-7 interfaces
# =============================================================================
# Why this is needed:
#   NetworkManager tries to get an IP via DHCP on ALL ethernet interfaces,
#   including the ConnectX-7 ports. Since there is no DHCP server on the
#   other end of the point-to-point cable, NM gets stuck in a
#   "connecting (getting IP configuration)" state. This causes NM to
#   repeatedly clear any IP you assign manually with `ip addr add`.
#
# This script creates a config file that tells NM to completely ignore
# the four ConnectX-7 interfaces. After this, manual IP assignment via
# the 02 scripts will stick.
#
# Usage:
#   sudo ./05_disable_nm_for_connectx7.sh
#
# Run on BOTH spark01 and spark02.
# =============================================================================

set -e

CONF_FILE="/etc/NetworkManager/conf.d/99-connectx7-unmanaged.conf"

echo ""
echo "=============================================="
echo " Disable NetworkManager for ConnectX-7"
echo "=============================================="
echo ""

echo " Creating config: $CONF_FILE"
cat > /tmp/99-connectx7-unmanaged.conf << 'EOF'
[keyfile]
unmanaged-devices=interface-name:enp1s0f0np0;interface-name:enp1s0f1np1;interface-name:enP2p1s0f0np0;interface-name:enP2p1s0f1np1
EOF

cp /tmp/99-connectx7-unmanaged.conf "$CONF_FILE"
echo " Written."
echo ""

echo " Reloading NetworkManager..."
systemctl reload NetworkManager
echo ""

echo " Verifying..."
sleep 2
echo ""
for dev in enp1s0f0np0 enp1s0f1np1 enP2p1s0f0np0 enP2p1s0f1np1; do
  state=$(nmcli -t -f GENERAL.STATE dev show "$dev" 2>/dev/null | head -1 || echo "unmanaged")
  echo "  $dev → $state"
done
echo ""

echo "=============================================="
echo " Done. Now run the IP assignment script:"
echo "   spark01: sudo ./02_a_assign_connectx7_ips_node1.sh"
echo "   spark02: sudo ./02_b_assign_connectx7_ips_node2.sh"
echo "=============================================="
