# SSH Keys Session Management Guide

## Overview
This guide provides solutions for managing SSH keys with passphrases in WSL2 Ubuntu, eliminating the need to repeatedly enter your SSH key password when performing Git operations like `git fetch origin`.

## Problem Statement
When your SSH key has a passphrase, Git operations that require authentication will prompt for the passphrase every time. This becomes tedious during active development sessions.

## Quick Start
For immediate relief, run these commands in your WSL2 Ubuntu terminal:

```bash
# Start SSH agent and load your key (run once per session)
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## Available Documentation

- **[SSH Key Session Management](ssh_key_session_management.md)** - Detailed guide on using ssh-agent and ssh-add for session-based key management
- **[Automated Login Setup](automated_login_setup.md)** - Configure automatic key loading when starting new terminal sessions
- **[Troubleshooting](troubleshooting.md)** - Common issues and their solutions

## Prerequisites
- WSL2 Ubuntu installation
- SSH key with passphrase already configured
- Git repository using SSH authentication

## Security Note
These methods keep your SSH key decrypted in memory for the duration of your session. Always lock your computer when stepping away, and consider the security implications for your specific use case.

## Next Steps
1. Start with the [SSH Key Session Management](ssh_key_session_management.md) guide for immediate usage
2. Set up [Automated Login Setup](automated_login_setup.md) for convenience
3. Refer to [Troubleshooting](troubleshooting.md) if you encounter issues
