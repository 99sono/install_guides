# 🐳 docker-push-to-github

This guide explains how to push Docker images to a public Docker Hub repository that’s linked to a GitHub project. It covers naming conventions, tagging strategies, and platform-specific issues — especially when working in Windows 11 and WSL2.

---

## 📦 Overview

When publishing Docker images to Docker Hub, it’s important to understand how repository naming works:

- **Docker Hub does not support nested paths** in repository names.
  - ❌ `username/public-repo/dev-environment` → Invalid
  - ✅ `username/dev-environment` → Valid

If you want to publish multiple types of images (e.g. dev environments, stubs, base layers) but only use a single Docker Hub repository, you’ll need to **encode the image’s semantic meaning into the tag name**.

---

## ✅ Tagging Strategy

Instead of trying to nest image types inside a single repo, use a flat structure and encode the image’s purpose in the tag:

```bash
docker tag local-image:1.0.0-SNAPSHOT username/public-repo:dev-environment-1.0.0-SNAPSHOT
docker push username/public-repo:dev-environment-1.0.0-SNAPSHOT
```

This keeps the repository structure valid while preserving clarity about the image’s purpose.

---

## 🧩 Troubleshooting

### ❗ Windows 11 + WSL2: Docker Login Confusion

In WSL2, you may encounter a situation where:

- `docker login` reports success
- But `docker push` fails with:

  ```
  push access denied, repository does not exist or may require authorization
  ```

This typically means:
- Docker credentials were stored in **Windows**, not accessible from **WSL2**
- WSL2’s Docker CLI can’t read the Windows credential store

### ✅ Workaround

Use **PowerShell or CMD** outside WSL2 to push the image:

```powershell
docker push username/public-repo:dev-environment-1.0.0-SNAPSHOT
```

This ensures Docker uses the correct credential context.

---

### 🗑️ Removing Incorrectly Pushed Tags or Images

If you accidentally push an image with the wrong tag or want to clean up a mistake:

- **Locally remove the image/tag:**
  ```bash
  docker rmi username/public-repo:incorrect-tag
  ```
  This deletes the local image associated with that tag. If the image is untagged and no other tags reference it, it will be removed entirely.

- **Remote repository cleanup (Docker Hub):**
  - Docker Hub does not support deleting tags via the CLI.
  - Visit the [Docker Hub web interface](https://hub.docker.com), navigate to your repository, and delete tags manually under the "Tags" section.

---

## 🧠 Notes

- Consider creating separate repositories for each image type if clarity and discoverability are priorities.
- Use tags like `1.0.0-SNAPSHOT` to indicate that the image may be overwritten frequently.
- Store your Docker Hub repo name and tag prefix in environment variables for scriptability.

---

Happy pushing!
