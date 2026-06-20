# ConnectX-7 Helper Scripts

Scripts for setting up and verifying dual-cable point-to-point RoCE v2 connectivity between two DGX Spark nodes.

## IP Scheme

| Cable | Interface | spark01 | spark02 |
|-------|-----------|---------|---------|
| 1 (Port 1) | `enp1s0f0np0` | `10.0.1.1/24` | `10.0.1.2/24` |
| 2 (Port 2) | `enP2p1s0f0np0` | `10.0.2.1/24` | `10.0.2.2/24` |

## Usage Order

Run scripts in numbered order:

### 1. Check Status
```bash
./01_check_connectx7_status.sh
```

### 2. Disable NetworkManager for ConnectX-7
NetworkManager tries DHCP on the ConnectX-7 ports and gets stuck, clearing any manually assigned IPs. This script tells NM to ignore them.

```bash
sudo ./02_disable_nm_for_connectx7.sh
```
Run on **both nodes**.

### 3. Assign IPs
Run with `sudo` on each node. The top-level script auto-detects which node it's on:

```bash
sudo ./03_assign_connectx7_ips.sh
```

Or run the node-specific script directly:

```bash
sudo ./03_a_assign_connectx7_ips_node1.sh   # on spark01
sudo ./03_b_assign_connectx7_ips_node2.sh   # on spark02
```

### 4. Verify Connectivity
```bash
./04_verify_connectx7.sh
```
Lists IPs and pings both ports.

### 5. Copy Scripts to spark01 (optional)
```bash
./05_copy_to_spark01.sh
```

## Alternative: Use `nmtui` Instead of Steps 2-3

Instead of running scripts, you can configure the IPs via NetworkManager's text UI:

```bash
sudo nmtui
```

Then:
1. **Edit a connection**
2. Pick `Wired connection 4` (enp1s0f0np0) → set **IPv4 configuration** to **Manual** → add address `10.0.1.2/24` (spark02) or `10.0.1.1/24` (spark01) → OK
3. Pick `Wired connection 1` (enP2p1s0f0np0) → set **IPv4 configuration** to **Manual** → add address `10.0.2.2/24` (spark02) or `10.0.2.1/24` (spark01) → OK
4. **Activate a connection** → deactivate and reactivate both to apply

This makes the IPs persistent across reboots.

## Interface Notes

Each physical QSFP112 port exposes 2 PCI functions (f0 and f1). These scripts use the **f0 (np0)** interface for data. The f1 interfaces are reserved.
