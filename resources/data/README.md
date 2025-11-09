# Game Configuration Data (JSON)

This directory contains game configuration data exported from the TypeScript source code. These JSON files serve as the data source for creating Godot Resource files in Week 3 of the migration.

## Files

### weapons.json
**Count:** 23 weapons
**Purpose:** Weapon configurations including damage, fire rate, range, and premium status.

**Structure:**
```json
{
  "id": "weapon_id",
  "name": "Display Name",
  "damage": 15,
  "fire_rate": 3,
  "projectile_speed": 400,
  "range": 300,
  "is_premium": false,
  "rarity": "common",
  "sprite": "sprite_name"
}
```

**Fields:**
- `id` (string): Unique weapon identifier
- `name` (string): Display name for UI
- `damage` (number): Base damage per hit
- `fire_rate` (number): Shots per second
- `projectile_speed` (number): Pixels per second
- `range` (number): Max distance in pixels
- `is_premium` (boolean): Requires premium unlock
- `rarity` (string): common | uncommon | rare | epic | legendary
- `sprite` (string): Sprite asset reference

**Distribution:**
- Free weapons: 15 (65%)
- Premium weapons: 8 (35%)

### items.json
**Count:** 31 items
**Purpose:** Item templates for upgrades, consumables, and craftable weapons.

**Structure:**
```json
{
  "id": "item_id",
  "name": "Display Name",
  "description": "Item description",
  "type": "upgrade",
  "rarity": "common",
  "stats": {
    "maxHp": 20,
    "damage": 5
  },
  "base_damage": 8,
  "damage_type": "ranged"
}
```

**Fields:**
- `id` (string): Unique item identifier
- `name` (string): Display name
- `description` (string): Item description for UI
- `type` (string): upgrade | item | weapon
- `rarity` (string): common | uncommon | rare | epic | legendary
- `stats` (object, optional): Stat modifiers
  - Supports: maxHp, damage, speed, armor, luck, lifeSteal, scrapGain, dodge
  - Can have negative values for trade-offs
- Weapon-specific fields (for type="weapon"):
  - `base_damage` (number)
  - `damage_type` (string): ranged | melee
  - `fire_rate` (number)
  - `projectile_speed` (number)
  - `base_range` (number)
  - `max_durability` (number)
  - `max_fuse_tier` (number)
  - `base_value` (number)

**Types:**
- upgrade: 4 items (permanent stat improvements)
- item: 12 items (consumables and modifiers)
- weapon: 15 items (craftable weapons)

### enemies.json
**Count:** 3 enemy types
**Purpose:** Enemy type definitions with base stats and spawn configuration.

**Structure:**
```json
{
  "id": "enemy_type",
  "name": "Display Name",
  "color": "#ff0000",
  "size": 20,
  "base_hp": 20,
  "base_speed": 30,
  "base_damage": 5,
  "base_value": 5,
  "spawn_weight": 60,
  "drop_chance": 0.3
}
```

**Fields:**
- `id` (string): Enemy type identifier (basic | fast | tank)
- `name` (string): Display name
- `color` (string): Hex color (#RRGGBB)
- `size` (number): Visual size in pixels
- `base_hp` (number): Base health points
- `base_speed` (number): Base movement speed
- `base_damage` (number): Base contact damage
- `base_value` (number): Base scrap reward
- `spawn_weight` (number): Relative spawn probability (out of 100)
- `drop_chance` (number): Item drop probability (0.0-1.0)

**Enemy Types:**
1. **Scrap Shambler** (basic)
   - 60% spawn weight
   - Balanced stats
   - Common swarm enemy

2. **Rust Runner** (fast)
   - 30% spawn weight
   - Low HP, high speed
   - Tactical challenge

3. **Junk Juggernaut** (tank)
   - 10% spawn weight
   - High HP, slow, high damage
   - Rare threat

**Wave Scaling Formulas** (from TypeScript source):
- HP: `base_hp * (1 + (wave - 1) * 0.25)` (+25% per wave)
- Speed: `base_speed * (1 + (wave - 1) * 0.05)` (+5% per wave)
- Damage: `base_damage * (1 + (wave - 1) * 0.10)` (+10% per wave)
- Value: `base_value * (1 + (wave - 1) * 0.20)` (+20% per wave)

### game_constants.json
**Count:** 33 configuration values
**Purpose:** Global game constants for balance, display, and monetization.

**Structure:**
```json
{
  "viewport": {...},
  "asset_config": {...},
  "monetization": {...},
  "game_balance": {...}
}
```

**Sections:**

#### viewport
Display and rendering settings.
- `width`: 1024px (game viewport width)
- `height`: 768px (game viewport height)
- `background_color`: #1a1a1a (main background)
- `background_dark`: #2a2a2a (darker variant)

#### asset_config
Asset loading and scaling configuration.
- `sprite_size`: 64px (base sprite dimensions)
- `scale_factor`: 1 (global scale multiplier)
- `texture_format`: "png" (image format)
- `enemy_texture_size`: 32px (enemy sprite size)
- `player_texture_size`: 30px (player sprite size)

#### monetization
Premium features and preview system.
- `premium_price`: 2.99 (USD)
- `free_limits`:
  - `characters`: 2
  - `weapons`: 15
  - `max_waves`: 15
  - `workshop_sessions`: 3
  - `save_slots`: 1
- `premium_previews`:
  - `first_session`: 7200000ms (2 hours)
  - `achievement`: 86400000ms (24 hours)
  - `video_ad`: 1800000ms (30 minutes)
  - `weekly_rotation`: 604800000ms (168 hours)

#### game_balance
Core gameplay balance values.

**Player:**
- `base_health`: 100
- `base_speed`: 200
- `base_damage`: 10
- `base_pickup_range`: 100
- `base_scrap_gain`: 100
- `min_damage`: 1
- `base_crit_damage`: 150
- `base_max_weapons`: 6

**Enemies:**
- `base_scrap_value`: 5
- `base_damage`: 5

**Waves:**
- `base_enemy_count`: 5 (starting wave size)
- `scaling_factor`: 1.2 (enemy count multiplier per wave)
- `max_wave`: 50 (maximum wave number)
- `wave_duration`: 60 (seconds between waves)

## Export Script

All JSON files are generated using the export script:

```bash
cd ~/Developer/scrap-survivor
npx tsx scripts/export-configs.ts
```

**Options:**
```bash
# Export all configs
npx tsx scripts/export-configs.ts

# Export specific configs
npx tsx scripts/export-configs.ts weapons
npx tsx scripts/export-configs.ts items
npx tsx scripts/export-configs.ts enemies
npx tsx scripts/export-configs.ts constants
```

**Source Location:** `~/Developer/scrap-survivor/scripts/export-configs.ts`

## Data Integrity

All JSON files have been validated:
- ✅ Valid JSON syntax
- ✅ All expected counts match
- ✅ Required fields present
- ✅ Data types correct
- ✅ Spot-checks match TypeScript source

See validation reports in `docs/migration/week2-day*-validation.md`

## Next Steps (Week 3)

These JSON files will be used to create Godot Resource files:
- `WeaponResource.gd` → 23 .tres files in `resources/weapons/`
- `EnemyResource.gd` → 3 .tres files in `resources/enemies/`
- `ItemResource.gd` → 31 .tres files in `resources/items/`
- Game constants will be loaded into autoload singletons

## Naming Conventions

**TypeScript → JSON conversions:**
- camelCase → snake_case (fireRate → fire_rate)
- Hex numbers → Hex strings (0xff0000 → "#ff0000")
- isPremium → is_premium
- baseHp → base_hp

This follows Godot/GDScript naming conventions.

## Maintenance

When game balance or configuration changes in the TypeScript source:

1. Update the TypeScript source files
2. Run the export script
3. Verify changes in JSON files
4. Update corresponding Godot Resources (Week 3+)

## References

- **TypeScript source:** `~/Developer/scrap-survivor/packages/core/src/`
- **Export script:** `~/Developer/scrap-survivor/scripts/export-configs.ts`
- **Migration plan:** `docs/godot-weekly-action-items.md`
- **Validation reports:** `docs/migration/week2-day*-validation.md`
