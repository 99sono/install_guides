# Interactive Editor Configuration

Git uses an editor for interactive operations like commit messages, rebasing, or amending commits. Configure it to match your environment.

## Check Current Editor

```bash
git config --global core.editor
```

If blank or unset, it defaults to your system's editor (often vi).

## Recommended Editors

### Nano (default on Ubuntu/WSL2)
- No configuration required
- Save: `Ctrl+O` then `Enter`
- Exit: `Ctrl+X`

### Vi / Vim

```bash
git config --global core.editor "vim"
```

- Press `i` to enter insert mode
- Save and quit: `Esc`, then `:wq`
- Quit without saving: `Esc`, then `:q!`

### VSCode

```bash
git config --global core.editor "code --wait"
```

The `--wait` flag tells Git to pause until you close the editor tab.

### Emacs

```bash
git config --global core.editor "emacsclient --tty"
```

## Testing

After setting your editor, test with:

```bash
git commit --amend
```

Your editor should open to edit the commit message. Save/exit to complete or close without saving to cancel.

```bash
git reset --soft HEAD~1    # undo the amend
rm test.txt                 # clean up test file
```

Choose based on your environment: nano/vim for quick terminal edits, VSCode for familiar UI.
