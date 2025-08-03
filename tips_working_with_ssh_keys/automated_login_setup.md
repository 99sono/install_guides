# Automated Login Setup

## Overview
This guide shows how to automatically load your SSH keys when starting new terminal sessions in WSL2 Ubuntu, eliminating the need to manually run ssh-agent and ssh-add commands.

## Shell Profile Configuration

### Step 1: Identify Your Shell
```bash
echo $SHELL
```

Common outputs:
- `/bin/bash` (default in Ubuntu)
- `/bin/zsh`
- `/bin/fish`

### Step 2: Edit Your Shell Profile

#### For Bash Users
Edit `~/.bashrc`:
```bash
nano ~/.bashrc
```

#### For Zsh Users
Edit `~/.zshrc`:
```bash
nano ~/.zshrc
```

### Step 3: Add SSH Agent Automation

Add the following configuration to your shell profile:

```bash
# SSH Agent Auto-Start and Key Loading
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check if ssh-agent is already running
   RUNNING_AGENT="$(ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]')"
   
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new ssh-agent
        eval "$(ssh-agent -s)"
   fi
   
   # Add your SSH key (adjust path as needed)
   ssh-add ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/id_rsa 2>/dev/null
fi
```

### Step 4: Alternative Configuration (More Robust)

For better error handling and multiple key support:

```bash
# SSH Agent Configuration with Error Handling
ssh_env="$HOME/.ssh/agent-environment"
ssh_add_lock="$HOME/.ssh/agent-lock"

# Function to start ssh-agent
start_ssh_agent() {
    echo "Starting SSH agent..."
    ssh-agent -s > "$ssh_env"
    chmod 600 "$ssh_env"
    . "$ssh_env" > /dev/null
    
    # Add common SSH keys
    for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
        if [ -f "$key" ]; then
            echo "Adding SSH key: $key"
            ssh-add "$key" 2>/dev/null
        fi
    done
}

# Check if agent is already running
if [ -f "$ssh_env" ]; then
    . "$ssh_env" > /dev/null
    ps -p "$SSH_AGENT_PID" > /dev/null 2>&1 || start_ssh_agent
else
    start_ssh_agent
fi
```

## GNOME Keyring Integration (Optional)

If you're using a desktop environment with GNOME:

### Check if GNOME Keyring is Available
```bash
ps aux | grep gnome-keyring
```

### Enable SSH Key Storage
```bash
# Install if not available
sudo apt update && sudo apt install gnome-keyring

# Ensure it's running
echo 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >> ~/.bashrc
```

## Testing Your Setup

### 1. Reload Your Shell Configuration
```bash
source ~/.bashrc  # or ~/.zshrc for zsh
```

### 2. Verify SSH Agent Started
```bash
echo $SSH_AUTH_SOCK
```

### 3. Check Loaded Keys
```bash
ssh-add -l
```

### 4. Test Git Operations
```bash
cd /path/to/your/repo
git fetch origin
```

## Customization Options

### Multiple Keys
Modify the configuration to add multiple keys:

```bash
# Add multiple keys
ssh-add ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_rsa_github
ssh-add ~/.ssh/id_rsa_gitlab
```

### Different Key Locations
If your keys are in non-standard locations:

```bash
ssh-add /custom/path/to/your/key
```

### Conditional Loading
Only load keys for specific directories:

```bash
# Only load keys when in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    ssh-add ~/.ssh/id_ed25519
fi
```

## Troubleshooting Automated Setup

### Issue: Keys Not Loading Automatically
**Solution**: Check if your shell profile is being sourced:
```bash
echo "SSH agent debug"  # Add this to your .bashrc to test
```

### Issue: Multiple SSH Agents
**Solution**: Use the more robust configuration above to prevent duplicate agents

### Issue: Passphrase Prompt on Every Terminal
**Solution**: Ensure the lock file mechanism is working or use the simpler configuration

## Security Considerations

- **Session-based**: Keys are loaded when you open a new terminal
- **User-specific**: Only affects your user account
- **Memory-only**: Keys are not persisted to disk
- **Automatic cleanup**: Keys are removed when you close all terminals

## Reverting Changes

To remove the automated setup:

1. Edit your shell profile:
   ```bash
   nano ~/.bashrc
   ```

2. Remove the SSH agent configuration you added
3. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

## Next Steps

After setting up automated login, you should no longer need to manually manage SSH keys. If you encounter issues, refer to the [troubleshooting guide](troubleshooting.md).
