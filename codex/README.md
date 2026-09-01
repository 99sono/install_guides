# Codex CLI Install Guide

[Codex CLI](https://github.com/openai/codex) is OpenAI's terminal-based coding agent — inspect, edit, and run code without leaving your terminal. This guide mirrors the official [**Quickstart**](https://learn.chatgpt.com/docs/codex/cli#getting-started): install Codex, sign in, and run your first task from a project directory. Steps below were tested on Ubuntu 24.04 (native or WSL2).

## Install

Pick **one** install method. The standalone installer is the default for macOS/Linux.

### macOS / Linux (standalone installer)

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

What that line does:

1. Fetches the Codex installer script from `chatgpt.com`.
2. Installs the `codex` binary and puts it on your `PATH`.

The **same command updates** an existing installation (it is idempotent — see [Update](#update)).

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

### npm

```bash
npm install -g @openai/codex
```

Requires Node.js on your `PATH`. If you don't have it, see the [`install_nodejs/`](../install_nodejs/) guide.

### Homebrew (macOS)

```bash
brew install --cask codex
```

## Check it worked

Open a **new** terminal (so `PATH` is picked up), then:

```bash
codex --version
```

It should print a version number.

## Sign in

Open a project directory and run `codex`:

```bash
cd /path/to/your/project
codex
```

The first time you run Codex, choose **Sign in with ChatGPT** or another available sign-in method. See the [authentication options](https://learn.chatgpt.com/docs/auth) for the full list of methods.

## Start your first task

Describe what you want to accomplish — ask Codex to explain the project, make a focused change, or help debug an issue:

```text
Tell me about this project
```

> **Tip:** Create Git checkpoints **before and after** a task so you can revert changes. See the [best practices](https://learn.chatgpt.com/guides/best-practices).

## Update

Re-run the command for the method you installed with:

| Method | Update command |
|--------|----------------|
| macOS/Linux (standalone) | `curl -fsSL https://chatgpt.com/codex/install.sh \| sh` |
| Windows (PowerShell) | `powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 \| iex"` |
| npm | `npm install -g @openai/codex` |
| Homebrew | `brew upgrade --cask codex` |

## Next steps

- [Explore the CLI reference](https://learn.chatgpt.com/docs/developer-commands?surface=cli)
- [Configure Codex](https://learn.chatgpt.com/docs/configuration?surface=cli)
- [Automate with `codex exec`](https://learn.chatgpt.com/docs/non-interactive-mode)

## Sources

Verified against the official docs on **2026-09-01**:

- Codex CLI quickstart: <https://learn.chatgpt.com/docs/codex/cli#getting-started>
- Authentication options: <https://learn.chatgpt.com/docs/auth>
- Best practices: <https://learn.chatgpt.com/guides/best-practices>