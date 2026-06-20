# ConnectX-7 Helper Scripts

Scripts for setting up and verifying dual-cable point-to-point RoCE v2 connectivity between two DGX Spark nodes.

## IP Scheme

| Cable | Interface | spark01 | spark02 |
|-------|-----------|---------|---------|
| 1 (Port 1) | `enp1s0f0np0` | `10.0.1.1/24` | `10.0.1.2/24` |
| 2 (Port 2) | `enP2p1s0f0np0` | `10.0.2.1/24` | `10.0.2.2/24` |

## Usage

### 1. Check Status

Run on both nodes to verify ConnectX-7 detection, link state, and speed:

```bash
./01_check_connectx7_status.sh
```

### 2. Assign IPs

Run with `sudo` on each node. The top-level script auto-detects which node it's on from the hostname:

```bash
sudo ./02_assign_connectx7_ips.sh
```

Or run the node-specific script directly:

```bash
sudo ./02_a_assign_connectx7_ips_node1.sh   # on spark01
sudo ./02_b_assign_connectx7_ips_node2.sh   # on spark02
```

### 3. Verify Connectivity

```bash
# From spark01:
ping -c 3 10.0.1.2
ping -c 3 10.0.2.2

# From spark02:
ping -c 3 10.0.1.1
ping -c 3 10.0.2.1
```

## Interface Notes

Each physical QSFP112 port on the DGX Spark exposes 2 PCI functions (f0 and f1). These scripts use the **f0 (np0)** interface for data. The f1 interfaces are reserved — they can be configured identically for additional bandwidth if needed.
