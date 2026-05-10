# Common Git Commands

Quick-reference commands for everyday operations.

## Quick Commands

```bash
git status                        # current state
git log --oneline -10              # last 10 commits
git log --oneline main..HEAD       # commits not on main
git diff main...HEAD              # diff against main
git branch                        # local branches
git branch -r                     # remote branches
git branch -vv                   # branches with upstream info
git remote -v                     # remote URLs
git fetch origin                  # fetch without merging
git stash                        # save uncommitted changes
git stash pop                    # apply stashed changes
```

## Shortcuts

```bash
git add .                         # stage all changes
git commit -m "message"           # commit with message
git push                          # push current branch
git pull                          # pull and merge
git reset HEAD~1                  # undo last commit (keep changes)
git reset --hard HEAD             # discard all uncommitted changes
```
