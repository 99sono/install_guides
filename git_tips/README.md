# Git Tips

## Introduction

This directory provides practical tips and examples for common Git workflows, focusing on local development, multi-agent workflows, and release branching strategies.

## Workflow Guides

- **Squashing commits before push** → `squashing_commits.md`. Pre-push checklist with scripts + interactive rebase deep dive.
- **Branching workflow** → `branching_workflow.md`. Create, push, pull, and clean up branches.
- **Git worktrees** → `git_worktrees.md`. Multi-branch and multi-agent workflows without cloning.
- **Merge request with LLM** → `patch_for_llm.md`. Generate MR descriptions from patch files.
- **Revert a specific file from a commit** → `revert_file_changes.md`.

## Editor & Configuration

- **Interactive editor** → `interactive_editor_config.md`. Configure nano, vim, or VSCode for Git editors.
- **Installation** → `installation.md`. Basic Git setup.

## Troubleshooting

- **Troubleshooting** → `troubleshooting.md`. Common errors: push rejections, auth, upstream, pathspec.

## Quick Reference

- **Common commands** → `common_commands.md`. Everyday Git commands.

## Files

| File | Purpose |
|---|---|
| `squashing_commits.md` | Pre-push checklist + squashing guide |
| `branching_workflow.md` | Create/push/pull branches |
| `git_worktrees.md` | Multi-branch and multi-agent workflows |
| `patch_for_llm.md` | GitLab MR description generation with LLMs |
| `revert_file_changes.md` | Reverting specific file changes |
| `interactive_editor_config.md` | Configuring nano, vim, or VSCode for Git |
| `installation.md` | Basic Git installation |
| `troubleshooting.md` | Common errors and fixes |
| `common_commands.md` | Quick reference |

## Quick Example: Pushing a New Branch

```bash
git checkout -b feature/my-feature
git push --set-upstream origin feature/my-feature
```

For more on Git fundamentals, refer to the official [Git documentation](https://git-scm.com/docs).
