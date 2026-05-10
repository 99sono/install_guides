# Squashing Commits Before Pushing

This guide walks you through your pre-push workflow: check commit count, review the diff, and interactive rebase-squash so you can push cleanly.

## The Pre-Push Checklist

Here's the routine you run before every push to keep your branch history clean:

### Step 1: Check How Many Commits Are Ahead

```bash
./scripts/01_a_git_number_of_commits_ahead.sh
```

Tells you exactly how many commits you've made that haven't been pushed to `origin/master` yet, and gives you the `git rebase -i HEAD~N` command you'll need.

### Step 2: Review the Changes

```bash
./scripts/01_b_git_diff_dump_against_origin.sh
```

Generates `SQUASH_MESSAGE_HELPER.diff` — a clean diff of all changes against `origin/master`. Use this to review your changes side by side and inform your squash commit message (you can even feed it to an LLM for a summary).

### Step 3: Interactive Rebase to Squash

```bash
git rebase -i HEAD~N
```

Replace `N` with the commit count from Step 1. This launches your configured editor with a todo list of all your unpushed commits.

## Interactive Rebase Deep Dive

### Step 1: Run the Rebase

```bash
git rebase -i HEAD~3    # squash the last 3 commits
git rebase -i main      # squash all commits in your branch vs main
```

Your editor opens with a list like this:

```
pick a1b2c3d First commit message
pick d4e5f6g Second commit message
pick h7i8j9k Third commit message

# Rebase instructions follow...
```

### Step 2: Edit the Todo List

- Keep the **first** line as `pick` (this is the commit message that will be kept).
- Change all other lines from `pick` to `squash` (or shortcut: `s`).

```
pick a1b2c3d First commit message
squash d4e5f6g Second commit message
squash h7i8j9k Third commit message
```

Save and exit your editor (see editor tips below).

### Step 3: Write the Combined Commit Message

Git opens the editor again with all commit messages combined. Edit to a single, clean message:

```
Implement Java parser feature with fixes

Initial implementation of the Java parser component,
including lexer support and token handling.

Fix minor boundary condition in tokenizer.
Add unit tests for parser edge cases.
```

Save and exit.

### Step 4: Handle Conflicts (If Any)

If you have conflicts (rare with squashing, but possible):

```bash
# Resolve conflicts in any conflicting files
# Then stage them and continue
git add .
git rebase --continue
```

### Step 5: Verify

```bash
git log --oneline -5    # should show fewer/squashed commits
git status               # should show clean state
```

Then push:

```bash
git push --force-with-lease
```

**Note:** `--force-with-lease` is safer than `--force`. It checks that no one else pushed to the branch in the meantime, and aborts if there are new remote commits you're not aware of.

## Editor Tips

### Nano

- Save: `Ctrl+O`, then `Enter`
- Exit: `Ctrl+X`

### Vim / Vi

- Press `i` to enter insert mode
- Save and quit: press `Esc`, then type `:wq`, then `Enter`
- Abort: press `Esc`, then type `:q!`, then `Enter`

### VSCode

- Save: `Ctrl+S`
- Close tab or quit as normal — VSCode works fine for Git editors
- `--wait` flag must be set (`git config --global core.editor "code --wait"`)

## Practical Tips

### When to Squash

- **Before pushing**: Always squash local commits before pushing to shared branches.
- **Not before pushing**: Squash after merge (if your workflow requires) or use squash merge via the GitLab/GitHub UI (which squashes on merge without rewriting history).
- **Never squash**: If commits have already been pulled by other collaborators — they'll have a divergent history. Ask them to rebase from a fresh `fetch`.

### When NOT to Squash

- Commits that have already been pushed and pulled by others.
- Commits on shared branches (e.g. `main`, `develop`) that other developers track.
- Feature branches that are actively being collaborated on with others via direct pushes.

### Alternative: Simple Reset

For quick local squashes without an editor:

```bash
git reset --soft HEAD~3
git commit -m "Clean combined message for all 3 commits"
```

This keeps all changes staged in one new commit. Less control over individual commit message content, but much faster.

### Abort

If you change your mind:

```bash
git rebase --abort    # resets to state before rebase started
```

## Safety

- **Never rewrite public history**: Squashing is safe for your own local, unpushed commits. Once shared, history rewriting requires coordination with collaborators.
- **Always use `--force-with-lease`**, not `--force`, when pushing after a rebase.
