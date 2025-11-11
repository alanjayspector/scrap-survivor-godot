#!/bin/bash
# Remove Unused iOS Privacy Permissions
# Run this script AFTER exporting from Godot to iOS/Xcode
#
# Usage: ./scripts/ios/remove-unused-permissions.sh /path/to/exported/ios/project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  iOS Privacy Permissions Cleanup Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if path argument provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No path provided${NC}"
    echo ""
    echo "Usage:"
    echo "  $0 /path/to/exported/ios/project"
    echo ""
    echo "Example:"
    echo "  $0 ~/Desktop/scrap-survivor-ios"
    echo ""
    exit 1
fi

IOS_PROJECT_PATH="$1"

# Check if directory exists
if [ ! -d "$IOS_PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory not found: $IOS_PROJECT_PATH${NC}"
    exit 1
fi

# Find Info.plist file
PLIST_FILE=$(find "$IOS_PROJECT_PATH" -name "Info.plist" -type f | head -1)

if [ -z "$PLIST_FILE" ]; then
    echo -e "${RED}Error: No Info.plist file found in $IOS_PROJECT_PATH${NC}"
    echo ""
    echo "Make sure you've exported the project from Godot first."
    exit 1
fi

echo -e "Found Info.plist: ${GREEN}$PLIST_FILE${NC}"
echo ""

# Create backup
BACKUP_FILE="${PLIST_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$PLIST_FILE" "$BACKUP_FILE"
echo -e "✓ Backup created: ${YELLOW}$BACKUP_FILE${NC}"
echo ""

# Count keys before removal
echo "Checking for unused permission keys..."
echo ""

KEYS_REMOVED=0

# Function to check and remove a key
remove_key() {
    local key=$1
    local description=$2

    if /usr/libexec/PlistBuddy -c "Print :$key" "$PLIST_FILE" &> /dev/null; then
        echo -e "  ${YELLOW}✗ Found:${NC} $key ($description)"
        /usr/libexec/PlistBuddy -c "Delete :$key" "$PLIST_FILE" 2>/dev/null || true
        KEYS_REMOVED=$((KEYS_REMOVED + 1))
    else
        echo -e "  ${GREEN}✓ Not present:${NC} $key"
    fi
}

# Remove unused permission keys
echo "Removing unused permissions:"
echo ""

remove_key "NSCameraUsageDescription" "Camera access"
remove_key "NSMicrophoneUsageDescription" "Microphone access"
remove_key "NSPhotoLibraryUsageDescription" "Photo Library access"
remove_key "NSPhotoLibraryAddUsageDescription" "Photo Library add access"
remove_key "NSMotionUsageDescription" "Motion sensors (accelerometer/gyroscope)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $KEYS_REMOVED -gt 0 ]; then
    echo -e "${GREEN}✓ Success!${NC} Removed $KEYS_REMOVED unused permission key(s)"
    echo ""
    echo "Next steps:"
    echo "  1. Open the Xcode project: $IOS_PROJECT_PATH"
    echo "  2. Clean build folder: Product → Clean Build Folder (⇧⌘K)"
    echo "  3. Delete derived data (optional but recommended)"
    echo "  4. Archive and validate your app"
else
    echo -e "${GREEN}✓ All good!${NC} No unused permission keys found"
    echo ""
    echo "Your Info.plist is clean. You can proceed with archiving."
fi

echo ""
echo "Backup saved to:"
echo "  $BACKUP_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
