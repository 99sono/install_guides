# DGX Spark Networking Primer

Understanding Linux networking on the Grace-Blackwell GB10 | ConnectX-7 vs Regular Ethernet

---

## Why This Guide Exists

A DGX Spark doesn't have a "normal" PC networking layout. It has **two networking domains**:

1. **Regular Ethernet** — Realtek PCIe NIC, connects to your home/office LAN, gets an IP via DHCP. This is `192.168.1.x` traffic.
2. **ConnectX-7 (QSFP112)** — Dual-port 200/400 Gb/s RDMA adapter for inter-node GPU communication. This is `10.0.x.x` cluster traffic.

Newcomers run `ip link` or `lspci` and see cryptic names like `enP7s7`, `enp1s0f0np0`, `rocep1s0f0` and have no idea what is what. This guide walks through every interface on a real DGX Spark and explains how to read the naming, purpose, and relationship between the pieces.

---

## 1. The Network Interfaces at a Glance

Here is the output of `ip link show` on a real DGX Spark (spark02):

```
1: lo: ...
2: enP7s7: <BROADCAST,MULTICAST,UP,LOWER_UP> ...  ← Regular Ethernet (to your router)
3: enp1s0f0np0: <BROADCAST,MULTICAST,UP,LOWER_UP>  ← ConnectX-7 Port 1, Function 0
4: enp1s0f1np1: <BROADCAST,MULTICAST,UP,LOWER_UP>  ← ConnectX-7 Port 1, Function 1
5: enP2p1s0f0np0: <BROADCAST,MULTICAST,UP,LOWER_UP> ← ConnectX-7 Port 2, Function 0
6: enP2p1s0f1np1: <BROADCAST,MULTICAST,UP,LOWER_UP> ← ConnectX-7 Port 2, Function 1
```

Let's break each one down.

---

## 2. Regular Ethernet: `enP7s7`

This is your standard RJ45 port — the one you plug into your home router, office switch, or whatever gives you internet access.

```
Interface : enP7s7
Driver    : r8127 (Realtek)
Speed     : 1 Gb/s (typical)
PCI Slot  : 0007:01:00.0
Role      : Management / Internet access
```

On this system, it gets an IP via DHCP:

```bash
$ ip -4 addr show enP7s7
    inet 192.168.1.56/24 brd 192.168.1.255 scope global dynamic enP7s7
```

The default route goes through it:

```bash
$ ip route show default
default via 192.168.1.1 dev enP7s7 proto dhcp src 192.168.1.56 metric 104
```

> **Key point**: This is what you SSH into. It has nothing to do with GPU-to-GPU communication.

### Interface Naming Decoder

The name `enP7s7` follows the **Predictable Network Interface Names** scheme:

| Part | Meaning |
|------|---------|
| `en` | Ethernet |
| `P` | PCI bus (capital `P` = domain 0, the leading segment number appended) |
| `7` | PCI domain number (this is on segment `0007`) |
| `s` | Slot |
| `7` | Slot number (PCI slot 0, function 0 — the trailing digit) |

In simpler terms: it means "Ethernet interface on PCI domain 7, slot 1, function 0". Older naming would have called it `eth0`.

You can verify the PCI location:

```bash
$ cat /sys/class/net/enP7s7/device/uevent | grep PCI_SLOT_NAME
PCI_SLOT_NAME=0007:01:00.0
```

---

## 3. ConnectX-7 Interfaces: `enp1s0f0np0`, `enp1s0f1np1`, etc.

These are the **two physical QSFP112 ports** on the rear panel, each appearing as **two PCI functions** (f0 and f1). The physical cables from the two DGX Sparks plug into these.

```
Physical Port 1 (left, from rear)
  ├── enp1s0f0np0  (function 0 — primary data path)  → rocep1s0f0
  └── enp1s0f1np1  (function 1 — secondary)          → rocep1s0f1

Physical Port 2 (right, from rear)
  ├── enP2p1s0f0np0 (function 0 — primary data path) → roceP2p1s0f0
  └── enP2p1s0f1np1 (function 1 — secondary)          → roceP2p1s0f1
```

### Why 4 interfaces for 2 ports?

The ConnectX-7 is a single ASIC that covers both ports. The NVIDIA driver splits each port into two PCI functions. **Function 0** is the standard data interface. **Function 1** is also usable and shows identical link state — both reflect the same physical cable. For most use cases (including vLLM/NCCL), you only need the f0 interfaces.

### Naming Decoder

Take `enp1s0f0np0`:

| Part | Meaning |
|------|---------|
| `en` | Ethernet |
| `p` | PCI bus number (lowercase `p` = bus number < 10) |
| `1` | PCI bus number (this is on bus `0000:01`) |
| `s` | Slot |
| `0` | Device number |
| `f` | Function |
| `0` | Function number (`f0` = function 0) |
| `np` | Network Physical port |
| `0` | Physical port index |

The name `enP2p1s0f0np0` follows a similar pattern but with an uppercase `P` indicating a PCI domain number >= 10 (actually PCI segment `0002` — the uppercase `P` is used when the segment number needs to be disambiguated).

### Link Status

All four interfaces show `carrier 1` and `operstate up` when a cable is plugged in and the other end is powered on:

```bash
$ cat /sys/class/net/enp1s0f0np0/carrier
1
$ cat /sys/class/net/enp1s0f0np0/operstate
up
```

---

## 4. RDMA: The Confusing Part (Same Cable, Two Personalities)

This is where most people get tripped up. **RoCE (RDMA over Converged Ethernet)** uses a standard Ethernet cable, runs at standard Ethernet L2 framing, and gets a regular IP address you can ping.

But it also exposes a **second, parallel data path** — the RDMA verbs interface — that lets applications read and write memory on a remote machine without involving the CPU or kernel at all.

### The Two Traffic Lanes

Think of a ConnectX-7 port as a single cable that carries **two independent lanes**:

| Lane | Protocol | API | What it's for | Does it need an IP? |
|------|----------|-----|---------------|-------------------|
| **Control lane** | Regular TCP/IP | Sockets (`ping`, `ssh`, `curl`) | Management, config, small control messages | Yes |
| **Data lane** | RDMA verbs | `ibv_post_send()`, NCCL | GPU memory → GPU memory, zero-copy | Yes (for RoCE routing) |

Both lanes share the same physical wire. The ConnectX-7 chip demultiplexes incoming packets based on their headers — regular TCP/UDP packets go to the kernel stack, RDMA packets get processed directly by the hardware.

### What This Means in Practice

```bash
# This works — regular IP over RoCE:
$ ping 10.0.1.1
64 bytes from 10.0.1.1: icmp_seq=1 ttl=64 time=0.05 ms
```

```bash
# This also works — RDMA reads remote GPU memory directly:
# (NCCL does this internally — no CPU involvement)
# GPU on spark01 reads from GPU on spark02 at ~200 Gb/s
```

The same interface (`enp1s0f0np0`) handles both. The IP address you assign is used by **both** paths — the kernel uses it for routing control traffic, and RoCE uses it to route RDMA packets.

### Why Two Paths?

If you move data the normal way (TCP/IP through the kernel), every byte gets copied multiple times:

```
GPU memory → CPU RAM → kernel socket buffer → NIC → wire
```

RDMA skips the middle steps entirely:

```
GPU memory → NIC → wire
```

At 200 Gb/s, that kernel bypass saves microseconds per packet and frees the CPU to actually run the model instead of shoveling data.

### How to See the RDMA Devices

Each ConnectX-7 network interface exposes an **RDMA device** under `/sys/class/infiniband/`:

| Network Interface | RDMA Device | Port | Speed |
|-------------------|-------------|------|-------|
| `enp1s0f0np0` | `rocep1s0f0` | 1 | 200 Gb/s |
| `enp1s0f1np1` | `rocep1s0f1` | 1 | 200 Gb/s |
| `enP2p1s0f0np0` | `roceP2p1s0f0` | 1 | 200 Gb/s |
| `enP2p1s0f1np1` | `roceP2p1s0f1` | 1 | 200 Gb/s |

The RDMA device naming follows PCI topology:

```
rocep1s0f0  = RDMA over Converged Ethernet on PCI bus 0000:01, slot 0, function 0
roceP2p1s0f0 = same, but on PCI segment 0002
```

You can inspect RDMA link state independently of the network layer:

```bash
$ cat /sys/class/infiniband/rocep1s0f0/ports/1/state
4: ACTIVE
$ cat /sys/class/infiniband/rocep1s0f0/ports/1/phys_state
5: LinkUp
$ cat /sys/class/infiniband/rocep1s0f0/ports/1/rate
200 Gb/sec (2X NDR)
```

All four RDMA devices on this Spark share the same `sys_image_guid`, confirming they come from one physical adapter:

```bash
$ cat /sys/class/infiniband/rocep1s0f0/sys_image_guid
4821:0b03:0096:a5cb
$ cat /sys/class/infiniband/rocep1s0f1/sys_image_guid
4821:0b03:0096:a5cb    # same!
```

### RoCE vs InfiniBand

The ConnectX-7 can operate in two modes:
- **InfiniBand** — native IB protocol, requires a subnet manager
- **RoCE (RDMA over Converged Ethernet)** — RDMA on top of Ethernet frames

On the DGX Spark, the ports run in **RoCE v2 mode** (link_layer = Ethernet). This is the easier mode: standard Ethernet framing, standard IP routing, no subnet manager needed. You assign IPs, connect the cables, and RDMA just works on top.

---

## 5. The Grace CPU's Unique PCIe Topology

The DGX Spark uses an **NVIDIA Grace CPU**, which has multiple independent PCIe root complexes. This is why you see interfaces on different PCI segments:

```
# From lspci -t:
-[0000:00]-+-00.0-[01]--+-00.0  ← ConnectX-7 Port 1, Function 0
           |            +-00.1  ← ConnectX-7 Port 1, Function 1
-[0002:00]-+-00.0-[01]--+-00.0  ← ConnectX-7 Port 2, Function 0
           |            +-00.1  ← ConnectX-7 Port 2, Function 1
-[0004:00]-...
-[0007:00]-...                    ← Realtek Ethernet (enP7s7)
-[0009:00]-...
```

Each `-[000X:00]` is a separate PCIe root complex within the Grace SoC. This matters for **NUMA locality** — traffic on `0000:01` stays on that memory domain. For NCCL, this layout is transparent; the drivers handle routing.

---

## 6. Quick Command Reference

| Goal | Command |
|------|---------|
| List all network interfaces | `ip link show` |
| Show IP addresses | `ip -4 addr show` |
| Show routing table | `ip route show` |
| Check interface speed | `ethtool <iface>` |
| Show PCI devices | `lspci \| grep -i mellanox` |
| Show PCI tree | `lspci -t` |
| Check link carrier | `cat /sys/class/net/<iface>/carrier` |
| List RDMA devices | `ls /sys/class/infiniband/` |
| Check RDMA link state | `cat /sys/class/infiniband/<dev>/ports/1/state` |
| Check RDMA link speed | `cat /sys/class/infiniband/<dev>/ports/1/rate` |
| Show driver info | `ethtool -i <iface>` |
| Show all mlx5 interfaces | `ls /sys/class/net/ \| grep -E 'enp\|enP' \| xargs -I{} sh -c 'echo "{} -> $(cat /sys/class/net/{}/device/uevent 2>/dev/null \| grep PCI_SLOT_NAME \| cut -d= -f2)"'` |
| Watch traffic on ConnectX-7 | `watch -n 1 cat /sys/class/net/<iface>/statistics/tx_bytes` |

---

## 7. Quick Reference: Interface Purpose Table

| Interface(s) | Type | Driver | Speed | Purpose |
|--------------|------|--------|-------|---------|
| `enP7s7` | RJ45 (1 GbE) | `r8127` | 1 Gb/s | Management, SSH, internet |
| `enp1s0f0np0` / `enp1s0f1np1` | QSFP112 Port 1 | `mlx5_core` | 200 Gb/s | GPU cluster interconnect |
| `enP2p1s0f0np0` / `enP2p1s0f1np1` | QSFP112 Port 2 | `mlx5_core` | 200 Gb/s | GPU cluster interconnect |

---

## 8. How RoCE Traffic Flows (Simplified)

When vLLM runs with Tensor Parallelism across two DGX Sparks:

```
GPU (spark01)
  ↓ NCCL sends data via RDMA
  ↓ mlx5_core driver writes directly from GPU memory
  ↓ enp1s0f0np0 + enP2p1s0f0np0
  ↓ QSFP112 cables
  ↓ enp1s0f0np0 + enP2p1s0f0np0 (spark02)
  ↓ mlx5_core driver writes directly to GPU memory
GPU (spark02)
```

The data **never touches the CPU or system RAM** on either side. The CPU is only involved in setting up the buffers (one-time), not in moving the data. This is the key difference from regular TCP/IP networking.

---

## 9. Common Confusions

**"Why does `ip link` show 4 ConnectX-7 interfaces when I only have 2 ports?"**

Each physical port is split into 2 PCI functions by the mlx5 driver. Function 0 is the primary data path. Function 1 is secondary and will show identical link state. For NCCL, you can use either or both — NCCL will stripe traffic across them.

**"Why don't the ConnectX-7 interfaces have IPs?"**

By default they don't. They need static IPs assigned for point-to-point RoCE. Unlike your regular ethernet NIC, there's no DHCP server on the other end of a direct-attach cable. You assign IPs manually via `ip addr add` or netplan.

**"Can I use the ConnectX-7 for internet access?"**

Technically yes, but practically no. They're connected directly to another Spark, not to a switch that leads to your router. They form a **private cluster network** for GPU traffic only.

**"What is `enP7s7` and why is the regular ethernet on PCI segment 0007 while the ConnectX-7 is on 0000/0002?"**

The Grace CPU has independent PCIe root complexes. The Realtek NIC happens to be on segment 0007, while the ConnectX-7 occupies segments 0000 and 0002. This is normal for the GB10 SoC's IO layout.

**"Do I need both Port 1 and Port 2 cabled for it to work?"**

No. A single cable (one port pair) is sufficient for NCCL communication. Having both doubles the available bandwidth because NCCL automatically stripes across all available links.

---

*See also: [ConnectX-7 Clustering Guide](./dgx-spark-connectx7-clustering.md) for the step-by-step setup.*
