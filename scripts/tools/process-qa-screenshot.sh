#!/bin/bash
# =============================================================================
# QA Screenshot Processor for Scrap Survivor
# =============================================================================
# Processes QA screenshots for Claude review
# Creates optimized preview files that Claude can safely read
#
# Usage: 
#   Single file:  ./process-qa-screenshot.sh <input-file>
#   Watch mode:   ./process-qa-screenshot.sh --watch
#   Batch:        ./process-qa-screenshot.sh --batch
# =============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QA_DIR="$PROJECT_ROOT/qa"
PREVIEW_DIR="$QA_DIR/previews"
ARCHIVE_DIR="$QA_DIR/archive"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# Screenshot Processing
# =============================================================================

process_screenshot() {
    local input="$1"
    local filename=$(basename "$input")
    local name_without_ext="${filename%.*}"
    local preview="$PREVIEW_DIR/${name_without_ext}-preview.jpg"
    
    # Skip if not an image
    if [[ ! "$input" =~ \.(png|jpg|jpeg|PNG|JPG|JPEG)$ ]]; then
        return
    fi
    
    # Skip preview files
    if [[ "$input" =~ -preview\. ]] || [[ "$input" =~ previews/ ]]; then
        return
    fi
    
    # Skip if file is too small (probably incomplete)
    local size=$(stat -f%z "$input" 2>/dev/null || stat -c%s "$input")
    if [ "$size" -lt 10000 ]; then
        return
    fi
    
    log_info "Processing: $filename"
    
    # Get original dimensions
    local width=$(sips -g pixelWidth "$input" | tail -1 | awk '{print $2}')
    local height=$(sips -g pixelHeight "$input" | tail -1 | awk '{print $2}')
    log_info "  → Original: ${width}x${height}"
    
    # Create preview (max 1200px wide, JPEG 85%)
    sips -s format jpeg \
         -s formatOptions 85 \
         -Z 1200 \
         "$input" \
         --out "$preview" > /dev/null 2>&1
    
    local preview_size=$(stat -f%z "$preview" 2>/dev/null || stat -c%s "$preview")
    local preview_kb=$((preview_size / 1024))
    
    log_success "Created: previews/${name_without_ext}-preview.jpg (${preview_kb}KB)"
    
    # Add timestamp to filename and move to archive
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local archive_name="${name_without_ext}_${timestamp}.${filename##*.}"
    mv "$input" "$ARCHIVE_DIR/$archive_name"
    log_info "  → Archived: archive/$archive_name"
}

# =============================================================================
# Batch Mode - Process all screenshots in qa/
# =============================================================================

batch_mode() {
    log_info "=========================================="
    log_info "QA Screenshot Batch Processor"
    log_info "=========================================="
    log_info "Processing all screenshots in: $QA_DIR"
    echo ""
    
    local count=0
    for file in "$QA_DIR"/*.{png,jpg,jpeg,PNG,JPG,JPEG} 2>/dev/null; do
        if [ -f "$file" ]; then
            process_screenshot "$file"
            ((count++))
        fi
    done
    
    if [ $count -eq 0 ]; then
        log_warn "No screenshots found in $QA_DIR"
    else
        log_success "Processed $count screenshot(s)"
    fi
}

# =============================================================================
# Watch Mode
# =============================================================================

watch_mode() {
    log_info "=========================================="
    log_info "QA Screenshot Watcher - Scrap Survivor"
    log_info "=========================================="
    log_info "Watching: $QA_DIR"
    log_info "Drop screenshots to auto-process!"
    log_info ""
    log_info "Output:"
    log_info "  Previews: qa/previews/ (for Claude review)"
    log_info "  Archives: qa/archive/ (originals with timestamp)"
    log_info ""
    log_info "Press Ctrl+C to stop"
    log_info "=========================================="
    
    # Check if fswatch is installed
    if ! command -v fswatch &> /dev/null; then
        log_error "fswatch not installed!"
        log_info "Install with: brew install fswatch"
        exit 1
    fi
    
    # Watch for new files (only in root qa/, not subdirs)
    fswatch -0 --event Created --event Updated -e "previews/" -e "archive/" "$QA_DIR" | while IFS= read -r -d '' file; do
        # Small delay to ensure file is fully written
        sleep 0.5
        process_screenshot "$file"
    done
}

# =============================================================================
# Entry Point
# =============================================================================

# Ensure directories exist
mkdir -p "$QA_DIR" "$PREVIEW_DIR" "$ARCHIVE_DIR"

# Create .gitkeep files
touch "$PREVIEW_DIR/.gitkeep" "$ARCHIVE_DIR/.gitkeep"

if [ "$1" == "--watch" ]; then
    watch_mode
elif [ "$1" == "--batch" ]; then
    batch_mode
elif [ -n "$1" ] && [ -f "$1" ]; then
    process_screenshot "$1"
else
    echo "QA Screenshot Processor"
    echo ""
    echo "Usage:"
    echo "  $0 <screenshot>    Process single screenshot"
    echo "  $0 --batch         Process all screenshots in qa/"
    echo "  $0 --watch         Watch qa/ for new screenshots"
    echo ""
    echo "Directory structure:"
    echo "  qa/                Drop screenshots here"
    echo "  qa/previews/       Claude-safe preview files"
    echo "  qa/archive/        Timestamped originals"
fi
