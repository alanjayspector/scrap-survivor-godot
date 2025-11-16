#!/usr/bin/env bash
## Archive iOS Log - QA Infrastructure Tool
##
## Purpose: Systematically archive ios.log files with commit hash and timestamp
## Usage:   bash .system/scripts/archive-ios-log.sh
## Output:  qa/logs/ios-{COMMIT}-{TIMESTAMP}.log
##
## Created: 2025-11-15 (Week 14 QA Infrastructure)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_SOURCE="$PROJECT_ROOT/ios.log"
LOG_ARCHIVE_DIR="$PROJECT_ROOT/qa/logs"
INDEX_FILE="$LOG_ARCHIVE_DIR/INDEX.md"

# Functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if ios.log exists
if [ ! -f "$LOG_SOURCE" ]; then
    log_error "ios.log not found at: $LOG_SOURCE"
    log_info "Make sure you've run the game on iOS and captured logs first"
    exit 1
fi

# Get commit hash (short form)
cd "$PROJECT_ROOT"
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
log_info "Current commit: $COMMIT_HASH"

# Get timestamp
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
log_info "Timestamp: $TIMESTAMP"

# Create archive directory if it doesn't exist
mkdir -p "$LOG_ARCHIVE_DIR"
log_success "Archive directory ready: qa/logs/"

# Generate archive filename
ARCHIVE_FILENAME="ios-${COMMIT_HASH}-${TIMESTAMP}.log"
ARCHIVE_PATH="$LOG_ARCHIVE_DIR/$ARCHIVE_FILENAME"

# Copy log file to archive
cp "$LOG_SOURCE" "$ARCHIVE_PATH"
log_success "Archived: $ARCHIVE_FILENAME"

# Get file size
FILE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)

# Get session description from git commit message
COMMIT_MESSAGE=$(git log -1 --pretty=%B 2>/dev/null | head -1 || echo "No commit message")

# Update or create INDEX.md
if [ ! -f "$INDEX_FILE" ]; then
    # Create new index
    cat > "$INDEX_FILE" << 'EOF'
# iOS QA Log Archive

This directory contains archived ios.log files from QA testing sessions.

## Archive Format

`ios-{COMMIT_HASH}-{TIMESTAMP}.log`

- **COMMIT_HASH**: Short git commit hash (7 characters)
- **TIMESTAMP**: YYYYMMDD-HHMMSS format

## Archive Index

| Date | Time | Commit | Session | Size | Log File |
|------|------|--------|---------|------|----------|
EOF
    log_success "Created new INDEX.md"
fi

# Add entry to index (insert after header)
DATE_ENTRY=$(date +"%Y-%m-%d")
TIME_ENTRY=$(date +"%H:%M:%S")
SESSION_DESC="${COMMIT_MESSAGE:0:40}"  # Truncate to 40 chars

# Create new entry
NEW_ENTRY="| $DATE_ENTRY | $TIME_ENTRY | [$COMMIT_HASH](../../commit/$COMMIT_HASH) | $SESSION_DESC | $FILE_SIZE | [$ARCHIVE_FILENAME]($ARCHIVE_FILENAME) |"

# Insert entry after table header (line 11)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    sed -i '' "11a\\
$NEW_ENTRY
" "$INDEX_FILE"
else
    # Linux sed
    sed -i "11a $NEW_ENTRY" "$INDEX_FILE"
fi

log_success "Updated INDEX.md"

# Summary
echo ""
log_info "═══════════════════════════════════════"
log_success "Log archived successfully!"
log_info "═══════════════════════════════════════"
echo ""
echo -e "  ${BLUE}Archive:${NC} qa/logs/$ARCHIVE_FILENAME"
echo -e "  ${BLUE}Size:${NC}    $FILE_SIZE"
echo -e "  ${BLUE}Commit:${NC}  $COMMIT_HASH"
echo -e "  ${BLUE}Session:${NC} $SESSION_DESC"
echo ""
log_info "View index: cat qa/logs/INDEX.md"
log_info "Original ios.log preserved at: $LOG_SOURCE"
echo ""

# Optional: Show tail of archived log
log_info "Last 10 lines of archived log:"
echo "─────────────────────────────────────────"
tail -10 "$ARCHIVE_PATH"
echo "─────────────────────────────────────────"
echo ""

log_success "Done! Log archive ready for analysis."
