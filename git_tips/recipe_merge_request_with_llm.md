# 🧪 Recipe: Generating Excellent GitLab Merge Request Descriptions with LLMs

This guide outlines a simple and effective method for creating clear, structured, and review-friendly merge request (MR) descriptions using a Large Language Model (LLM).

---

## 🥣 Ingredients

To prepare your MR description, gather the following:

### 1. 📄 Feature Metadata

Write a short summary or explanation of the feature/topic you're working on. This can be a rough sketch written by the developer that explains:

- What the feature is
- Why it matters
- Any relevant background or context

Save this as a plain text or markdown file.

```bash
# Example:
# Save as: FEATURE-1234_summary.md
```

---

### 2. 🧵 Patch File (Code Diff)

Generate a patch file that captures all code changes in your feature branch compared to the main branch.

```bash
git fetch origin master:master
git diff master...HEAD > FEATURE-1234_full_development.patch
```

---

## 🧑‍🍳 Instructions

### Step 1: Upload Your Ingredients

Upload both the feature summary and the patch file to the LLM interface or workspace.

---

### Step 2: Use the Prompt

Use the following prompt to instruct the LLM:

````markdown
My intention is for you to:

1. Review the metadata about the topic written in the <FeatureSummaryFile>.
2. Scan through the code changes written in the <PatchFile>.
3. Create an **excellent** Markdown file that I can use as the GitLab merge request description.

The Markdown should:
- Clearly explain the overall problem.
- Describe the solution and summarize the key code changes across files.
- Highlight the most important file to review in relation to the feature.
````

---

### Step 3: Review and Refine

Once the LLM generates the Markdown, review it for accuracy and completeness. You can tweak the wording or add additional context if needed.

---

## ✅ Benefits

- Saves time writing MR descriptions
- Improves clarity and review quality
- Ensures traceability between feature intent and code changes
