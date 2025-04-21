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

### Example of Mixed Package Management
```bash
conda install numpy pandas
pip install some_missing_package
```

### Environment Export/Import
```bash
conda env export > environment.yml             # Export environment
conda env create -f environment.yml           # Create from file
```