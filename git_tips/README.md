# Git Tips

## Introduction
This directory provides practical tips and examples for common Git workflows, focusing on branch management, collaboration, and everyday commands. It assumes a basic Git installation and a remote repository setup (e.g., on GitHub). These tips are tailored for developers working in Unix-like environments such as WSL2/Ubuntu.

The goal is to streamline Git usage for tasks like creating branches, pushing changes, and resolving common issues, making collaboration smoother.

### Covered Topics
- **Editor Configuration**: Setting up nano, vi, or VSCode as Git's interactive editor, with tips and testing.
- **Branch Creation and Pushing**: How to create a local branch and set it up to track a remote branch.
- **Common Commands**: Step-by-step examples for frequent Git operations.
- **Rebasing and Commit Squashing**: Using interactive rebase to consolidate unpushed commits.
- **Installation/Setup**: Basic Git installation if needed (cross-references to WSL2 guide).
- **Troubleshooting**: Fixes for typical errors like push rejections or upstream issues.

For more on Git fundamentals, refer to the official [Git documentation](https://git-scm.com/docs).

### Quick Example: Pushing a New Branch
Assuming you've created a local branch with `git branch feature/99sono_java_parser_start_implementation`:

```
git push --set-upstream origin feature/99sono_java_parser_start_implementation
```

This command pushes the branch to the remote (`origin`) and sets the upstream tracking, allowing future `git push` and `git pull` without extra flags.

## Repository Consistency
This guide follows the standard structure of the install_guides repository:
- `README.md`: Overview and quick starts.
- `common_commands.md`: Detailed command examples.
- `installation_steps.md`: Setup instructions.
- `troubleshooting.md`: Common issues and solutions.

Contribute more tips by adding examples or expanding sections!
