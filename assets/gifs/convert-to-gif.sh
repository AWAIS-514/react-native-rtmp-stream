#!/bin/bash

# Convert SVG animations to GIF files
# Requires: ImageMagick or Inkscape

echo "Converting SVG animations to GIF files..."

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    echo "Using ImageMagick..."
    
    # Convert each SVG to GIF
    for svg in *.svg; do
        if [ -f "$svg" ]; then
            gif_name="${svg%.svg}.gif"
            echo "Converting $svg to $gif_name..."
            
            # Convert SVG to PNG frames, then to GIF
            # Note: ImageMagick may not preserve animations perfectly
            # For better results, use Inkscape or online tools
            convert -background none -resize 600x400 "$svg" "$gif_name" 2>/dev/null || \
            echo "Warning: Could not convert $svg. Try using Inkscape or online converter."
        fi
    done
    
elif command -v inkscape &> /dev/null; then
    echo "Using Inkscape..."
    echo "Note: Inkscape converts to PNG. Use an online tool to create animated GIFs."
    
    for svg in *.svg; do
        if [ -f "$svg" ]; then
            png_name="${svg%.svg}.png"
            echo "Converting $svg to $png_name..."
            inkscape "$svg" --export-filename="$png_name" --export-width=600 --export-height=400
        fi
    done
    
else
    echo "Error: Neither ImageMagick nor Inkscape found."
    echo ""
    echo "Install ImageMagick:"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu: sudo apt-get install imagemagick"
    echo ""
    echo "Or use online converters:"
    echo "  - https://ezgif.com/svg-to-gif"
    echo "  - https://cloudconvert.com/svg-to-gif"
    echo ""
    echo "Or install Inkscape:"
    echo "  macOS: brew install inkscape"
    echo "  Ubuntu: sudo apt-get install inkscape"
fi

echo "Done!"

