# Week 21 - Post-Run Flow + Meta Progression
## Complete Roguelite Loop

**Status:** PLANNING
**Date:** 2025-11-27
**Estimated Effort:** 4-6 hours
**Depends On:** Weeks 18-20 (Shop, Workshop)
**Focus:** Between-run progression and complete game loop

---

## 🎯 WEEK OBJECTIVE

Implement the post-run flow and meta-progression system that completes the roguelite loop: Run → Summary → Currency Conversion → Permanent Upgrades → Next Run.

### Design Principle

> **"Every Run Matters"** - Win or lose, players make permanent progress.

---

## 🧑‍⚖️ EXPERT PANEL

| Role | Focus Area |
|------|------------|
| **Sr Game Designer** | Progression curve, reward pacing, player motivation |
| **Sr Economy Designer** | Currency balance, exchange rates, upgrade costs |
| **Sr Product Manager** | Retention loop, engagement metrics |
| **Sr SQA Engineer** | Save/load validation, edge cases |
| **Sr Godot Developer** | Service architecture, hook integration |

---

## 📊 CURRENT STATE ANALYSIS

### What Will Exist (After Week 20)

| Component | Status | Notes |
|-----------|--------|-------|
| `ShopService` | ✅ Week 18 | Item purchasing |
| `InventoryService` | ✅ Week 18 | Item management |
| Workshop (full) | ✅ Weeks 19-20 | Repair, Fusion, Craft |
| `BankingService` | ✅ Existing | Currency management |
| `SaveService` | ✅ Existing | Persistence |
| Game over screen | ✅ Existing | Basic stats display |

### What's Missing

| Component | Priority | Notes |
|-----------|----------|-------|
| Post-run summary | **CRITICAL** | Enhanced game over |
| Chips currency | **CRITICAL** | Meta-progression currency |
| Scrap → Chips conversion | **CRITICAL** | Exchange at run end |
| `MetaProgressionService` | **CRITICAL** | Permanent upgrades |
| Upgrade Shop UI | HIGH | Spend Chips |

---

## 🎨 KEY DESIGN ELEMENTS

### Meta-Currency: Chips

**Theme:** Casino/gambling, "Cashing in" your run

**Exchange Rate:** 100 Scrap → 1 Chip

**Why Chips:**
- Distinct from Scrap (run currency)
- Fits junkpunk aesthetic
- Short word, fits UI
- "Cashing in" metaphor

### Upgrade Categories (9 upgrades)

**Starting Stats (3):**
| ID | Name | Effect/Tier | Max |
|----|------|-------------|-----|
| `starting_hp` | Toughened | +5 Max HP | 5 |
| `starting_damage` | Battle-Hardened | +1 Damage | 5 |
| `starting_speed` | Quick Feet | +10 Speed | 5 |

**Starting Resources (3):**
| ID | Name | Effect/Tier | Max |
|----|------|-------------|-----|
| `starting_scrap` | Nest Egg | +50 Starting Scrap | 5 |
| `starting_armor` | Thick Skin | +1 Armor | 5 |
| `scrap_magnet` | Scavenger | +5% Pickup Range | 5 |

**Shop Quality (3):**
| ID | Name | Effect/Tier | Max |
|----|------|-------------|-----|
| `shop_rare_chance` | Lucky Find | +2% Rare Chance | 5 |
| `shop_discount` | Haggler | -2% Shop Prices | 5 |
| `shop_reroll_discount` | Window Shopper | -10% Reroll Cost | 5 |

### Upgrade Costs (Exponential)

| Tier | Cost (Chips) | Cumulative |
|------|--------------|------------|
| 1 | 50 | 50 |
| 2 | 100 | 150 |
| 3 | 200 | 350 |
| 4 | 400 | 750 |
| 5 (MAX) | 800 | 1,550 |

**Math:**
- Average run earns ~1,000-2,000 Scrap = 10-20 Chips
- First upgrade (Tier 1): ~3-5 runs
- Max one upgrade (1,550 Chips): ~100+ runs

### Post-Run Summary

**Display:**
- Wave reached
- Enemies killed
- Damage dealt
- Survival time
- Scrap earned
- **Chips gained** (Scrap ÷ 100)
- XP gained
- Level progress
- "Upgrade Available!" notification

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: Chips Currency + Conversion (1-1.5 hours)
**Priority:** CRITICAL

#### Tasks

1. **Add Chips to BankingService**
   ```gdscript
   enum CurrencyType {
       SCRAP,
       COMPONENTS,
       CHIPS,  # NEW
       PREMIUM,
       NANITES
   }
   ```

2. **Create conversion function**
   ```gdscript
   # In BankingService or new MetaProgressionService
   const SCRAP_TO_CHIPS_RATE = 100

   func convert_scrap_to_chips(scrap_amount: int) -> int:
       var chips = scrap_amount / SCRAP_TO_CHIPS_RATE
       return chips

   func process_run_end(character_id: String) -> Dictionary:
       var scrap = get_balance(CurrencyType.SCRAP)
       var chips_earned = convert_scrap_to_chips(scrap)

       # Clear run scrap (or keep based on design)
       # subtract_currency(CurrencyType.SCRAP, scrap)

       # Award chips
       add_currency(CurrencyType.CHIPS, chips_earned)

       return {
           "scrap_converted": scrap,
           "chips_earned": chips_earned,
           "total_chips": get_balance(CurrencyType.CHIPS)
       }
   ```

3. **Persist Chips across sessions**
   - Add to SaveService
   - Load on app start

4. **Unit tests**
   - Conversion math
   - Currency addition
   - Persistence

**Success Criteria:**
- [ ] Chips currency exists
- [ ] Conversion at 100:1 rate
- [ ] Chips persist across sessions
- [ ] Unit tests passing

---

### Phase 2: MetaProgressionService (1.5-2 hours)
**Priority:** CRITICAL

#### Tasks

1. **Create MetaProgressionService**
   ```gdscript
   class_name MetaProgressionService
   extends Node

   signal upgrade_purchased(upgrade_id: String, new_tier: int)
   signal bonuses_applied(bonuses: Dictionary)

   const UPGRADES = {
       "starting_hp": {
           "name": "Toughened",
           "description": "+5 Max HP per tier",
           "max_tier": 5,
           "costs": [50, 100, 200, 400, 800],
           "bonus_per_tier": 5,
           "bonus_type": "flat",
           "stat": "max_hp"
       },
       "starting_damage": {
           "name": "Battle-Hardened",
           "description": "+1 Damage per tier",
           "max_tier": 5,
           "costs": [50, 100, 200, 400, 800],
           "bonus_per_tier": 1,
           "bonus_type": "flat",
           "stat": "damage"
       },
       # ... all 9 upgrades
   }

   var upgrade_tiers: Dictionary = {}  # upgrade_id → current_tier

   func _ready():
       _load_progress()

   func get_upgrade_tier(upgrade_id: String) -> int:
       return upgrade_tiers.get(upgrade_id, 0)

   func get_next_cost(upgrade_id: String) -> int:
       var tier = get_upgrade_tier(upgrade_id)
       var upgrade = UPGRADES[upgrade_id]
       if tier >= upgrade.max_tier:
           return -1  # Maxed
       return upgrade.costs[tier]

   func can_purchase(upgrade_id: String) -> bool:
       var cost = get_next_cost(upgrade_id)
       if cost < 0:
           return false
       return BankingService.get_balance(CurrencyType.CHIPS) >= cost

   func purchase_upgrade(upgrade_id: String) -> Dictionary:
       if not can_purchase(upgrade_id):
           return {"success": false, "error": "CANNOT_PURCHASE"}

       var cost = get_next_cost(upgrade_id)
       BankingService.subtract_currency(CurrencyType.CHIPS, cost)

       var new_tier = get_upgrade_tier(upgrade_id) + 1
       upgrade_tiers[upgrade_id] = new_tier

       _save_progress()
       upgrade_purchased.emit(upgrade_id, new_tier)

       return {"success": true, "new_tier": new_tier}

   func get_total_bonus(stat: String) -> float:
       var total = 0.0
       for upgrade_id in UPGRADES:
           var upgrade = UPGRADES[upgrade_id]
           if upgrade.stat == stat:
               var tier = get_upgrade_tier(upgrade_id)
               total += upgrade.bonus_per_tier * tier
       return total

   func apply_bonuses_to_character(character: Dictionary) -> Dictionary:
       # Called at character creation or run start
       character.max_hp += get_total_bonus("max_hp")
       character.damage += get_total_bonus("damage")
       character.speed += get_total_bonus("speed")
       character.armor += get_total_bonus("armor")
       # ... etc

       bonuses_applied.emit(character)
       return character
   ```

2. **Hook into character creation**
   ```gdscript
   # In CharacterService or game start
   func start_run(character_id: String):
       var character = get_character(character_id)
       character = MetaProgressionService.apply_bonuses_to_character(character)
       # Continue with enhanced stats
   ```

3. **Persistence**
   - Save upgrade_tiers to SaveService
   - Load on startup

4. **Unit tests**
   - Upgrade purchase
   - Cost calculation
   - Bonus application
   - Save/load

**Success Criteria:**
- [ ] MetaProgressionService functional
- [ ] 9 upgrades defined
- [ ] Purchase with Chips works
- [ ] Bonuses apply to characters
- [ ] Persistence works
- [ ] Unit tests passing

---

### Phase 3: Post-Run Summary Screen (1-1.5 hours)
**Priority:** HIGH

#### Tasks

1. **Enhance game over screen**
   - Add Scrap → Chips conversion display
   - Show Chips earned this run
   - Show total Chips balance
   - Add "Upgrade Available!" indicator

2. **UI Layout**
   ```
   ┌─────────────────────────────────────┐
   │         RUN COMPLETE                │
   ├─────────────────────────────────────┤
   │  Wave Reached: 12                   │
   │  Enemies Killed: 147                │
   │  Damage Dealt: 45,231               │
   │  Survival Time: 04:23               │
   ├─────────────────────────────────────┤
   │  ═══ REWARDS ═══                    │
   │                                     │
   │  Scrap Earned: 1,250                │
   │        ↓ (100:1)                    │
   │  Chips Gained: +12                  │
   │  Total Chips: 156                   │
   │                                     │
   │  [🔓 New Upgrade Available!]        │
   ├─────────────────────────────────────┤
   │  ═══ EXPERIENCE ═══                 │
   │  XP Gained: +130                    │
   │  [████████░░░░] 67/100              │
   │  Level 4                            │
   ├─────────────────────────────────────┤
   │  [Try Again]  [Return to Hub]       │
   │           [View Upgrades]           │
   └─────────────────────────────────────┘
   ```

3. **"Upgrade Available" check**
   ```gdscript
   func check_affordable_upgrades() -> Array:
       var affordable = []
       var chips = BankingService.get_balance(CurrencyType.CHIPS)

       for upgrade_id in MetaProgressionService.UPGRADES:
           var cost = MetaProgressionService.get_next_cost(upgrade_id)
           if cost > 0 and chips >= cost:
               affordable.append(upgrade_id)

       return affordable
   ```

4. **Navigation buttons**
   - "Try Again" → Start new run
   - "Return to Hub" → Scrapyard
   - "View Upgrades" → Upgrade Shop (if upgrades available)

**Success Criteria:**
- [ ] Post-run screen shows all stats
- [ ] Chips conversion displayed
- [ ] "Upgrade Available" indicator works
- [ ] Navigation buttons functional

---

### Phase 4: Upgrade Shop UI (1-1.5 hours)
**Priority:** HIGH

#### Tasks

1. **Create Upgrade Shop screen**
   - `scenes/ui/upgrade_shop_screen.tscn`
   - Grid of 9 upgrade cards
   - Chips balance display
   - Category grouping (optional)

2. **Upgrade card component**
   - Upgrade name, description
   - Current tier / max tier
   - Progress bar (visual)
   - Next tier cost
   - "Purchase" button
   - "MAXED" state

3. **Purchase flow**
   - Tap upgrade card
   - Show confirmation (optional)
   - Deduct Chips
   - Update UI immediately
   - Save automatically

4. **Access from Hub**
   - Add button/area in Scrapyard
   - Badge if upgrades affordable

**Success Criteria:**
- [ ] Upgrade Shop accessible from Hub
- [ ] All 9 upgrades displayed
- [ ] Current tier and cost shown
- [ ] Purchase works
- [ ] Maxed upgrades indicated
- [ ] Device QA passed

---

## 🧪 QA CHECKLIST

### Automated Tests

- [ ] Chips conversion tests
- [ ] Upgrade purchase tests
- [ ] Cost calculation tests
- [ ] Bonus application tests
- [ ] Save/load tests

### Manual Testing (Device)

**Post-Run Flow:**
- [ ] Game over shows all stats
- [ ] Scrap → Chips conversion displayed
- [ ] Chips added to balance
- [ ] "Upgrade Available" shows when applicable
- [ ] Navigation buttons work

**Upgrade Shop:**
- [ ] Screen accessible from Hub
- [ ] All 9 upgrades visible
- [ ] Chips balance displayed
- [ ] Can purchase upgrades
- [ ] Tiers increment correctly
- [ ] Costs escalate correctly
- [ ] Maxed upgrades show "MAXED"

**Integration:**
- [ ] New run has meta bonuses
- [ ] Stats match upgrade levels
- [ ] Chips persist across sessions
- [ ] Upgrades persist across sessions

---

## 📊 SUCCESS METRICS

**Week 21 Definition of Done:**

| Metric | Target |
|--------|--------|
| Chips currency | Functional |
| Conversion rate | 100:1 |
| Upgrades implemented | 9 |
| Post-run flow | Complete |
| Upgrade Shop | Accessible |
| Persistence | Working |

---

## 📂 FILE STRUCTURE

```
scripts/
├── services/
│   └── meta_progression_service.gd  # NEW
├── tests/
│   └── meta_progression_test.gd     # NEW

scenes/
├── ui/
│   ├── post_run_screen.tscn         # UPDATE existing game_over
│   ├── upgrade_shop_screen.tscn     # NEW
│   └── components/
│       └── upgrade_card.tscn        # NEW
```

---

## 🎉 COMPLETE ROGUELITE LOOP

After Week 21, the full loop is:

```
1. Select Character (Hub)
        ↓
2. Start Run (Combat)
        ↓
3. Wave Combat → Shop → Repeat
        ↓
4. Death / Win
        ↓
5. Post-Run Summary
   - Stats display
   - Scrap → Chips
   - "Upgrade Available!"
        ↓
6. Upgrade Shop (if desired)
   - Spend Chips
   - Permanent bonuses
        ↓
7. Return to Hub
        ↓
8. Next Run (with bonuses!)
```

---

## Implementation Status (LIVING SECTION)

**Last Updated**: 2025-11-27 by Claude Code

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 1: Chips + Conversion | 1-1.5h | - | ⏭️ PENDING | - | - |
| Phase 2: MetaProgressionService | 1.5-2h | - | ⏭️ PENDING | - | - |
| Phase 3: Post-Run Screen | 1-1.5h | - | ⏭️ PENDING | - | - |
| Phase 4: Upgrade Shop UI | 1-1.5h | - | ⏭️ PENDING | - | - |

**Total Estimated**: 4-6 hours

---

**Document Version:** 1.0
**Created:** 2025-11-27
**Next Review:** After Week 20 completion
