# HEIC to JPEG Conversion on WSL2 (Ubuntu)

This guide explains how to convert a folder of `.HEIC` images—such as those downloaded from Google Photos—into `.jpg` format using WSL2 (Ubuntu), and reduce the image resolution by half using command-line tools. It covers all installation steps, conversion commands, and troubleshooting for common issues.

## Prerequisites

Before you begin, ensure you have:

*   **WSL2 (Ubuntu):**  Follow the official Microsoft documentation to set up WSL2.
*   **Required Packages:** Install the following packages in your Ubuntu WSL2 terminal:

    ```bash
    sudo apt update
    sudo apt install libheif-examples imagemagick
    ```

## Installation Steps

For a detailed breakdown of the installation process, refer to the `heic_to_jpeg/installation_steps.md` file. This document provides a step-by-step guide to setting up the necessary tools.

## Troubleshooting

If you encounter any issues during the conversion process, consult the `heic_to_jpeg/troubleshooting.md` file for common problems and their solutions.

## Further Reading

*   `heic_to_jpeg/installation_steps.md`: Detailed installation instructions.
*   `heic_to_jpeg/troubleshooting.md`:  Solutions to common problems.
