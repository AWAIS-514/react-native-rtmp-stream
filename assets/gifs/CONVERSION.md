# Converting SVG to GIF

The animated SVG files in this directory can be converted to GIF format for better compatibility.

## Quick Conversion (Online Tools)

### Recommended: EZGIF
1. Go to https://ezgif.com/svg-to-gif
2. Upload each SVG file
3. Set frame delay (recommended: 100ms for smooth animation)
4. Download the GIF

### Alternative: CloudConvert
1. Go to https://cloudconvert.com/svg-to-gif
2. Upload SVG files
3. Configure settings:
   - Width: 600-800px
   - Height: 400-500px
   - Quality: High
4. Convert and download

## Command Line Conversion

### Using ImageMagick (may not preserve animations perfectly)

```bash
# Install ImageMagick
brew install imagemagick  # macOS
# or
sudo apt-get install imagemagick  # Ubuntu

# Convert (basic - may lose animation)
convert -background none -resize 600x400 rtmp-support.svg rtmp-support.gif
```

### Using Inkscape + FFmpeg (better for animations)

```bash
# Install tools
brew install inkscape ffmpeg  # macOS

# Export frames from SVG (requires manual frame extraction)
# Then use FFmpeg to create GIF:
ffmpeg -framerate 10 -i frame%03d.png -vf "scale=600:400:flags=lanczos" output.gif
```

## Best Method: Use Online Tools

For the best results preserving animations, use:
- **EZGIF.com** - Best for SVG to GIF conversion
- **CloudConvert.com** - High quality conversion
- **Convertio.co** - Simple interface

## File Sizes

After conversion, optimize GIFs:
- Target size: Under 2MB per GIF
- Use EZGIF optimizer: https://ezgif.com/optimize
- Reduce colors if needed (256 max)
- Adjust frame rate (10-15 fps is usually enough)

## Current SVG Files

All SVG files are ready and animated. They work in:
- Modern browsers (Chrome, Firefox, Safari)
- GitHub README (static preview)
- Documentation sites

For maximum compatibility, convert to GIF using the methods above.

