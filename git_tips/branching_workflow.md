# Branching Workflow

This guide covers the branching workflow: creating branches, pushing them to remote, pulling remote branches, and cleaning up after merges.

## 1. Pushing a Locally Created Branch

### Scenario
You have created a new feature branch locally and want to push it to the remote repository, setting it up for tracking.

### Steps

1. Create and switch to the new branch:
```bash
git checkout -b feature/99sono_java_parser_start_implementation
```

2. Make changes and commit:
```bash
git add .
git commit -m "Initial implementation for Java parser feature"
```

3. Push the branch to remote and set upstream:
```bash
git push --set-upstream origin feature/99sono_java_parser_start_implementation
```

### Verification
- `git status` should show "Your branch is up to date with origin/feature/..."
- Future pushes: Simply `git push`

### Tips
- Use descriptive branch names: `feature/<ticket_id>-<description>`
- If the branch already exists remotely, use `git push origin feature/...` without `--set-upstream`

## 2. Pulling a Remotely Created Branch to Local

### Scenario
A branch was created remotely (e.g. by a teammate via GitLab/GitHub UI), and you want to fetch and work on it locally.

### Steps

1. Fetch remote updates:
```bash
git fetch origin
```

2. Create and switch to local tracking branch:
```bash
git checkout -b feature/99sono_upgrade_software_versions_and_coding_agents origin/feature/99sono_upgrade_software_versions_and_coding_agents
```

Or for Git 2.23+:
```bash
git switch -c feature/99sono_upgrade_software_versions_and_coding_agents origin/feature/99sono_upgrade_software_versions_and_coding_agents
```

3. (Usually automatic) Verify upstream:
```bash
git branch -vv
```

### Tips
- List remote branches: `git branch -r`
- For all remotes: `git fetch --all`

## 3. Deleting a Remote Feature Branch After Merge

### Scenario
After a merge request has been completed and merged, clean up the branch on the remote.

### Steps

1. Delete the remote branch:
```bash
git push origin --delete feature/99sono_upgrade_software_versions_and_coding_agents
```

2. Delete the local branch:
```bash
git branch -d feature/99sono_upgrade_software_versions_and_coding_agents
```

### Tips
- Use `git branch -D` instead of `-d` if the branch wasn't fully merged
- Always confirm the branch is no longer needed before deleting

## 4. Updating Local Main Without Checkout

### Scenario
You want to update your local `main` branch with the latest from `origin/main` without checking it out.

```bash
git fetch origin main
git update-ref refs/heads/main origin/main
```

> ⚠️ This overwrites your local `main` branch pointer. If you have local commits on `main`, they will be lost unless backed up.

**Safer approach** — just fetch and inspect:
```bash
git fetch origin
git log origin/main
git diff main origin/main
```
