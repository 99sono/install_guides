# Common Conda Commands and Best Practices

This document provides a reference for frequently used Conda commands and package management best practices.

## Environment Management

### 🔍 List Environments
```bash
conda env list
```

### 🆕 Create Environment
```bash
conda create -n my_env python=3.10
```

## 🛠️ Managing Non-Python Environments (Node.js / NPM)

Conda is an excellent tool for creating isolated environments for non-Python runtimes. This is particularly useful for managing JavaScript-based CLI tools.

### Why use Conda for Node.js?
When you install `nodejs` inside a Conda environment, it creates a **dedicated, isolated binary** for that environment. This ensures that any global installations (using `npm install -g`) are contained within that specific environment's directory and do not interfere with your system-wide configuration.

**Verification:**
You can verify that you are using the environment-specific binary by using the `whereis` command. For example, if you run `whereis npm`, the output will show the path to the binary within your active environment, such as:
- **NPM Path:** `~/programs/miniforge3/envs/your_env/bin/npm`
- **Node Path:** `~/programs/miniforge3/envs/your_env/bin/node`

### Typical Workflow for CLI Tools
If an installation guide instructs you to run `npm install -g <package>`, follow these steps to ensure it stays in a sandbox:

1. **Create the environment with Node.js included:**
   ```bash
   conda create -n cli_env nodejs -y
   ```
2. **Activate the environment:**
   ```bash
   conda activate cli_env
   ```
3. **Install the package globally within the environment:**
   ```bash
   npm install -g <package_name>
   ```

#### 🆙 Updating NPM
If you need to update `npm` itself to a specific version within your environment, you can run:
```bash
npm install -g npm@11.13.0
```

### 🔥 Environment Activation/Deactivation
```bash
conda activate my_env    # Activate environment
conda deactivate        # Return to base environment
```

## Package Management

### Installing Packages
```bash
conda install package_name          # Install a single package
conda install package1 package2     # Install multiple packages
conda install package=1.2.3         # Install specific version
```

### Managing Dependencies
```bash
conda list                         # List installed packages
conda update --all                 # Update all packages
conda install python=3.13.3        # Update the python version of the selected conda environment
conda remove package_name          # Remove a package
```

## Best Practices

### Package Installation Priority
1. **First Choice**: Use `conda install package_name`
   - Ensures proper dependency resolution
   - Maintains environment consistency

2. **Second Choice**: Use `pip install package_name`
   - Only when package is not available via conda
   - Install after conda packages to avoid conflicts

### Example of Mixed Package Management (not recommended)
```bash
conda install numpy pandas  # install a library with conda
pip install some_missing_package
pip install -r requirements.txt # installs a list of requirements with pip
pip list    # list packages installed by pip
pip list --outdated # list oudate packages
pip install --upgrade   packagename # upgrade outdated packages 
pip install --upgrade pip  #upgrade pip
```


### Environment Export/Import
```bash
conda env export > environment.yml             # Export environment
conda env create -f environment.yml           # Create from file
```