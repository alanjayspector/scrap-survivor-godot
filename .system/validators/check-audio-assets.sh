#!/bin/bash
## Audio Asset Verification Script - Week 14 Phase 1.1
##
## Validates that all required audio files are present and meet quality criteria
## Usage: bash .system/validators/check-audio-assets.sh

set -e

echo "🔊 Audio Asset Verification - Week 14 Phase 1.1"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_FILES=0
FOUND_FILES=0
MISSING_FILES=0
SIZE_WARNINGS=0

# Base directory
AUDIO_DIR="assets/audio"

# Check if audio directory exists
if [ ! -d "$AUDIO_DIR" ]; then
    echo -e "${RED}❌ Error: $AUDIO_DIR directory not found!${NC}"
    exit 1
fi

echo "📂 Checking directory: $AUDIO_DIR"
echo ""

# Function to check file existence and size
check_audio_file() {
    local file_path=$1
    local max_size_kb=$2
    local category=$3

    TOTAL_FILES=$((TOTAL_FILES + 1))

    if [ -f "$file_path" ]; then
        FOUND_FILES=$((FOUND_FILES + 1))

        # Get file size in KB
        local size_bytes=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
        local size_kb=$((size_bytes / 1024))

        # Check size
        if [ $size_kb -gt $max_size_kb ]; then
            echo -e "  ${YELLOW}⚠️  $file_path (${size_kb} KB > ${max_size_kb} KB target)${NC}"
            SIZE_WARNINGS=$((SIZE_WARNINGS + 1))
        else
            echo -e "  ${GREEN}✓${NC} $file_path (${size_kb} KB)"
        fi
    else
        echo -e "  ${RED}✗${NC} $file_path (MISSING)"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
}

# Weapon sounds (10 files, max 200 KB each)
echo "🔫 WEAPONS (10 files, target < 200 KB each):"
check_audio_file "$AUDIO_DIR/weapons/plasma_pistol.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/rusty_blade.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/shock_rifle.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/steel_sword.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/shotgun.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/sniper_rifle.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/flamethrower.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/laser_rifle.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/minigun.ogg" 200 "weapon"
check_audio_file "$AUDIO_DIR/weapons/rocket_launcher.ogg" 200 "weapon"
echo ""

# Enemy sounds (8 files, max 100 KB each)
echo "👾 ENEMIES (8 files, target < 100 KB each):"
check_audio_file "$AUDIO_DIR/enemies/spawn_1.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/spawn_2.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/spawn_3.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/damage_1.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/damage_2.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/death_1.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/death_2.ogg" 100 "enemy"
check_audio_file "$AUDIO_DIR/enemies/death_3.ogg" 100 "enemy"
echo ""

# Ambient sounds (3 files, max 500 KB each)
echo "🌍 AMBIENT (3 files, target < 500 KB each):"
check_audio_file "$AUDIO_DIR/ambient/wave_start.ogg" 500 "ambient"
check_audio_file "$AUDIO_DIR/ambient/wave_complete.ogg" 500 "ambient"
check_audio_file "$AUDIO_DIR/ambient/low_hp_warning.ogg" 500 "ambient"
echo ""

# UI sounds (3 files, max 50 KB each)
echo "🖱️  UI (3 files, target < 50 KB each):"
check_audio_file "$AUDIO_DIR/ui/button_click.ogg" 50 "ui"
check_audio_file "$AUDIO_DIR/ui/character_select.ogg" 50 "ui"
check_audio_file "$AUDIO_DIR/ui/error.ogg" 50 "ui"
echo ""

# Summary
echo "================================================"
echo "📊 SUMMARY:"
echo "  Total files required: $TOTAL_FILES"
echo -e "  Files found: ${GREEN}$FOUND_FILES${NC}"

if [ $MISSING_FILES -gt 0 ]; then
    echo -e "  Missing files: ${RED}$MISSING_FILES${NC}"
else
    echo -e "  Missing files: ${GREEN}0${NC}"
fi

if [ $SIZE_WARNINGS -gt 0 ]; then
    echo -e "  Size warnings: ${YELLOW}$SIZE_WARNINGS${NC}"
else
    echo -e "  Size warnings: ${GREEN}0${NC}"
fi

# Calculate total size
if [ $FOUND_FILES -gt 0 ]; then
    TOTAL_SIZE_KB=$(find "$AUDIO_DIR" -name "*.ogg" -o -name "*.ogg" | xargs stat -f%z 2>/dev/null | awk '{sum+=$1} END {print int(sum/1024)}')
    TOTAL_SIZE_MB=$(echo "scale=2; $TOTAL_SIZE_KB / 1024" | bc)
    echo "  Total size: ${TOTAL_SIZE_KB} KB (${TOTAL_SIZE_MB} MB)"

    # Check against 10 MB mobile limit
    if [ $TOTAL_SIZE_KB -gt 10240 ]; then
        echo -e "  ${RED}⚠️  WARNING: Total size exceeds 10 MB mobile limit!${NC}"
    else
        echo -e "  ${GREEN}✓${NC} Total size within 10 MB mobile limit"
    fi
fi

echo ""

# Exit status
if [ $MISSING_FILES -eq 0 ]; then
    echo -e "${GREEN}✅ All audio files present!${NC}"

    if [ $SIZE_WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Some files exceed size targets. Consider optimizing.${NC}"
        exit 0
    else
        echo -e "${GREEN}✅ All files within size targets!${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ Missing $MISSING_FILES audio files.${NC}"
    echo ""
    echo "📖 See assets/audio/AUDIO_SOURCING_GUIDE.md for sourcing instructions."
    exit 1
fi
