# OpenCode Skills Guide

## What are Skills?

Skills are specialized, high-level instruction sets and workflows that extend the native capabilities of OpenCode. While OpenCode is inherently capable of text, image, and audio processing, **Skills** provide the model with:

- **Specialized Reasoning**: Domain-specific logical workflows (e.g., advanced PDF table extraction).
- **Advanced Tool Use**: Pre-defined protocols for interacting with complex local or remote tools.
- **Optimized Context**: Structured prompt templates designed to trigger specific professional behaviors (e.g., "Plan" vs "Build" modes).

---

## Local Environment Adaptations

While skills are designed to be platform-agnostic, you may occasionally need to adapt them to match your local setup—especially when a skill relies on specific Python dependencies.

### The "Environment Gap"
A standard skill assumes that all required commands and libraries are available in the current shell. However, if your dependencies are isolated in a specific environment (like a Conda env), the skill might fail if it tries to run a command directly.

**Example: The PDF Skill**
In our environment, the PDF skill requires several heavy libraries (`pypdf`, `pdfplumber`, etc.) which are installed in the `opencode` conda environment. To ensure the skill works correctly, the environment instructions must be modified to use:
`conda run -n opencode <command>`

Instead of the original generic instruction:
`python script.py`

The adapted skill uses:
`conda run -n opencode python script.py`

### Best Practice: Aim for Portability
Ideally, you should strive to keep skills in their **original, vanilla state**. The most practical approach is to ensure your local environment is "skill-compatible"—meaning you have an environment ready that meets the skill's requirements. 

By managing your environment to match the skill's needs, you avoid the maintenance burden of having to "fine-tune" or rewrite individual skill files every time you pull a new one from a repository.

---

## Centralized Skill Management

Skills are managed centrally to allow them to be shared across all your OpenCode projects. You do not need to add skill files to every repository you work in.

### Installation Directory
All custom skills should be placed in your global OpenCode configuration directory:

`~/.config/opencode/skills/`

When you run OpenCode, it automatically scans this directory and loads any `.md` files found within, making their specialized instructions available to the model.

---

## Skill Discovery & "Shopping"

If you are looking to expand the capabilities of your OpenCode instance, there is a rich ecosystem of community-driven skills available.

### The Ultimate Starting Point
For a vast collection of high-quality, ready-to-use skills, visit the [boazcstrike/opencode](https://github.com/boazcstrike/opencode) repository. This repository serves as a primary resource for the community.

**Example Skill:**
- [PDF Processing Skill](https://github.com/boazcstrike/opencode/blob/main/skills/pdf/SKILL.md): A comprehensive guide for advanced PDF manipulation and extraction.

### Lineage and Transferability
Many of the most powerful skills in the OpenCode ecosystem are intelligent adaptations of the [Anthropic Skills](https://github.com/anthropics/skills/tree/main/skills) library designed for **Claude Code**.

Because OpenCode uses a similar agentic architecture, these skills are highly transferable. If you find a skill that works well for Claude Code, it can often be adapted or used directly within OpenCode to unlock professional-grade workflows.
