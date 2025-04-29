# Installation Steps: Convert HEIC to JPEG on WSL2 Ubuntu

Follow these steps to install the required tools and convert your HEIC files to JPEG format with reduced resolution.

## 1. Install Required Packages

Open your WSL2 Ubuntu terminal and install the following:

```bash
sudo apt update
sudo apt install libheif-examples imagemagick
```

- `libheif-examples`: Includes `heif-convert`, a CLI tool to convert `.heic` to `.jpg`.
- `imagemagick`: Used for resizing images via the `mogrify` or `convert` commands.

## 2. Convert HEIC Images to JPEG

Navigate to the folder containing your `.HEIC` files:

```bash
cd /mnt/c/Users/<your-user>/Downloads/photos/
```

Create an output directory and convert all images:

```bash
mkdir -p jpg_output
for file in *.HEIC; do
  heif-convert "$file" "jpg_output/${file%.HEIC}.jpg"
done
```

## 3. Resize JPEG Images by 50%

Navigate to the output folder:

```bash
cd jpg_output
```

Resize all JPEGs to half their original size:

```bash
mogrify -resize 50% *.jpg
```

> This will overwrite the original `.jpg` files with resized versions.