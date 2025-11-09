#!/bin/bash

#
# AUTO-SYNC ALL SYSTEM COMPONENTS
#
# Synchronizes validators, MCP servers, and docs from source code.
# Source of truth: Code → Validators → MCP → Docs
#
# Created: 2025-11-08
# Version: 1.0.0
#

set -e  # Exit on error

echo "🔄 Syncing system components..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#
# Function: Sync validators from code patterns
#
sync_validators() {
  echo "${YELLOW}📝 Syncing validators from code patterns...${NC}"

  # Run pattern extractor (Phase 0 - just logs, Phase 2 will actually generate)
  npx tsx .system/meta/run-sync-validators.ts

  if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Validators synced${NC}"
  else
    echo "${RED}❌ Validator sync failed${NC}"
    return 1
  fi

  echo ""
}

#
# Function: Sync MCP servers from validators
#
sync_mcp() {
  echo "${YELLOW}🔌 Syncing MCP servers...${NC}"

  # Phase 0: Just log, Phase 1 will actually sync
  echo "ℹ️  MCP sync will be implemented in Phase 1"
  echo "${GREEN}✅ MCP sync placeholder (Phase 1)${NC}"

  echo ""
}

#
# Function: Sync docs from code + validators
#
sync_docs() {
  echo "${YELLOW}📚 Syncing documentation...${NC}"

  # Phase 0: Just log, Phase 4 will actually sync
  echo "ℹ️  Doc sync will be implemented in Phase 4"
  echo "${GREEN}✅ Doc sync placeholder (Phase 4)${NC}"

  echo ""
}

#
# Function: Validate system health
#
validate_system() {
  echo "${YELLOW}🏥 Validating system health...${NC}"

  npx tsx .system/meta/run-health-check.ts

  if [ $? -eq 0 ]; then
    echo "${GREEN}✅ System health check passed${NC}"
  else
    echo "${RED}❌ System health check failed${NC}"
    return 1
  fi

  echo ""
}

#
# Main sync sequence
#
main() {
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║           SYSTEM COMPONENT SYNCHRONIZATION               ║"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""

  # Sync in order (source of truth hierarchy)
  sync_validators
  sync_mcp
  sync_docs

  # Validate everything is consistent
  validate_system

  if [ $? -eq 0 ]; then
    echo "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo "${GREEN}║                 ✅ SYNC COMPLETED                        ║${NC}"
    echo "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    exit 0
  else
    echo "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo "${RED}║                 ❌ SYNC FAILED                           ║${NC}"
    echo "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    exit 1
  fi
}

# Run main function
main
