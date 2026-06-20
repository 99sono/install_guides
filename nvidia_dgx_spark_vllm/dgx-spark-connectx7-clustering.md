# DGX Spark ConnectX-7 Clustering Guide

Two-Node Direct Connect via Dual QSFP112 (RoCE v2) | Grace-Blackwell GB10 Interconnect

---

## Overview

This guide covers connecting two DGX Spark nodes (e.g. `spark01`, `spark02`) via their onboard **ConnectX-7 (QSFP112)** ports in a **dual-cable point-to-point topology** with no external switch. This is the foundation for running distributed LLM inference (e.g. Tensor Parallelism with vLLM) across multiple DGX Sparks.

Based on NVIDIA's official [Spark Clustering documentation](https://docs.nvidia.com/dgx/dgx-spark/spark-clustering.html).

---

## Pre-Verification

This configuration enables the **DeepSeek-V4-Flash** two-node recipe by `tonyd2wild`, which requires a high-performance RoCE/RDMA link for NCCL-based Tensor Parallelism (TP=2). Wiring both ConnectX-7 ports provides:

- Two distinct point-to-point networks (one per port pair)
- NCCL natively stripes traffic across all available active interfaces
- Redundant pathing and increased inter-node throughput

---

## 1. Physical Cable Installation

Each DGX Spark has two **ConnectX-7 (QSFP112)** ports on the rear panel, side by side.

1. **Power down** both units completely before handling the cables.
2. **Cable 1**: Plug into **Port 1** (left) on both nodes.
3. **Cable 2**: Plug into **Port 2** (right) on both nodes.
4. Ensure the pull-tab (ring tab) faces **upward** toward the top of the chassis. Push straight in until you hear a firm click.

> Do not force the connector. If it does not slide in smoothly, verify tab orientation and alignment.

![](./images/spark_dual_connectx7_ports.png) *(optional: add a photo of the rear panel)*

---

## 2. Verify Physical Links

Power on both nodes and log in. Confirm the ConnectX-7 ports see each other:

```bash
ibstatus
```

Expected output — both ports listed as `LinkUp` with active rate (200 Gb/s or 400 Gb/s):

```
Infiniband device 'mlx5_0' port 1 status: active
Infiniband device 'mlx5_1' port 1 status: active
```

---

## 3. Assign Static IPs for RoCE

With no switch or DHCP, assign static IPs to each port on unique subnets.

**Node A (spark01):**

```bash
sudo ip addr add 192.168.10.1/24 dev mlx5_0
sudo ip addr add 192.168.20.1/24 dev mlx5_1
```

**Node B (spark02):**

```bash
sudo ip addr add 192.168.10.2/24 dev mlx5_0
sudo ip addr add 192.168.20.2/24 dev mlx5_1
```

**Test connectivity across both links:**

```bash
# From Node A:
ping 192.168.10.2
ping 192.168.20.2
```

### Make IPs Persistent

Create or edit `/etc/netplan/99-connectx7.yaml` on each node:

**Node A (spark01):**

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    mlx5_0:
      addresses:
        - 192.168.10.1/24
    mlx5_1:
      addresses:
        - 192.168.20.1/24
```

**Node B (spark02):**

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    mlx5_0:
      addresses:
        - 192.168.10.2/24
    mlx5_1:
      addresses:
        - 192.168.20.2/24
```

Apply:

```bash
sudo netplan apply
```

---

## 4. Run the Cluster Discovery Wizard

NVIDIA provides a script that finalizes clustering over direct links:

```bash
sudo discover-sparks.sh
```

This interactive wizard updates local configurations so MPI and NCCL understand how to route traffic between nodes. Follow the prompts to declare the dual-interface point-to-point topology.

> If `discover-sparks.sh` is not found, ensure the DGX Spark's NGC base image is up to date, or consult the [official Spark Clustering guide](https://docs.nvidia.com/dgx/dgx-spark/spark-clustering.html) for alternative setup steps.

---

## 5. NCCL Environment Variables for vLLM

When running the vLLM container, set the following environment variables so NCCL uses both ConnectX-7 links:

```bash
export NCCL_DEBUG=INFO
export NCCL_IB_DISABLE=0
export NCCL_IB_HCA=mlx5_0,mlx5_1
export NCCL_IB_GID_INDEX=3  # Standard for RoCE v2
```

These instruct NCCL to:
- Enable InfiniBand verbs (RoCE)
- Use both `mlx5_0` and `mlx5_1` interfaces
- Use RoCE v2 GID index

---

## 6. Run the DeepSeek-V4-Flash Recipe

With the interconnect established:

```bash
git clone <tonyd2wild-repo-url>
cd <recipe-directory>
# Set the NCCL vars above, then launch
docker compose up
```

NCCL will automatically detect both interfaces and stripe traffic across them for maximum throughput.

---

## 7. Verification

Check NCCL topology detection:

```bash
# Inside the container or with nvidia-smi
nvidia-smi topo -m
```

Monitor link utilization during inference:

```bash
watch -n 1 cat /sys/class/net/mlx5_0/statistics/tx_bytes
```

---

## References

- [NVIDIA Spark Clustering — Official Documentation](https://docs.nvidia.com/dgx/dgx-spark/spark-clustering.html)
- [Connect Two Sparks — NVIDIA Build Playbook](https://build.nvidia.com/spark/connect-two-sparks)
- [Connect Three Sparks — NVIDIA Build Playbook](https://build.nvidia.com/spark/connect-three-sparks)
- [Multi Sparks Through a Switch — NVIDIA Build Playbook](https://build.nvidia.com/spark/multi-sparks-through-switch)
- [DGX Spark GB10 vLLM Survival Guide](./dgx-spark-gb10-vllm-survival-guide.md)
- [DGX Spark Initial Steps with Docker](./dgx-spark-initial-steps-with-docker.md)

---

*This guide was generated with assistance from Gemini, DeepSeek, and OpenCode. Validate all steps in your own sandbox before production use.*
