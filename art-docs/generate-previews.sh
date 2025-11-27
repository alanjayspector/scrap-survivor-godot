#!/bin/bash
# Art Preview Generator for Claude Code
# Creates compressed versions of art assets for AI analysis
# Uses macOS sips (no external dependencies)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREVIEW_DIR="${SCRIPT_DIR}/preview"
MAX_DIMENSION=1200
QUALITY=80
MAX_SIZE_KB=2000  # Target max ~2MB per image

echo "=== Art Preview Generator ==="
echo "Source: ${SCRIPT_DIR}"
echo "Output: ${PREVIEW_DIR}"
echo "Max dimension: ${MAX_DIMENSION}px"
echo ""

# Create preview directory
mkdir -p "${PREVIEW_DIR}"

# Process each image
for img in "${SCRIPT_DIR}"/*.png "${SCRIPT_DIR}"/*.jpg "${SCRIPT_DIR}"/*.jpeg "${SCRIPT_DIR}"/*.webp; do
    [ -f "$img" ] || continue

    filename=$(basename "$img")
    base="${filename%.*}"
    output="${PREVIEW_DIR}/${base}-preview.jpg"

    echo "Processing: ${filename}"

    # Get original dimensions
    orig_width=$(sips -g pixelWidth "$img" | tail -1 | awk '{print $2}')
    orig_height=$(sips -g pixelHeight "$img" | tail -1 | awk '{print $2}')
    orig_size=$(ls -l "$img" | awk '{print $5}')
    orig_size_mb=$(echo "scale=1; $orig_size / 1048576" | bc)

    echo "  Original: ${orig_width}x${orig_height} (${orig_size_mb}MB)"

    # Calculate new dimensions maintaining aspect ratio
    if [ "$orig_width" -gt "$orig_height" ]; then
        new_width=$MAX_DIMENSION
        new_height=$(echo "scale=0; $orig_height * $MAX_DIMENSION / $orig_width" | bc)
    else
        new_height=$MAX_DIMENSION
        new_width=$(echo "scale=0; $orig_width * $MAX_DIMENSION / $orig_height" | bc)
    fi

    # Create resized copy
    cp "$img" "$output"
    sips -z "$new_height" "$new_width" "$output" > /dev/null 2>&1

    # Convert to JPEG with compression (sips uses -s formatOptions for quality)
    sips -s format jpeg -s formatOptions $QUALITY "$output" --out "$output" > /dev/null 2>&1

    # Get new size
    new_size=$(ls -l "$output" | awk '{print $5}')
    new_size_kb=$(echo "scale=0; $new_size / 1024" | bc)

    echo "  Preview:  ${new_width}x${new_height} (${new_size_kb}KB)"
    echo ""
done

# Summary
echo "=== Complete ==="
echo "Preview images created in: ${PREVIEW_DIR}"
echo ""
echo "File sizes:"
ls -lh "${PREVIEW_DIR}"/*.jpg 2>/dev/null | awk '{print "  " $5 " " $9}'
echo ""
echo "Total size:"
du -sh "${PREVIEW_DIR}"
