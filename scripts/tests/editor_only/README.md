# Editor-Only Resource Tests

This directory contains copies of resource test files with `ENABLE_RESOURCE_TESTS` and `ENABLE_WEAPON_TESTS` flags set to `true`.

## Purpose

Resource tests (weapons, enemies, entities, items) cannot run in headless CI because they load `.tres` files which require the Godot editor environment. These editor-only versions allow you to test resources in the Godot Editor.

## Usage

**Option 1: Use Resource Test Runner Scene (Recommended)**
1. Open `scenes/resource_test_runner.tscn`
2. Press **F6** (Run Current Scene)
3. Watch GUT UI show results for all 108 resource tests

**Option 2: Use GUT Panel with Manual Flag Toggle**
1. Temporarily enable flags in `scripts/tests/*.gd` files
2. Open GUT panel (Window > GUT or bottom panel)
3. Click "Run All"
4. Restore flags to `false` after testing

## Files

- `weapon_loading_test.gd` - 14 weapon resource tests (ENABLE_WEAPON_TESTS=true)
- `enemy_loading_test.gd` - 23 enemy resource tests (ENABLE_RESOURCE_TESTS=true)
- `entity_classes_test.gd` - 30 entity resource tests (ENABLE_RESOURCE_TESTS=true)
- `item_resources_test.gd` - 41 item resource tests (ENABLE_RESOURCE_TESTS=true)

## CI/CD

This directory is excluded from CI via `.gdignore`. The main test files in `scripts/tests/` keep flags disabled for headless CI compatibility.

## Maintenance

When updating resource tests in `scripts/tests/`, remember to sync changes to this directory:

```bash
cp scripts/tests/weapon_loading_test.gd scripts/tests/editor_only/
cp scripts/tests/enemy_loading_test.gd scripts/tests/editor_only/
cp scripts/tests/entity_classes_test.gd scripts/tests/editor_only/
cp scripts/tests/item_resources_test.gd scripts/tests/editor_only/

# Re-enable flags
sed -i '' 's/const ENABLE_WEAPON_TESTS = false/const ENABLE_WEAPON_TESTS = true/' scripts/tests/editor_only/weapon_loading_test.gd
sed -i '' 's/const ENABLE_RESOURCE_TESTS = false/const ENABLE_RESOURCE_TESTS = true/' scripts/tests/editor_only/{enemy,entity_classes,item_resources}_loading_test.gd
```
