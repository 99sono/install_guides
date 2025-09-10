
# 📝 Converting DOCX Files to Markdown on Ubuntu

This guide walks you through converting `.docx` files (Microsoft Word format) into clean, readable Markdown files using Ubuntu. Perfect for preparing documents as context for LLMs or for version-controlled documentation.

---

## 📦 Step 1: Install Required Software

We’ll use [`pandoc`](https://pandoc.org), a powerful universal document converter.

### Install via terminal:
```bash
sudo apt update
sudo apt install pandoc
```

---

## 🔄 Step 2: Convert DOCX to Markdown

Once installed, you can convert any `.docx` file to `.md` using the following command:

```bash
pandoc "your-file.docx" -f docx -t markdown -o "your-file.md"
```

### Example:
```bash
pandoc "code reviewer 04.a_ mini app to interact with github.docx" -f docx -t markdown -o "code reviewer 04.a_ mini app to interact with github.md"
```

---

## 🔁 Bonus: Batch Convert All DOCX Files in a Folder

To convert all `.docx` files in the current directory:

```bash
for file in *.docx; do
    pandoc "$file" -f docx -t markdown -o "${file%.docx}.md"
done
```

This will create a `.md` version of each `.docx` file with the same name.

---

## ✅ Done!

You now have Markdown versions of your Word documents, ready for use in LLM pipelines, documentation repos, or static site generators.

