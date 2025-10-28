# Reverting Changes on a Specific File from a Specific Commit

Sometimes you need to revert changes made to **just one file** in a commit (or merge request) without undoing everything else. Here’s how to do it.

---

## Steps

### 1. Identify the Commit
Run:
```bash
git log -- <path-to-file>
```
Example:
```bash
git log -- com/some/path/to/JohnDoe.xlsx
```
This shows all commits that modified the file. Copy the commit hash you want to revert.

---

### 2. Restore the File
If you want the version **before** that commit:
```bash
git restore --source=<commit-hash>^ -- com/some/path/to/JohnDoe.xlsx
```

If you want the version **from that commit**:
```bash
git restore --source=<commit-hash> -- com/some/path/to/JohnDoe.xlsx
```

> **Tip:** `^` means “the parent of that commit,” so you get the state before the change.

---

### 3. Stage and Commit
```bash
git add com/some/path/to/JohnDoe.xlsx
git commit -m "Revert changes to JohnDoe.xlsx from commit <commit-hash>"
```

---

## Notes
- Works with **Git LFS** files too.
- If you prefer the older syntax:
```bash
git checkout <commit-hash>^ -- com/some/path/to/JohnDoe.xlsx
```
