# Godot Migration: Weekly Action Items

**Complete 16-week breakdown** with daily tasks, deliverables, and verification steps.

**Estimated effort:** 25-35 hours per week

---

## Table of Contents

- [Week 1: Repository & Environment Setup](#week-1-repository--environment-setup)
- [Week 2: Configuration Export & JSON Creation](#week-2-configuration-export--json-creation)
- [Week 3: Custom Resources & Type Classes](#week-3-custom-resources--type-classes)
- [Week 4: Foundation Services](#week-4-foundation-services)
- [Week 5: Business Logic Services](#week-5-business-logic-services)
- [Week 6: Complex Services Part 1](#week-6-complex-services-part-1)
- [Week 7: Complex Services Part 2 & Supabase](#week-7-complex-services-part-2--supabase)
- [Week 8: Core Game Loop & Player](#week-8-core-game-loop--player)
- [Week 9: Enemy System & Wave Spawning](#week-9-enemy-system--wave-spawning)
- [Week 10: Weapon System & Projectiles](#week-10-weapon-system--projectiles)
- [Week 11: Items, Pickups & Drops](#week-11-items-pickups--drops)
- [Week 12: UI Theme & Core Screens](#week-12-ui-theme--core-screens)
- [Week 13: Game-Specific UI](#week-13-game-specific-ui)
- [Week 14: Testing Infrastructure](#week-14-testing-infrastructure)
- [Week 15: Mobile Export & Performance](#week-15-mobile-export--performance)
- [Week 16: Deployment & Launch Prep](#week-16-deployment--launch-prep)

---

## Week 1: Repository & Environment Setup

**Goal:** Complete development environment with working Godot project

### Day 1 (Monday): Repository Creation

**Tasks:**
- [ ] Create `scrap-survivor-godot` repository on GitHub
- [ ] Clone locally to `~/Developer/scrap-survivor-godot`
- [ ] Create initial README.md
- [ ] Create .gitignore for Godot
- [ ] Create directory structure (assets, scripts, scenes, resources, docs)
- [ ] Initial commit and push

**Commands:**
```bash
cd ~/Developer
gh repo create scrap-survivor-godot --public --clone
cd scrap-survivor-godot
# (See godot-quick-start.md for full commands)
```

**Deliverables:**
- Working Git repository with clean structure

**Verification:**
```bash
git log  # Should show initial commits
ls -la   # Should show all directories
```

**Time:** 2 hours

---

### Day 2 (Tuesday): Tool Installation

**Tasks:**
- [ ] Download Godot 4.4 from godotengine.org
- [ ] Install to /Applications/Godot.app
- [ ] Verify Godot runs: `/Applications/Godot.app/Contents/MacOS/Godot --version`
- [ ] Install Python 3 (if not installed)
- [ ] Install gdtoolkit: `pip3 install "gdtoolkit==4.*"`
- [ ] Verify gdlint: `gdlint --version`
- [ ] Verify gdformat: `gdformat --version`
- [ ] Install VS Code Godot extension
- [ ] Configure VS Code settings for Godot

**Deliverables:**
- All tools installed and working

**Verification:**
```bash
/Applications/Godot.app/Contents/MacOS/Godot --version  # 4.4.x
gdlint --version  # 4.x.x
gdformat --version  # 4.x.x
```

**Time:** 2-3 hours

---

### Day 3 (Wednesday): Godot Project Setup

**Tasks:**
- [ ] Open Godot Project Manager
- [ ] Import ~/Developer/scrap-survivor-godot
- [ ] Wait for initial import (1-2 minutes)
- [ ] Configure Project Settings:
  - [ ] Display → Window (1920x1080, windowed, resizable)
  - [ ] Input Map (move_left, move_right, move_up, move_down, fire, pause)
  - [ ] Rendering → Forward+ renderer
  - [ ] Rendering → MSAA 2D: 2x
- [ ] Save project.godot
- [ ] Commit project.godot to Git
- [ ] Install Supabase addon from AssetLib
- [ ] Restart Godot
- [ ] Verify addon installed: check addons/supabase/ directory

**Deliverables:**
- Godot project runs (F5 shows blank screen - expected)
- Supabase addon installed

**Verification:**
```bash
ls project.godot  # Exists
ls addons/supabase/  # Exists
# Press F5 in Godot - blank screen shows (no errors)
```

**Time:** 3 hours

---

### Day 4 (Thursday): System Enforcement Migration

**Tasks:**
- [ ] Copy .system/ from scrap-survivor repo: `cp -r ~/Developer/scrap-survivor/.system ./`
- [ ] Update .system/hooks/pre-commit for gdlint
- [ ] Create .gdlintrc configuration
- [ ] Make pre-commit executable: `chmod +x .system/hooks/pre-commit`
- [ ] Link to git hooks: `ln -sf ../../.system/hooks/pre-commit .git/hooks/pre-commit`
- [ ] Test pre-commit hook: create dummy .gd file, commit, verify lint runs
- [ ] Update .system/validators/ for GDScript patterns (if needed)
- [ ] Verify git autonomy system: `ls .system/git/`
- [ ] Commit .system/ directory

**Deliverables:**
- .system/ directory functional
- Pre-commit hook running gdlint

**Verification:**
```bash
# Create test file
echo 'extends Node' > test.gd
git add test.gd
git commit -m "test"  # Hook should run gdlint
rm test.gd
```

**Time:** 3 hours

---

### Day 5 (Friday): Documentation Migration

**Tasks:**
- [ ] Copy architecture docs from scrap-survivor
- [ ] Copy monetization-architecture.md
- [ ] Copy PATTERN-CATALOG.md
- [ ] Copy DATA-MODEL.md
- [ ] Copy all lessons-learned/
- [ ] Copy commit-guidelines.md
- [ ] Create docs/godot/setup-guide.md
- [ ] Create docs/godot/gdscript-conventions.md
- [ ] Create docs/godot/architecture-decisions.md (empty, fill later)
- [ ] Create docs/migration/weekly-progress.md (tracker)
- [ ] Commit all documentation

**Deliverables:**
- Complete documentation structure

**Verification:**
```bash
ls docs/core-architecture/  # Shows migrated docs
ls docs/godot/  # Shows new Godot docs
ls docs/lessons-learned/  # Shows all lessons
```

**Time:** 2-3 hours

---

### Week 1 Wrap-Up

**End-of-week checklist:**
- [ ] Repository exists on GitHub with clean history
- [ ] Godot 4.4 installed and working
- [ ] gdtoolkit installed and working
- [ ] VS Code configured
- [ ] Godot project initialized (project.godot exists)
- [ ] Project settings configured
- [ ] Supabase addon installed
- [ ] .system/ directory migrated and functional
- [ ] Git hooks running
- [ ] Documentation migrated

**Time this week:** ~15-18 hours

---

## Week 2: Configuration Export & JSON Creation

**Goal:** All game configurations exported to JSON files

### Day 1 (Monday): Export Script Creation

**Tasks:**
- [ ] In scrap-survivor repo, create scripts/export-configs.js
- [ ] Write function to export weapons.ts → JSON
- [ ] Write function to export items.ts → JSON
- [ ] Write function to export enemies.ts → JSON
- [ ] Write function to export gameConstants.ts → JSON
- [ ] Add command line argument parsing for selective export
- [ ] Test script: `node scripts/export-configs.js`
- [ ] Verify JSON output in ../scrap-survivor-godot/resources/data/

**Script structure:**
```javascript
const fs = require('fs');
const path = require('path');

// Load TypeScript configs (require or import)
const weapons = require('./packages/core/src/config/weapons.ts');
const items = require('./packages/core/src/config/items.ts');
const enemies = require('./packages/core/src/types/enemies.ts');
const constants = require('./packages/core/src/config/gameConstants.ts');

function exportWeapons() {
  // Convert weapons object to array of JSON objects
  const weaponsArray = Object.entries(weapons).map(([key, weapon]) => ({
    id: key,
    name: weapon.name,
    damage: weapon.damage,
    fire_rate: weapon.fireRate,
    projectile_speed: weapon.projectileSpeed,
    range: weapon.range,
    durability: weapon.durability,
    is_premium: weapon.tier === 'premium',
    fusion_tier: weapon.fuseTier || 1,
    description: weapon.description || ""
  }));

  const outputPath = path.join(__dirname, '..', 'scrap-survivor-godot', 'resources', 'data', 'weapons.json');
  fs.writeFileSync(outputPath, JSON.stringify(weaponsArray, null, 2));
  console.log(`✅ Exported ${weaponsArray.length} weapons to ${outputPath}`);
}

function exportItems() {
  // Similar to exportWeapons
}

function exportEnemies() {
  // Similar to exportWeapons
}

function exportConstants() {
  // Similar to exportWeapons
}

// CLI
const args = process.argv.slice(2);
if (args.length === 0 || args.includes('weapons')) exportWeapons();
if (args.length === 0 || args.includes('items')) exportItems();
if (args.length === 0 || args.includes('enemies')) exportEnemies();
if (args.length === 0 || args.includes('constants')) exportConstants();
```

**Deliverables:**
- Working export script

**Verification:**
```bash
cd ~/Developer/scrap-survivor
node scripts/export-configs.js
ls ../scrap-survivor-godot/resources/data/*.json  # Should show 4 files
```

**Time:** 4 hours

---

### Day 2 (Tuesday): Weapons Export

**Tasks:**
- [ ] Run: `node scripts/export-configs.js weapons`
- [ ] Verify weapons.json in scrap-survivor-godot/resources/data/
- [ ] Validate JSON format (use jq or JSON validator)
- [ ] Check all 23 weapons present
- [ ] Verify required fields: id, name, damage, fire_rate, etc.
- [ ] Check premium flags correct
- [ ] Spot-check 3 random weapons against TypeScript source
- [ ] Commit weapons.json

**Deliverables:**
- weapons.json with 23 weapons

**Verification:**
```bash
cd ~/Developer/scrap-survivor-godot
cat resources/data/weapons.json | jq '. | length'  # Should output 23
cat resources/data/weapons.json | jq '.[0]'  # Check first weapon
```

**Time:** 2 hours

---

### Day 3 (Wednesday): Items Export

**Tasks:**
- [ ] Run: `node scripts/export-configs.js items`
- [ ] Verify items.json in scrap-survivor-godot/resources/data/
- [ ] Validate JSON format
- [ ] Check all 30+ items present
- [ ] Verify required fields: id, name, type, rarity, effects
- [ ] Categorize items by type (health, scrap, powerup, etc.)
- [ ] Spot-check 5 random items against TypeScript source
- [ ] Commit items.json

**Deliverables:**
- items.json with 30+ items

**Verification:**
```bash
cat resources/data/items.json | jq '. | length'  # Should output 30+
cat resources/data/items.json | jq 'group_by(.type)'  # Check types
```

**Time:** 2 hours

---

### Day 4 (Thursday): Enemies Export

**Tasks:**
- [ ] Run: `node scripts/export-configs.js enemies`
- [ ] Verify enemies.json
- [ ] Check all 3 enemy types present (Shambler, Runner, Juggernaut)
- [ ] Verify base stats: health, speed, damage
- [ ] Verify spawn weights: 60%, 30%, 10%
- [ ] Verify wave scaling formulas: +25% HP, +5% speed, +10% damage per wave
- [ ] Verify colors: red, orange, dark red
- [ ] Verify sizes: 20px, 15px, 30px
- [ ] Commit enemies.json

**Deliverables:**
- enemies.json with 3 enemy types

**Verification:**
```bash
cat resources/data/enemies.json | jq '. | length'  # Should output 3
cat resources/data/enemies.json | jq '.[0]'  # Check Scrap Shambler
```

**Time:** 2 hours

---

### Day 5 (Friday): Constants & Cleanup

**Tasks:**
- [ ] Run: `node scripts/export-configs.js constants`
- [ ] Verify game_constants.json
- [ ] Check all balance values present
- [ ] Verify timeouts, limits, multipliers
- [ ] Create JSON schema files (optional but recommended):
  - [ ] resources/data/schemas/weapon_schema.json
  - [ ] resources/data/schemas/item_schema.json
  - [ ] resources/data/schemas/enemy_schema.json
- [ ] Validate all JSON files against schemas
- [ ] Create resources/data/README.md explaining JSON structure
- [ ] Final commit for Week 2

**Deliverables:**
- All configuration JSONs exported
- Documentation for JSON structure

**Verification:**
```bash
ls resources/data/*.json  # Should show: weapons, items, enemies, constants
cat resources/data/README.md  # Documentation exists
```

**Time:** 3 hours

---

### Week 2 Wrap-Up

**End-of-week checklist:**
- [ ] weapons.json (23 weapons)
- [ ] items.json (30+ items)
- [ ] enemies.json (3 types)
- [ ] game_constants.json (all balance values)
- [ ] All JSON files validated
- [ ] Export script committed to scrap-survivor repo
- [ ] JSON files committed to scrap-survivor-godot repo

**Time this week:** ~15 hours

---

## Week 3: Custom Resources & Type Classes

**Goal:** Godot-native resource files and entity classes

### Day 1 (Monday): Resource Class Creation

**Tasks:**
- [ ] Create scripts/resources/ directory
- [ ] Create WeaponResource.gd:
  - [ ] Extends Resource
  - [ ] @export variables for all weapon properties
  - [ ] Type hints on all fields
- [ ] Create EnemyResource.gd:
  - [ ] Extends Resource
  - [ ] Base stats + wave scaling properties
  - [ ] get_scaled_stats(wave: int) method
- [ ] Create ItemResource.gd:
  - [ ] Extends Resource
  - [ ] Item type, rarity, effects
- [ ] Test resources in Godot editor:
  - [ ] Right-click → New Resource → WeaponResource
  - [ ] Fill in sample data
  - [ ] Save as .tres, verify it loads

**Deliverables:**
- 3 resource class files

**Verification:**
```bash
ls scripts/resources/*.gd  # weapon_resource.gd, enemy_resource.gd, item_resource.gd
# In Godot: Create → Resource → WeaponResource (should appear in list)
```

**Time:** 3 hours

---

### Day 2 (Tuesday): Weapon Resources Creation

**Tasks:**
- [ ] Create resources/weapons/ directory
- [ ] For each weapon in weapons.json:
  - [ ] Right-click → New Resource → WeaponResource
  - [ ] Fill in all fields from JSON
  - [ ] Save as resources/weapons/{weapon_id}.tres
- [ ] Create batch import script (GDScript) to automate:
  - [ ] scripts/utils/import_weapons.gd
  - [ ] Reads weapons.json
  - [ ] Creates .tres files programmatically
- [ ] Run import script
- [ ] Verify all 23 weapon .tres files created
- [ ] Test load in code:
  ```gdscript
  var weapon = load("res://resources/weapons/rusty_pistol.tres")
  print(weapon.weapon_name)  # Should print "Rusty Pistol"
  ```

**Deliverables:**
- 23 weapon .tres files
- Import script

**Verification:**
```bash
ls resources/weapons/*.tres | wc -l  # Should output 23
```

**Time:** 4 hours

---

### Day 3 (Wednesday): Enemy & Item Resources

**Tasks:**
- [ ] Create resources/enemies/ directory
- [ ] Create enemy .tres files (3 total):
  - [ ] scrap_shambler.tres
  - [ ] rust_runner.tres
  - [ ] junk_juggernaut.tres
- [ ] Verify wave scaling formula in editor
- [ ] Create resources/items/ directory
- [ ] Create batch import script for items
- [ ] Run import for all 30+ items
- [ ] Verify all .tres files created

**Deliverables:**
- 3 enemy .tres files
- 30+ item .tres files

**Verification:**
```bash
ls resources/enemies/*.tres | wc -l  # Should output 3
ls resources/items/*.tres | wc -l  # Should output 30+
```

**Time:** 3 hours

---

### Day 4 (Thursday): Entity Classes

**Tasks:**
- [ ] Create scripts/entities/ directory
- [ ] Create player.gd:
  - [ ] Extends CharacterBody2D
  - [ ] Properties: health, speed, equipped_weapon
  - [ ] Movement in _physics_process()
  - [ ] Signals: health_changed, died
- [ ] Create enemy.gd:
  - [ ] Extends CharacterBody2D
  - [ ] Link to EnemyResource
  - [ ] initialize(wave: int) method
  - [ ] take_damage(amount: float) method
  - [ ] die() method
- [ ] Create projectile.gd:
  - [ ] Extends Area2D
  - [ ] Properties: velocity, damage, range
  - [ ] activate() and deactivate() methods
  - [ ] _physics_process() for movement
- [ ] Create test scenes:
  - [ ] scenes/entities/player.tscn
  - [ ] scenes/entities/enemy.tscn
  - [ ] scenes/entities/projectile.tscn

**Deliverables:**
- 3 entity class scripts
- 3 entity scene files

**Verification:**
```bash
ls scripts/entities/*.gd  # player.gd, enemy.gd, projectile.gd
ls scenes/entities/*.tscn  # player.tscn, enemy.tscn, projectile.tscn
# In Godot: Instantiate each scene, verify properties appear in inspector
```

**Time:** 4 hours

---

### Day 5 (Friday): Type System & Testing

**Tasks:**
- [ ] Create scripts/types/ directory (for enums and type definitions)
- [ ] Create types/damage_type.gd:
  ```gdscript
  class_name DamageType
  enum Type {
      PHYSICAL,
      ENERGY,
      POISON
  }
  ```
- [ ] Create types/item_rarity.gd:
  ```gdscript
  class_name ItemRarity
  enum Rarity {
      COMMON,
      UNCOMMON,
      RARE,
      EPIC,
      LEGENDARY
  }
  ```
- [ ] Create types/enemy_type.gd
- [ ] Update entity scripts to use type enums
- [ ] Test loading resources in code:
  - [ ] Create test scene: scenes/tests/resource_test.tscn
  - [ ] Script loads all weapons, enemies, items
  - [ ] Prints properties to console
  - [ ] Verify output correct
- [ ] Commit all work for Week 3

**Deliverables:**
- Type definition files
- Resource loading test

**Verification:**
```bash
# Run test scene
# Console should show all weapons, enemies, items loading successfully
```

**Time:** 3 hours

---

### Week 3 Wrap-Up

**End-of-week checklist:**
- [ ] WeaponResource, EnemyResource, ItemResource classes created
- [ ] 23 weapon .tres files
- [ ] 3 enemy .tres files
- [ ] 30+ item .tres files
- [ ] Player, Enemy, Projectile entity classes
- [ ] Type definition files
- [ ] All resources load successfully in Godot

**Time this week:** ~17 hours

---

## Week 4: Foundation Services

**Goal:** Basic service layer with error handling and logging

### Day 1 (Monday): Autoload Setup

**Tasks:**
- [ ] Create scripts/autoload/ directory
- [ ] Create GameState autoload (game_state.gd):
  - [ ] Signals for state changes
  - [ ] Variables: current_user, current_character, is_gameplay_active, current_wave, score
  - [ ] Setters with signal emission
- [ ] Configure in Project Settings → Autoload:
  - [ ] Add game_state.gd as "GameState"
  - [ ] Enable
- [ ] Test in test scene:
  ```gdscript
  GameState.set_current_wave(5)
  print(GameState.current_wave)  # Should print 5
  ```

**Deliverables:**
- GameState autoload working

**Verification:**
```bash
# In Godot: Project Settings → Autoload → GameState visible
# Run test scene, console shows state changes
```

**Time:** 2 hours

---

### Day 2 (Tuesday): Error Service

**Tasks:**
- [ ] Create scripts/services/ directory
- [ ] Create error_service.gd:
  - [ ] Extends Node
  - [ ] ErrorLevel enum (INFO, WARNING, ERROR, CRITICAL)
  - [ ] log_error() method
  - [ ] log_info(), log_warning() helpers
  - [ ] error_occurred signal
- [ ] Configure as autoload: "ErrorService"
- [ ] Test:
  ```gdscript
  ErrorService.log_error("Test error", ErrorService.ErrorLevel.ERROR)
  ErrorService.log_info("Test info")
  ```
- [ ] Verify console output

**Deliverables:**
- ErrorService autoload

**Verification:**
```bash
# Console shows: [ERROR] Test error
# Console shows: [INFO] Test info
```

**Time:** 2 hours

---

### Day 3 (Wednesday): Logger Utility

**Tasks:**
- [ ] Create scripts/utils/ directory
- [ ] Create logger.gd:
  - [ ] class_name Logger
  - [ ] Static methods: debug(), info(), warning(), error()
  - [ ] Timestamp formatting
  - [ ] Optional file logging (write to user://logs/)
- [ ] Test in various scripts:
  ```gdscript
  Logger.info("Game started")
  Logger.error("Failed to load resource")
  ```
- [ ] Create logs/ directory in user:// path
- [ ] Verify logs written to file

**Deliverables:**
- Logger utility class

**Verification:**
```bash
# Check Godot user:// path logs
# macOS: ~/Library/Application Support/Godot/app_userdata/Scrap Survivor/logs/
```

**Time:** 3 hours

---

### Day 4 (Thursday): Stat Service

**Tasks:**
- [ ] Create stat_service.gd
- [ ] Port from TypeScript packages/core/src/services/statService.ts:
  - [ ] calculate_damage(base, strength, weapon_bonus)
  - [ ] calculate_health(base, vitality)
  - [ ] calculate_speed(base, agility)
  - [ ] apply_stat_modifiers(base_stats, modifiers)
- [ ] Configure as autoload (optional, or use static methods)
- [ ] Create unit tests:
  - [ ] scripts/tests/test_stat_service.gd
  - [ ] Test calculate_damage with known values
  - [ ] Test calculate_health
  - [ ] Test apply_stat_modifiers
- [ ] Run tests (manually or with GUT if installed)

**Deliverables:**
- StatService with TypeScript logic ported
- Unit tests

**Verification:**
```gdscript
var damage = StatService.calculate_damage(100, 50, 10)
assert(damage == 160)  # Should pass
```

**Time:** 3 hours

---

### Day 5 (Friday): Foundation Services Integration

**Tasks:**
- [ ] Create service integration test scene
- [ ] Test all foundation services together:
  - [ ] GameState tracks game state
  - [ ] ErrorService logs errors
  - [ ] Logger writes to file
  - [ ] StatService calculates correctly
- [ ] Create docs/godot/services-guide.md:
  - [ ] Document each service
  - [ ] Usage examples
  - [ ] API reference
- [ ] Commit all Week 4 work

**Deliverables:**
- Integration test scene
- Services documentation

**Verification:**
```bash
# Run integration scene, all services work together
# Check logs written
# Check calculations correct
```

**Time:** 3 hours

---

### Week 4 Wrap-Up

**End-of-week checklist:**
- [ ] GameState autoload working
- [ ] ErrorService autoload working
- [ ] Logger utility class working
- [ ] StatService ported and tested
- [ ] All services documented
- [ ] Unit tests created

**Time this week:** ~13 hours

---

## Week 5: Business Logic Services

**Goal:** Port RecyclerService, ShopRerollService, BankingService

### Day 1 (Monday): BankingService Setup

**Tasks:**
- [ ] Create banking_service.gd
- [ ] Define currency types enum:
  ```gdscript
  enum Currency {
      SCRAP,
      PREMIUM
  }
  ```
- [ ] Implement data structure for balances:
  ```gdscript
  var balances: Dictionary = {
      "scrap": 0,
      "premium": 0
  }
  ```
- [ ] Implement add_currency(type, amount) method
- [ ] Implement subtract_currency(type, amount) method
- [ ] Implement get_balance(type) method
- [ ] Add signals: currency_changed(type, new_balance)
- [ ] Configure as autoload: "BankingService"

**Deliverables:**
- BankingService skeleton

**Verification:**
```gdscript
BankingService.add_currency("scrap", 100)
assert(BankingService.get_balance("scrap") == 100)
```

**Time:** 3 hours

---

### Day 2 (Tuesday): BankingService Logic

**Tasks:**
- [ ] Port tier-gating logic from TypeScript:
  - [ ] check_tier_access(user_tier) method
  - [ ] Premium currency restrictions
- [ ] Implement transaction validation:
  - [ ] Prevent negative balances
  - [ ] Check tier before premium operations
- [ ] Add transaction history (optional):
  - [ ] Array of transactions
  - [ ] get_transaction_history() method
- [ ] Create unit tests:
  - [ ] Test add/subtract currency
  - [ ] Test tier-gating
  - [ ] Test negative balance prevention
- [ ] Run tests

**Deliverables:**
- Complete BankingService with tests

**Verification:**
```gdscript
BankingService.subtract_currency("scrap", 1000)  # Should fail if balance < 1000
# Test passes
```

**Time:** 4 hours

---

### Day 3 (Wednesday): RecyclerService

**Tasks:**
- [ ] Create recycler_service.gd
- [ ] Port from TypeScript packages/core/src/services/RecyclerService.ts:
  - [ ] recycle_item(item_id) method
  - [ ] _calculate_scrap_value(item_data) method
  - [ ] _get_rarity_multiplier(rarity) method
  - [ ] _get_item_data(item_id) helper
- [ ] Integrate with BankingService:
  - [ ] Call BankingService.add_currency() when recycling
- [ ] Add signal: item_recycled(item_id, scrap_gained)
- [ ] Load items from resources/data/items.json
- [ ] Configure as autoload: "RecyclerService"

**Deliverables:**
- RecyclerService with TypeScript logic ported

**Verification:**
```gdscript
var result = RecyclerService.recycle_item("health_pack")
assert(result.success == true)
assert(result.scrap_gained > 0)
```

**Time:** 4 hours

---

### Day 4 (Thursday): ShopRerollService

**Tasks:**
- [ ] Create shop_reroll_service.gd
- [ ] Port from TypeScript packages/core/src/services/ShopRerollService.ts:
  - [ ] reroll_shop() method
  - [ ] Calculate reroll cost (increases with each reroll)
  - [ ] Generate new shop inventory (random items/weapons)
- [ ] Integrate with BankingService:
  - [ ] Check balance before reroll
  - [ ] Deduct reroll cost
- [ ] Add signals:
  - [ ] shop_rerolled(new_inventory, cost)
  - [ ] reroll_failed(reason)
- [ ] Configure as autoload: "ShopRerollService"

**Deliverables:**
- ShopRerollService working

**Verification:**
```gdscript
var result = ShopRerollService.reroll_shop()
assert(result.success == true)
assert(result.new_inventory.size() > 0)
```

**Time:** 3 hours

---

### Day 5 (Friday): Service Integration & Testing

**Tasks:**
- [ ] Create integration test for all business services:
  - [ ] Recycle item → gain scrap
  - [ ] Reroll shop → deduct currency
  - [ ] Check balances correct after operations
- [ ] Create scripts/tests/test_business_services.gd
- [ ] Run all unit tests
- [ ] Fix any failing tests
- [ ] Update docs/godot/services-guide.md with new services
- [ ] Commit Week 5 work

**Deliverables:**
- All business services integrated and tested

**Verification:**
```bash
# Run all tests - should pass
# Check service guide documentation updated
```

**Time:** 3 hours

---

### Week 5 Wrap-Up

**End-of-week checklist:**
- [ ] BankingService complete with tier-gating
- [ ] RecyclerService complete
- [ ] ShopRerollService complete
- [ ] All services unit tested
- [ ] Integration tests passing
- [ ] Documentation updated

**Time this week:** ~17 hours

---

## Week 6: Complex Services Part 1

**Goal:** Start porting HybridCharacterService and SyncService

### Day 1 (Monday): Supabase Client Setup

**Tasks:**
- [ ] Create supabase_client.gd autoload
- [ ] Load Supabase URL and anon key from environment:
  ```gdscript
  var url = OS.get_environment("SUPABASE_URL")
  var key = OS.get_environment("SUPABASE_ANON_KEY")
  ```
- [ ] Initialize SupabaseClient from addon:
  ```gdscript
  var client = SupabaseClient.new()
  client.setup(url, key)
  ```
- [ ] Create wrapper methods:
  - [ ] auth_sign_up(email, password)
  - [ ] auth_sign_in(email, password)
  - [ ] auth_sign_out()
  - [ ] get_current_user()
- [ ] Configure as autoload: "SupabaseClient"
- [ ] Create .env file with credentials (add to .gitignore)

**Deliverables:**
- SupabaseClient autoload configured

**Verification:**
```gdscript
# Test auth (requires valid Supabase project)
var result = await SupabaseClient.auth_sign_in("test@example.com", "password")
print(result)  # Should show user data or error
```

**Time:** 3 hours

---

### Day 2 (Tuesday): Test Supabase Connection

**Tasks:**
- [ ] Create test scene: scenes/tests/supabase_test.tscn
- [ ] Test authentication:
  - [ ] Sign up new user
  - [ ] Sign in existing user
  - [ ] Get current user
  - [ ] Sign out
- [ ] Test database operations:
  - [ ] Insert test record
  - [ ] Query test record
  - [ ] Update test record
  - [ ] Delete test record
- [ ] Verify all operations work
- [ ] Document any Supabase-specific quirks in docs/godot/supabase-integration.md

**Deliverables:**
- Working Supabase connection
- Test scene demonstrating all operations

**Verification:**
```bash
# Run test scene
# Console shows successful auth and DB operations
```

**Time:** 4 hours

---

### Day 3 (Wednesday): Character Service - Data Models

**Tasks:**
- [ ] Create character_service.gd
- [ ] Define CharacterData class:
  ```gdscript
  class CharacterData:
      var id: String
      var user_id: String
      var name: String
      var stats: Dictionary
      var level: int
      var experience: int
      var created_at: String
  ```
- [ ] Create validation methods:
  - [ ] _validate_character_data(data: Dictionary) -> bool
  - [ ] _validate_character_name(name: String) -> bool
- [ ] Add signals:
  - [ ] character_created(character: Dictionary)
  - [ ] character_updated(character: Dictionary)
  - [ ] character_deleted(character_id: String)

**Deliverables:**
- CharacterService skeleton with data models

**Verification:**
```gdscript
var valid = CharacterService._validate_character_name("Test Hero")
assert(valid == true)
```

**Time:** 3 hours

---

### Day 4 (Thursday): Character Service - CRUD Operations

**Tasks:**
- [ ] Port from TypeScript HybridCharacterService.ts:
  - [ ] create_character(user_id, character_data) method
  - [ ] get_user_characters(user_id) method
  - [ ] update_character(character_id, updates) method
  - [ ] delete_character(character_id) method
- [ ] Integrate with SupabaseClient:
  - [ ] Use client.database.from("characters").insert()
  - [ ] Use client.database.from("characters").select()
  - [ ] Use client.database.from("characters").update()
  - [ ] Use client.database.from("characters").delete()
- [ ] Add error handling via ErrorService
- [ ] Configure as autoload: "CharacterService"

**Deliverables:**
- CharacterService with full CRUD operations

**Verification:**
```gdscript
var result = await CharacterService.create_character(user_id, {
    "name": "Test Hero",
    "level": 1
})
assert(result.success == true)
```

**Time:** 5 hours

---

### Day 5 (Friday): Character Service Testing

**Tasks:**
- [ ] Create test scene: scenes/tests/character_service_test.tscn
- [ ] Test create_character with valid data
- [ ] Test create_character with invalid data (should fail)
- [ ] Test get_user_characters
- [ ] Test update_character
- [ ] Test delete_character
- [ ] Verify all operations reflected in Supabase dashboard
- [ ] Create unit tests: scripts/tests/test_character_service.gd
- [ ] Commit Week 6 work

**Deliverables:**
- Fully tested CharacterService

**Verification:**
```bash
# Run test scene
# All CRUD operations succeed
# Check Supabase dashboard - data matches
```

**Time:** 4 hours

---

### Week 6 Wrap-Up

**End-of-week checklist:**
- [ ] SupabaseClient autoload working
- [ ] Supabase authentication working
- [ ] CharacterService complete with CRUD operations
- [ ] All database operations tested
- [ ] Error handling in place
- [ ] Documentation updated

**Time this week:** ~19 hours

---

## Week 7: Complex Services Part 2 & Supabase

**Goal:** Complete SyncService and finalize all backend integration

### Day 1 (Monday): SyncService - Setup

**Tasks:**
- [ ] Create sync_service.gd
- [ ] Port from TypeScript SyncService.ts:
  - [ ] SyncStatus enum (PENDING, SYNCING, SYNCED, ERROR)
  - [ ] sync_character(character_id) method
  - [ ] sync_all_characters(user_id) method
  - [ ] _detect_conflicts(local, remote) method
- [ ] Add signals:
  - [ ] sync_started(character_id)
  - [ ] sync_completed(character_id, status)
  - [ ] sync_failed(character_id, error)
- [ ] Configure as autoload: "SyncService"

**Deliverables:**
- SyncService skeleton

**Verification:**
```bash
# Service loads without errors
```

**Time:** 3 hours

---

### Day 2 (Tuesday): SyncService - Sync Logic

**Tasks:**
- [ ] Implement retry logic with exponential backoff:
  - [ ] _retry_with_backoff(operation, max_retries) method
  - [ ] Delay calculation: 2^attempt seconds
- [ ] Implement conflict resolution:
  - [ ] Server-wins strategy (default)
  - [ ] Timestamp comparison for last-write-wins
- [ ] Integrate with CharacterService:
  - [ ] Pull remote character data
  - [ ] Compare with local data
  - [ ] Push updates if local newer
- [ ] Add network connectivity check:
  - [ ] Use OS.get_name() to check platform
  - [ ] Use HTTPRequest to ping Supabase

**Deliverables:**
- SyncService with retry and conflict resolution

**Verification:**
```gdscript
var result = await SyncService.sync_character(character_id)
assert(result.status == SyncService.SyncStatus.SYNCED)
```

**Time:** 5 hours

---

### Day 3 (Wednesday): TierService

**Tasks:**
- [ ] Create tier_service.gd
- [ ] Port from TypeScript TierService.ts:
  - [ ] Tier enum (FREE, PREMIUM, SUBSCRIPTION)
  - [ ] get_user_tier(user_id) method
  - [ ] check_feature_access(user_tier, feature) method
  - [ ] upgrade_tier(user_id, new_tier) method
- [ ] Define feature gates:
  - [ ] Premium weapons
  - [ ] Extra character slots
  - [ ] Cloud sync
- [ ] Integrate with Supabase:
  - [ ] Query user_tiers table
  - [ ] Update tier on purchase
- [ ] Configure as autoload: "TierService"

**Deliverables:**
- TierService with tier-gating logic

**Verification:**
```gdscript
var tier = TierService.get_user_tier(user_id)
var access = TierService.check_feature_access(tier, "premium_weapons")
assert(access == true or access == false)  # Depends on tier
```

**Time:** 4 hours

---

### Day 4 (Thursday): Service Integration Testing

**Tasks:**
- [ ] Create comprehensive integration test:
  - [ ] Create character (CharacterService)
  - [ ] Add currency (BankingService)
  - [ ] Recycle item (RecyclerService)
  - [ ] Sync character (SyncService)
  - [ ] Check tier access (TierService)
- [ ] Verify all services work together
- [ ] Test error scenarios:
  - [ ] Network failure during sync
  - [ ] Insufficient currency for reroll
  - [ ] Invalid tier access attempt
- [ ] Fix any integration bugs

**Deliverables:**
- Full service integration test passing

**Verification:**
```bash
# Run integration test scene
# All operations succeed in sequence
```

**Time:** 4 hours

---

### Day 5 (Friday): Services Documentation & Wrap-Up

**Tasks:**
- [ ] Update docs/godot/services-guide.md:
  - [ ] Document all 10+ services
  - [ ] API reference for each
  - [ ] Usage examples
  - [ ] Error handling patterns
- [ ] Create architecture diagram:
  - [ ] docs/godot/service-architecture.png
  - [ ] Show service dependencies
  - [ ] Show autoload relationships
- [ ] Code cleanup:
  - [ ] Remove debug prints
  - [ ] Add doc comments to all public methods
  - [ ] Run gdformat on all files
- [ ] Commit Week 7 work

**Deliverables:**
- Complete service layer documentation
- All services clean and documented

**Verification:**
```bash
gdformat --check scripts/  # Should pass
# Check docs - all services documented
```

**Time:** 3 hours

---

### Week 7 Wrap-Up

**End-of-week checklist:**
- [ ] SyncService complete with retry logic
- [ ] TierService complete
- [ ] All 10+ services working together
- [ ] Integration tests passing
- [ ] Complete service documentation
- [ ] Code formatted and clean

**Time this week:** ~19 hours

**Major milestone:** Backend integration complete ✅

---

## Week 8: Core Game Loop & Player

**Goal:** Playable prototype with player movement and basic game loop

### Day 1 (Monday): Main Game Scene Setup

**Tasks:**
- [ ] Create scenes/game/ directory
- [ ] Create wasteland.tscn scene:
  - [ ] Root: Node2D
  - [ ] Player (CharacterBody2D) - instance of scenes/entities/player.tscn
  - [ ] Camera2D (child of Player, follows player)
  - [ ] EnemyContainer (Node2D) - holds all enemies
  - [ ] ProjectileContainer (Node2D) - holds projectile pool
  - [ ] PickupContainer (Node2D) - holds item pickups
  - [ ] CanvasLayer → HUD
  - [ ] WaveSystem (Node) - attach script later
- [ ] Set as main scene: Project → Project Settings → Application → Run → Main Scene
- [ ] Test: Press F5, should show empty scene with player sprite

**Deliverables:**
- Main game scene structure

**Verification:**
```bash
# Press F5 in Godot
# Scene loads, player visible (even if static)
```

**Time:** 2 hours

---

### Day 2 (Tuesday): Player Movement

**Tasks:**
- [ ] Update scripts/entities/player.gd:
  - [ ] Implement _physics_process(delta)
  - [ ] Get input vector (WASD or arrows)
  - [ ] Calculate velocity = input * move_speed
  - [ ] Call move_and_slide()
- [ ] Add player sprite:
  - [ ] Create temporary colored rectangle or use placeholder sprite
  - [ ] Add Sprite2D node to player.tscn
  - [ ] Add CollisionShape2D (CircleShape2D or RectangleShape2D)
- [ ] Test movement:
  - [ ] Press F5
  - [ ] Use WASD to move
  - [ ] Verify smooth movement at 60 FPS
- [ ] Add camera follow:
  - [ ] Camera2D smoothing enabled
  - [ ] Zoom level: 1.5 (adjust to preference)

**Deliverables:**
- Working player movement

**Verification:**
```bash
# Run game (F5)
# Player moves with WASD
# Camera follows smoothly
```

**Time:** 3 hours

---

### Day 3 (Wednesday): Game Controller

**Tasks:**
- [ ] Create scripts/game/wasteland.gd
- [ ] Attach to wasteland.tscn root node
- [ ] Implement _ready():
  - [ ] Get references to player, containers
  - [ ] Connect to GameState signals
  - [ ] Initialize game state
- [ ] Implement game loop:
  - [ ] Start wave 1
  - [ ] Track time (GameState.game_time)
  - [ ] Update HUD (wave number, score)
- [ ] Add pause functionality:
  - [ ] Detect "pause" input action
  - [ ] Set tree paused: get_tree().paused = true
  - [ ] Show pause menu (placeholder for now)

**Deliverables:**
- Game controller managing game state

**Verification:**
```bash
# Run game
# Press Escape - game pauses
# GameState.current_wave == 1
```

**Time:** 3 hours

---

### Day 4 (Thursday): HUD Setup

**Tasks:**
- [ ] Create scenes/ui/hud.tscn:
  - [ ] CanvasLayer → VBoxContainer
  - [ ] HealthBar (ProgressBar)
  - [ ] WaveLabel (Label) - "Wave: 1"
  - [ ] ScoreLabel (Label) - "Score: 0"
  - [ ] TimerLabel (Label) - "Time: 00:00"
- [ ] Create scripts/ui/hud.gd:
  - [ ] Connect to GameState signals
  - [ ] Update labels when state changes
  - [ ] Update health bar when player health changes
- [ ] Instance in wasteland.tscn
- [ ] Test HUD updates:
  - [ ] Manually change GameState values
  - [ ] Verify HUD reflects changes

**Deliverables:**
- Functional HUD

**Verification:**
```bash
# Run game
# HUD shows wave, score, time
# Values update when GameState changes
```

**Time:** 3 hours

---

### Day 5 (Friday): Polish & Testing

**Tasks:**
- [ ] Add player health system:
  - [ ] Player.take_damage() method
  - [ ] Player.died signal
  - [ ] Connect to game controller
  - [ ] Test death (manually call take_damage(1000))
- [ ] Add basic boundaries:
  - [ ] StaticBody2D walls around play area
  - [ ] Player collides with walls
- [ ] Performance test:
  - [ ] Enable profiler (Debug → Profiler)
  - [ ] Verify 60 FPS
  - [ ] Check frame time < 16.67ms
- [ ] Create docs/godot/week-8-prototype.md:
  - [ ] Document playable prototype
  - [ ] Controls guide
  - [ ] Known issues
- [ ] Commit Week 8 work

**Deliverables:**
- Playable prototype (move player, see HUD, basic boundaries)

**Verification:**
```bash
# Run game
# Player moves smoothly at 60 FPS
# HUD updates
# Player can't leave play area
```

**Time:** 4 hours

---

### Week 8 Wrap-Up

**End-of-week checklist:**
- [ ] Main game scene created
- [ ] Player movement working (WASD)
- [ ] Camera following player
- [ ] Game controller managing state
- [ ] HUD showing wave, score, time, health
- [ ] Pause functionality
- [ ] 60 FPS performance
- [ ] Playable prototype ready

**Time this week:** ~15 hours

**Milestone:** DECISION POINT - Compare with React Native prototype

---

## Week 9: Enemy System & Wave Spawning

**Goal:** Enemies spawning in waves with correct scaling

### Day 1 (Monday): Wave System Setup

**Tasks:**
- [ ] Create scripts/systems/wave_system.gd
- [ ] Implement signals:
  - [ ] wave_started(wave_number: int)
  - [ ] wave_complete(wave_number: int)
  - [ ] enemy_spawned(enemy: Enemy)
- [ ] Implement start_waves() method
- [ ] Implement _start_wave(wave_number: int) method
- [ ] Calculate enemy count per wave:
  - [ ] Formula: min(5 + wave * 2, 50)
  - [ ] Same as TypeScript version
- [ ] Add to wasteland.tscn as child node

**Deliverables:**
- WaveSystem skeleton

**Verification:**
```bash
# WaveSystem node exists in scene
# Can call WaveSystem.start_waves()
```

**Time:** 3 hours

---

### Day 2 (Tuesday): Enemy Spawning

**Tasks:**
- [ ] Update wave_system.gd:
  - [ ] _load_enemy_templates() method
  - [ ] Loads all .tres from resources/enemies/
  - [ ] Stores in enemy_templates array
- [ ] Implement _spawn_enemy() method:
  - [ ] Weighted random selection (spawn_weight)
  - [ ] Load enemy scene: enemy_scene.instantiate()
  - [ ] Set enemy.enemy_resource
  - [ ] Call enemy.initialize(current_wave)
  - [ ] Set random spawn position (off-screen)
  - [ ] Emit enemy_spawned signal
- [ ] Implement _get_random_spawn_position() helper:
  - [ ] Spawn around player at 600px distance
  - [ ] Random angle using randf() * TAU

**Deliverables:**
- Enemy spawning working

**Verification:**
```gdscript
# Call WaveSystem._spawn_enemy()
# Enemy appears off-screen
# Enemy has correct stats for current wave
```

**Time:** 4 hours

---

### Day 3 (Wednesday): Wave Progression

**Tasks:**
- [ ] Implement wave completion logic:
  - [ ] Track enemies_alive count
  - [ ] Decrement on enemy death
  - [ ] When enemies_alive == 0: wave_complete signal
- [ ] Implement automatic wave progression:
  - [ ] After wave_complete, wait 5 seconds
  - [ ] Start next wave
  - [ ] Increment GameState.current_wave
- [ ] Test wave progression:
  - [ ] Start wave 1
  - [ ] Manually kill all enemies (player.queue_free() all enemies)
  - [ ] Verify wave 2 starts after 5 seconds
- [ ] Add max_waves check (50 waves max)

**Deliverables:**
- Automatic wave progression

**Verification:**
```bash
# Run game
# Wave 1 completes
# After 5s, Wave 2 starts
# HUD shows "Wave: 2"
```

**Time:** 3 hours

---

### Day 4 (Thursday): Enemy AI & Movement

**Tasks:**
- [ ] Update scripts/entities/enemy.gd:
  - [ ] Add AI in _physics_process(delta)
  - [ ] Get player position: get_tree().get_first_node_in_group("player").position
  - [ ] Calculate direction: (player_pos - position).normalized()
  - [ ] Set velocity: direction * current_speed
  - [ ] Call move_and_slide()
- [ ] Add player collision:
  - [ ] Detect collision with player (using Area2D or body_entered)
  - [ ] Deal damage to player
  - [ ] Push back enemy slightly
- [ ] Test enemy movement:
  - [ ] Enemies chase player
  - [ ] Enemies stop when reaching player
  - [ ] Collision deals damage

**Deliverables:**
- Enemy AI chasing player

**Verification:**
```bash
# Run game
# Enemies spawn and move toward player
# When touching player, health decreases
```

**Time:** 4 hours

---

### Day 5 (Friday): Wave Balancing & Testing

**Tasks:**
- [ ] Test wave scaling:
  - [ ] Manually set GameState.current_wave = 10
  - [ ] Spawn enemy, check stats
  - [ ] Verify health/speed/damage scaled correctly
- [ ] Test spawn weights:
  - [ ] Spawn 20 enemies in wave 1
  - [ ] Count types: ~60% Shambler, ~30% Runner, ~10% Juggernaut
  - [ ] Adjust weights if needed
- [ ] Performance test:
  - [ ] Spawn 50 enemies
  - [ ] Check FPS (should maintain 60)
  - [ ] Profile frame time
- [ ] Create docs/godot/wave-system-design.md:
  - [ ] Document spawn formulas
  - [ ] Document wave scaling
  - [ ] Document balancing decisions
- [ ] Commit Week 9 work

**Deliverables:**
- Balanced wave system with 60 FPS at 50 enemies

**Verification:**
```bash
# Spawn 50 enemies
# FPS stays at 60
# CPU usage < 50%
```

**Time:** 3 hours

---

### Week 9 Wrap-Up

**End-of-week checklist:**
- [ ] WaveSystem spawning enemies
- [ ] Weighted random selection working
- [ ] Wave scaling correct (HP, speed, damage)
- [ ] Enemy AI chasing player
- [ ] Wave progression automatic
- [ ] 60 FPS with 50 enemies
- [ ] Collision damage working

**Time this week:** ~17 hours

---

## Week 10: Weapon System & Projectiles

**Goal:** Player can fire weapons, projectiles damage enemies

### Day 1 (Monday): Projectile Pool Setup

**Tasks:**
- [ ] Create scripts/systems/projectile_pool.gd
- [ ] Implement pool initialization:
  - [ ] const POOL_SIZE = 100
  - [ ] Load projectile scene
  - [ ] Instantiate 100 projectiles
  - [ ] Add to pool array
  - [ ] Set all inactive/invisible
- [ ] Implement get_projectile() method:
  - [ ] Find first inactive projectile
  - [ ] Return it
  - [ ] If all active, push_warning() and return null
- [ ] Implement return_projectile(projectile) method
- [ ] Track active_count
- [ ] Add to wasteland.tscn as child of ProjectileContainer

**Deliverables:**
- ProjectilePool working

**Verification:**
```gdscript
var proj = ProjectilePool.get_projectile()
assert(proj != null)
ProjectilePool.return_projectile(proj)
```

**Time:** 3 hours

---

### Day 2 (Tuesday): Projectile Movement & Collision

**Tasks:**
- [ ] Update scripts/entities/projectile.gd:
  - [ ] Implement activate(start_pos, direction, weapon) method
  - [ ] Implement _physics_process(delta):
    - [ ] Move: position += velocity * delta
    - [ ] Track distance_traveled
    - [ ] If distance >= range: deactivate()
  - [ ] Implement _on_body_entered(body) callback:
    - [ ] If body is Enemy: body.take_damage(damage)
    - [ ] Call deactivate()
- [ ] Add Area2D collision:
  - [ ] Add CollisionShape2D to projectile.tscn
  - [ ] Set layer/mask for enemy detection
  - [ ] Connect body_entered signal
- [ ] Test projectile:
  - [ ] Manually activate projectile
  - [ ] Verify movement
  - [ ] Verify deactivation at range
  - [ ] Verify collision with enemy

**Deliverables:**
- Projectile movement and collision working

**Verification:**
```bash
# Activate projectile toward enemy
# Projectile moves
# On hit: enemy takes damage, projectile deactivates
```

**Time:** 4 hours

---

### Day 3 (Wednesday): Weapon System

**Tasks:**
- [ ] Create scripts/systems/weapon_system.gd
- [ ] Implement fire_weapon(weapon, origin, direction) method:
  - [ ] Get projectile from pool
  - [ ] If projectile != null: projectile.activate(...)
  - [ ] Else: push_warning("Pool exhausted")
- [ ] Add to wasteland.tscn as child node
- [ ] Test firing:
  - [ ] Manually call fire_weapon()
  - [ ] Verify projectile spawns and moves
  - [ ] Verify pool usage

**Deliverables:**
- WeaponSystem firing projectiles

**Verification:**
```gdscript
WeaponSystem.fire_weapon(weapon_resource, player_pos, Vector2.RIGHT)
# Projectile fires to the right
```

**Time:** 2 hours

---

### Day 4 (Thursday): Player Weapon Firing

**Tasks:**
- [ ] Update scripts/entities/player.gd:
  - [ ] Add equipped_weapon variable (load rusty_pistol.tres)
  - [ ] Add last_fire_time variable
  - [ ] Implement _process(delta) for weapon firing:
    - [ ] Check Input.is_action_pressed("fire")
    - [ ] Check fire_rate cooldown
    - [ ] Get aim direction (mouse position)
    - [ ] Call WeaponSystem.fire_weapon()
    - [ ] Update last_fire_time
- [ ] Test player firing:
  - [ ] Run game
  - [ ] Click mouse to fire
  - [ ] Verify projectiles fire toward mouse
  - [ ] Verify fire rate respected

**Deliverables:**
- Player firing weapon with mouse

**Verification:**
```bash
# Run game
# Click mouse rapidly
# Projectiles fire at correct fire_rate (not every frame)
```

**Time:** 3 hours

---

### Day 5 (Friday): Weapon Testing & Polish

**Tasks:**
- [ ] Test all 23 weapons:
  - [ ] Create weapon test scene
  - [ ] Load each weapon .tres
  - [ ] Fire with player
  - [ ] Verify damage, fire_rate, projectile_speed, range
- [ ] Test premium weapons:
  - [ ] quantum_disruptor.tres
  - [ ] void_cannon.tres
  - [ ] Verify they work correctly
- [ ] Performance test:
  - [ ] Fire 100 projectiles rapidly
  - [ ] Verify 60 FPS maintained
  - [ ] Check projectile pool usage (should stay < 100)
- [ ] Add visual/audio feedback (optional):
  - [ ] Muzzle flash sprite (simple)
  - [ ] Placeholder sound effect
- [ ] Commit Week 10 work

**Deliverables:**
- All weapons working, 60 FPS with 100 projectiles

**Verification:**
```bash
# Rapid fire for 10 seconds
# FPS stays at 60
# No "pool exhausted" warnings
```

**Time:** 4 hours

---

### Week 10 Wrap-Up

**End-of-week checklist:**
- [ ] ProjectilePool with 100 projectiles
- [ ] Projectile movement and collision working
- [ ] WeaponSystem firing projectiles
- [ ] Player firing with mouse
- [ ] Fire rate cooldown working
- [ ] All 23 weapons tested
- [ ] 60 FPS with 100 active projectiles

**Time this week:** ~16 hours

---

## Week 11: Items, Pickups & Drops

**Goal:** Items drop from enemies, player can collect

### Day 1 (Monday): Pickup Entity

**Tasks:**
- [ ] Update scripts/entities/pickup.gd:
  - [ ] Add item_resource property
  - [ ] Add Sprite2D for visual (colored square for now)
  - [ ] Add Area2D for collision detection
  - [ ] Implement _on_body_entered(body) callback:
    - [ ] If body is Player: _apply_item_effect(body)
    - [ ] Emit collected signal
    - [ ] queue_free()
- [ ] Create scenes/entities/pickup.tscn:
  - [ ] Root: Area2D (class_name Pickup)
  - [ ] Sprite2D (colored square, 16x16)
  - [ ] CollisionShape2D (CircleShape2D, radius 8)
  - [ ] Attach pickup.gd script
- [ ] Test pickup:
  - [ ] Manually instance pickup in game
  - [ ] Player walks over it
  - [ ] Verify collected signal emits
  - [ ] Pickup disappears

**Deliverables:**
- Pickup entity with collision detection

**Verification:**
```bash
# Run game
# Spawn pickup near player
# Walk over it - pickup disappears
```

**Time:** 3 hours

---

### Day 2 (Tuesday): Item Effects

**Tasks:**
- [ ] Update scripts/entities/pickup.gd:
  - [ ] Implement _apply_item_effect(player: Player) method:
    - [ ] Switch on item_resource.item_type:
      - [ ] "health": player.heal(item_resource.value)
      - [ ] "scrap": BankingService.add_currency("scrap", item_resource.value)
      - [ ] "powerup": apply temporary buff (placeholder)
- [ ] Add player.heal() method to player.gd:
  - [ ] current_health = min(max_health, current_health + amount)
  - [ ] Emit health_changed signal
- [ ] Test item effects:
  - [ ] Create health pickup
  - [ ] Collect it
  - [ ] Verify player health increases
  - [ ] Create scrap pickup
  - [ ] Verify currency increases

**Deliverables:**
- Item effects applying to player

**Verification:**
```gdscript
# Collect health pack
# Player health increases
# HUD shows updated health
```

**Time:** 3 hours

---

### Day 3 (Wednesday): Drop System

**Tasks:**
- [ ] Create scripts/systems/drop_system.gd
- [ ] Implement drop tables:
  - [ ] Load from JSON or hard-code for now
  - [ ] Each enemy type has drop table:
    - [ ] { "item_id": "scrap_small", "chance": 0.5 }
    - [ ] { "item_id": "health_pack", "chance": 0.2 }
- [ ] Implement roll_drop(enemy_type, wave) method:
  - [ ] For each entry in drop table:
    - [ ] If randf() <= chance: add item_id to drops array
  - [ ] Return drops array
- [ ] Implement spawn_pickup(item_id, position) method:
  - [ ] Load pickup scene
  - [ ] Set item_resource
  - [ ] Set position
  - [ ] Add to PickupContainer
- [ ] Configure as autoload: "DropSystem"

**Deliverables:**
- DropSystem with drop tables

**Verification:**
```gdscript
var drops = DropSystem.roll_drop("scrap_shambler", 5)
print(drops)  # Should show array of item IDs
```

**Time:** 3 hours

---

### Day 4 (Thursday): Enemy Death Drops

**Tasks:**
- [ ] Update scripts/entities/enemy.gd:
  - [ ] In die() method:
    - [ ] Call DropSystem.roll_drop(enemy_type, current_wave)
    - [ ] For each dropped item:
      - [ ] DropSystem.spawn_pickup(item_id, position)
- [ ] Test drops:
  - [ ] Kill enemy
  - [ ] Verify pickups spawn at enemy position
  - [ ] Collect pickups
  - [ ] Verify effects apply
- [ ] Test drop rates:
  - [ ] Kill 20 enemies
  - [ ] Count drops
  - [ ] Verify roughly matches probabilities

**Deliverables:**
- Enemies dropping items on death

**Verification:**
```bash
# Kill enemy
# Item(s) spawn at death location
# Collect them
# Currency/health increases
```

**Time:** 3 hours

---

### Day 5 (Friday): Item System Polish

**Tasks:**
- [ ] Add item visuals:
  - [ ] Create simple sprites for each item type
  - [ ] Health: red cross
  - [ ] Scrap: gray/brown square
  - [ ] Powerup: blue star
- [ ] Add pickup animations (optional):
  - [ ] Float/bob up and down (Tween)
  - [ ] Fade in when spawned
- [ ] Add pickup sound effects (placeholder)
- [ ] Test full loop:
  - [ ] Kill enemy → item drops → collect → effect applies
- [ ] Performance test:
  - [ ] Spawn 50 pickups
  - [ ] Verify 60 FPS
- [ ] Commit Week 11 work

**Deliverables:**
- Complete item/pickup system

**Verification:**
```bash
# Play for 5 minutes
# Kill many enemies
# Collect items
# All effects work
# 60 FPS maintained
```

**Time:** 4 hours

---

### Week 11 Wrap-Up

**End-of-week checklist:**
- [ ] Pickup entity with collision
- [ ] Item effects (health, scrap, powerups)
- [ ] DropSystem with drop tables
- [ ] Enemies dropping items on death
- [ ] All item types working
- [ ] 60 FPS with 50 pickups on screen

**Time this week:** ~16 hours

**Milestone:** CORE GAMEPLAY COMPLETE ✅

---

## Week 12: UI Theme & Core Screens

**Goal:** Themed UI with main menu, character select, settings

### Day 1 (Monday): Theme Creation

**Tasks:**
- [ ] Create resources/theme/main_theme.tres (right-click → New Resource → Theme)
- [ ] Configure colors from designTokens.ts:
  - [ ] bg_dark: #0a0a0a
  - [ ] surface: #1a1a1a
  - [ ] primary: #10b981
  - [ ] danger: #ef4444
  - [ ] text_primary: #ffffff
  - [ ] text_secondary: #9ca3af
- [ ] Add font:
  - [ ] Import default font or similar to web version
  - [ ] Add to theme
- [ ] Configure StyleBoxFlat for Button:
  - [ ] Normal: surface color
  - [ ] Hover: lighter surface
  - [ ] Pressed: primary color
  - [ ] Disabled: dark gray
- [ ] Configure Panel StyleBox
- [ ] Configure Label font colors

**Deliverables:**
- Complete theme resource

**Verification:**
```bash
# In Godot: Project Settings → GUI → Theme → main_theme.tres
# All UI elements use theme colors
```

**Time:** 3 hours

---

### Day 2 (Tuesday): Main Menu

**Tasks:**
- [ ] Create scenes/ui/main_menu.tscn:
  - [ ] Root: Control (full rect)
  - [ ] Background: ColorRect (bg_dark color)
  - [ ] VBoxContainer (centered):
    - [ ] Title Label: "Scrap Survivor"
    - [ ] PlayButton: "Play"
    - [ ] SettingsButton: "Settings"
    - [ ] QuitButton: "Quit"
  - [ ] VersionLabel (bottom-right): "v0.1.0"
- [ ] Create scripts/ui/main_menu.gd:
  - [ ] Connect button.pressed signals
  - [ ] _on_play_pressed(): change_scene to character_select
  - [ ] _on_settings_pressed(): show settings modal
  - [ ] _on_quit_pressed(): get_tree().quit()
- [ ] Set as main scene temporarily
- [ ] Test menu:
  - [ ] All buttons clickable
  - [ ] Theme applied correctly

**Deliverables:**
- Main menu with working buttons

**Verification:**
```bash
# Run game (F5)
# Main menu appears
# Click Play - goes to character select (will error for now)
```

**Time:** 3 hours

---

### Day 3 (Wednesday): Character Select Screen

**Tasks:**
- [ ] Create scenes/ui/character_select.tscn:
  - [ ] Background
  - [ ] Title: "Select Character"
  - [ ] ScrollContainer → VBoxContainer (for character list)
  - [ ] NewCharacterButton: "+ Create New"
  - [ ] BackButton: "Back to Menu"
- [ ] Create scripts/ui/character_select.gd:
  - [ ] _ready(): load user characters from CharacterService
  - [ ] Display character list (name, level)
  - [ ] _on_character_selected(character): save to GameState, start game
  - [ ] _on_new_character_pressed(): show character creation modal
- [ ] Create placeholder character list item scene
- [ ] Test:
  - [ ] Load characters from database
  - [ ] Display in list
  - [ ] Select character → start game

**Deliverables:**
- Character select screen

**Verification:**
```bash
# Run game → Play
# Character select loads
# Shows existing characters or "Create New"
```

**Time:** 4 hours

---

### Day 4 (Thursday): Settings Screen

**Tasks:**
- [ ] Create scenes/ui/settings.tscn:
  - [ ] Panel container (modal)
  - [ ] TabContainer:
    - [ ] Graphics tab:
      - [ ] Resolution dropdown
      - [ ] Fullscreen checkbox
      - [ ] VSync checkbox
    - [ ] Audio tab:
      - [ ] Master volume slider
      - [ ] SFX volume slider
      - [ ] Music volume slider
    - [ ] Controls tab:
      - [ ] Key bindings (placeholder for now)
  - [ ] ApplyButton
  - [ ] CancelButton
- [ ] Create scripts/ui/settings.gd:
  - [ ] Load settings from config file (ConfigFile class)
  - [ ] Apply changes to DisplayServer and AudioServer
  - [ ] Save to user://settings.cfg
- [ ] Test:
  - [ ] Change resolution - window resizes
  - [ ] Toggle fullscreen - works
  - [ ] Adjust volume - audio changes

**Deliverables:**
- Settings screen with working options

**Verification:**
```bash
# Open settings
# Change resolution
# Click Apply
# Window resizes correctly
```

**Time:** 4 hours

---

### Day 5 (Friday): Pause Menu & Polish

**Tasks:**
- [ ] Create scenes/ui/pause_menu.tscn:
  - [ ] Panel (semi-transparent background)
  - [ ] Title: "Paused"
  - [ ] ResumeButton
  - [ ] SettingsButton
  - [ ] QuitButton
- [ ] Create scripts/ui/pause_menu.gd:
  - [ ] _on_resume_pressed(): unpause game
  - [ ] _on_settings_pressed(): open settings
  - [ ] _on_quit_pressed(): return to main menu
- [ ] Integrate with wasteland.gd:
  - [ ] Detect "pause" input action
  - [ ] Instance pause_menu.tscn
  - [ ] Set get_tree().paused = true
- [ ] Test pause functionality
- [ ] Apply theme to all screens
- [ ] Commit Week 12 work

**Deliverables:**
- Pause menu and all core screens themed

**Verification:**
```bash
# Run game
# Press Escape - pause menu appears
# Game pauses
# Resume works
```

**Time:** 3 hours

---

### Week 12 Wrap-Up

**End-of-week checklist:**
- [ ] Theme resource created
- [ ] Main menu with Play/Settings/Quit
- [ ] Character select screen
- [ ] Settings screen (graphics, audio, controls)
- [ ] Pause menu
- [ ] All screens use consistent theme
- [ ] Navigation between screens works

**Time this week:** ~17 hours

---

## Week 13: Game-Specific UI

**Goal:** Workshop, Shop, HUD improvements

### Day 1 (Monday): Workshop UI - Layout

**Tasks:**
- [ ] Create scenes/ui/workshop.tscn:
  - [ ] Background
  - [ ] Title: "Workshop"
  - [ ] TabContainer:
    - [ ] Crafting tab
    - [ ] Fusion tab
    - [ ] Repair tab
  - [ ] Inventory panel (left side)
  - [ ] Recipe/Result panel (right side)
  - [ ] CraftButton
  - [ ] BackButton
- [ ] Create scripts/ui/workshop.gd:
  - [ ] Load player inventory from CharacterService
  - [ ] Display items in inventory list
- [ ] Test layout:
  - [ ] All panels visible
  - [ ] Tabs switchable

**Deliverables:**
- Workshop UI layout

**Verification:**
```bash
# Open workshop scene
# Tabs switch
# Layout looks correct
```

**Time:** 4 hours

---

### Day 2 (Tuesday): Workshop UI - Crafting Logic

**Tasks:**
- [ ] Create CraftingService (if not already exists from TypeScript port)
- [ ] Implement crafting in workshop.gd:
  - [ ] Load recipes from JSON or resources
  - [ ] Display available recipes
  - [ ] Check materials required
  - [ ] _on_craft_pressed():
    - [ ] Validate materials
    - [ ] Call CraftingService.craft_item()
    - [ ] Update inventory
    - [ ] Show result
- [ ] Test crafting:
  - [ ] Select recipe
  - [ ] Verify materials checked
  - [ ] Craft item
  - [ ] Verify inventory updated

**Deliverables:**
- Working crafting system in UI

**Verification:**
```bash
# Open workshop → Crafting
# Select recipe
# Click Craft
# Item added to inventory
```

**Time:** 4 hours

---

### Day 3 (Wednesday): Shop UI

**Tasks:**
- [ ] Create scenes/ui/shop.tscn:
  - [ ] Title: "Shop"
  - [ ] Shop inventory list (4-6 items)
  - [ ] Each item:
    - [ ] Icon
    - [ ] Name
    - [ ] Price
    - [ ] BuyButton
  - [ ] Currency display (scrap balance)
  - [ ] RerollButton
  - [ ] BackButton
- [ ] Create scripts/ui/shop.gd:
  - [ ] _ready(): load shop inventory
  - [ ] _on_buy_pressed(item):
    - [ ] Check balance
    - [ ] Deduct currency
    - [ ] Add item to inventory
  - [ ] _on_reroll_pressed():
    - [ ] Call ShopRerollService.reroll_shop()
    - [ ] Refresh inventory display
- [ ] Test shop:
  - [ ] Buy item with sufficient funds
  - [ ] Try buy with insufficient funds (should fail)
  - [ ] Reroll shop (inventory changes)

**Deliverables:**
- Working shop UI

**Verification:**
```bash
# Open shop
# Buy item - balance decreases
# Reroll - shop inventory changes
```

**Time:** 4 hours

---

### Day 4 (Thursday): HUD Improvements

**Tasks:**
- [ ] Update scenes/ui/hud.tscn:
  - [ ] Add minimap (optional, placeholder)
  - [ ] Add weapon display (current weapon icon)
  - [ ] Add ammo/durability bar (if applicable)
  - [ ] Add combo meter (if applicable)
  - [ ] Improve health bar visual (gradient, border)
- [ ] Update scripts/ui/hud.gd:
  - [ ] Listen to weapon changes
  - [ ] Update weapon display
  - [ ] Add damage numbers (floating text on enemy hit)
- [ ] Test HUD:
  - [ ] All elements visible during gameplay
  - [ ] Updates responsive

**Deliverables:**
- Enhanced HUD

**Verification:**
```bash
# Play game
# HUD shows all relevant info
# Damage numbers appear on hit
```

**Time:** 3 hours

---

### Day 5 (Friday): UI Polish & Integration

**Tasks:**
- [ ] Add transitions between screens:
  - [ ] Fade in/out using Tween
  - [ ] Slide animations for modals
- [ ] Add button hover effects (already in theme, verify working)
- [ ] Add button click sounds (placeholder)
- [ ] Test full UI flow:
  - [ ] Main menu → Character select → Game
  - [ ] Pause → Settings → Resume
  - [ ] Game → Workshop → Back
  - [ ] Game → Shop → Back
- [ ] Create docs/godot/ui-navigation.md:
  - [ ] Document all screens
  - [ ] Document navigation flow
- [ ] Commit Week 13 work

**Deliverables:**
- Complete, polished UI system

**Verification:**
```bash
# Navigate through all screens
# All transitions smooth
# No navigation bugs
```

**Time:** 3 hours

---

### Week 13 Wrap-Up

**End-of-week checklist:**
- [ ] Workshop UI with crafting/fusion/repair
- [ ] Shop UI with buy/reroll
- [ ] Enhanced HUD
- [ ] UI transitions and animations
- [ ] All screens navigable
- [ ] UI documentation complete

**Time this week:** ~18 hours

---

## Week 14: Testing Infrastructure

**Goal:** Comprehensive test suite with automated tests

### Day 1 (Monday): GUT Framework Setup

**Tasks:**
- [ ] Install GUT (Godot Unit Test) from AssetLib:
  - [ ] Search "GUT"
  - [ ] Install latest version
  - [ ] Restart Godot
- [ ] Configure GUT:
  - [ ] Create .gutconfig.json in project root
  - [ ] Set test directory: "res://scripts/tests/"
  - [ ] Set prefix: "test_"
- [ ] Create test runner scene:
  - [ ] addons/gut/gut_cmdln.tscn
  - [ ] Configure output
- [ ] Test GUT installation:
  - [ ] Create dummy test: scripts/tests/test_example.gd
  - [ ] Run: Godot → Run GUT tests
  - [ ] Verify test runs

**Deliverables:**
- GUT framework installed and working

**Verification:**
```bash
# In Godot: Bottom panel → GUT
# Run Tests
# Example test passes
```

**Time:** 2 hours

---

### Day 2 (Tuesday): Service Unit Tests

**Tasks:**
- [ ] Create test files for all services:
  - [ ] scripts/tests/test_stat_service.gd
  - [ ] scripts/tests/test_banking_service.gd
  - [ ] scripts/tests/test_recycler_service.gd
  - [ ] scripts/tests/test_character_service.gd
- [ ] Write tests for StatService:
  - [ ] test_calculate_damage()
  - [ ] test_calculate_health()
  - [ ] test_apply_stat_modifiers()
- [ ] Write tests for BankingService:
  - [ ] test_add_currency()
  - [ ] test_subtract_currency()
  - [ ] test_negative_balance_prevention()
- [ ] Run all tests
- [ ] Fix any failures

**Deliverables:**
- Unit tests for core services

**Verification:**
```bash
# Run GUT tests
# All service tests pass
```

**Time:** 5 hours

---

### Day 3 (Wednesday): Game System Tests

**Tasks:**
- [ ] Create integration tests:
  - [ ] scripts/tests/test_wave_system.gd
  - [ ] scripts/tests/test_weapon_system.gd
  - [ ] scripts/tests/test_drop_system.gd
- [ ] Write WaveSystem tests:
  - [ ] test_enemy_count_calculation()
  - [ ] test_wave_scaling()
  - [ ] test_spawn_weights()
- [ ] Write WeaponSystem tests:
  - [ ] test_fire_weapon()
  - [ ] test_projectile_pool()
- [ ] Write DropSystem tests:
  - [ ] test_drop_probability()
  - [ ] test_spawn_pickup()
- [ ] Run all tests

**Deliverables:**
- Integration tests for game systems

**Verification:**
```bash
# All game system tests pass
```

**Time:** 5 hours

---

### Day 4 (Thursday): Performance Tests

**Tasks:**
- [ ] Create performance test scene:
  - [ ] scenes/tests/performance_test.tscn
  - [ ] Spawn 150 enemies
  - [ ] Fire 100 projectiles
  - [ ] Spawn 50 pickups
- [ ] Measure performance:
  - [ ] FPS (should be 60)
  - [ ] Frame time (should be < 16.67ms)
  - [ ] Memory usage (should be < 250MB)
- [ ] Create automated performance test script:
  - [ ] Run for 60 seconds
  - [ ] Record FPS every second
  - [ ] Report min/avg/max FPS
  - [ ] Fail if min FPS < 45
- [ ] Run performance tests on Mac M4 Max

**Deliverables:**
- Performance test suite

**Verification:**
```bash
# Run performance test
# Min FPS >= 45
# Avg FPS >= 55
# Test passes
```

**Time:** 4 hours

---

### Day 5 (Friday): CI/CD Setup & Documentation

**Tasks:**
- [ ] Create .github/workflows/godot-tests.yml:
  - [ ] Run on push to main
  - [ ] Install Godot headless
  - [ ] Run GUT tests
  - [ ] Report results
- [ ] Test CI workflow:
  - [ ] Push commit
  - [ ] Verify workflow runs on GitHub Actions
  - [ ] Verify tests pass
- [ ] Create docs/testing/test-guide.md:
  - [ ] How to write tests
  - [ ] How to run tests
  - [ ] Test coverage goals
  - [ ] Performance benchmarks
- [ ] Create test coverage report (if GUT supports)
- [ ] Commit Week 14 work

**Deliverables:**
- CI/CD pipeline with automated tests

**Verification:**
```bash
# Push to GitHub
# GitHub Actions runs tests
# All tests pass
```

**Time:** 4 hours

---

### Week 14 Wrap-Up

**End-of-week checklist:**
- [ ] GUT framework installed
- [ ] Unit tests for all services
- [ ] Integration tests for game systems
- [ ] Performance test suite
- [ ] CI/CD pipeline running tests
- [ ] Test documentation complete

**Time this week:** ~20 hours

---

## Week 15: Mobile Export & Performance

**Goal:** iOS and Android builds with 60 FPS performance

### Day 1 (Monday): iOS Export Setup

**Tasks:**
- [ ] Download iOS export templates:
  - [ ] Godot → Editor → Manage Export Templates
  - [ ] Download official 4.4 templates
- [ ] Configure iOS export:
  - [ ] Project → Export → Add → iOS
  - [ ] Bundle Identifier: com.yourname.scrapsurvivor
  - [ ] Team ID: (from Apple Developer account)
  - [ ] Provisioning Profile: Select your profile
  - [ ] Icons: Add from assets/icons/
  - [ ] Splash screens: Add
- [ ] Test export:
  - [ ] Export to Xcode project
  - [ ] Open in Xcode
  - [ ] Build for simulator
  - [ ] Run on simulator

**Deliverables:**
- iOS export configuration

**Verification:**
```bash
# Export iOS project
# Build succeeds in Xcode
# Runs on simulator
```

**Time:** 3 hours

---

### Day 2 (Tuesday): iOS Device Testing

**Tasks:**
- [ ] Connect iPhone to Mac
- [ ] Configure signing in Xcode:
  - [ ] Select development team
  - [ ] Enable automatic signing
- [ ] Build and run on iPhone:
  - [ ] Select iPhone device
  - [ ] Click Run
  - [ ] Wait for install
- [ ] Test on device:
  - [ ] Touch controls work
  - [ ] Performance (FPS)
  - [ ] Audio
  - [ ] Save/load
- [ ] Profile performance:
  - [ ] Xcode → Product → Profile
  - [ ] Use Instruments (Time Profiler)
  - [ ] Check CPU usage
  - [ ] Check FPS (should be 60)
- [ ] Fix any iOS-specific bugs

**Deliverables:**
- Working iOS build on device

**Verification:**
```bash
# Game runs on iPhone
# 60 FPS sustained
# No crashes
```

**Time:** 5 hours

---

### Day 3 (Wednesday): Android Export Setup

**Tasks:**
- [ ] Install Android SDK (if not installed):
  - [ ] Download Android Studio
  - [ ] Install SDK
  - [ ] Configure ANDROID_HOME environment variable
- [ ] Install Java JDK 17+
- [ ] Configure Android export:
  - [ ] Project → Export → Add → Android
  - [ ] Package: com.yourname.scrapsurvivor
  - [ ] Keystore: Create debug.keystore
  - [ ] Min SDK: 21 (Android 5.0)
  - [ ] Target SDK: 34 (latest)
  - [ ] Icons: Add adaptive icons
- [ ] Export APK:
  - [ ] Export as debug APK
  - [ ] Install on Android device or emulator:
    - [ ] adb install scrap-survivor.apk

**Deliverables:**
- Android export configuration

**Verification:**
```bash
# Export APK succeeds
# Install on Android device
# App launches
```

**Time:** 4 hours

---

### Day 4 (Thursday): Android Device Testing

**Tasks:**
- [ ] Install APK on Android device (or emulator)
- [ ] Test on device:
  - [ ] Touch controls work
  - [ ] Performance (FPS)
  - [ ] Audio
  - [ ] Save/load
- [ ] Profile performance:
  - [ ] Android Studio → Profiler
  - [ ] Check CPU usage
  - [ ] Check FPS
  - [ ] Check memory usage
- [ ] Test on multiple Android versions (if possible):
  - [ ] Android 9 (API 28)
  - [ ] Android 12 (API 31)
  - [ ] Android 14 (API 34)
- [ ] Fix any Android-specific bugs

**Deliverables:**
- Working Android build on device

**Verification:**
```bash
# Game runs on Android
# 60 FPS sustained
# No crashes
```

**Time:** 5 hours

---

### Day 5 (Friday): Performance Optimization

**Tasks:**
- [ ] Analyze profiler data from iOS and Android
- [ ] Identify performance bottlenecks
- [ ] Optimize if needed:
  - [ ] Reduce draw calls (batch sprites)
  - [ ] Optimize collision checks (spatial partitioning)
  - [ ] Reduce garbage collection (object pooling)
- [ ] Test optimizations:
  - [ ] Spawn 150 entities
  - [ ] Verify 60 FPS on both platforms
- [ ] Create performance comparison doc:
  - [ ] docs/testing/mobile-performance.md
  - [ ] iOS results
  - [ ] Android results
  - [ ] Optimizations applied
- [ ] Commit Week 15 work

**Deliverables:**
- Optimized mobile builds with 60 FPS

**Verification:**
```bash
# iOS: 60 FPS with 150 entities
# Android: 60 FPS with 150 entities
```

**Time:** 3 hours

---

### Week 15 Wrap-Up

**End-of-week checklist:**
- [ ] iOS export configured
- [ ] iOS build running on device at 60 FPS
- [ ] Android export configured
- [ ] Android build running on device at 60 FPS
- [ ] Performance profiling complete
- [ ] Optimizations applied
- [ ] Mobile performance documentation

**Time this week:** ~20 hours

**Milestone:** Mobile builds ready for beta testing ✅

---

## Week 16: Deployment & Launch Prep

**Goal:** Production builds, beta testing, launch preparation

### Day 1 (Monday): Production Build Configuration

**Tasks:**
- [ ] iOS release configuration:
  - [ ] Create distribution provisioning profile
  - [ ] Configure release signing in Xcode
  - [ ] Set optimization level: Speed
  - [ ] Disable debug symbols (or include DSYM for crash reports)
  - [ ] Set version number: 0.1.0
  - [ ] Set build number: 1
- [ ] Android release configuration:
  - [ ] Create release keystore (store securely!)
  - [ ] Configure release signing in Godot
  - [ ] Generate signed APK/AAB
  - [ ] Obfuscate code (ProGuard)
  - [ ] Set version code: 1
  - [ ] Set version name: 0.1.0
- [ ] Test release builds:
  - [ ] Install on devices
  - [ ] Verify no debug info visible
  - [ ] Performance same as debug

**Deliverables:**
- Production build configurations

**Verification:**
```bash
# Export release builds
# Install on devices
# No debug info shown
# Performance optimal
```

**Time:** 4 hours

---

### Day 2 (Tuesday): TestFlight Beta (iOS)

**Tasks:**
- [ ] Export iOS app for distribution:
  - [ ] Archive in Xcode
  - [ ] Validate app
  - [ ] Upload to App Store Connect
- [ ] Configure in App Store Connect:
  - [ ] Create app listing
  - [ ] Add screenshots (can be placeholder)
  - [ ] Add app description
  - [ ] Set privacy policy URL
  - [ ] Enable TestFlight
- [ ] Invite beta testers:
  - [ ] Add internal testers (yourself)
  - [ ] Add external testers (5-10 friends)
- [ ] Distribute beta build
- [ ] Monitor crash reports in App Store Connect

**Deliverables:**
- TestFlight beta live

**Verification:**
```bash
# Beta testers receive invite
# Can install app via TestFlight
# App runs correctly
```

**Time:** 4 hours

---

### Day 3 (Wednesday): Google Play Internal Testing (Android)

**Tasks:**
- [ ] Create Google Play Console account (if not exists)
- [ ] Create app listing:
  - [ ] App name: Scrap Survivor
  - [ ] Package name: com.yourname.scrapsurvivor
  - [ ] Default language: English
- [ ] Upload AAB (Android App Bundle):
  - [ ] Create internal testing release
  - [ ] Upload signed AAB
  - [ ] Set version: 0.1.0 (1)
- [ ] Configure app details:
  - [ ] Short description
  - [ ] Full description
  - [ ] Screenshots
  - [ ] Privacy policy
- [ ] Add internal testers:
  - [ ] Create test user group
  - [ ] Add 5-10 testers
- [ ] Publish to internal testing
- [ ] Monitor crash reports in Play Console

**Deliverables:**
- Google Play internal testing live

**Verification:**
```bash
# Testers receive link
# Can install via Play Store
# App runs correctly
```

**Time:** 4 hours

---

### Day 4 (Thursday): Beta Testing & Bug Fixes

**Tasks:**
- [ ] Collect feedback from beta testers:
  - [ ] Create feedback form (Google Forms)
  - [ ] Share with testers
- [ ] Monitor crash reports:
  - [ ] App Store Connect (iOS)
  - [ ] Google Play Console (Android)
- [ ] Fix critical bugs:
  - [ ] Prioritize crashes
  - [ ] Fix game-breaking bugs
  - [ ] Ignore minor issues (for v1.1)
- [ ] Upload new beta builds if needed
- [ ] Verify fixes on devices

**Deliverables:**
- Critical bugs fixed

**Verification:**
```bash
# No crashes reported
# Game playable from start to finish
```

**Time:** 6 hours

---

### Day 5 (Friday): Launch Preparation & Documentation

**Tasks:**
- [ ] Create launch checklist:
  - [ ] App Store submission requirements
  - [ ] Google Play submission requirements
  - [ ] Marketing materials ready
  - [ ] Support email configured
- [ ] Prepare App Store listing:
  - [ ] Final screenshots (5-10 per device size)
  - [ ] App preview video (optional)
  - [ ] Finalize description
  - [ ] Add keywords for ASO
- [ ] Prepare Play Store listing:
  - [ ] Same as App Store
- [ ] Create support documentation:
  - [ ] docs/launch/support-faq.md
  - [ ] docs/launch/privacy-policy.md
  - [ ] docs/launch/terms-of-service.md
- [ ] Set up analytics (if not done):
  - [ ] Firebase Analytics or Amplitude
  - [ ] Track key events (game start, wave complete, death)
- [ ] Final commit for Week 16
- [ ] Create Git tag: v0.1.0

**Deliverables:**
- Launch-ready builds and documentation

**Verification:**
```bash
# All launch materials ready
# Beta testing complete
# No critical bugs
# Ready for public release
```

**Time:** 6 hours

---

### Week 16 Wrap-Up

**End-of-week checklist:**
- [ ] Production builds configured (iOS + Android)
- [ ] TestFlight beta live
- [ ] Google Play internal testing live
- [ ] Beta feedback collected
- [ ] Critical bugs fixed
- [ ] App Store listing ready
- [ ] Google Play listing ready
- [ ] Support documentation ready
- [ ] Analytics configured
- [ ] v0.1.0 tagged and ready to ship

**Time this week:** ~24 hours

**MIGRATION COMPLETE** ✅🎉

---

## Summary

**Total time investment:** ~280 hours (over 16 weeks)

**Key deliverables:**
- ✅ Working Godot 4 project
- ✅ All game systems ported (weapons, enemies, waves, items)
- ✅ All services ported (banking, character, sync, tier, recycler, shop)
- ✅ Complete UI (menu, character select, HUD, workshop, shop, settings)
- ✅ Comprehensive test suite (unit + integration + performance)
- ✅ iOS build at 60 FPS
- ✅ Android build at 60 FPS
- ✅ Beta testing complete
- ✅ Launch-ready

**Next steps:**
1. Publish to App Store (review: 24-48 hours)
2. Publish to Google Play (review: ~2-7 days)
3. Monitor analytics and crash reports
4. Plan v0.2.0 features based on feedback

---

**You did it!** 🚀

From React+Phaser to native Godot 4 in 16 weeks. Your game now runs at 60 FPS on both iOS and Android with all original features preserved.
