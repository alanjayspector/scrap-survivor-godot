# Next Session Handoff

**Updated:** 2025-11-27
**Current Branch:** `main`
**Status:** Week 18 Phase 2 COMPLETE - Phase 3 NEXT

---

## IMMEDIATE NEXT ACTION

**Begin Phase 3: ShopService**

Phase 2 (Character Type System) is complete and tests passing.

---

## SESSION ACCOMPLISHMENTS

1. Created `scripts/data/character_type_database.gd` with 6 character types
2. Updated CharacterService to use CharacterTypeDatabase
3. Implemented weapon_slots, inventory_slots, special_mechanics per type
4. Created `scripts/tests/character_type_test.gd` (60+ tests)
5. Updated 15+ files to use new CharacterTypeDatabase
6. Removed obsolete `character_types_test.gd`
7. Tests passing: 787/811

---

## WEEK 18 PHASE ORDER

| Phase | Description | Est. Time | Status |
|-------|-------------|-----------|--------|
| **1** | Item Database + ItemService | 1.5h | ✅ COMPLETE |
| **2** | Character Type System | 1.5h | ✅ COMPLETE |
| **3** | ShopService | 1.5h | ⏭️ NEXT |
| **4** | InventoryService | 1.5h | PENDING |
| **5** | WeaponService Refactor | 1h | PENDING |
| **6** | Shop UI | 1.5h | PENDING |
| **7** | Integration & QA | 1h | PENDING |
| **8** | Try-Before-Buy | 2h | STRETCH |

---

## QUICK START PROMPT

```
Continue Week 18 Phase 3: ShopService.

Read (IN THIS ORDER):
1. .system/CLAUDE_RULES.md (ALWAYS read first - development protocols)
2. docs/migration/week18-plan.md (Phase 3 section)
3. docs/game-design/systems/SHOPS-SYSTEM.md (shop design spec)
4. scripts/services/item_service.gd (reference pattern)
5. scripts/data/item_database.gd (item data source)

Tasks:
1. Create scripts/services/shop_service.gd
2. Implement shop inventory with timed refresh (4h cycle)
3. Add tier-based item pools (FREE/PREMIUM/SUBSCRIPTION)
4. Create purchase flow with validation
5. Implement manual reroll with scrap cost
6. Create scripts/tests/shop_service_test.gd
```

---

## PHASE 2 DELIVERABLES (Reference)

**6 Character Types:**
| Type | Tier | Weapon Slots | Special Mechanic |
|------|------|--------------|------------------|
| Scavenger | FREE | 6 | +10% scrap drops, +15 pickup range |
| Rustbucket | FREE | 4 | +30 HP, +5 armor, -15% speed |
| Hotshot | FREE | 6 | +20% damage, +10% crit, -20 HP |
| Tinkerer | PREMIUM | 6 | +1 stack limit, -10% damage |
| Salvager | PREMIUM | 5 | +50% components, 25% shop discount |
| Overclocked | SUBSCRIPTION | 6 | +25% attack speed, +15% damage, 5% HP/wave |

**Files Created:**
- `scripts/data/character_type_database.gd` - Type definitions
- `scripts/tests/character_type_test.gd` - 60+ unit tests

**Files Updated:**
- `scripts/services/character_service.gd` - Uses CharacterTypeDatabase
- Multiple UI files updated for new character types

---

## KEY DOCUMENTS

- `docs/migration/week18-plan.md` - Master plan (v2.2)
- `docs/game-design/systems/SHOPS-SYSTEM.md` - Shop design
- `docs/game-design/systems/CHARACTER-SYSTEM.md` - Character types
- `.system/CLAUDE_RULES.md` - Development protocols

---

## ARCHITECTURE NOTES

### CharacterTypeDatabase Usage:
```gdscript
# Access type definition
var type_def = CharacterTypeDatabase.get_type("scavenger")

# Check tier access
var can_access = CharacterTypeDatabase.can_access_type("tinkerer", user_tier)

# Get slot limits
var weapon_slots = CharacterTypeDatabase.get_weapon_slots("rustbucket")  # Returns 4

# Get special mechanics
var mechanics = CharacterTypeDatabase.get_special_mechanics("scavenger")
# mechanics.scrap_drop_bonus = 0.10
```

### Character Data Structure (Updated):
```gdscript
{
    "id": "char_1",
    "character_type": "scavenger",
    "weapon_slots": 6,           # Per-type limit
    "inventory_slots": 30,       # Consistent across types
    "special_mechanics": {       # Type-specific abilities
        "scrap_drop_bonus": 0.10
    },
    "stats": { ... },
}
```

---

## KNOWN ISSUES / NOTES

1. **Silhouette Textures Missing**: New character types (hotshot, tinkerer, salvager, overclocked) need art assets. Tests skip these.

2. **Aura System Decoupled**: Old aura_type field removed from character data. Tests updated accordingly.

3. **Starting Items**: Passed in character_create_post context for InventoryService (Phase 4).

---

**Git Status:** Uncommitted Phase 2 changes
**Tests:** 787/811 passing (24 pending)
**Last Commit:** `2f18a0d` feat: implement Week 18 Phase 1 - Item Database & ItemService
