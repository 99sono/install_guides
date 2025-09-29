# Git Troubleshooting

This file addresses common issues encountered in Git workflows, particularly those related to branch management and remote operations. Solutions are provided with step-by-step fixes. If an error persists, check Git logs with `git log` or consult the official [Git troubleshooting guide](https://git-scm.com/docs/git#Documentation/git.txt).

## 1. Error: "no upstream branch" or "There is no tracking information for the current branch"

### Issue
Trying to `git push` or `git pull` without setting upstream for a new local branch.

### Solution
Set the upstream explicitly:
```
git push --set-upstream origin <branch-name>
```
- Example: `git push --set-upstream origin feature/99sono_java_parser_start_implementation`.
- Once set, future operations simplify to `git push` or `git pull`.

### Prevention
Always use `--set-upstream` (or `-u`) on the first push for new branches.

## 2. Error: "Updates were rejected because the remote branch is up to date" or Push Rejected

### Issue
The remote branch has changes (e.g., from another collaborator) that conflict with your local commits.

### Solution
1. Pull remote changes first:
   ```
   git pull origin <branch-name>
   ```
   - This fetches and merges remote changes. If conflicts arise, resolve them manually in the files, then `git add .` and `git commit`.

2. If no merge needed, rebase instead:
   ```
   git pull --rebase origin <branch-name>
   ```
   - Applies your commits on top of remote changes.

3. Push again:
   ```
   git push
   ```

### Prevention
Pull before pushing if collaborating. Use `git status` to check for divergence.

## 3. Authentication Errors: "Permission denied (publickey)" or "remote: Support for password authentication was removed"

### Issue
Using HTTPS with passwords (deprecated) or SSH without keys.

### Solution
- **Switch to SSH**: Follow `tips_working_with_ssh_keys/README.md`. Add SSH remote:
  ```
  git remote set-url origin git@github.com:username/repo.git
  ```
- **Use Personal Access Token (PAT) for HTTPS**:
  1. Generate a PAT in GitHub settings > Developer settings > Personal access tokens.
  2. Use the PAT as password when prompted (username remains your GitHub username).
- Verify remotes: `git remote -v`.

### Prevention
Prefer SSH for frequent use. Update remotes in `.git/config` if needed.

## 4. Branch Not Found: "error: pathspec 'feature/...' did not match any file(s) known to git"

### Issue
Typo in branch name or branch doesn't exist locally/remotely.

### Solution
- List local branches: `git branch`.
- List remote branches: `git branch -r`.
- Create if missing: `git checkout -b <branch-name>`.
- Correct typo and retry.

## 5. General Tips
- Enable verbose output: Add `-v` to commands (e.g., `git push -v`) for more details.
- Reset to last commit if needed: `git reset --hard HEAD` (caution: loses uncommitted changes).
- For WSL2-specific issues (e.g., line endings, permissions): Ensure `git config --global core.autocrlf false` and run Git from WSL terminal.
- If Git hangs: Check SSH agent (`ssh-add -l`) or increase timeout (`git config --global http.postBuffer 524288000` for large pushes).

Refer to `common_commands.md` for correct workflows. If stuck, share the exact error message for further help.
