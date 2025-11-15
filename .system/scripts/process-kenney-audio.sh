#!/bin/bash
## Kenney Audio Processor - Week 14 Phase 1.1
##
## Processes Kenney Audio Packs from ~/Downloads and organizes them for the project
## Usage: bash .system/scripts/process-kenney-audio.sh [--dry-run]
##
## Prerequisites:
## 1. Download these ZIP files from Kenney.nl to ~/Downloads:
##    - kenney_impact-sounds.zip (https://kenney.nl/assets/impact-sounds)
##    - kenney_digital-audio.zip (https://kenney.nl/assets/digital-audio)
##    - kenney_sci-fi-sounds.zip (https://kenney.nl/assets/sci-fi-sounds)
##    - kenney_ui-audio.zip (https://kenney.nl/assets/ui-audio)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_DIR="$PROJECT_ROOT/assets/audio"
DOWNLOADS_DIR="$HOME/Downloads"
TEMP_DIR="$PROJECT_ROOT/.temp/kenney-audio"

# Flags
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
fi

echo -e "${BLUE}🎵 Kenney Audio Processor${NC}"
echo -e "${BLUE}=========================${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will be copied${NC}"
    echo ""
fi

# Check for required ZIP files
echo -e "${BLUE}Step 1: Checking for Kenney Audio Packs in ~/Downloads${NC}"
echo "========================================================"
echo ""

REQUIRED_ZIPS=(
    "kenney_impact-sounds.zip:Impact Sounds:https://kenney.nl/assets/impact-sounds"
    "kenney_digital-audio.zip:Digital Audio:https://kenney.nl/assets/digital-audio"
    "kenney_sci-fi-sounds.zip:Sci-Fi Sounds:https://kenney.nl/assets/sci-fi-sounds"
    "kenney_ui-audio.zip:UI Audio:https://kenney.nl/assets/ui-audio"
)

MISSING_ZIPS=()

for zip_info in "${REQUIRED_ZIPS[@]}"; do
    IFS=':' read -r zip_name display_name url <<< "$zip_info"
    zip_path="$DOWNLOADS_DIR/$zip_name"

    if [ -f "$zip_path" ]; then
        echo -e "${GREEN}✓${NC} Found: $zip_name"
    else
        echo -e "${RED}✗${NC} Missing: $zip_name"
        MISSING_ZIPS+=("$display_name:$url")
    fi
done

if [ ${#MISSING_ZIPS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Missing ${#MISSING_ZIPS[@]} required audio packs${NC}"
    echo ""
    echo "Please download these packs to ~/Downloads:"
    echo ""
    for missing in "${MISSING_ZIPS[@]}"; do
        IFS=':' read -r name url <<< "$missing"
        echo -e "  ${YELLOW}→${NC} $name"
        echo "     $url"
        echo "     Click 'Download' button → Save to ~/Downloads"
        echo ""
    done
    exit 1
fi

echo ""
echo -e "${GREEN}✅ All required packs found in ~/Downloads${NC}"

# Extract packs
echo ""
echo -e "${BLUE}Step 2: Extracting Audio Packs${NC}"
echo "==============================="
echo ""

mkdir -p "$TEMP_DIR"

extract_pack() {
    local zip_name=$1
    local display_name=$2
    local zip_path="$DOWNLOADS_DIR/$zip_name"
    local extract_dir="$TEMP_DIR/$(basename "$zip_name" .zip)"

    echo -e "${BLUE}📦${NC} Extracting $display_name..."

    if [ -d "$extract_dir" ]; then
        rm -rf "$extract_dir"
    fi

    mkdir -p "$extract_dir"
    unzip -q "$zip_path" -d "$extract_dir"
    echo -e "   ${GREEN}✓${NC} Extracted to $extract_dir"
}

extract_pack "kenney_impact-sounds.zip" "Impact Sounds"
extract_pack "kenney_digital-audio.zip" "Digital Audio"
extract_pack "kenney_sci-fi-sounds.zip" "Sci-Fi Sounds"
extract_pack "kenney_ui-audio.zip" "UI Audio"

# Helper function to find and copy audio
find_and_copy() {
    local search_dirs=$1
    local patterns=$2
    local dest_file=$3
    local description=$4

    # Split patterns by |
    IFS='|' read -ra PATTERN_ARRAY <<< "$patterns"

    # Search in each directory
    IFS=':' read -ra DIR_ARRAY <<< "$search_dirs"

    local found_file=""
    for dir in "${DIR_ARRAY[@]}"; do
        for pattern in "${PATTERN_ARRAY[@]}"; do
            # Find first matching file (case insensitive)
            found_file=$(find "$dir" -type f \( -iname "*${pattern}*.wav" -o -iname "*${pattern}*.ogg" \) 2>/dev/null | head -1)

            if [ -n "$found_file" ]; then
                break 2
            fi
        done
    done

    if [ -z "$found_file" ]; then
        echo -e "   ${YELLOW}⚠️${NC}  $description - No match for: $patterns"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "   ${BLUE}[DRY]${NC} $description"
        echo -e "         $(basename "$found_file") → $(basename "$dest_file")"
    else
        cp "$found_file" "$dest_file"
        local size_kb=$(($(stat -f%z "$dest_file" 2>/dev/null || stat -c%s "$dest_file" 2>/dev/null) / 1024))
        echo -e "   ${GREEN}✓${NC} $description (${size_kb} KB)"
        echo -e "      $(basename "$found_file")"
    fi
}

# Set up search directories (Kenney extracts to directory matching ZIP name without .zip)
IMPACT_DIR="$TEMP_DIR/kenney_impact-sounds"
DIGITAL_DIR="$TEMP_DIR/kenney_digital-audio"
SCIFI_DIR="$TEMP_DIR/kenney_sci-fi-sounds"
UI_DIR="$TEMP_DIR/kenney_ui-audio"

# Select and copy weapons
echo ""
echo -e "${BLUE}Step 3: Selecting Weapon Sounds (10 files)${NC}"
echo "==========================================="
echo ""

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "laser1|laserSmall|zap" \
    "$AUDIO_DIR/weapons/plasma_pistol.wav" "Plasma Pistol"

find_and_copy "$IMPACT_DIR" "impactMetal_heavy_000|impactMetal_medium_000" \
    "$AUDIO_DIR/weapons/rusty_blade.wav" "Rusty Blade"

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "zapThreeToneDown|zapTwoTone2" \
    "$AUDIO_DIR/weapons/shock_rifle.wav" "Shock Rifle"

find_and_copy "$IMPACT_DIR" "impactMetal_light_000|impactMetal_medium_001" \
    "$AUDIO_DIR/weapons/steel_sword.wav" "Steel Sword"

find_and_copy "$IMPACT_DIR:$SCIFI_DIR" "impactPlate_heavy_004|explosionCrunch_000" \
    "$AUDIO_DIR/weapons/shotgun.wav" "Shotgun"

find_and_copy "$IMPACT_DIR" "impactMetal_light_004|impactPlate_light_004" \
    "$AUDIO_DIR/weapons/sniper_rifle.wav" "Sniper Rifle"

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "forceField_000|lowFrequency" \
    "$AUDIO_DIR/weapons/flamethrower.wav" "Flamethrower"

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "laserLarge_000|laser2" \
    "$AUDIO_DIR/weapons/laser_rifle.wav" "Laser Rifle"

find_and_copy "$IMPACT_DIR:$DIGITAL_DIR" "impactPlate_light_000|zapThreeToneUp" \
    "$AUDIO_DIR/weapons/minigun.wav" "Minigun"

find_and_copy "$SCIFI_DIR:$IMPACT_DIR" "explosionCrunch_000|impactPlank_heavy_000" \
    "$AUDIO_DIR/weapons/rocket_launcher.wav" "Rocket Launcher"

# Select and copy enemies
echo ""
echo -e "${BLUE}Step 4: Selecting Enemy Sounds (8 files)${NC}"
echo "========================================="
echo ""

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "zapThreeToneDown|powerUp" \
    "$AUDIO_DIR/enemies/spawn_1.wav" "Enemy Spawn 1"

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "threeTone1|twoTone1" \
    "$AUDIO_DIR/enemies/spawn_2.wav" "Enemy Spawn 2"

find_and_copy "$DIGITAL_DIR" "phaseJump1|pepSound1" \
    "$AUDIO_DIR/enemies/spawn_3.wav" "Enemy Spawn 3"

find_and_copy "$IMPACT_DIR" "impactSoft_medium_000|impactWood_light_000" \
    "$AUDIO_DIR/enemies/damage_1.wav" "Enemy Damage 1"

find_and_copy "$IMPACT_DIR" "impactMetal_light_001|impactPlate_light_000" \
    "$AUDIO_DIR/enemies/damage_2.wav" "Enemy Damage 2"

find_and_copy "$SCIFI_DIR:$IMPACT_DIR" "explosionCrunch_001|impactPlate_heavy_000" \
    "$AUDIO_DIR/enemies/death_1.wav" "Enemy Death 1"

find_and_copy "$SCIFI_DIR:$DIGITAL_DIR" "lowDown|powerDown" \
    "$AUDIO_DIR/enemies/death_2.wav" "Enemy Death 2"

find_and_copy "$IMPACT_DIR" "impactPlank_heavy_000|impactGlass_heavy_000" \
    "$AUDIO_DIR/enemies/death_3.wav" "Enemy Death 3"

# Select and copy ambient
echo ""
echo -e "${BLUE}Step 5: Selecting Ambient Sounds (3 files)${NC}"
echo "==========================================="
echo ""

find_and_copy "$DIGITAL_DIR:$SCIFI_DIR" "alarm|forceField_000" \
    "$AUDIO_DIR/ambient/wave_start.wav" "Wave Start"

find_and_copy "$UI_DIR:$DIGITAL_DIR" "confirmation|powerUp" \
    "$AUDIO_DIR/ambient/wave_complete.wav" "Wave Complete"

find_and_copy "$DIGITAL_DIR" "lowFrequency_explosion|tone" \
    "$AUDIO_DIR/ambient/low_hp_warning.wav" "Low HP Warning"

# Select and copy UI
echo ""
echo -e "${BLUE}Step 6: Selecting UI Sounds (3 files)${NC}"
echo "======================================"
echo ""

find_and_copy "$UI_DIR:$DIGITAL_DIR" "click1|tick" \
    "$AUDIO_DIR/ui/button_click.wav" "Button Click"

find_and_copy "$UI_DIR:$DIGITAL_DIR" "switch1|powerUp1" \
    "$AUDIO_DIR/ui/character_select.wav" "Character Select"

find_and_copy "$UI_DIR:$DIGITAL_DIR" "switch2|tone1" \
    "$AUDIO_DIR/ui/error.wav" "Error"

# Cleanup
echo ""
echo -e "${BLUE}Step 7: Cleanup${NC}"
echo "==============="
echo ""

if [ "$DRY_RUN" = false ]; then
    echo "Removing temp directory: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✓${NC} Cleanup complete"
else
    echo -e "${YELLOW}[DRY RUN] Would remove: $TEMP_DIR${NC}"
fi

# Verification
echo ""
echo -e "${BLUE}Step 8: Verification${NC}"
echo "===================="
echo ""

if [ "$DRY_RUN" = false ]; then
    bash "$PROJECT_ROOT/.system/validators/check-audio-assets.sh"
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Audio sourcing complete!${NC}"
        echo ""
        echo "Next steps:"
        echo "1. Open Godot project"
        echo "2. FileSystem dock will auto-import audio files"
        echo "3. Continue to Phase 1.2: Implement weapon firing sounds"
    else
        echo ""
        echo -e "${YELLOW}⚠️  Some audio files may be missing or need optimization${NC}"
    fi
else
    echo -e "${YELLOW}[DRY RUN] Run without --dry-run to verify${NC}"
fi
