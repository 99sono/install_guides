# Google Antigravity Install Guide

[Google Antigravity](https://antigravity.google/) is Google's agentic development platform. This guide covers the **Antigravity CLI (`agy`)** — a terminal-first agent surface — on Ubuntu (native or WSL2). Steps below were tested on Ubuntu 24.04 / WSL2.

## Install

One line in your terminal:

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

## What that line does

1. Detects your OS and CPU type (e.g. `linux_amd64`).
2. Fetches the latest version from the release server (it self-updates on later runs).
3. Downloads the `agy` binary and verifies its SHA512 checksum.
4. Installs it to `~/.local/bin/agy`.
5. Puts `~/.local/bin` on your `PATH` in your shell profile.

If the last line says **`Antigravity CLI installed successfully`**, you're done.

> You may see lines like `ERROR: logging before google.Init ...` during the install. They look like errors but are harmless log noise — ignore them.

## Check it worked

Open a **new** terminal (so PATH is picked up), then:

```bash
agy --version
```

It should print a version number.

## First run

```bash
agy
```

Run it from inside a project folder. First launch shows a short setup (colors, rendering, workspace trust), then opens your browser to sign in with Google. On WSL2 that browser opens on Windows. There's no separate `agy auth login` command — signing in happens automatically on first launch, and it stays signed in after that.

## Uninstall

```bash
rm ~/.local/bin/agy
```

## Sources

Verified against the official docs on **2026-08-24**:

- CLI installation & auth: <https://antigravity.google/docs/cli/install/>
- CLI getting started: <https://antigravity.google/docs/cli/getting-started/>
- Download page: <https://antigravity.google/download>

> **Note on third-party instructions:** An APT package repository method circulated for Antigravity. It could not be verified — the referenced repository returns 404 — and the official docs mention no APT repo. The official Linux install channel is the one-line installer above. Use that one.
