# Scrap Survivor - Documentation Index

**Welcome to the Scrap Survivor Godot documentation!**

This directory contains all game design, system specifications, and technical architecture documentation needed to understand and work on Scrap Survivor.

**Last Updated:** 2025-11-27 (Week 17 Complete, Week 18 Ready)

---

## 🚀 Quick Start

**New to the project?** Start here:

1. Read [GAME-DESIGN.md](GAME-DESIGN.md) - Complete game design overview
2. Review [core-architecture/DATA-MODEL.md](core-architecture/DATA-MODEL.md) - How data is stored
3. Check [GLOSSARY.md](GLOSSARY.md) - Key terminology definitions

**Starting a new session?** Check:
- [../.system/NEXT_SESSION.md](../.system/NEXT_SESSION.md) - Session continuity handoff
- [../.system/CLAUDE_RULES.md](../.system/CLAUDE_RULES.md) - Development protocols

---

## 📂 Documentation Structure

```
docs/
├── README.md                    # You are here - main index
├── GLOSSARY.md                  # Terminology definitions
├── GAME-DESIGN.md               # Complete game design overview
│
├── core-architecture/           # Technical architecture
│   ├── DATA-MODEL.md            # CRITICAL: How data is stored
│   ├── monetization-architecture.md
│   ├── PATTERN-CATALOG.md       # GDScript patterns
│   └── ui-design-system.md      # Design tokens
│
├── game-design/systems/         # AUTHORITATIVE system specs
│   ├── CHARACTER-SYSTEM.md      # 6 character types, progression
│   ├── COMBAT-SYSTEM.md         # Wave-based combat, enemies
│   ├── INVENTORY-SYSTEM.md      # Items, death penalties, yields
│   ├── ITEM-STATS-SYSTEM.md     # Rarities, stack limits
│   ├── SHOPS-SYSTEM.md          # Shop mechanics (Godot)
│   ├── WORKSHOP-SYSTEM.md       # Repair, fusion, crafting
│   └── HUB-SYSTEM.md            # Scrapyard navigation
│
├── tier-experiences/            # Monetization tiers
│   ├── free-tier.md             # 3 slots, full gameplay
│   ├── premium-tier.md          # $2.99-$9.99 one-time
│   └── subscription-tier.md     # $1.99-$4.99/month
│
├── migration/                   # Active week plans
│   ├── GODOT-MIGRATION-PLAN.md  # Original migration roadmap
│   ├── GODOT-MIGRATION-SUMMARY.md
│   ├── week17-plan.md           # Reference (recent patterns)
│   ├── week18-plan.md           # ACTIVE
│   ├── week19-plan.md           # UPCOMING
│   ├── week20-plan.md           # UPCOMING
│   └── week21-plan.md           # UPCOMING
│
├── lessons-learned/             # Post-mortems and patterns
│   └── *.md                     # Numbered lessons
│
└── archive/                     # Historical reference only
    ├── completed-weeks/         # Week 2-16 plans
    ├── experiments/             # Investigation docs
    ├── legacy-react-native/     # Pre-Godot migration docs
    └── brainstorm/              # Planning proposals
```

---

## 🎯 Authoritative Documents

These documents are the **source of truth** for their respective systems:

| System | Document | Key Contents |
|--------|----------|--------------|
| **Character Types** | [CHARACTER-SYSTEM.md](game-design/systems/CHARACTER-SYSTEM.md) | 6 types, stat modifiers, tier gating |
| **Inventory/Items** | [INVENTORY-SYSTEM.md](game-design/systems/INVENTORY-SYSTEM.md) | Death penalties, component yields |
| **Item Stats** | [ITEM-STATS-SYSTEM.md](game-design/systems/ITEM-STATS-SYSTEM.md) | Rarities, stack limits |
| **Data Storage** | [DATA-MODEL.md](core-architecture/DATA-MODEL.md) | Hybrid weapon/item storage |

---

## 🎮 Key Concepts

### Character Types (6 Total)

| Type | Tier | Special |
|------|------|---------|
| Scavenger | Free | +10% Scrap, +15 pickup range |
| Rustbucket | Free | +30 HP, +5 Armor, -15% Speed |
| Hotshot | Free | +20% Damage, +10% Crit, -20 HP |
| Tinkerer | Premium | +1 Stack limit, -10% Damage |
| Salvager | Premium | +50% Component yield, +25% Shop discount |
| Overclocked | Subscription | +25% Attack Speed, +15% Damage, 5% HP/wave |

### Tier System

| Tier | Price | Character Slots | Key Features |
|------|-------|-----------------|--------------|
| Free | $0 | 3 | Full gameplay, 3 character types |
| Premium | $2.99-$9.99 | 10 | +2 character types, reduced death penalty |
| Subscription | $1.99-$4.99/mo | Unlimited | +1 character type, Mr. Fix-It, idle systems |

### Death Penalty by Tier

| Tier | Durability Loss per Death |
|------|---------------------------|
| Free | 10% |
| Premium | 5% |
| Subscription | 2% |

### Item Rarities & Stack Limits

| Rarity | Color | Stack Limit |
|--------|-------|-------------|
| Common | Gray | 5 |
| Uncommon | Green | 4 |
| Rare | Blue | 3 |
| Epic | Purple | 2 |
| Legendary | Orange | 1 |

---

## 🔧 For AI Assistants

**CRITICAL: Read these files FIRST before working on features:**

1. [core-architecture/DATA-MODEL.md](core-architecture/DATA-MODEL.md) - Hybrid storage
2. [game-design/systems/CHARACTER-SYSTEM.md](game-design/systems/CHARACTER-SYSTEM.md) - Character types
3. [../.system/CLAUDE_RULES.md](../.system/CLAUDE_RULES.md) - Development protocols

**Common Mistakes to Avoid:**
- ❌ Using old character types (Tank, Commando, Mutant, One Armed, Weapon Master)
- ❌ Assuming `character.items` exists (use `InventoryService`)
- ❌ Only checking `character.weapons` for workshop (check both)
- ❌ Inventing item types beyond weapon/armor/consumable/trinket
- ❌ Manual .tscn editing without Godot editor validation

**Service Patterns:**
```gdscript
# Get character (includes weapons)
var character = CharacterService.get_character(character_id)

# Get items (armor, consumables, trinkets)
var items = InventoryService.get_character_inventory(character_id)

# Full inventory = weapons + items
var full_inventory = character.weapons + items
```

---

## 📅 Current Status

**Week 17:** ✅ Complete
- CharacterTypeCard component
- UI/UX polish
- Documentation audit

**Week 18:** 📋 Ready to Implement
- 6 character types with mechanics
- Try-before-buy conversion flow
- Premium/Subscription character gating

**See:** [migration/week18-plan.md](migration/week18-plan.md)

---

## 📚 Archive Notice

Documents in `docs/archive/` are **historical reference only**:
- `completed-weeks/` - Week 2-16 implementation plans
- `experiments/` - Bug investigations, research
- `legacy-react-native/` - Pre-Godot migration docs
- `brainstorm/` - Planning proposals

**Do not use archived documents as authoritative sources.**

---

## 🔗 External Resources

**Godot Documentation:**
- [Godot 4.5 Docs](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)

**Testing:**
- [GUT (Godot Unit Test)](https://github.com/bitwes/Gut)
- Test naming: `*_test.gd` pattern
- Run tests: `python3 .system/validators/godot_test_runner.py`

---

**Questions?** Check [GAME-DESIGN.md](GAME-DESIGN.md) first - it has the complete game design!
