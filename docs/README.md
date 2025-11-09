# Scrap Survivor - Documentation

**Welcome to the Scrap Survivor Godot documentation!**

This directory contains all game design, system specifications, and technical architecture documentation needed to understand and work on Scrap Survivor.

---

## Quick Start

**New to the project?** Start here:

1. Read [GAME-DESIGN.md](GAME-DESIGN.md) - Complete game design overview
2. Review [core-architecture/DATA-MODEL.md](core-architecture/DATA-MODEL.md) - How data is stored
3. Check [tier-experiences/](tier-experiences/) - Understand the monetization tiers

**Working on a specific system?** Jump to:
- Combat mechanics → [game-design/systems/COMBAT-SYSTEM.md](game-design/systems/COMBAT-SYSTEM.md)
- Character types → [game-design/systems/CHARACTER-SYSTEM.md](game-design/systems/CHARACTER-SYSTEM.md)
- Inventory/Items → [game-design/systems/INVENTORY-SYSTEM.md](game-design/systems/INVENTORY-SYSTEM.md)
- Shop/Reroll → [game-design/systems/SHOP-SYSTEM.md](game-design/systems/SHOP-SYSTEM.md)
- Workshop (Repair/Fusion/Craft) → [game-design/systems/WORKSHOP-SYSTEM.md](game-design/systems/WORKSHOP-SYSTEM.md)
- Hub navigation → [game-design/systems/HUB-SYSTEM.md](game-design/systems/HUB-SYSTEM.md)

**Working on architecture?** See:
- Data model & storage → [core-architecture/DATA-MODEL.md](core-architecture/DATA-MODEL.md)
- Design patterns → [core-architecture/PATTERN-CATALOG.md](core-architecture/PATTERN-CATALOG.md)
- Monetization system → [core-architecture/monetization-architecture.md](core-architecture/monetization-architecture.md)
- UI design tokens → [core-architecture/ui-design-system.md](core-architecture/ui-design-system.md)

**Working on migration?** See:
- Original migration plan → [migration/GODOT-MIGRATION-PLAN.md](migration/GODOT-MIGRATION-PLAN.md)
- Week 6 completion → [migration/week6-days1-3-completion.md](migration/week6-days1-3-completion.md)

---

## Documentation Structure

```
docs/
├── README.md (you are here)
├── GAME-DESIGN.md (6000+ line consolidation - start here!)
├── core-architecture/
│   ├── DATA-MODEL.md (CRITICAL: How data is stored)
│   ├── monetization-architecture.md (Tier system specification)
│   ├── PATTERN-CATALOG.md (TypeScript → GDScript patterns)
│   └── ui-design-system.md (Design tokens)
├── game-design/
│   └── systems/
│       ├── COMBAT-SYSTEM.md (Wave-based combat, enemy scaling)
│       ├── CHARACTER-SYSTEM.md (Types, progression, slots)
│       ├── INVENTORY-SYSTEM.md (Auto-active inventory)
│       ├── SHOP-SYSTEM.md (Pricing, reroll mechanics)
│       ├── WORKSHOP-SYSTEM.md (Repair, fusion, crafting)
│       └── HUB-SYSTEM.md (Scrapyard navigation)
├── tier-experiences/
│   ├── free-tier.md (3 slots, 15 weapons, full gameplay)
│   ├── premium-tier.md ($4.99 one-time, 15 slots, 23 weapons)
│   └── subscription-tier.md ($2.99/month, Quantum features)
└── migration/
    ├── GODOT-MIGRATION-PLAN.md (Original 16-week plan)
    ├── godot-quick-start.md (Week 1 guide)
    ├── godot-weekly-action-items.md (Detailed weekly tasks)
    └── week6-days1-3-completion.md (SaveSystem implementation)
```

---

## Key Concepts

### Game Loop
1. **Select Character** → Load from Hub roster
2. **Fight Waves** → Survive escalating enemies
3. **Collect Loot** → Get weapons, items, scrap
4. **Die & Progress** → Permanent upgrades, better gear
5. **Workshop** → Repair, fuse, craft gear
6. **Repeat** → Get stronger, reach higher waves

### Storage Architecture
- **Weapons**: Stored in `character.weapons` array
- **Items** (armor/consumable/trinket): Stored separately via `InventoryService`
- **ALWAYS query both** for complete inventory
- See [DATA-MODEL.md](core-architecture/DATA-MODEL.md) for details

### Tier System
- **Free**: 3 character slots, 15 weapons, full gameplay
- **Premium**: $4.99 one-time, 15 slots, 23 weapons, premium items
- **Subscription**: $2.99/month, 50 slots, Quantum Banking/Storage, Mr. Fix-It
- Referral rewards can unlock Premium for free (5 successful referrals)

### Item Types (DO NOT invent others!)
```gdscript
type ItemType = 'weapon' | 'armor' | 'consumable' | 'trinket'
```

### Rarity Levels
```gdscript
type ItemRarity = 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
```

---

## For AI Assistants

**CRITICAL: Read these files FIRST before working on character/inventory features:**

1. [core-architecture/DATA-MODEL.md](core-architecture/DATA-MODEL.md) - Explains hybrid storage (weapons vs items)
2. [GAME-DESIGN.md](GAME-DESIGN.md) - Complete game design spec
3. [tier-experiences/](tier-experiences/) - Feature gating by tier

**Common Mistakes to Avoid:**
- ❌ Assuming `character.items` exists (it doesn't - use `InventoryService`)
- ❌ Only checking `character.weapons` for workshop (must check both weapons AND items)
- ❌ Inventing item types beyond weapon/armor/consumable/trinket
- ❌ Treating `isPremium` and `rarity` as the same thing (they're independent)

**Service Patterns:**
```gdscript
# Get character (includes weapons)
var character = await CharacterService.get_character(character_id)

# Get items (armor, consumables, trinkets)
var items = await InventoryService.get_character_inventory(character_id)

# Full inventory = weapons + items
var full_inventory = character.weapons + items
```

---

## Migration Progress

**Week 6 Status:**
- ✅ Days 1-3: SaveSystem + 4 quality validators
- 🚧 Days 4-5: CharacterService (local-only)
- 📝 SaveMigrator deferred (YAGNI - no v2 format exists yet)

See [migration/week6-days1-3-completion.md](migration/week6-days1-3-completion.md) for details.

---

## External Resources

**Original TypeScript Repo:**
- GitHub: `~/Developer/scrap-survivor` (monorepo with React Native game)
- This Godot port migrates the game logic to GDScript

**Godot Documentation:**
- [Godot 4.4 Docs](https://docs.godotengine.org/en/4.4/)
- [GDScript Reference](https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/index.html)

**Testing:**
- [GUT (Godot Unit Test)](https://github.com/bitwes/Gut)
- Test naming: `*_test.gd` pattern

---

## Contributing

**Before making changes:**
1. Read relevant system docs from [game-design/systems/](game-design/systems/)
2. Check [DATA-MODEL.md](core-architecture/DATA-MODEL.md) for storage patterns
3. Review [PATTERN-CATALOG.md](core-architecture/PATTERN-CATALOG.md) for GDScript conventions
4. Write tests following `*_test.gd` naming convention
5. Run quality validators before committing

**Architecture Principles:**
- **Local-First**: Save to disk before cloud sync
- **Signal-Driven**: Use Godot signals for decoupling
- **Service Layer**: Autoload singletons for business logic
- **Auto-Active Inventory**: All owned items contribute stats
- **YAGNI**: Don't build features until needed

---

## Document Status

**Last Updated:** November 9, 2025
**Migrated From:** `~/Developer/scrap-survivor/docs/` (original TypeScript repo)
**Maintained By:** Alan + AI Assistants

**Document Quality:**
- ✅ GAME-DESIGN.md - Canonical consolidated reference
- ✅ DATA-MODEL.md - Canonical storage reference
- ✅ Core architecture docs - Verified accurate
- ✅ Game system docs - Synced with TypeScript implementation
- ✅ Tier experience docs - Current as of monetization v2

---

**Questions?** Check [GAME-DESIGN.md](GAME-DESIGN.md) first - it has everything!
