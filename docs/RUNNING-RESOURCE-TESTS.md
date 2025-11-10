# Running Resource Tests in Godot Editor

Resource tests (weapons, enemies, entities, items) cannot run in headless CI because they load `.tres` files which require the Godot editor environment.

## Quick Start

1. **Enable resource test flags** (one-time setup):
   ```bash
   sed -i '' 's/const ENABLE_WEAPON_TESTS = false/const ENABLE_WEAPON_TESTS = true/' scripts/tests/weapon_loading_test.gd
   sed -i '' 's/const ENABLE_RESOURCE_TESTS = false/const ENABLE_RESOURCE_TESTS = true/' scripts/tests/enemy_loading_test.gd scripts/tests/entity_classes_test.gd scripts/tests/item_resources_test.gd
   ```

2. **Open Godot Editor** and open GUT panel (Window > GUT or bottom panel)

3. **Click "Run All"** button

4. **Watch results**: All 108 resource tests should pass (not show as `[Pending]`)

5. **Disable flags** when done (to keep CI happy):
   ```bash
   sed -i '' 's/const ENABLE_WEAPON_TESTS = true/const ENABLE_WEAPON_TESTS = false/' scripts/tests/weapon_loading_test.gd
   sed -i '' 's/const ENABLE_RESOURCE_TESTS = true/const ENABLE_RESOURCE_TESTS = false/' scripts/tests/enemy_loading_test.gd scripts/tests/entity_classes_test.gd scripts/tests/item_resources_test.gd
   ```

## Test Coverage

- **weapon_loading_test.gd**: 14 weapon resource tests
- **enemy_loading_test.gd**: 23 enemy resource tests
- **entity_classes_test.gd**: 30 entity resource tests
- **item_resources_test.gd**: 41 item resource tests

**Total**: 108 resource tests

## Why This Approach?

- Main test files keep flags disabled for CI compatibility
- Temporarily enable flags only when testing in editor
- No duplicate test files to maintain
- No class_name conflicts
- Simple toggle with sed commands

## Troubleshooting

**Tests still show as `[Pending]`?**
- Verify flags are `true` in test files
- Restart Godot Editor
- Check GUT panel is pointing to `res://scripts/tests`

**Parser Error about duplicate class_name?**
- This should not happen with this approach
- If it does, check for stray editor_only files

**Resource loading errors?**
- These tests MUST run in Godot Editor (not headless)
- Ensure you're using the GUT panel, not command line
