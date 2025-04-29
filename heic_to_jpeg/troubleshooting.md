# Troubleshooting: HEIC to JPEG Conversion

## 🧯 Issue: `mogrify-im6.q16: time limit exceeded` or `cache` error

**Symptom:**
```bash
mogrify-im6.q16: time limit exceeded 'IMG_4134.HEIC.jpg' @ fatal/cache.c/GetImagePixelCache/1867.
```

**Cause:**
This happens when ImageMagick hits default resource limits (memory, time).

**Fix:**

1. Edit the ImageMagick policy file:

```bash
sudo nano /etc/ImageMagick-6/policy.xml
```

2. Look for or add the following lines (adjust as needed):

```xml
<policy domain="resource" name="memory" value="4GiB"/>
<policy domain="resource" name="map" value="8GiB"/>
<policy domain="resource" name="time" value="600"/>
```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

## 🧯 Alternative: Use `convert` instead of `mogrify`

If `mogrify` continues to fail, use this workaround:

```bash
for f in *.jpg; do convert "$f" -resize 50% "$f"; done
```

This processes images one at a time and avoids resource spikes.