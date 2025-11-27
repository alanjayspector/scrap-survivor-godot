#!/bin/bash
# optimize-art-assets.sh
# Optimizes art assets for mobile deployment
# Uses macOS sips (no ImageMagick required)

set -e

ART_DIR="/Users/alan/Developer/scrap-survivor-godot/art-docs"
ASSETS_DIR="/Users/alan/Developer/scrap-survivor-godot/assets/ui/backgrounds"
PORTRAITS_DIR="/Users/alan/Developer/scrap-survivor-godot/assets/ui/portraits"

# Create output directories if they don't exist
mkdir -p "$ASSETS_DIR"
mkdir -p "$PORTRAITS_DIR"

echo "🎨 Optimizing Art Assets for Mobile"
echo "===================================="

# Function to optimize background images (convert to JPG, resize to 2048 max)
optimize_background() {
    local input="$1"
    local output="$2"
    local max_size="${3:-2048}"
    
    if [ ! -f "$input" ]; then
        echo "⚠️  Source not found: $input"
        return 1
    fi
    
    echo "📦 Optimizing: $(basename "$input")"
    
    # Get current dimensions
    local width=$(sips -g pixelWidth "$input" | tail -1 | awk '{print $2}')
    local height=$(sips -g pixelHeight "$input" | tail -1 | awk '{print $2}')
    echo "   Original: ${width}x${height}"
    
    # Copy to temp file for processing
    local temp_file="/tmp/$(basename "$input")"
    cp "$input" "$temp_file"
    
    # Resize if larger than max_size
    if [ "$width" -gt "$max_size" ] || [ "$height" -gt "$max_size" ]; then
        echo "   Resizing to max ${max_size}px..."
        sips --resampleHeightWidthMax "$max_size" "$temp_file" --out "$temp_file" > /dev/null
    fi
    
    # Convert to JPG with quality optimization
    local output_base="${output%.png}"
    output_base="${output_base%.jpg}"
    local output_jpg="${output_base}.jpg"
    sips -s format jpeg -s formatOptions 85 "$temp_file" --out "$output_jpg" > /dev/null
    
    # Get final size
    local final_size=$(ls -lh "$output_jpg" | awk '{print $5}')
    echo "   Output: $output_jpg ($final_size)"
    
    # Cleanup
    rm -f "$temp_file"
    
    return 0
}

# Function to optimize silhouette images (keep PNG for transparency, resize to 512)
optimize_silhouette() {
    local input="$1"
    local output="$2"
    local target_size="${3:-512}"
    
    if [ ! -f "$input" ]; then
        echo "⚠️  Source not found: $input"
        return 1
    fi
    
    echo "📦 Optimizing silhouette: $(basename "$input")"
    
    # Copy and resize
    cp "$input" "$output"
    sips --resampleHeightWidthMax "$target_size" "$output" --out "$output" > /dev/null
    
    # Get final size
    local final_size=$(ls -lh "$output" | awk '{print $5}')
    echo "   Output: $output ($final_size)"
    
    return 0
}

echo ""
echo "📸 Processing Background Images..."
echo "-----------------------------------"

# Recruitment background (Character Creation)
optimize_background "$ART_DIR/recruitment.png" "$ASSETS_DIR/character_creation_bg.jpg" 2048

# Character Details background (if exists)
if [ -f "$ART_DIR/character-details-bg.png" ]; then
    optimize_background "$ART_DIR/character-details-bg.png" "$ASSETS_DIR/character_details_bg.jpg" 2048
else
    echo "⏳ character-details-bg.png not yet created"
fi

# Barracks interior (already optimized, but let's ensure consistency)
if [ -f "$ART_DIR/final-option-c-barracks.png" ]; then
    optimize_background "$ART_DIR/final-option-c-barracks.png" "$ASSETS_DIR/barracks_interior.jpg" 2048
fi

echo ""
echo "👤 Processing Silhouette Images..."
echo "-----------------------------------"

# Type silhouettes
for type in scavenger tank commando mutant; do
    if [ -f "$ART_DIR/silhouette-${type}.png" ]; then
        optimize_silhouette "$ART_DIR/silhouette-${type}.png" "$PORTRAITS_DIR/silhouette_${type}.png" 512
    else
        echo "⏳ silhouette-${type}.png not yet created"
    fi
done

echo ""
echo "✅ Optimization Complete!"
echo ""
echo "📊 Final Asset Sizes:"
echo "-----------------------------------"
ls -lh "$ASSETS_DIR"/*.jpg 2>/dev/null || echo "No background JPGs yet"
echo ""
ls -lh "$PORTRAITS_DIR"/*.png 2>/dev/null || echo "No silhouette PNGs yet"
