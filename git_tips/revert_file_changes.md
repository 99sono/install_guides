# Reverting Changes on a Specific File

Sometimes you need to revert changes to just one file in a commit without undoing everything else.

## Steps

### 1. Identify the Commit

```bash
git log -- <path-to-file>
```

Example:
```bash
git log -- com/some/path/to/JohnDoe.xlsx
```

This shows all commits that modified the file. Copy the commit hash you want to revert.

### 2. Restore the File

**To get the version BEFORE that commit:**

```bash
git restore --source=<commit-hash>^ -- com/some/path/to/JohnDoe.xlsx
```

**To get the version FROM that commit:**

```bash
git restore --source=<commit-hash> -- com/some/path/to/JohnDoe.xlsx
```

> **Tip:** `^` means "the parent of that commit," so you get the state before the change.

### 3. Stage and Commit

```bash
git add com/some/path/to/JohnDoe.xlsx
git commit -m "Revert changes to JohnDoe.xlsx from commit <commit-hash>"
```

## Notes

- Works with Git LFS files too.
- Older syntax:
  ```bash
  git checkout <commit-hash>^ -- com/some/path/to/JohnDoe.xlsx
  ```
