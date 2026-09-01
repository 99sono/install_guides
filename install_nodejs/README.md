# Node.js Install Guide

Three ways to install Node.js on Ubuntu / WSL2, each as a self-contained script. Pick the one that matches your setup.

| Method | Script | How it works | Needs `sudo`? | Isolated? | Best when |
|--------|--------|--------------|---------------|-----------|-----------|
| **C. Conda (conda-forge)** ⭐ | [`01_C_install_nodejs_conda.sh`](01_C_install_nodejs_conda.sh) | `conda create -n <env> nodejs` | No | Yes (per env) | You have Miniforge3 / Conda |
| **A. Official tarball** | [`01_A_install_nodejs.sh`](01_A_install_nodejs.sh) | Download + extract into `/usr/local` | Yes | No (system) | You want a pinned global binary |
| **B. NodeSource (apt)** | [`01_B_install_nodejs.sh`](01_B_install_nodejs.sh) | `apt install nodejs` from NodeSource | Yes | No (system) | You want Node managed through apt |

> **Recommendation:** If you already use Miniforge3/Conda, **Method C** is the cleanest — no `sudo`, fully isolated, and easy to pin/swap versions or remove. That's why it's covered in detail first below.

---

## Method C — Conda / conda-forge (recommended for Conda users) ⭐

This method installs Node.js into a **dedicated Conda environment**, so it never conflicts with a system-wide Node and can be removed in one command.

**Prerequisite:** Conda must be installed and on `PATH`. If not, set it up first — see [`../conda_miniforge3/`](../conda_miniforge3/). Node.js is a **conda-forge** package, so make sure `conda-forge` is a channel you can use (`conda config --show channels`).

### 1. Find available versions
```bash
# List every Node.js build on conda-forge
conda search -c conda-forge nodejs

# Or filter to a major version, e.g. all 24.x builds
conda search -c conda-forge nodejs | grep 24.
```

### 2. Create the environment (with a pinned version)
```bash
conda create -n nodejs_24_19 -c conda-forge nodejs=24.19 -y
```
- `nodejs=24.19` resolves to the newest `24.19.x` build (e.g. `24.19.0`) — a good, reproducible pin.
- Pin the exact `major.minor` you want. Use plain `nodejs` (no version) for the absolute latest build.
- `-c conda-forge` is optional if `conda-forge` is already your default channel, but it makes the command portable.

### 3. Activate it
```bash
conda activate nodejs_24_19
```

### 4. Verify
```bash
node -v      # e.g. v24.19.0
npm -v
which node   # points inside the env, NOT /usr/local or /usr/bin
```

### 5. Remove it (when you're done)
```bash
conda env remove -n nodejs_24_19 -y
```

### One-liner
Instead of the individual commands, run the script — it does the sanity checks, the "env already exists" prompt, and the verification for you:
```bash
./01_C_install_nodejs_conda.sh
NODE_VERSION=24.19 ./01_C_install_nodejs_conda.sh   # pin a specific version
```

---

## Method A — Official binary tarball

Downloads the official `node-vX-linux-x64.tar.xz` from nodejs.org and extracts it into `/usr/local`.

```bash
./01_A_install_nodejs.sh
```
- **Version** is pinned at the top of the script (`NODE_VERSION="v25.9.0"`). Edit it to change.
- Removes any previous `/usr/local` Node binaries first, so it's safe to re-run even after a NodeSource/apt install.
- Node ends up at `/usr/local/bin/node` (on your `PATH`, ahead of `/usr/bin`).

## Method B — NodeSource (apt)

Installs Node.js from the [NodeSource](https://deb.nodesource.com/) APT repository.

```bash
bash 01_B_install_nodejs.sh
```
Equivalent to running:
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```
- Installs the **LTS** line and keeps Node on the system `PATH` (`/usr/bin/node`).
- To remove: `sudo apt remove -y nodejs && sudo apt autoremove`.

---

## Which method should I use?

- **You use Conda / Miniforge3 →** **Method C.** Isolated, no `sudo`, easy version management. This is the recommended path in this repo.
- **You want a global, pinned binary with no extra toolchain →** **Method A.**
- **You want Node managed through apt (LTS, `apt` updates) →** **Method B.**

> Avoid installing two *system* methods at once (A + B). They both write to the system `PATH` and can shadow each other. Method C avoids this entirely because it lives in its own environment.

## Troubleshooting

**`'conda' not found on PATH`**
Miniforge3 is installed but the shell hasn't sourced it. Open a new terminal, or run `source ~/.bashrc`. See [`../conda_miniforge3/`](../conda_miniforge3/).

**`No 'nodejs=<version>' build found`**
conda-forge can lag the newest Node.js release. Check the highest available version with `conda search -c conda-forge nodejs` and pin that (or use plain `nodejs` for the latest).

**Multiple `node` versions on `PATH` (apt Node vs. env Node)**
`which node` shows which one is active. Inside a Conda env, `conda activate nodejs_24_19` puts the env's `node` first on `PATH`. `conda deactivate` returns you to the system Node (if one exists).

**Corporate / proxy SSL errors during `conda create`**
See the SSL / Certificate Configuration section in [`../conda_miniforge3/installation_steps.md`](../conda_miniforge3/installation_steps.md).