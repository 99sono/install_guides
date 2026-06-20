# DGX Spark Networking Primer

Understanding Linux networking on the Grace-Blackwell GB10 | ConnectX-7 vs Regular Ethernet

---

## Why This Guide Exists

A DGX Spark doesn't have a "normal" PC networking layout. It has **two networking domains**:

1. **Regular Ethernet** — Realtek PCIe NIC, connects to your home/office LAN, gets an IP via DHCP. This is `192.168.1.x` traffic.
2. **ConnectX-7 (QSFP112)** — Dual-port 200/400 Gb/s RDMA adapter for inter-node GPU communication. This is `10.0.x.x` cluster traffic.

Newcomers run `ip link` or `lspci` and see cryptic names like `enP7s7`, `enp1s0f0np0`, `rocep1s0f0` and have no idea what is what. This guide walks through the physical interfaces on a real DGX Spark and explains how to read the naming, purpose, and relationship between the pieces.

---

## 1. What `ip link` Shows You

When you run `ip link`, the kernel lists every registered **network interface** — both physical hardware and virtual software devices. On a DGX Spark, most of the output is virtual noise from Docker and system internals. The physical hardware you care about is only a handful of entries.

### Filtering the Noise

Here is the full output from spark02:

```
1:  lo: <LOOPBACK,UP,LOWER_UP> ...
2:  enP7s7: <BROADCAST,MULTICAST,UP,LOWER_UP> ...          ← keep (regular ethernet)
3:  enp1s0f0np0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...     ← keep (ConnectX-7 Port 1)
4:  enp1s0f1np1: <BROADCAST,MULTICAST,UP,LOWER_UP> ...     ← keep (ConnectX-7 Port 1 dup)
5:  enP2p1s0f0np0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...   ← keep (ConnectX-7 Port 2)
6:  enP2p1s0f1np1: <BROADCAST,MULTICAST,UP,LOWER_UP> ...   ← keep (ConnectX-7 Port 2 dup)
7:  enx001122334455: <NO-CARRIER,BROADCAST,MULTICAST,UP> ... ← keep (USB ethernet)
8:  wlP9s9: <NO-CARRIER,BROADCAST,MULTICAST,UP> ...        ← keep (WiFi)
9:  docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> ...
10: br-bdc9f2b0839b: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
11: vethb1e3d65@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
12: veth514f127@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
13: veth3ee382b@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
```

Out of 13 entries, **only 6 are physical hardware**. The rest are:

- `lo` — loopback (purely in-kernel, no real cable)
- `docker0`, `br-*` — Docker bridges
- `veth*` — virtual ethernet pairs for containers

For this guide, we focus on the physical interfaces. Virtual ones are out of scope.

---

## 1.5 Before Parsing Names: Every Network Device Lives on PCI Express

Every wired network interface on this machine is a **PCI Express (PCIe) device** — including the Realtek NIC and the ConnectX-7 ports. WiFi is also PCIe. Understanding this is the key to understanding the names.

### The PCI Address Format

Every PCIe device has a hierarchical address:

```
  domain   :  bus  : device . function
  ───────     ───    ─────     ───────
   0000      :  01  :  00   .    0
```

- **domain** (or **segment**) — groups PCI buses under one PCIe root complex. The Grace CPU has multiple root complexes, so you see multiple domains: `0000`, `0002`, `0007`, `0009`. A normal PC usually has just `0000`.
- **bus** — a PCI bus number within that domain.
- **device** — the device number on that bus.
- **function** — a sub-function of a multi-function device (the ConnectX-7 exposes two functions per port: f0 and f1).

### How the Interface Name Relates to the PCI Address

The `ip link` name is derived from this PCI address. The naming convention encodes parts of the address, and the **domain/segment** controls whether you see an uppercase `P` or a lowercase `p`:

| If domain is … | Name pattern | Example |
|----------------|-------------|---------|
| `0000` (default) | `enp<bus>s<device>f<func>np<port>` | `enp1s0f0np0` |
| non-zero (e.g. `0002`) | `enP<domain>p<bus>s<device>f<func>np<port>` | `enP2p1s0f0np0` |

Domain `0000` is the default — it's **omitted** from the name, making it shorter. This is purely a convention to keep names concise.

### How to Look Up the PCI Address for Any Interface

You don't need to memorize — you can always check:

```bash
# Quick method — direct from sysfs
$ cat /sys/class/net/enp1s0f0np0/device/uevent | grep PCI_SLOT_NAME
PCI_SLOT_NAME=0000:01:00.0

# Also visible via ethtool
$ ethtool -i enp1s0f0np0 | grep bus-info
bus-info: 0000:01:00.0
```

Try it on the noisy interfaces:

```bash
$ cat /sys/class/net/docker0/device/uevent 2>/dev/null | grep PCI_SLOT_NAME
# (nothing — docker0 has no PCI device because it is virtual)
```

This is the quick test: if `PCI_SLOT_NAME` exists, it is a physical PCIe device. If not, it is virtual.

---

## 2. How to Read an Interface Name (The Pattern Language)

Every physical interface name encodes its **hardware location** and **type** using a consistent pattern. Once you learn the grammar, you can decode any name on sight.

### The Two-Letter Type Prefix

| Prefix | Meaning | Example |
|--------|---------|---------|
| `en` | Ethernet (wired) | `enP7s7` |
| `wl` | Wireless LAN | `wlP9s9` |
| `ww` | WWAN / cellular | (not present here) |

Everything after the prefix describes the **connection bus** and **location on that bus**.

### The Two Template Patterns

Before looking at real devices, here are the two abstract naming templates:

```
Pattern A — Segment 0000 (default, shorter):
  en  p<bus>  s<device>  f<func>  np<port>

Pattern B — Non-zero segment:
  en  P<segment>  p<bus>  s<device>  f<func>  np<port>
```

In Pattern A, the entire `P<segment>` part is dropped because segment `0000` is the default. In Pattern B, the uppercase `P` introduces the non-zero segment, then a lowercase `p` introduces the bus within that segment.

Some devices use a **slot-based** name variant (`enP7s7`) where firmware provides a slot number instead of the full bus/device/function path. The slot number encodes the same physical location, just in a more compact form.

### Decomposition Tables

**ConnectX-7 Port 1 — `enp1s0f0np0`** (PCI segment 0000, full path)

| Component | Text | PCI Express meaning |
|-----------|------|---------------------|
| Type | `en` | Ethernet |
| Segment marker | `p` (lowercase) | Introduces the PCI bus. Lowercase because the PCI segment is `0000` (default) — the `P<segment>` prefix is omitted entirely. |
| Bus number | `1` | PCI bus `01` in `0000:01:00.0` |
| Slot marker | `s` | Keyword "slot" — introduces the device number |
| Device number | `0` | PCI device `00` in `0000:01:00.0` |
| Function marker | `f` | Keyword "function" |
| Function number | `0` | PCI function `0` in `0000:01:00.0` |
| Phys port marker | `np` | Keyword "network physical port" |
| Phys port index | `0` | Port 0 on this NIC |
| **Full PCI address** | `0000:01:00.0` | Verify: `cat /sys/class/net/enp1s0f0np0/device/uevent \| grep PCI_SLOT_NAME` |

**ConnectX-7 Port 2 — `enP2p1s0f0np0`** (PCI segment 0002, full path)

| Component | Text | PCI Express meaning |
|-----------|------|---------------------|
| Type | `en` | Ethernet |
| Segment marker | `P` (uppercase) | Introduces the PCI segment. Uppercase because this segment is NOT `0000` — it must be shown to avoid ambiguity. |
| Segment number | `2` | PCI segment `0002` in `0002:01:00.0` |
| Bus marker | `p` (lowercase) | Introduces the PCI bus **within** the segment above. Lowercase because this is the bus, not the segment. |
| Bus number | `1` | PCI bus `01` in `0002:01:00.0` |
| Slot marker | `s` | Keyword "slot" |
| Device number | `0` | PCI device `00` in `0002:01:00.0` |
| Function marker | `f` | Keyword "function" |
| Function number | `0` | PCI function `0` in `0002:01:00.0` |
| Phys port marker | `np` | Keyword "network physical port" |
| Phys port index | `0` | Port 0 on this NIC |
| **Full PCI address** | `0002:01:00.0` | Verify: `cat /sys/class/net/enP2p1s0f0np0/device/uevent \| grep PCI_SLOT_NAME` |

> **Why both uppercase P and lowercase p in the same name?** The first uppercase `P` introduces the non-zero segment (`0002`). Then, within that segment, a regular lowercase `p` introduces the bus number. Without the `P2`, the `p1` would be assumed to be on segment `0000` — which would be wrong.

**Realtek Ethernet — `enP7s7`** (PCI segment 0007, slot-based compact form)

| Component | Text | PCI Express meaning |
|-----------|------|---------------------|
| Type | `en` | Ethernet |
| Segment marker | `P` (uppercase) | Introduces the PCI segment. Uppercase because segment `0007` is NOT the default. |
| Segment number | `7` | PCI segment `0007` in `0007:01:00.0` |
| Slot marker | `s` | Keyword "slot" |
| Slot number | `7` | Firmware-assigned slot (compact encoding of bus=`01`, device=`00`). The full altname `enP7p1s0` shows the expanded form. |
| **Full PCI address** | `0007:01:00.0` | Verify: `cat /sys/class/net/enP7s7/device/uevent \| grep PCI_SLOT_NAME` |

> **Why is `enP7s7` shorter than the ConnectX-7 names?** This device is single-function (no f0/f1 split) and uses a firmware slot number instead of the full PCI path. The Linux fallback naming gives it a compact slot-based name. The altname `enP7p1s0` shows what the full path-based name would look like.

### Special Case: USB Ethernet (No PCI)

`enx001122334455` — the `x` means the name is derived from the **MAC address** (in this example, `00:11:22:33:44:55`). This happens for USB ethernet adapters that have no PCI topology to describe.

---

## 3. The Physical Interfaces (One by One)

### 3a. Regular Ethernet: `enP7s7`

This is your standard RJ45 port — the one you plug into your home router, office switch, or whatever gives you internet access.

```
Name      : enP7s7
Driver    : r8127 (Realtek)
Speed     : 1 Gb/s
PCI Slot  : 0007:01:00.0
Role      : Management / SSH / internet
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

**Key point**: This is what you SSH into. It has nothing to do with GPU-to-GPU communication.

### 3b. ConnectX-7 (QSFP112): `enp1s0f0np0`, `enP2p1s0f0np0`, etc.

These are the **two physical QSFP112 ports** on the rear panel for GPU cluster interconnect. Each physical port appears as **two PCI functions** in `ip link`:

```
Physical Port 1 (left, looking at rear)
  ├── enp1s0f0np0   (function 0 — primary)    →  200 Gb/s
  └── enp1s0f1np1   (function 1 — secondary)   →  200 Gb/s

Physical Port 2 (right, looking at rear)
  ├── enP2p1s0f0np0 (function 0 — primary)    →  200 Gb/s
  └── enP2p1s0f1np1 (function 1 — secondary)   →  200 Gb/s
```

Why 4 entries for 2 physical ports? The mlx5 driver splits each port into two PCI functions. Function 0 is the primary data interface. Function 1 is a duplicate — it shows identical link state and speed because both reflect the same physical cable. For most use cases (including vLLM/NCCL), you only need the f0 interfaces.

All four show `carrier 1` when the cable is plugged in and the other end is powered on:

```bash
$ cat /sys/class/net/enp1s0f0np0/carrier
1
$ cat /sys/class/net/enp1s0f0np0/operstate
up
```

### 3c. WiFi: `wlP9s9`

```
Name      : wlP9s9 (altname: wlP9p1s0)
Driver    : mt7925e (MediaTek)
PCI Slot  : 0009:01:00.0
```

Currently down (carrier 0, no IP). Present on the Spark but not typically used for development.

---

## 4. At a Glance: All Physical Interfaces

```
┌──────────────┬────────────┬──────────┬──────────────┬────────────────────┐
│ Interface    │ Driver     │ Speed    │ PCI Slot     │ What it connects   │
├──────────────┼────────────┼──────────┼──────────────┼────────────────────┤
│ enP7s7       │ r8127      │ 1 Gb/s   │ 0007:01:00.0 │ Router / LAN       │
│              │ (Realtek)  │          │              │ (SSH, internet)    │
├──────────────┼────────────┼──────────┼──────────────┼────────────────────┤
│ enp1s0f0np0  │ mlx5_core  │ 200 Gb/s │ 0000:01:00.0 │ ConnectX-7 Port 1  │
│ enp1s0f1np1  │ (Mellanox) │          │ 0000:01:00.1 │ (to other Spark)   │
├──────────────┼────────────┼──────────┼──────────────┼────────────────────┤
│ enP2p1s0f0np0│ mlx5_core  │ 200 Gb/s │ 0002:01:00.0 │ ConnectX-7 Port 2  │
│ enP2p1s0f1np1│ (Mellanox) │          │ 0002:01:00.1 │ (to other Spark)   │
├──────────────┼────────────┼──────────┼──────────────┼────────────────────┤
│ enx00112233… │ cdc_ncm    │ ?        │ USB (no PCI) │ USB ethernet dongle│
├──────────────┼────────────┼──────────┼──────────────┼────────────────────┤
│ wlP9s9       │ mt7925e    │ ?        │ 0009:01:00.0 │ WiFi (not in use)  │
└──────────────┴────────────┴──────────┴──────────────┴────────────────────┘
```

### How to Check the Driver Yourself

When a name isn't obvious, look at the driver:

```bash
$ ethtool -i enP7s7      | grep driver
driver: r8127          → Realtek = regular ethernet

$ ethtool -i enp1s0f0np0 | grep driver
driver: mlx5_core      → Mellanox = ConnectX-7
```

Or check the PCI vendor ID:

```bash
$ cat /sys/class/net/enP7s7/device/vendor
0x10ec                 → Realtek

$ cat /sys/class/net/enp1s0f0np0/device/vendor
0x15b3                 → Mellanox
```

---

## 5. RDMA: The Confusing Part (Same Cable, Two Personalities)

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

## 6. The Grace CPU's Unique PCIe Topology

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

## 7. Quick Command Reference

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
