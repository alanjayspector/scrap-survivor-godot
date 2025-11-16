#!/bin/bash
## Audio Asset Automation Script - Week 14 Phase 1.1
##
## Automatically downloads, extracts, and organizes audio from Kenney Audio Packs
## Usage: bash .system/scripts/source-audio-assets.sh [--dry-run]
##
## Author: Week 14 Phase 1.1 - Audio System Implementation
## License: Script is MIT, Audio is CC0 (Kenney.nl)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIO_DIR="$PROJECT_ROOT/assets/audio"
TEMP_DIR="$PROJECT_ROOT/.temp/audio-download"

# Flags
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
fi

echo -e "${BLUE}🎵 Audio Asset Automation Script${NC}"
echo -e "${BLUE}===================================${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will be copied${NC}"
    echo ""
fi

# Create temp directory
echo "📂 Creating temp directory: $TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Kenney Audio Pack URLs (direct download links)
# Note: These are example URLs - Kenney.nl may require browser downloads
# Update URLs if needed or implement browser-based download prompt

PACKS=(
    "impact-sounds:https://kenney.nl/content/3-assets/45-impact-sounds/impactSounds.zip"
    "digital-audio:https://kenney.nl/content/3-assets/42-digital-audio/digitalAudio.zip"
    "sci-fi-sounds:https://kenney.nl/content/3-assets/16-sci-fi-sounds/scifiSounds.zip"
    "ui-audio:https://kenney.nl/content/3-assets/10-ui-audio/uiAudio.zip"
)

# Download function with fallback to manual download
download_pack() {
    local pack_name=$1
    local url=$2
    local zip_file="$TEMP_DIR/${pack_name}.zip"

    echo ""
    echo -e "${BLUE}📥 Downloading: $pack_name${NC}"
    echo "   URL: $url"

    # Try curl first
    if command -v curl &> /dev/null; then
        if curl -L -o "$zip_file" "$url" 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} Downloaded with curl"
            return 0
        fi
    fi

    # Try wget as fallback
    if command -v wget &> /dev/null; then
        if wget -O "$zip_file" "$url" 2>/dev/null; then
            echo -e "   ${GREEN}✓${NC} Downloaded with wget"
            return 0
        fi
    fi

    # Manual download fallback
    echo -e "   ${YELLOW}⚠️  Automatic download failed${NC}"
    echo -e "   ${YELLOW}Please download manually:${NC}"
    echo "   1. Visit: $url"
    echo "   2. Download ZIP file"
    echo "   3. Save to: $zip_file"
    echo ""
    read -p "   Press Enter when download is complete..."

    if [ ! -f "$zip_file" ]; then
        echo -e "   ${RED}✗${NC} File not found: $zip_file"
        return 1
    fi

    echo -e "   ${GREEN}✓${NC} Manual download confirmed"
    return 0
}

# Extract function
extract_pack() {
    local pack_name=$1
    local zip_file="$TEMP_DIR/${pack_name}.zip"
    local extract_dir="$TEMP_DIR/${pack_name}"

    echo ""
    echo -e "${BLUE}📦 Extracting: $pack_name${NC}"

    if [ ! -f "$zip_file" ]; then
        echo -e "   ${RED}✗${NC} ZIP file not found: $zip_file"
        return 1
    fi

    mkdir -p "$extract_dir"
    unzip -q "$zip_file" -d "$extract_dir"
    echo -e "   ${GREEN}✓${NC} Extracted to $extract_dir"
}

# Smart sound selection based on filename patterns
select_sound() {
    local search_dir=$1
    local patterns=$2
    local category=$3

    # Convert patterns string to array
    IFS='|' read -ra PATTERN_ARRAY <<< "$patterns"

    # Search for files matching patterns (case insensitive)
    for pattern in "${PATTERN_ARRAY[@]}"; do
        local found_file=$(find "$search_dir" -type f \( -iname "*${pattern}*.wav" -o -iname "*${pattern}*.ogg" \) | head -1)
        if [ -n "$found_file" ]; then
            echo "$found_file"
            return 0
        fi
    done

    # No match found
    echo -e "   ${YELLOW}⚠️  No match for patterns: $patterns${NC}" >&2
    return 1
}

# Copy sound file to destination
copy_sound() {
    local source=$1
    local dest=$2
    local description=$3

    if [ -z "$source" ]; then
        echo -e "   ${RED}✗${NC} $description - No source file"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "   ${BLUE}[DRY RUN]${NC} $description"
        echo -e "      Source: $(basename "$source")"
        echo -e "      Dest: $dest"
    else
        cp "$source" "$dest"
        echo -e "   ${GREEN}✓${NC} $description"
        echo -e "      Copied: $(basename "$source") → $(basename "$dest")"
    fi
}

# Download all packs
echo -e "${BLUE}📥 Step 1: Downloading Kenney Audio Packs${NC}"
echo "==========================================="

for pack in "${PACKS[@]}"; do
    IFS=':' read -r pack_name pack_url <<< "$pack"
    download_pack "$pack_name" "$pack_url" || {
        echo -e "${RED}Failed to download $pack_name. Exiting.${NC}"
        exit 1
    }
done

# Extract all packs
echo ""
echo -e "${BLUE}📦 Step 2: Extracting Audio Packs${NC}"
echo "=================================="

for pack in "${PACKS[@]}"; do
    IFS=':' read -r pack_name pack_url <<< "$pack"
    extract_pack "$pack_name" || {
        echo -e "${RED}Failed to extract $pack_name. Exiting.${NC}"
        exit 1
    }
done

# Select and copy sounds
echo ""
echo -e "${BLUE}🔫 Step 3: Selecting Weapon Sounds (10 files)${NC}"
echo "=============================================="

IMPACT_DIR="$TEMP_DIR/impact-sounds"
DIGITAL_DIR="$TEMP_DIR/digital-audio"
SCIFI_DIR="$TEMP_DIR/sci-fi-sounds"
UI_DIR="$TEMP_DIR/ui-audio"

# Weapon sounds
copy_sound "$(select_sound "$SCIFI_DIR" "laser|zap|plasma" "weapon")" \
    "$AUDIO_DIR/weapons/plasma_pistol.ogg" "Plasma Pistol"

copy_sound "$(select_sound "$IMPACT_DIR" "metal|sword|blade|swing" "weapon")" \
    "$AUDIO_DIR/weapons/rusty_blade.ogg" "Rusty Blade"

copy_sound "$(select_sound "$SCIFI_DIR" "electric|shock|lightning" "weapon")" \
    "$AUDIO_DIR/weapons/shock_rifle.ogg" "Shock Rifle"

copy_sound "$(select_sound "$IMPACT_DIR" "metal|sword|sharp" "weapon")" \
    "$AUDIO_DIR/weapons/steel_sword.ogg" "Steel Sword"

copy_sound "$(select_sound "$IMPACT_DIR" "explosion|boom|blast" "weapon")" \
    "$AUDIO_DIR/weapons/shotgun.ogg" "Shotgun"

copy_sound "$(select_sound "$IMPACT_DIR" "crack|snap|shot" "weapon")" \
    "$AUDIO_DIR/weapons/sniper_rifle.ogg" "Sniper Rifle"

copy_sound "$(select_sound "$SCIFI_DIR" "fire|flame|whoosh" "weapon")" \
    "$AUDIO_DIR/weapons/flamethrower.ogg" "Flamethrower"

copy_sound "$(select_sound "$SCIFI_DIR" "laser|beam" "weapon")" \
    "$AUDIO_DIR/weapons/laser_rifle.ogg" "Laser Rifle"

copy_sound "$(select_sound "$IMPACT_DIR" "rapid|machine|gun" "weapon")" \
    "$AUDIO_DIR/weapons/minigun.ogg" "Minigun"

copy_sound "$(select_sound "$IMPACT_DIR" "explosion|rocket|missile" "weapon")" \
    "$AUDIO_DIR/weapons/rocket_launcher.ogg" "Rocket Launcher"

# Enemy sounds
echo ""
echo -e "${BLUE}👾 Step 4: Selecting Enemy Sounds (8 files)${NC}"
echo "==========================================="

copy_sound "$(select_sound "$SCIFI_DIR" "spawn|teleport|appear" "enemy")" \
    "$AUDIO_DIR/enemies/spawn_1.ogg" "Enemy Spawn 1"

copy_sound "$(select_sound "$SCIFI_DIR" "mechanical|robot|drone" "enemy")" \
    "$AUDIO_DIR/enemies/spawn_2.ogg" "Enemy Spawn 2"

copy_sound "$(select_sound "$DIGITAL_DIR" "beep|ping|blip" "enemy")" \
    "$AUDIO_DIR/enemies/spawn_3.ogg" "Enemy Spawn 3"

copy_sound "$(select_sound "$IMPACT_DIR" "impact|hit|thud" "enemy")" \
    "$AUDIO_DIR/enemies/damage_1.ogg" "Enemy Damage 1"

copy_sound "$(select_sound "$IMPACT_DIR" "metal|clang|ding" "enemy")" \
    "$AUDIO_DIR/enemies/damage_2.ogg" "Enemy Damage 2"

copy_sound "$(select_sound "$IMPACT_DIR" "explosion|blast|boom" "enemy")" \
    "$AUDIO_DIR/enemies/death_1.ogg" "Enemy Death 1"

copy_sound "$(select_sound "$SCIFI_DIR" "power|down|fail" "enemy")" \
    "$AUDIO_DIR/enemies/death_2.ogg" "Enemy Death 2"

copy_sound "$(select_sound "$IMPACT_DIR" "crash|destroy|break" "enemy")" \
    "$AUDIO_DIR/enemies/death_3.ogg" "Enemy Death 3"

# Ambient sounds
echo ""
echo -e "${BLUE}🌍 Step 5: Selecting Ambient Sounds (3 files)${NC}"
echo "============================================="

copy_sound "$(select_sound "$DIGITAL_DIR" "alarm|alert|warning" "ambient")" \
    "$AUDIO_DIR/ambient/wave_start.ogg" "Wave Start"

copy_sound "$(select_sound "$UI_DIR" "success|complete|victory" "ambient")" \
    "$AUDIO_DIR/ambient/wave_complete.ogg" "Wave Complete"

copy_sound "$(select_sound "$DIGITAL_DIR" "heartbeat|pulse|beep" "ambient")" \
    "$AUDIO_DIR/ambient/low_hp_warning.ogg" "Low HP Warning"

# UI sounds
echo ""
echo -e "${BLUE}🖱️  Step 6: Selecting UI Sounds (3 files)${NC}"
echo "========================================"

copy_sound "$(select_sound "$UI_DIR" "click|tap|button" "ui")" \
    "$AUDIO_DIR/ui/button_click.ogg" "Button Click"

copy_sound "$(select_sound "$UI_DIR" "select|confirm|accept" "ui")" \
    "$AUDIO_DIR/ui/character_select.ogg" "Character Select"

copy_sound "$(select_sound "$UI_DIR" "error|deny|reject" "ui")" \
    "$AUDIO_DIR/ui/error.ogg" "Error"

# Cleanup
echo ""
echo -e "${BLUE}🧹 Step 7: Cleanup${NC}"
echo "=================="

if [ "$DRY_RUN" = false ]; then
    echo "Removing temp directory: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✓${NC} Cleanup complete"
else
    echo -e "${YELLOW}[DRY RUN] Would remove: $TEMP_DIR${NC}"
fi

# Verify
echo ""
echo -e "${BLUE}✅ Step 8: Verification${NC}"
echo "======================"

if [ "$DRY_RUN" = false ]; then
    echo ""
    bash "$PROJECT_ROOT/.system/validators/check-audio-assets.sh"
else
    echo -e "${YELLOW}[DRY RUN] Run without --dry-run to copy files and verify${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Audio sourcing complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open Godot project"
echo "2. Verify audio files imported correctly (FileSystem dock)"
echo "3. Continue to Phase 1.2: Implement weapon firing sounds"
