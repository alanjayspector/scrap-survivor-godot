#!/bin/bash
# GDScript Pattern Validator
# Enforces Godot-specific patterns and best practices

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Validating GDScript patterns..."
echo ""

ERRORS=0

# ============================================================================
# PATTERN 1: Autoload Services (Singletons)
# ============================================================================

echo "📦 Checking autoload services..."

AUTOLOAD_FILES=$(find scripts/autoload -name "*.gd" 2>/dev/null || true)

if [ -n "$AUTOLOAD_FILES" ]; then
  for file in $AUTOLOAD_FILES; do
    # Check for extends Node
    if ! grep -q "extends Node" "$file"; then
      echo -e "${RED}❌ Autoload must extend Node: $file${NC}"
      echo "   Add: extends Node"
      ((ERRORS++))
      continue
    fi

    # Check for type hints on exported variables
    if grep -q "@export" "$file"; then
      if grep "@export var" "$file" | grep -qv ":"; then
        echo -e "${YELLOW}⚠️  Exported vars should have type hints: $file${NC}"
      fi
    fi

    echo -e "${GREEN}✅ Autoload valid: $file${NC}"
  done
else
  echo "  No autoload files yet"
fi

echo ""

# ============================================================================
# PATTERN 2: Resource Scripts
# ============================================================================

echo "📦 Checking resource scripts..."

RESOURCE_FILES=$(find scripts/resources -name "*.gd" 2>/dev/null || true)

if [ -n "$RESOURCE_FILES" ]; then
  for file in $RESOURCE_FILES; do
    # Check for extends Resource
    if ! grep -q "extends Resource" "$file"; then
      echo -e "${RED}❌ Resource script must extend Resource: $file${NC}"
      echo "   Add: extends Resource"
      ((ERRORS++))
      continue
    fi

    # Check for class_name
    if ! grep -q "class_name" "$file"; then
      echo -e "${YELLOW}⚠️  Resource should have class_name: $file${NC}"
    fi

    echo -e "${GREEN}✅ Resource valid: $file${NC}"
  done
else
  echo "  No resource files yet"
fi

echo ""

# ============================================================================
# PATTERN 3: Service Pattern (Autoload with Supabase)
# ============================================================================

echo "🔌 Checking service pattern..."

SERVICE_FILES=$(find scripts/services -name "*_service.gd" 2>/dev/null || true)

if [ -n "$SERVICE_FILES" ]; then
  for file in $SERVICE_FILES; do
    # Check if it's a static utility class (has class_name and static funcs, but no extends)
    if grep -q "class_name" "$file" && grep -q "static func" "$file" && ! grep -q "^extends" "$file"; then
      echo -e "${GREEN}✅ Static utility service: $file${NC}"
      continue
    fi

    # Check for extends Node (required for autoload services)
    if ! grep -q "extends Node" "$file"; then
      echo -e "${RED}❌ Service must extend Node: $file${NC}"
      ((ERRORS++))
      continue
    fi

    # Check for Supabase reference (if it's a backend service)
    if grep -qi "supabase" "$file"; then
      if ! grep -q "SupabaseService" "$file" && ! grep -q "supabase" "$file"; then
        echo -e "${YELLOW}⚠️  Service mentions Supabase but doesn't reference it: $file${NC}"
      fi
    fi

    echo -e "${GREEN}✅ Service valid: $file${NC}"
  done
else
  echo "  No service files yet"
fi

echo ""

# ============================================================================
# PATTERN 4: Naming Conventions
# ============================================================================

echo "📝 Checking naming conventions..."

ALL_GD_FILES=$(find scripts -name "*.gd" 2>/dev/null || true)

if [ -n "$ALL_GD_FILES" ]; then
  for file in $ALL_GD_FILES; do
    # Check filename is snake_case
    filename=$(basename "$file" .gd)
    if [[ ! "$filename" =~ ^[a-z][a-z0-9_]*$ ]]; then
      echo -e "${RED}❌ Filename must be snake_case: $file${NC}"
      echo "   Example: enemy_spawner.gd, wave_system.gd"
      ((ERRORS++))
    fi

    # Check for PascalCase class names (if class_name is used)
    if grep -q "class_name" "$file"; then
      class_name=$(grep "class_name" "$file" | head -1 | awk '{print $2}')
      if [[ ! "$class_name" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
        echo -e "${RED}❌ class_name must be PascalCase: $file${NC}"
        echo "   Found: $class_name"
        echo "   Example: EnemySpawner, WaveSystem"
        ((ERRORS++))
      fi
    fi

    # Check for SCREAMING_SNAKE_CASE constants
    if grep -q "^const " "$file"; then
      while IFS= read -r line; do
        const_name=$(echo "$line" | awk '{print $2}' | cut -d':' -f1 | cut -d'=' -f1)
        if [[ ! "$const_name" =~ ^[A-Z][A-Z0-9_]*$ ]]; then
          echo -e "${YELLOW}⚠️  Constants should be SCREAMING_SNAKE_CASE: $const_name in $file${NC}"
        fi
      done < <(grep "^const " "$file")
    fi
  done
fi

echo ""

# ============================================================================
# PATTERN 5: Type Hints
# ============================================================================

echo "🔤 Checking type hints..."

if [ -n "$ALL_GD_FILES" ]; then
  for file in $ALL_GD_FILES; do
    # Check for functions without return type hints
    if grep -q "^func " "$file"; then
      while IFS= read -r line; do
        if [[ ! "$line" =~ "->" ]] && [[ ! "$line" =~ "_ready\(\)" ]] && [[ ! "$line" =~ "_process\(" ]] && [[ ! "$line" =~ "_physics_process\(" ]]; then
          func_name=$(echo "$line" | awk '{print $2}' | cut -d'(' -f1)
          echo -e "${YELLOW}⚠️  Function missing return type: $func_name in $file${NC}"
          echo "   Add: -> ReturnType"
        fi
      done < <(grep "^func " "$file")
    fi
  done
fi

echo ""

# ============================================================================
# PATTERN 6: Signal Naming
# ============================================================================

echo "📡 Checking signal naming..."

if [ -n "$ALL_GD_FILES" ]; then
  for file in $ALL_GD_FILES; do
    # Check for signals (should be snake_case, past tense recommended)
    if grep -q "^signal " "$file"; then
      while IFS= read -r line; do
        signal_name=$(echo "$line" | awk '{print $2}' | cut -d'(' -f1)
        if [[ ! "$signal_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
          echo -e "${RED}❌ Signal must be snake_case: $signal_name in $file${NC}"
          ((ERRORS++))
        fi
      done < <(grep "^signal " "$file")
    fi
  done
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ All pattern checks passed!${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo -e "${RED}❌ Found $ERRORS pattern violations${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Fix violations and run again"
  exit 1
fi
