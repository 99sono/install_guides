# Common Git Commands

This file provides step-by-step examples of frequently used Git commands, focusing on practical workflows. Commands are presented with explanations, prerequisites, and potential output. These examples assume you are working in a Git repository with a remote (e.g., GitHub) named `origin`.

## Configuring the Git Editor

Git uses an editor for interactive operations like commit messages, rebasing, or amending commits. The default is often vi or nano, but you can configure a global editor. Start by checking the current setting:

```
git config --global core.editor
```

- If blank or unset, it defaults to your system's editor (e.g., vi).
- To change it, use the commands below for your preferred editor.

### Default: Nano
No configuration required—it's lightweight and often the default on Ubuntu/WSL2.

- **Tips for Use**: The "^" symbol means hold the Ctrl key.
  - Save: Ctrl+O (^O).
  - Exit: Ctrl+X (^X) after saving.
  - If in nano, look at the bottom for commands (e.g., "^O Write Out").

### Vi/Vim
Popular for terminal users; install if needed (`sudo apt install vim`).

- **Configuration**:
  ```
  git config --global core.editor "vim"
  ```
  (Use "vi" if vim isn't installed.)

- **Tips for Use**:
  - Press `i` to enter insert mode and edit.
  - Press Esc to return to command mode.
  - Save and quit: Type `:wq` and press Enter (write and quit).
  - Quit without saving: `:q!`.

### VSCode
Ideal for GUI editing; assumes `code` is in your PATH (available in WSL2/VSCode Remote).

- **Configuration**:
  ```
  git config --global core.editor "code --wait"
  ```
  The `--wait` flag pauses Git until you close the editor.

- **Tips for Use**:
  - Edit the file normally.
  - Save: Ctrl+S.
  - Close the tab: Ctrl+W (or click X), or use the Command Palette (Ctrl+Shift+P) > "Close Editor".
  - **Dev Containers/Remote Setup**: Works when VSCode is attached to a container (via Dev Containers extension). The `code` CLI runs inside the container, opening VSCode on the host. Verify with `which code`. If issues, ensure VSCode Server is installed in the container; it may open a new window, but edits sync back.

### Verification and Testing
After setting:
1. Confirm: `git config --global core.editor`.
2. Test (safe, no history change): Create a test file (`echo "test" > test.txt`), stage it (`git add test.txt`), then:
   ```
   git commit --amend
   ```
   - Your editor should open to edit the message. Save/exit to complete (or cancel by closing without saving).
   - Clean up: `git reset --soft HEAD~1 && rm test.txt`.

Choose based on your environment: Nano/Vi for quick terminal edits, VSCode for familiar UI. For other editors (e.g., emacs: `"emacsclient --tty"`), adapt similarly.

## 2. Pushing a Locally Created Branch to Remote

### Scenario
You have created a new feature branch locally and want to push it to the remote repository, setting it up for tracking (upstream) so future pushes/pulls are simpler.

### Prerequisites
- Git repository initialized (`git init` or cloned).
- Local branch created but not yet pushed.
- Remote origin configured (`git remote add origin <url>` if not already set).

### Steps

1. **Create and Switch to the New Branch** (if not already done):
   ```
   git checkout -b feature/99sono_java_parser_start_implementation
   ```
   - This creates a new branch from the current one (typically `main` or `master`) and switches to it.
   - Alternative: `git branch feature/99sono_java_parser_start_implementation` followed by `git checkout feature/99sono_java_parser_start_implementation`.

2. **Make Changes and Commit**:
   Add your files and commit:
   ```
   git add .
   git commit -m "Initial implementation for Java parser feature"
   ```
   - Replace the message with a descriptive one.

3. **Push the Branch to Remote and Set Upstream**:
   ```
   git push --set-upstream origin feature/99sono_java_parser_start_implementation
   ```
   - `--set-upstream` (or `-u`) pushes the branch to the remote and configures local branch to track the remote one.
   - Output example:
     ```
     Enumerating objects: 5, done.
     Counting objects: 100% (5/5), done.
     Writing objects: 100% (3/3), 1.23 KiB | 1.23 MiB/s, done.
     Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
     To https://github.com/99sono/install_guides.git
      * [new branch]      feature/99sono_java_parser_start_implementation -> feature/99sono_java_parser_start_implementation
     Branch 'feature/99sono_java_parser_start_implementation' set up to track remote branch 'feature/99sono_java_parser_start_implementation' from 'origin'.
     ```

### Verification
- Check branch status: `git status` (should show "Your branch is up to date with 'origin/feature/99sono_java_parser_start_implementation'").
- Future pushes: Simply `git push` (no need for branch name or upstream flag).

### Tips
- Use descriptive branch names following conventions like `feature/<ticket_id>-<description>` or `bugfix/<issue>-<description>`.
- If the branch already exists remotely, use `git push origin feature/99sono_java_parser_start_implementation` without `--set-upstream`.
- Before creating, check if the branch exists remotely: `git fetch origin && git branch -r | grep feature/99sono_java_parser_start_implementation`. If it does, see "4. Pulling a Remotely Created Branch to Local" instead.

## 3. Interactive Rebase for Squashing Commits

### Scenario
You have multiple small, unpushed commits on your local branch (e.g., from iterative development) and want to consolidate (squash) them into fewer, more meaningful commits before pushing. This cleans up history without losing changes.

### Prerequisites
- Commits are unpushed: `git status` shows "Your branch is ahead of 'origin/branch' by N commits."
- Configure your editor (see "Configuring the Git Editor" above)—Git will open it for editing the commit list and messages.
- In a clean working directory (commit or stash changes first: `git stash`).

### Steps for Squashing the Last 2 Unpushed Commits

1. **Initiate Interactive Rebase**:
   ```
   git rebase -i HEAD~2
   ```
   - `-i` enables interactive mode; `HEAD~2` targets the last 2 commits (use `~N` for more).
   - Your editor opens a "todo" list like:
     ```
     pick abc1234 First commit message
     pick def5678 Second commit message

     # Rebase instructions...
     ```
   - Comment lines (#) explain options.

2. **Edit the Todo List**:
   - Keep the first line as `pick` (or unpicked for the base).
   - Change the second line to `squash` (or `s`) to combine it with the first.
   - Example edited:
     ```
     pick abc1234 First commit message
     squash def5678 Second commit message
     ```
   - Save and exit the editor (e.g., Ctrl+O/X in nano, :wq in vim, Ctrl+S/close in VSCode).

3. **Edit the Combined Commit Message**:
   - Git opens the editor again for the new message:
     ```
     # This is a combination of 2 commits...
     # The first commit's message is:
     First commit message

     # This is the 2nd commit message:
     Second commit message

     # Please enter a new message...
     ```
   - Edit to a single descriptive message, e.g., "Implement Java parser feature with fixes."
   - Save and exit.

4. **Complete Rebase**:
   - Git applies the squashed commit. If conflicts, resolve files, `git add`, then `git rebase --continue`.
   - Output example: "Successfully rebased and updated refs/heads/feature/..."

### Verification
- Check history: `git log --oneline -5` (should show 1 commit instead of 2).
- Status: `git status` confirms no divergence.

### Tips
- Only rebase unpushed/local commits—rewriting pushed history can cause issues for collaborators.
- For more options: `drop` (d) to remove a commit, `edit` (e) to pause and amend.
- Alternative for simple squashes: `git reset --soft HEAD~2 && git commit -m "Combined message"` (resets but keeps changes staged).
- If aborted: `git rebase --abort` to reset.

Refer to `troubleshooting.md` for rebase conflicts or errors.

## 4. Pulling a Remotely Created Branch to Local

### Scenario
A branch was created remotely (e.g., by a teammate via GitHub UI or another developer), and you want to fetch it and work on it locally by creating a tracking branch.

### Prerequisites
- Repository cloned and connected to remote (`git remote -v` shows origin).
- No local branch with the same name yet, or handle merges if it exists.

### Steps

1. **Fetch Remote Updates**:
   ```
   git fetch origin
   ```
   - This downloads the latest changes and branches from the remote without affecting your local work. Output shows new branches like " * [new branch] origin/feature/99sono_java_parser_start_implementation -> origin/feature/99sono_java_parser_start_implementation".

2. **Create and Switch to Local Tracking Branch**:
   ```
   git checkout -b feature/99sono_java_parser_start_implementation origin/feature/99sono_java_parser_start_implementation
   ```
   - This creates a local branch named `feature/99sono_java_parser_start_implementation` from the remote version and switches to it, setting up automatic tracking.
   - Alternative for Git 2.23+: `git switch -c feature/99sono_java_parser_start_implementation origin/feature/99sono_java_parser_start_implementation`.

3. **Set Upstream (if not automatic)**:
   ```
   git branch --set-upstream-to=origin/feature/99sono_java_parser_start_implementation
   ```
   - Ensures future `git pull`/`git push` use the remote as default. Usually done by step 2.

### Verification
- Status: `git status` should show "Your branch is up to date with 'origin/feature/99sono_java_parser_start_implementation'".
- List branches: `git branch -vv` (shows tracking, e.g., [origin/...: ahead/behind 0:0]).

### Tips
- To see remote branches: `git branch -r` (e.g., after fetch).
- If local branch exists: `git checkout feature/...` to switch, or `git merge origin/feature/...` to integrate changes.
- For all remotes: `git fetch --all`. Pull instead of fetch for merging: `git pull origin feature/...` (but fetch first for safety).
- If conflicts during future pulls, resolve and commit.

Refer to `troubleshooting.md` for fetch/pull errors or tracking issues.

## 5. Deleting a Remote Feature Branch After Merge

### Scenario
After a merge request (pull request) is completed and merged into the main branch (e.g., main/master), clean up by deleting the now-unnecessary feature branch from the remote repository (e.g., GitHub) to keep the remote branch list tidy.

### Prerequisites
- The merge request has been approved and merged.
- You have push access to the remote repository.
- Fetch the latest remote state: `git fetch origin` to ensure you're up to date.
- The local branch may still exist; this command only affects the remote.

### Steps

1. **Delete the Remote Branch**:
   ```
   git push origin --delete feature/99sono_upgrade_software_versions_and_coding_agents
   ```
   - `--delete` (or `-d`) removes the specified branch from the remote.
   - Replace `feature/99sono_upgrade_software_versions_and_coding_agents` with your actual branch name.
   - Output example:
     ```
     To https://github.com/99sono/install_guides.git
      - [deleted]         feature/99sono_upgrade_software_versions_and_coding_agents
     ```

### Verification
- Check remote branches: `git fetch origin && git branch -r` (the deleted branch should no longer appear).
- On GitHub: Refresh the repository branches page; the branch should be gone.

### Tips
- This does not delete your local branch. To delete locally: `git branch -d feature/99sono_upgrade_software_versions_and_coding_agents` (use `-D` to force if not fully merged).
- For protected branches (e.g., main), you may need additional permissions or use the GitHub UI.
- Bulk deletion: If cleaning up multiple, list them, e.g., `git push origin --delete branch1 branch2`.
- Alternative via GitHub UI: Go to the repository > Branches tab > Select the branch > Delete (no CLI needed, but CLI is faster for scripting).
- Always confirm the branch is no longer needed before deleting.
- Refer to `troubleshooting.md` for permission errors or other issues.

## Future Additions
- Cherry-picking commits.
- Undoing changes: `git revert` or `git reset`.

Refer to `troubleshooting.md` for common errors like "no upstream branch" or authentication issues.
