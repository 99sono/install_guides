# How to Upgrade Aider

To keep your Aider installation up to date, follow these steps:

## 1. Check Installed Packages

List the currently installed pip packages and check the version of `aider-install`:

```bash
pip list
```

Look for the `aider-install` package in the output and note its version.

## 2. Upgrade Aider

First, upgrade the `aider-install` package:

```bash
pip install --upgrade aider-install
```

Then, use the `aider-install` command to automatically upgrade Aider:

```bash
aider-install
```

This will update Aider and its dependencies to the latest version.

## 3. Verify the Installation

Check that Aider has been upgraded successfully:

```bash
aider --version
```

This should display the new version number.

---

**Tip:** If you encounter any issues during the upgrade, refer to the [troubleshooting.md](troubleshooting.md) guide for solutions.
