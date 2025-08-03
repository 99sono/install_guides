# Troubleshooting SSH Key Issues

## Common Problems and Solutions

### 1. "Could not open a connection to your authentication agent"

**Error Message:**
```
Could not open a connection to your authentication agent
```

**Solutions:**

#### Quick Fix (Manual)
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

#### Permanent Fix (Add to .bashrc)
Add to your `~/.bashrc`:
```bash
# Ensure SSH agent is running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
fi
```

### 2. "Permission denied (publickey)"

**Error Message:**
```
git@github.com: Permission denied (publickey).
```

**Checklist:**

1. **Verify SSH key exists:**
   ```bash
   ls -la ~/.ssh/
   ```

2. **Check key permissions:**
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

3. **Test SSH connection:**
   ```bash
   ssh -T git@github.com
   ```

4. **Check if key is loaded:**
   ```bash
   ssh-add -l
   ```

### 3. SSH Key Not Found

**Error Message:**
```
/home/username/.ssh/id_ed25519: No such file or directory
```

**Solutions:**

1. **Check available keys:**
   ```bash
   ls ~/.ssh/
   ```

2. **Use correct key path:**
   ```bash
   # For RSA keys
   ssh-add ~/.ssh/id_rsa
   
   # For ED25519 keys
   ssh-add ~/.ssh/id_ed25519
   
   # For custom named keys
   ssh-add ~/.ssh/github_key
   ```

### 4. "Agent admitted failure to sign"

**Error Message:**
```
sign_and_send_pubkey: signing failed: agent refused operation
```

**Solutions:**

1. **Restart SSH agent:**
   ```bash
   ssh-add -D  # Remove all keys
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

2. **Check key permissions:**
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   ```

### 5. SSH Agent Not Persisting Between Terminals

**Problem:** SSH agent doesn't work in new terminal windows

**Solution:** Add to `~/.bashrc`:
```bash
# Ensure SSH agent environment is available
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
fi
```

### 6. "Bad permissions" Error

**Error Message:**
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0644 for '/home/username/.ssh/id_ed25519' are too open.
```

**Fix permissions:**
```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh
```

## Diagnostic Commands

### 1. Check SSH Agent Status
```bash
# Check if agent is running
echo $SSH_AUTH_SOCK

# List loaded keys
ssh-add -l

# List all keys (including non-loaded)
ssh-add -L
```

### 2. Test SSH Connection
```bash
# Verbose SSH test
ssh -vT git@github.com

# Test specific key
ssh -i ~/.ssh/id_ed25519 -T git@github.com
```

### 3. Debug SSH Agent
```bash
# Check running processes
ps aux | grep ssh-agent

# Check environment variables
env | grep SSH
```

### 4. Verify Key Format
```bash
# Check key type
file ~/.ssh/id_ed25519

# Verify key is valid
ssh-keygen -y -f ~/.ssh/id_ed25519 > /dev/null && echo "Key is valid"
```

## Git-Specific Issues

### 1. Git Still Asks for Password

**Check Git remote URL:**
```bash
git remote -v
```

**Should show SSH format:**
```
origin  git@github.com:username/repo.git (fetch)
origin  git@github.com:username/repo.git (push)
```

**If showing HTTPS format, change to SSH:**
```bash
git remote set-url origin git@github.com:username/repo.git
```

### 2. Multiple Git Identities

**Problem:** Using different SSH keys for different Git accounts

**Solution:** Create SSH config file:
```bash
nano ~/.ssh/config
```

Add configuration:
```
# GitHub personal
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

# GitHub work
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_work
```

Then use:
```bash
git remote set-url origin git@github-work:workusername/repo.git
```

## WSL2 Specific Issues

### 1. SSH Agent Not Working in WSL2

**Solution:** Ensure proper environment variable passing:
```bash
# Add to ~/.bashrc
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
```

### 2. Windows SSH Agent Conflict

**Problem:** WSL2 using Windows SSH agent instead of Linux

**Solution:** Force Linux SSH agent:
```bash
# In ~/.bashrc
unset SSH_AUTH_SOCK
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## Recovery Procedures

### Reset SSH Environment
```bash
# Kill all SSH agents
killall ssh-agent

# Start fresh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Regenerate SSH Key (Last Resort)
```bash
# Backup existing key
cp ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.backup

# Generate new key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519
```

## Testing Your Fix

### 1. Verify SSH Agent
```bash
ssh-add -l
```

### 2. Test Git Operations
```bash
cd /path/to/your/repo
git fetch origin
```

### 3. Test SSH Connection
```bash
ssh -T git@github.com
```

Expected output:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

## Getting Help

If issues persist:

1. **Check system logs:**
   ```bash
   journalctl -u ssh
   ```

2. **Verify SSH configuration:**
   ```bash
   sshd -t  # Test SSH daemon config
   ```

3. **Check Git configuration:**
   ```bash
   git config --list | grep -i ssh
   ```

## Quick Reference Card

| Problem | Command |
|---------|---------|
| Start SSH agent | `eval "$(ssh-agent -s)"` |
| Add key | `ssh-add ~/.ssh/id_ed25519` |
| List keys | `ssh-add -l` |
| Remove all keys | `ssh-add -D` |
| Test connection | `ssh -T git@github.com` |
| Fix permissions | `chmod 600 ~/.ssh/id_ed25519` |
