#!/usr/bin/env bash
# Asset Import Validator
# Validates Godot .import files for correct compression, format, and size settings
# Based on: docs/godot-import-research.md

set -e

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKED=0

echo -e "${BLUE}🎨 Validating asset imports...${NC}"

# Check if assets directory exists
if [ ! -d "assets" ] && [ ! -d "resources" ]; then
    echo -e "${GREEN}✓ No assets directory found - skipping import validation${NC}"
    exit 0
fi

# Function to check PNG import settings
check_png_import() {
    local import_file="$1"
    local source_file="${import_file%.import}"

    # Skip if .import file doesn't exist
    [ ! -f "$import_file" ] && return

    CHECKED=$((CHECKED + 1))

    # Extract key parameters from .import file
    local compress_mode=$(grep "compress/mode=" "$import_file" | cut -d'=' -f2)
    local detect_3d=$(grep "detect_3d/compress_to=" "$import_file" | cut -d'=' -f2)
    local mipmaps=$(grep "mipmaps/generate=" "$import_file" | cut -d'=' -f2)

    # Check compression mode (0 = Lossless for pixel art)
    if [ "$compress_mode" != "0" ] && [ -n "$compress_mode" ]; then
        echo -e "${RED}❌ ERROR: Pixel art using non-lossless compression${NC}"
        echo "   File: $source_file"
        echo "   compress/mode=$compress_mode (should be 0 for Lossless)"
        echo "   Fix: Set 'Compress > Mode: Lossless' in Godot import settings"
        ERRORS=$((ERRORS + 1))
    fi

    # Check Detect 3D (should be disabled = 0 or 1)
    # detect_3d/compress_to: 0 = Disabled, 1 = VRAM Compressed (bad for 2D)
    if [ "$detect_3d" = "1" ] && [ -n "$detect_3d" ]; then
        echo -e "${RED}❌ ERROR: Detect 3D enabled on 2D sprite (causes auto-recompression)${NC}"
        echo "   File: $source_file"
        echo "   detect_3d/compress_to=$detect_3d (should be 0 for Disabled)"
        echo "   Fix: Set 'Detect 3D > Compress To: Disabled' in Godot import settings"
        ERRORS=$((ERRORS + 1))
    fi

    # Check mipmaps (should be false for pixel art)
    if [ "$mipmaps" = "true" ]; then
        echo -e "${YELLOW}⚠️  WARNING: Mipmaps enabled on sprite (blurs pixel art)${NC}"
        echo "   File: $source_file"
        echo "   mipmaps/generate=true (should be false for 2D pixel art)"
        echo "   Fix: Set 'Mipmaps > Generate: No' in Godot import settings"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check file size (warn if >2MB for sprites)
    if [ -f "$source_file" ]; then
        local file_size=$(stat -f%z "$source_file" 2>/dev/null || stat -c%s "$source_file" 2>/dev/null)
        local size_mb=$((file_size / 1024 / 1024))

        # Sprite sheets should be ≤2MB
        if [ "$size_mb" -gt 2 ]; then
            echo -e "${RED}❌ ERROR: Sprite sheet exceeds 2MB limit${NC}"
            echo "   File: $source_file"
            echo "   Size: ${size_mb}MB (max 2MB)"
            echo "   Fix: Split into smaller atlases or reduce dimensions"
            ERRORS=$((ERRORS + 1))
        fi

        # Check texture dimensions (warn if >4096 for mobile)
        # We can't easily check dimensions from bash without imagemagick
        # Will rely on pre-commit validation during actual imports
    fi
}

# Function to check OGG/WAV import settings
check_audio_import() {
    local audio_file="$1"
    local ext="${audio_file##*.}"

    CHECKED=$((CHECKED + 1))

    # Check if it's MP3 (should reject)
    if [ "$ext" = "mp3" ]; then
        echo -e "${RED}❌ ERROR: MP3 audio file found (use OGG Vorbis)${NC}"
        echo "   File: $audio_file"
        echo "   Fix: Convert to OGG Vorbis format"
        echo "   Reason: MP3 has licensing/patent concerns, OGG is open"
        ERRORS=$((ERRORS + 1))
        return
    fi

    # Check file size for music (warn if >8MB)
    if [ -f "$audio_file" ]; then
        local file_size=$(stat -f%z "$audio_file" 2>/dev/null || stat -c%s "$audio_file" 2>/dev/null)
        local size_mb=$((file_size / 1024 / 1024))

        # Music should be ≤8MB
        if [[ "$audio_file" == *"music"* ]] && [ "$size_mb" -gt 8 ]; then
            echo -e "${YELLOW}⚠️  WARNING: Music track exceeds 8MB${NC}"
            echo "   File: $audio_file"
            echo "   Size: ${size_mb}MB (max 8MB recommended)"
            echo "   Fix: Reduce bitrate to 128kbps or use OGG compression"
            WARNINGS=$((WARNINGS + 1))
        fi

        # SFX should be much smaller
        if [[ "$audio_file" == *"sfx"* ]] && [ "$size_mb" -gt 1 ]; then
            echo -e "${YELLOW}⚠️  WARNING: SFX file is large (>1MB)${NC}"
            echo "   File: $audio_file"
            echo "   Size: ${size_mb}MB"
            echo "   Fix: Use OGG 96kbps or WAV with compression"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# Function to check asset naming conventions
check_naming_convention() {
    local file="$1"
    local basename=$(basename "$file")
    local name="${basename%.*}"

    # Pattern: [category]_[entity]_[variant] (snake_case)
    # Examples: characters_player_idle.png, ui_button_hover.png

    # Check if file follows snake_case
    if [[ ! "$name" =~ ^[a-z0-9_]+$ ]]; then
        echo -e "${YELLOW}⚠️  WARNING: Asset naming convention violation${NC}"
        echo "   File: $file"
        echo "   Expected: snake_case pattern like 'category_entity_variant'"
        echo "   Examples: characters_player_idle.png, ui_button_hover.png"
        WARNINGS=$((WARNINGS + 1))
        return
    fi

    # Check if file has at least one underscore (category separator)
    if [[ ! "$name" =~ _ ]]; then
        echo -e "${YELLOW}⚠️  WARNING: Asset missing category prefix${NC}"
        echo "   File: $file"
        echo "   Expected: category_entity_variant (e.g., characters_player_idle)"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Scan for PNG files and check imports
if [ -d "assets" ]; then
    while IFS= read -r -d '' png_file; do
        import_file="${png_file}.import"
        check_png_import "$import_file"
        check_naming_convention "$png_file"
    done < <(find assets -name "*.png" -print0 2>/dev/null)
fi

if [ -d "resources" ]; then
    while IFS= read -r -d '' png_file; do
        import_file="${png_file}.import"
        check_png_import "$import_file"
        check_naming_convention "$png_file"
    done < <(find resources -name "*.png" -print0 2>/dev/null)
fi

# Scan for audio files
if [ -d "assets" ] || [ -d "audio" ] || [ -d "sounds" ]; then
    for dir in assets audio sounds; do
        [ ! -d "$dir" ] && continue
        while IFS= read -r -d '' audio_file; do
            check_audio_import "$audio_file"
            check_naming_convention "$audio_file"
        done < <(find "$dir" -type f \( -name "*.ogg" -o -name "*.wav" -o -name "*.mp3" \) -print0 2>/dev/null)
    done
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Asset Import Validation Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "Files checked: $CHECKED"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Errors: $ERRORS${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All asset imports validated successfully!${NC}"
fi

echo ""

# Exit with error if there are blocking errors
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Asset import validation failed with $ERRORS error(s)${NC}"
    echo -e "${YELLOW}💡 See docs/godot-import-research.md for import guidelines${NC}"
    exit 1
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Asset import validation passed with $WARNINGS warning(s)${NC}"
    echo -e "${YELLOW}💡 Consider fixing warnings for optimal performance${NC}"
fi

exit 0
