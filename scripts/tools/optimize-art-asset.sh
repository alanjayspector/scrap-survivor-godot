#!/bin/bash
# =============================================================================
# Art Asset Optimizer for Scrap Survivor
# =============================================================================
# Automatically processes images dropped into art-docs/ directory
# Creates game-ready versions in appropriate asset folders
#
# Usage: 
#   Single file:  ./optimize-art-asset.sh <input-file> [output-type]
#   Watch mode:   ./optimize-art-asset.sh --watch
#
# Output types: background, icon, sprite (default: background)
# =============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ART_DOCS="$PROJECT_ROOT/art-docs"
BACKGROUNDS_DIR="$PROJECT_ROOT/assets/ui/backgrounds"
ICONS_DIR="$PROJECT_ROOT/assets/ui/icons"
SPRITES_DIR="$PROJECT_ROOT/assets/sprites"
PROCESSED_DIR="$ART_DOCS/processed"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# Asset Processing Functions
# =============================================================================

process_background() {
    local input="$1"
    local filename=$(basename "$input")
    local name_without_ext="${filename%.*}"
    local output="$BACKGROUNDS_DIR/${name_without_ext}.jpg"
    
    log_info "Processing background: $filename"
    log_info "  → Target: 2048x2048, JPEG 85% quality"
    
    # Get original dimensions
    local width=$(sips -g pixelWidth "$input" | tail -1 | awk '{print $2}')
    local height=$(sips -g pixelHeight "$input" | tail -1 | awk '{print $2}')
    log_info "  → Original: ${width}x${height}"
    
    # Convert to 2048x2048 JPEG
    sips -s format jpeg \
         -s formatOptions 85 \
         --resampleWidth 2048 \
         --resampleHeight 2048 \
         "$input" \
         --out "$output" > /dev/null 2>&1
    
    local output_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output")
    local output_kb=$((output_size / 1024))
    
    log_success "Created: $output (${output_kb}KB)"
}

process_icon() {
    local input="$1"
    local filename=$(basename "$input")
    local name_without_ext="${filename%.*}"
    local output="$ICONS_DIR/${name_without_ext}.png"
    
    log_info "Processing icon: $filename"
    log_info "  → Target: 128x128, PNG"
    
    sips -s format png \
         --resampleWidth 128 \
         --resampleHeight 128 \
         "$input" \
         --out "$output" > /dev/null 2>&1
    
    log_success "Created: $output"
}

process_sprite() {
    local input="$1"
    local filename=$(basename "$input")
    local name_without_ext="${filename%.*}"
    local output="$SPRITES_DIR/${name_without_ext}.png"
    
    log_info "Processing sprite: $filename"
    log_info "  → Target: PNG (preserving dimensions)"
    
    sips -s format png "$input" --out "$output" > /dev/null 2>&1
    
    log_success "Created: $output"
}

create_preview() {
    local input="$1"
    local filename=$(basename "$input")
    local name_without_ext="${filename%.*}"
    local preview="$ART_DOCS/${name_without_ext}-preview.jpg"
    
    # Create 1024px wide preview for Claude review
    sips -s format jpeg \
         -s formatOptions 80 \
         -Z 1024 \
         "$input" \
         --out "$preview" > /dev/null 2>&1
    
    log_info "  → Preview: ${name_without_ext}-preview.jpg"
}

# =============================================================================
# Main Processing Logic
# =============================================================================

process_file() {
    local input="$1"
    local output_type="${2:-background}"
    
    # Skip if not an image
    if [[ ! "$input" =~ \.(png|jpg|jpeg|PNG|JPG|JPEG)$ ]]; then
        return
    fi
    
    # Skip preview files and processed files
    if [[ "$input" =~ -preview\. ]] || [[ "$input" =~ processed/ ]]; then
        return
    fi
    
    # Skip if file is too small (probably a temp file)
    local size=$(stat -f%z "$input" 2>/dev/null || stat -c%s "$input")
    if [ "$size" -lt 10000 ]; then
        return
    fi
    
    echo ""
    log_info "=========================================="
    log_info "Processing: $(basename "$input")"
    log_info "Type: $output_type"
    log_info "=========================================="
    
    # Always create a preview for Claude
    create_preview "$input"
    
    # Process based on type
    case "$output_type" in
        background|bg)
            process_background "$input"
            ;;
        icon)
            process_icon "$input"
            ;;
        sprite)
            process_sprite "$input"
            ;;
        *)
            log_error "Unknown output type: $output_type"
            log_info "Valid types: background, icon, sprite"
            return 1
            ;;
    esac
    
    # Move original to processed folder
    mkdir -p "$PROCESSED_DIR"
    mv "$input" "$PROCESSED_DIR/"
    log_info "  → Original moved to: processed/$(basename "$input")"
}

# =============================================================================
# Watch Mode
# =============================================================================

watch_mode() {
    log_info "=========================================="
    log_info "Art Asset Watcher - Scrap Survivor"
    log_info "=========================================="
    log_info "Watching: $ART_DOCS"
    log_info "Drop images to auto-process!"
    log_info ""
    log_info "Naming convention for auto-detection:"
    log_info "  *_bg.png, *_background.png → Background (2048x2048)"
    log_info "  *_icon.png                 → Icon (128x128)"
    log_info "  *_sprite.png               → Sprite (original size)"
    log_info "  (other)                    → Background (default)"
    log_info ""
    log_info "Press Ctrl+C to stop"
    log_info "=========================================="
    
    # Check if fswatch is installed
    if ! command -v fswatch &> /dev/null; then
        log_error "fswatch not installed!"
        log_info "Install with: brew install fswatch"
        exit 1
    fi
    
    # Watch for new files
    fswatch -0 --event Created --event Updated "$ART_DOCS" | while IFS= read -r -d '' file; do
        # Determine type from filename
        local type="background"
        if [[ "$file" =~ _icon\. ]]; then
            type="icon"
        elif [[ "$file" =~ _sprite\. ]]; then
            type="sprite"
        fi
        
        # Small delay to ensure file is fully written
        sleep 1
        
        process_file "$file" "$type"
    done
}

# =============================================================================
# Entry Point
# =============================================================================

# Ensure directories exist
mkdir -p "$BACKGROUNDS_DIR" "$ICONS_DIR" "$SPRITES_DIR" "$PROCESSED_DIR"

if [ "$1" == "--watch" ]; then
    watch_mode
elif [ -n "$1" ]; then
    process_file "$1" "${2:-background}"
else
    echo "Usage:"
    echo "  $0 <input-file> [type]    Process single file"
    echo "  $0 --watch                Watch art-docs/ for new files"
    echo ""
    echo "Types: background (default), icon, sprite"
fi
