# Next Session: Documentation Cleanup & Consolidation

**Created:** 2025-11-27
**Purpose:** Execute documentation restructure with fresh context window
**Priority:** HIGH - Do this BEFORE Week 18 implementation
**Estimated Time:** 4-5 hours

---

## 🎯 SESSION OBJECTIVES

1. **Archive legacy documentation** (React Native, completed weeks)
2. **Update core system documents** with finalized decisions
3. **Create new index/glossary documents**
4. **Restructure directory layout**
5. **Verify consistency across all active documents**

---

## ✅ DECISIONS FINALIZED (From Audit Session)

### 1. Character Types (APPROVED)

**Replace** the character types in `CHARACTER-SYSTEM.md` with these 6 types:

| Type | Tier | Weapon Slots | Special Mechanic | Flavor |
|------|------|--------------|------------------|--------|
| **Scavenger** | Free | 6 | +10% Scrap drops, +15 pickup range | "Knows where the good junk is" |
| **Rustbucket** | Free | 4 | +30 Max HP, +5 Armor, -15% Speed | "More patches than original parts" |
| **Hotshot** | Free | 6 | +20% Damage, +10% Crit, -20 Max HP | "Burns bright, burns fast" |
| **Tinkerer** | Premium | 6 | +1 Stack limit (all rarities), -10% Damage | "Can always fit one more gadget" |
| **Salvager** | Premium | 5 | +50% Component yield, +25% Shop discount, -1 Weapon slot | "Sees value in everything" |
| **Overclocked** | Subscription | 6 | +25% Attack Speed, +15% Damage, takes 5% Max HP damage per wave | "Pushed past factory specs" |

**Remove:** Scavenger (old), Tank, Commando, Mutant (old definitions)
**Remove:** One Armed, Weapon Master (Brotato ripoffs from Week 18)

### 2. Death Penalty by Tier (APPROVED)

Update `INVENTORY-SYSTEM.md` with tier-based durability loss:

```
Free Tier:         10% durability loss per death
Premium Tier:       5% durability loss per death  
Subscription Tier:  2% durability loss per death
```

### 3. Component Yields from Recycling (APPROVED)

Update `INVENTORY-SYSTEM.md` with hybrid formula:

**Base Yields:**
- Tier 1: 8 components
- Tier 2: 20 components
- Tier 3: 40 components
- Tier 4: 80 components

**Luck Bonus:** Up to +50% at 100 luck stat

**Formula:**
```gdscript
func calculate_component_yield(item_tier: int, luck: int) -> int:
    var base = BASE_YIELDS[item_tier]
    var luck_bonus = base * (luck / 100.0) * 0.5
    return base + int(luck_bonus)
```

**Result Table:**
| Tier | 0 Luck | 50 Luck | 100 Luck |
|------|--------|---------|----------|
| 1 | 8 | 10 | 12 |
| 2 | 20 | 25 | 30 |
| 3 | 40 | 50 | 60 |
| 4 | 80 | 100 | 120 |

### 4. Minions System (DEFERRED)

- **Status:** Future work (Week 22+)
- **Action:** Update `premium-tier.md` and `subscription-tier.md` to note as "Future Work"

---

## 📁 DOCUMENTATION RESTRUCTURE PLAN

### Phase 1: Create Archive Structure (15 min)

```bash
# Create archive directories
mkdir -p docs/archive/legacy-react-native
mkdir -p docs/archive/completed-weeks
mkdir -p docs/archive/experiments
mkdir -p docs/archive/brainstorm
mkdir -p docs/implementation
```

### Phase 2: Archive Legacy React Native Docs (30 min)

**Files to archive to `docs/archive/legacy-react-native/`:**
- `docs/migration/REACT-NATIVE-MIGRATION-PLAN.md`
- `docs/game-design/systems/SHOP-SYSTEM.md` (has React Native FlatList references)
- Any files referencing `packages/native/src/` paths

**Verification:** Search for "React Native", "FlatList", "packages/native" in docs

### Phase 3: Archive Completed Week Plans (20 min)

**Move to `docs/archive/completed-weeks/`:**
- `docs/migration/week2-*.md` (5 files)
- `docs/migration/week3-*.md` (5 files)
- `docs/migration/week4-*.md` (5 files)
- `docs/migration/week6-*.md`
- `docs/migration/week7-*.md`
- `docs/migration/week8-*.md`
- `docs/migration/week9-*.md`
- `docs/migration/week10-*.md`
- `docs/migration/week11-*.md`
- `docs/migration/week12-*.md`
- `docs/migration/week13-*.md` (2 files)
- `docs/migration/week14-*.md` (3 files)
- `docs/migration/week15-*.md` (2 files)
- `docs/migration/week16-*.md` (multiple files + root docs/)

**Keep in `docs/migration/`:**
- `week17-plan.md` (reference for recent patterns)
- `week18-plan.md` (ACTIVE)
- `week19-plan.md` (UPCOMING)
- `week20-plan.md` (UPCOMING)
- `week21-plan.md` (UPCOMING)
- `GODOT-MIGRATION-PLAN.md` (reference)
- `GODOT-MIGRATION-SUMMARY.md` (reference)

### Phase 4: Update Core System Documents (1.5 hours)

#### 4a. CHARACTER-SYSTEM.md Update

**File:** `docs/game-design/systems/CHARACTER-SYSTEM.md`

**Changes:**
1. Replace character type definitions with new 6-type system
2. Remove old Scavenger/Tank/Commando/Mutant definitions
3. Add character stat modifiers table
4. Add SQA testing matrix

#### 4b. INVENTORY-SYSTEM.md Update

**File:** `docs/game-design/systems/INVENTORY-SYSTEM.md`

**Changes:**
1. Add tier-based death penalty section (10%/5%/2%)
2. Update component yield section with hybrid formula
3. Add luck bonus calculation
4. Remove any React Native references

#### 4c. ITEM-STATS-SYSTEM.md Update

**File:** `docs/game-design/systems/ITEM-STATS-SYSTEM.md`

**Changes:**
1. Add stack limits section:
   - Common: 5
   - Uncommon: 4
   - Rare: 3
   - Epic: 2
   - Legendary: 1

#### 4d. Tier Experience Docs Update

**Files:**
- `docs/tier-experiences/premium-tier.md`
- `docs/tier-experiences/subscription-tier.md`

**Changes:**
1. Mark Minions System as "Future Work (Post-Week 21)"
2. Update character type availability to match new types

### Phase 5: Create New Index Documents (1 hour)

#### 5a. docs/README.md (Main Index)

Create comprehensive index with:
- Document categories
- Quick links to authoritative sources
- "Start Here" section for new sessions
- Last updated date

#### 5b. docs/GLOSSARY.md

Create terminology glossary with:
- Character types
- Item rarities
- Tier definitions
- Economy terms
- System names

### Phase 6: Update Week 18 Plan (30 min)

**File:** `docs/migration/week18-plan.md`

**Changes:**
1. Replace One Armed/Weapon Master with Tinkerer/Salvager/Overclocked
2. Update character type implementations to match new definitions
3. Reference updated CHARACTER-SYSTEM.md

### Phase 7: Verification (30 min)

1. Search for "React Native" - should only be in archive
2. Search for "One Armed" - should not exist
3. Search for "Weapon Master" - should not exist
4. Verify CHARACTER-SYSTEM.md matches Week 18 plan
5. Verify INVENTORY-SYSTEM.md has death penalties and yields
6. Verify tier docs mark Minions as future

---

## 🔍 FILES TO UPDATE (Checklist)

### Critical Updates (Must Complete)

- [ ] `docs/game-design/systems/CHARACTER-SYSTEM.md` - Replace character types
- [ ] `docs/game-design/systems/INVENTORY-SYSTEM.md` - Add death penalties, update yields
- [ ] `docs/game-design/systems/ITEM-STATS-SYSTEM.md` - Add stack limits
- [ ] `docs/migration/week18-plan.md` - Update character types
- [ ] `docs/tier-experiences/premium-tier.md` - Mark Minions as future
- [ ] `docs/tier-experiences/subscription-tier.md` - Mark Minions as future

### New Documents to Create

- [ ] `docs/README.md` - Main documentation index
- [ ] `docs/GLOSSARY.md` - Terminology definitions
- [ ] `docs/archive/` directory structure

### Archive Operations

- [ ] Move completed week plans to `docs/archive/completed-weeks/`
- [ ] Move React Native docs to `docs/archive/legacy-react-native/`
- [ ] Archive `SHOP-SYSTEM.md` (React Native version)

---

## ⚠️ WARNINGS FOR NEXT SESSION

1. **Do NOT modify** `SHOPS-SYSTEM.md` (Godot version) - this is correct
2. **SHOP-SYSTEM.md** (singular) is React Native legacy - archive it
3. **Keep `week17-plan.md`** as reference for recent patterns
4. **Verify git status** before starting - ensure clean working tree
5. **Commit after each phase** for safety

---

## 📊 SUCCESS CRITERIA

After cleanup, running these searches should return:

| Search Term | Expected Result |
|-------------|-----------------|
| "React Native" in docs/ | Only in `archive/legacy-react-native/` |
| "One Armed" anywhere | No results |
| "Weapon Master" anywhere | No results |
| "Tinkerer" in CHARACTER-SYSTEM.md | Found with full definition |
| "10% durability loss" | Found in INVENTORY-SYSTEM.md |
| "Base yield" | Found in INVENTORY-SYSTEM.md with formula |

---

## 🚀 QUICK START FOR NEXT SESSION

```
1. Read this document completely
2. Verify git status is clean: `git status`
3. Create archive directories (Phase 1)
4. Execute phases in order, committing after each
5. Run verification searches (Phase 7)
6. Create handoff summary
```

---

**Document Status:** Ready for execution in fresh session
**Blocking:** Week 18 implementation should wait for this cleanup
