# Scrap Survivor - Glossary

**Purpose:** Authoritative terminology definitions for Scrap Survivor development.

**Last Updated:** 2025-11-27

---

## Character Types

| Term | Definition |
|------|------------|
| **Scavenger** | Free tier character. +10% Scrap drops, +15 pickup range. "Knows where the good junk is" |
| **Rustbucket** | Free tier tank character. +30 Max HP, +5 Armor, -15% Speed, 4 weapon slots. "More patches than original parts" |
| **Hotshot** | Free tier glass cannon. +20% Damage, +10% Crit, -20 Max HP. "Burns bright, burns fast" |
| **Tinkerer** | Premium tier character. +1 Stack limit (all rarities), -10% Damage. "Can always fit one more gadget" |
| **Salvager** | Premium tier resource character. +50% Component yield, +25% Shop discount, 5 weapon slots. "Sees value in everything" |
| **Overclocked** | Subscription tier high-risk character. +25% Attack Speed, +15% Damage, takes 5% Max HP damage per wave. "Pushed past factory specs" |

**Deprecated Types (DO NOT USE):**
- ~~Tank~~ → Use Rustbucket
- ~~Commando~~ → Removed
- ~~Mutant~~ → Removed
- ~~One Armed~~ → Removed (Brotato ripoff)
- ~~Weapon Master~~ → Removed (Brotato ripoff)

---

## Monetization Tiers

| Term | Definition |
|------|------------|
| **Free Tier** | Default tier. 3 character slots, 3 character types, 10% death penalty. |
| **Premium Tier** | One-time purchase ($2.99-$9.99). 10 character slots, 5 character types, 5% death penalty, cloud backup. |
| **Subscription Tier** | Monthly subscription ($1.99-$4.99). Unlimited slots, 6 character types, 2% death penalty, Mr. Fix-It, idle systems. |

---

## Item Rarities

| Term | Color | Stack Limit | Drop Rate |
|------|-------|-------------|-----------|
| **Common** | Gray | 5 | ~60% |
| **Uncommon** | Green | 4 | ~25% |
| **Rare** | Blue | 3 | ~10% |
| **Epic** | Purple | 2 | ~4% |
| **Legendary** | Orange | 1 | ~1% |

---

## Item Types

| Term | Definition |
|------|------------|
| **Weapon** | Equipped combat items. Stored in `character.weapons`. Max 6 slots (varies by character type). |
| **Armor** | Passive defensive items. Stored via `InventoryService`. |
| **Consumable** | Single-use items with effects. Stored via `InventoryService`. |
| **Trinket** | Passive stat bonus items. Stored via `InventoryService`. |

**DO NOT invent other item types.**

---

## Item Tiers (Recycling)

| Term | Base Component Yield |
|------|---------------------|
| **Tier 1** | 8 components |
| **Tier 2** | 20 components |
| **Tier 3** | 40 components |
| **Tier 4** | 80 components |

Luck bonus: Up to +50% at 100 luck stat.

---

## Game Systems

| Term | Definition |
|------|------------|
| **Scrapyard** | The hub area between runs. Contains Barracks, Workshop, Shop. |
| **Wasteland** | The combat zone where waves occur. |
| **Wave** | A timed enemy spawn phase. Survive waves to progress. |
| **Run** | A single combat session from start to death/extraction. |
| **Death Penalty** | Durability loss on equipped items when character dies. Varies by tier (10%/5%/2%). |

---

## Workshop Systems

| Term | Definition |
|------|------------|
| **Repair** | Restore item durability using components. |
| **Fusion** | Combine items to increase rarity/stats. |
| **Crafting** | Create new items from components and blueprints. |
| **Recycling** | Convert unwanted items to components. |

---

## Economy Terms

| Term | Definition |
|------|------------|
| **Scrap** | Primary in-run currency. Dropped by enemies, used in shops. |
| **Components** | Crafting currency from recycling. Used in Workshop. |
| **Quantum Coins** | Subscription-tier premium currency for Quantum Banking. |

---

## Technical Terms

| Term | Definition |
|------|------------|
| **Service** | Autoload singleton handling business logic (e.g., `CharacterService`, `BankingService`). |
| **Resource** | Godot resource class for data (e.g., `WeaponResource`, `EnemyResource`). |
| **Scene** | Godot `.tscn` file defining node hierarchy. |
| **Signal** | Godot event system for decoupled communication. |
| **Autoload** | Globally accessible singleton in Godot. |

---

## UI Components

| Term | Definition |
|------|------------|
| **CharacterTypeCard** | Reusable card component showing character type info with selection/creation modes. |
| **MobileModal** | iOS HIG-compliant modal component. Use via `ModalFactory`. |
| **IconButton** | Standardized button with icon support. |
| **SurvivorStatusPanel** | HUD component showing player stats. |

---

## Development Terms

| Term | Definition |
|------|------------|
| **GUT** | Godot Unit Test framework. Test files: `*_test.gd`. |
| **Parent-First Protocol** | MANDATORY: Always `add_child()` before configuring dynamic Control nodes. Prevents iOS SIGKILL. |
| **Marvel Snap Law** | Design principle: Characters are the visual stars; UI serves them. |
| **Blocking Protocol** | Git commits require explicit user approval. See `.system/CLAUDE_RULES.md`. |

---

## Acronyms

| Acronym | Meaning |
|---------|---------|
| **HIG** | Human Interface Guidelines (Apple iOS design standards) |
| **SIGKILL** | iOS watchdog termination signal (0x8badf00d = "ate bad food") |
| **YAGNI** | "You Aren't Gonna Need It" - Don't build features until needed |
| **SQA** | Software Quality Assurance |
| **QA** | Quality Assurance (testing) |
| **MVP** | Minimum Viable Product |
| **CTA** | Call to Action (button/prompt encouraging user action) |

---

## File Naming Conventions

| Pattern | Purpose |
|---------|---------|
| `*_service.gd` | Service layer autoloads |
| `*_resource.gd` | Resource class definitions |
| `*_test.gd` | GUT test files |
| `*.tscn` | Godot scene files |
| `*.tres` | Godot resource instances |

---

## Document Types

| Term | Location | Purpose |
|------|----------|---------|
| **System Doc** | `docs/game-design/systems/` | Authoritative game system specs |
| **Week Plan** | `docs/migration/` | Weekly implementation roadmap |
| **Lesson Learned** | `docs/lessons-learned/` | Post-mortem patterns |
| **Session Handoff** | `.system/NEXT_SESSION.md` | Session continuity state |

---

**See Also:**
- [README.md](README.md) - Documentation index
- [GAME-DESIGN.md](GAME-DESIGN.md) - Complete game design
- [CHARACTER-SYSTEM.md](game-design/systems/CHARACTER-SYSTEM.md) - Character type details
