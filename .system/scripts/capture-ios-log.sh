#!/usr/bin/env bash
## Capture iOS Log - Automated log collection
##
## Purpose: Automatically capture iOS device/simulator logs to ios.log
## Usage:   bash .system/scripts/capture-ios-log.sh [device|simulator]
##
## Created: 2025-11-15 (Week 14 QA Infrastructure)

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_FILE="$PROJECT_ROOT/ios.log"

# Mode: device or simulator (default to simulator)
MODE="${1:-simulator}"

echo -e "${BLUE}ℹ${NC} iOS Log Capture Tool"
echo -e "${BLUE}ℹ${NC} Mode: $MODE"
echo -e "${BLUE}ℹ${NC} Output: ios.log"
echo ""

case "$MODE" in
    device)
        # Physical iOS device logging
        if ! command -v idevicesyslog &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} idevicesyslog not found"
            echo -e "${BLUE}ℹ${NC} Install with: brew install libimobiledevice"
            echo ""
            echo -e "${BLUE}ℹ${NC} Falling back to Console.app instructions:"
            echo "  1. Open Console.app on Mac"
            echo "  2. Connect iOS device via USB"
            echo "  3. Select your device in sidebar"
            echo "  4. Filter by 'scrap-survivor'"
            echo "  5. Run QA session"
            echo "  6. File → Export → Save As: ios.log"
            exit 1
        fi

        echo -e "${GREEN}✓${NC} Starting device log capture..."
        echo -e "${BLUE}ℹ${NC} Press Ctrl+C when done"
        echo ""

        # Capture device logs (filtered for game process)
        idevicesyslog | tee "$LOG_FILE"
        ;;

    simulator)
        # iOS Simulator logging
        echo -e "${GREEN}✓${NC} Starting simulator log capture..."
        echo -e "${BLUE}ℹ${NC} Make sure simulator is running"
        echo -e "${BLUE}ℹ${NC} Press Ctrl+C when done"
        echo ""

        # Capture simulator logs
        # Note: processImagePath filter requires knowing exact app path
        # For now, capture all logs (you can filter manually)
        xcrun simctl spawn booted log stream --level debug | tee "$LOG_FILE"
        ;;

    *)
        echo "Usage: $0 [device|simulator]"
        echo ""
        echo "Examples:"
        echo "  $0 simulator    # Capture from iOS Simulator (default)"
        echo "  $0 device       # Capture from physical iOS device"
        exit 1
        ;;
esac
