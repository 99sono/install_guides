# DGX Spark Initial Steps with Docker

Grace-Blackwell (GB10) | 128GB Unified Memory | Docker Onboarding Guide

---

## Table of Contents

- [1. Prerequisites & Docker Permissions](#1-prerequisites--docker-permissions)
- [2. Verification](#2-verification)
- [3. Deployment: The vLLM Phase](#3-deployment-the-vllm-phase)
- [4. Technical Disclaimer](#4-technical-disclaimer)
- [5. Hardware Context](#5-hardware-context)
- [Next Steps](#next-steps)

---

## 1. Prerequisites & Docker Permissions

On a fresh DGX Spark (Ubuntu 24.04 ARM64), Docker is pre-installed via the NGC base image, but your user account will not have permission to access the Docker socket by default. You will encounter a `permission denied` error when attempting to run any Docker command.

### Fix Docker Permissions

Run the following commands to add your user to the `docker` group:

```bash
# Create the docker group (if it doesn't already exist)
sudo groupadd docker

# Add your current user to the docker group
sudo usermod -aG docker $USER

# Activate the group membership in your current session
newgrp docker
```

### Verify Docker Access

Create a quick test script to confirm Docker is working without needing to clone any external repositories:

```bash
#!/bin/bash
# 01_docker_run_hello_world.sh
# Quick Docker installation verification for DGX Spark (aarch64)

echo "=== Docker Hello World Test ==="
echo "Running on: $(uname -m) | Kernel: $(uname -r)"
echo ""

docker run --rm hello-world

echo ""
echo "=== Done ==="
echo "If you see 'Hello from Docker!' above, your ARM64 Docker"
echo "engine is correctly communicating with the hardware."
```

Save this as `01_docker_run_hello_world.sh`, make it executable (`chmod +x 01_docker_run_hello_world.sh`), and run it.

---

## 2. Verification

Run the verification script:

```bash
./01_docker_run_hello_world.sh
```

**Expected output:**

```
=== Docker Hello World Test ===
Running on: aarch64 | Kernel: 6.6.87-rt41.1.0.85.1-202505150657

Hello from Docker!
This message shows that your installation appears to be working correctly.

... (truncated for brevity) ...

=== Done ===
If you see 'Hello from Docker!' above, your ARM64 Docker
engine is correctly communicating with the hardware.
```

Seeing the **`Hello from Docker!`** message confirms that:

- ✅ The Arm-based Docker engine is correctly installed
- ✅ Docker daemon is running and accessible without `sudo`
- ✅ The container runtime can communicate with the hardware

---

## 3. Deployment: The vLLM Phase

Once Docker is verified, the next step is to clone the DGX-optimized Docker build files repository and navigate to the vLLM configuration directory:

```bash
# Clone the DockerBuildFiles repository
git clone https://github.com/99sono/DockerBuildFiles.git

# Navigate to the vLLM NGX/DGX configuration directory
cd DockerBuildFiles/vllm/qwen-3.6-35b-a3b-vllm-nvpf4-dgx-spark
```

This directory contains the specific `aarch64` and `cu130` configurations tested for the Grace-Blackwell architecture, including:

- `Dockerfile` — ARM64-optimized vLLM image build
- `docker-compose.yml` — Pre-configured service definition
- `build-and-copy.sh` — Automated build script with SM121 kernel support
- `README.md` — Directory-specific instructions

### What's Next

After cloning, refer to the companion guide for the full step-by-step:

- **[📘 DGX Spark GB10 vLLM Survival Guide](./dgx-spark-gb10-vllm-survival-guide.md)** — Deep-dive into SM121 kernel configuration, UMA memory management, NVFP4 model serving, and performance tuning.

---

## 4. Technical Disclaimer

> ⚠️ **EXPERIMENTAL / UNTESTED**
>
> The configurations in this guide — specifically within the `dgx-spark` directory — are **early-access migration files** for the **Grace-Blackwell (GB10) / SM121** architecture. Performance tuning, kernel optimization, and full compatibility validation are **ongoing**.
>
> **Important for users coming from x86_64 GPUs (H100, A100, RTX 4090, etc.):**
>
> Standard `x86_64` vLLM Docker images **will not work** on the DGX Spark. The GB10 uses an **ARM64 (aarch64)** CPU and **Blackwell SM121** GPU architecture. Running incompatible images will result in:
>
> - `Illegal instruction` errors (missing SM121 instructions)
> - Silent fallback to CPU emulation (extremely slow — tokens/sec in single digits)
> - Memory corruption due to architecture mismatch
>
> Always use the `aarch64`-specific builds and SM121-compiled wheels provided in these configurations.

---

## 5. Hardware Context

### Why This Setup Is Unique: Unified Memory Architecture (UMA)

The DGX Spark uses **128GB Unified Memory (UMA)**, meaning the CPU and GPU share a **single memory pool**. This is fundamentally different from traditional GPU setups where the GPU has dedicated VRAM (e.g., 80GB H100) connected via PCIe.

| Aspect | Traditional GPU | DGX Spark (UMA) |
|--------|----------------|-----------------|
| Memory Topology | GPU VRAM (80GB) + System RAM (PCIe, slow) | Single 128GB pool shared by CPU & GPU |
| Data Transfer | Over PCIe bus (bottleneck) | No PCIe bottleneck — unified address space |
| Linux Cache | Independent of GPU memory | Kernel buffer cache **competes** with GPU for memory |
| vLLM Config | Standard GPU settings | Requires UMA-aware configuration |

### Key Operational Implications

1. **Memory Utilization is Lower**: Set `--gpu-memory-utilization 0.70` (70%) rather than the typical 0.85–0.95 used on dedicated GPU servers. This reserves headroom for the CPU side of the unified pool.

2. **Flush the Cache Before Starting vLLM**: The Linux kernel aggressively caches files in RAM. Before starting vLLM, clear the buffer cache:

   ```bash
   sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
   ```

   This ensures the GPU gets maximum available unified memory at container startup. See the [Survival Guide](./dgx-spark-gb10-vllm-survival-guide.md) for automated scripts.

3. **Monitor Total Memory Pressure**: Since the CPU and GPU share memory, heavy system processes (SSH, monitoring tools, file operations) reduce available GPU memory in real-time.

---

## Next Steps

| Step | Action | Reference |
|------|--------|-----------|
| 1 | Verify Docker works | This guide, Sections 1–2 |
| 2 | Clone build files and navigate to config | This guide, Section 3 |
| 3 | Build the vLLM image with SM121 kernels | [Survival Guide – Step 2](./dgx-spark-gb10-vllm-survival-guide.md#step-2-build-the-image) |
| 4 | Download and serve Qwen 3.6 35B NVFP4 | [Survival Guide – Step 3–5](./dgx-spark-gb10-vllm-survival-guide.md#step-3-pre-download-the-model) |
| 5 | Verify tensor cores and performance | [Survival Guide – Section 6](./dgx-spark-gb10-vllm-survival-guide.md#6-final-verification) |

---

*This guide is part of the `99sono/install_guides` repository. For the complete DGX Spark vLLM reference, see the companion [DGX Spark GB10 vLLM Survival Guide](./dgx-spark-gb10-vllm-survival-guide.md).*