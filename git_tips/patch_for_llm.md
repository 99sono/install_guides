# GitLab Merge Request Description with LLMs

Generate MR/PR descriptions using a patch file and LLM, capturing the full scope of your changes.

## Ingredients

### 1. Feature Metadata
Write a short summary explaining:
- What the feature is
- Why it matters
- Any relevant background/context

```bash
# Save as: FEATURE-1234_summary.md
```

### 2. Patch File (Code Diff)
Generate a patch capturing all changes compared to the main branch:

```bash
git fetch origin master:master
git diff master...HEAD > FEATURE-1234_full_development.patch
```

## How To

### Generate the Patch

```bash
git diff main...HEAD > FEATURE-1234.patch
```

For a more structured patch with commit metadata:

```bash
git format-patch main --stdout > FEATURE-1234_detailed.patch
```

Preview commits for context:

```bash
git log main..HEAD --oneline
```

### Feed to an LLM

Upload the feature summary and patch file to your LLM with a prompt like:

> Review the metadata in FEATURE-1234_summary.md. Scan the code changes in FEATURE-1234.patch.
> Create a Markdown merge request description that:
> - Clearly explains the overall problem
> - Describes the solution and summarizes key code changes across files
> - Highlights the most important file to review

### Generate a Merge Request Commit Message

Alternatively, use the patch to generate a comprehensive commit message for squashing:

```bash
git diff main...HEAD | cat | llama-cpp-python-chat
```

Combine with the squash workflow to get a single, well-written commit message.

## Notes

- File naming: use descriptive names like `feature_java_parser_implementation.patch`
- Large branches: for very large patch files, target recent commits: `git diff main...HEAD~5`
- Patch files work best with text-based changes; large binary file changes may need special handling
