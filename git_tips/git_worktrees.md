# Git Worktrees

Git worktrees let you check out multiple branches of the same repository simultaneously in different directories — all sharing the same Git database. No need for separate clones.

## Why Use Worktrees?

### Working on Multiple Release Branches

When you need to test or fix bugs on several branches at once (e.g. `main`, `release/v1.0`, `release/v2.0`), worktrees let you have all of them open side by side without cloning the repo multiple times.

```bash
git worktree add ../project-release-v1.0 release/v1.0
git worktree add ../project-release-v2.0 release/v2.0
```

Each works like a normal working directory: you can build, test, edit, and commit.

### Multi-Agent / Multi-Tasker Workflow

If you have multiple agents (or yourself) working on different features, worktrees keep them isolated from each other:

```bash
# Create a worktree for agent working on feature A
git worktree add ../worktree-agentA feature/some_new_branch

# Create a worktree for agent working on feature B
git worktree add ../worktree-agentB feature/another_branch
```

Each agent works in its own directory with its own branch. No interference, no need to switch branches and risk losing uncommitted changes.

## Basic Workflow

### Create a Worktree

```bash
# From any branch, create a new worktree for an existing local branch
git worktree add ../worktree-name branch-name

# Or create and check out a new branch in a new directory
git worktree add -b feature/new-work ../worktree-name

# From a remote branch (creates local tracking branch)
git worktree add -b new-branch-name ../worktree-name origin/remote-branch
```

The `../worktree-name` part is just where the new working directory is created. Place it wherever makes sense for your project layout.

### List Worktrees

```bash
git worktree list
```

Output looks like:

```
/home/sono99/project              539f0912 [main]
/home/sono99/project-release-v1.0 ab12cd34 [release/v1.0]
/home/sono99/project-agentA      ef56ab78 [feature/some_new_branch]
```

The `-v` flag adds more details:

```bash
git worktree list -v
```

### Move a Worktree

```bash
git worktree move ../worktree-name /new/path/to/worktree-name
```

### Remove a Worktree

```bash
# Only remove the working directory, don't delete the branch
git worktree remove ../worktree-name

# When you're done with a branch too, remove it entirely
git branch -d feature/some_new_branch
git worktree remove ../worktree-name
```

### Lock a Worktree

Prevent accidental modifications (e.g. when a CI job holds it):

```bash
git worktree lock ../worktree-name
git worktree unlock ../worktree-name
```

### Push/Pull in a Worktree

Inside a worktree directory, everything works like a normal Git repo:

```bash
cd ../worktree-name
git status
git pull origin feature/some_new_branch
git push origin feature/some_new_branch
```

## Useful Commands

```bash
git worktree add -b new-branch-name ../worktree-name            # create new branch + worktree
git worktree add ../worktree-name main                           # checkout existing branch
git worktree add -b new-branch-name ../worktree-name origin/master  # start tracking remote
git worktree list                                                 # show all worktrees
git worktree list --porcelain                                   # machine-readable output
git worktree remove ../worktree-name                             # remove directory only
git worktree move ../old-path ../new-path                       # move a worktree
git worktree lock ../worktree-name                               # prevent modifications
git worktree unlock ../worktree-name                             # unlock
git worktree remove --force ../worktree-name                     # remove even with changes
```

## Notes

- `git worktree`, `git branch`, and `git remotes` commands work from the **root** directory only — not from within a worktree.
- Worktrees share the same Git database, so they don't duplicate `.git` objects. Space savings are significant when managing several branches.
- A branch can only be checked out in one worktree at a time.
