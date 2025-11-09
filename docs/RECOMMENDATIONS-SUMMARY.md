# Recommendations Summary (Brotato Comparison)

**Date:** 2025-01-09
**Status:** Approved for Implementation
**Source:** Documentation reconciliation + Brotato comparison + Professional opinion analysis

---

## Executive Summary

Based on comprehensive analysis of Brotato (genre leader with 98% positive reviews), professional perspectives from Sr. Mobile Game Designer, Sr. Godot Engineer, and Sr. Product Manager, here are the approved changes to Scrap Survivor's design.

---

## 1. CRITICAL: Remove/Reduce Durability System ⚠️

**Current Design:**
- 10% durability loss on death
- Repair costs (scrap currency)
- Items can be destroyed at 0 durability

**Recommended Change:**
- **Option A (RECOMMENDED):** Remove durability system entirely
- **Option B:** Reduce to 2-3% symbolic loss (Premium 1%, Subscription 0%)
- **Option C:** Make durability opt-in (Hardcore mode with 2x rewards)

**Rationale:**
- Brotato: NO durability (98% positive, 50k+ reviews)
- Vampire Survivors: NO durability (97% positive)
- Halls of Torment: NO durability (95% positive)
- Death in roguelites = learning experience, not punishment
- Repair costs create friction between runs

**Decision:** → **PENDING USER APPROVAL**

---

## 2. Increase Weapon Count from 23 to 40-50

**Current Plan:**
- 23 total weapons (15 free, 8 premium)

**Recommended Change:**
- **Launch: 40-50 weapons** (not 23)
- **6 months: 60-80 weapons**
- **12 months: 100+ weapons**

**Rationale:**
- Brotato has 83 weapons
- Build variety = replayability
- 23 weapons = only 28% of Brotato's variety

**Implementation:**
- Add weapon classes (see below)
- Increase free weapons to 30-35 (keep 70% free)
- Increase premium weapons to 15-20

**Status:** ✅ **APPROVED**

---

## 3. Add Weapon Class System

**New Feature:**
- **8-10 weapon classes** (Melee, Ranged, Energy, Explosive, Support, Blade, Blunt, Precise, etc.)
- **Stacking bonuses:** 2/3/4/5/6 of same class = increasing bonuses
- Example: 6 Blade weapons = +5 Melee DMG, +5% Life Steal

**Rationale:**
- Brotato's 14 weapon classes create synergy depth
- Encourages build specialization
- Adds strategic layer

**Implementation:**
```gdscript
# Weapon data structure
class_name Weapon
var weapon_classes: Array[String] = ["Blade", "Melee"]

# Class bonuses
const CLASS_BONUSES = {
    "Blade": {
        2: {"melee_damage": 1, "life_steal": 1},
        3: {"melee_damage": 2, "life_steal": 2},
        4: {"melee_damage": 3, "life_steal": 3},
        5: {"melee_damage": 4, "life_steal": 4},
        6: {"melee_damage": 5, "life_steal": 5}
    }
}
```

**Status:** ✅ **APPROVED**

---

## 4. Document Advancement Hall (Leveling System)

**Current State:**
- Mentioned in brainstorm.md but not designed
- Unclear mechanics

**Completed:**
- ✅ Created [ADVANCEMENT-HALL-SYSTEM.md](game-design/systems/ADVANCEMENT-HALL-SYSTEM.md)
- ✅ Based on Brotato's 20 levels, +1 stat choice
- ✅ Added tier restrictions (Free: 5, Premium: 15, Subscription: 20)
- ✅ Added radioactivity interaction
- ✅ Added character-specific exceptions

**Status:** ✅ **COMPLETE** (pending tier discussion)

---

## 5. Add Item Tags to Characters

**New Feature:**
- Each character has 1-3 item tags
- 5% chance shop selects from tagged items
- Example: Bruiser → "Melee Damage", "Max HP"

**Rationale:**
- Brotato's system reduces RNG frustration
- Helps players find build-relevant items
- Still allows off-meta builds

**Implementation:**
```gdscript
class_name CharacterType
var item_tags: Array[String] = ["Melee Damage", "Max HP"]

# ShopService uses tags for item selection
func select_shop_items(character: Character) -> Array[Item]:
    var items = []
    for i in 3:
        if randf() < 0.05 and character.item_tags.size() > 0:
            # 5% chance: select from tagged items
            var tag = character.item_tags.pick_random()
            items.append(get_item_by_tag(tag))
        else:
            # 95% chance: select from all items
            items.append(get_random_item())
    return items
```

**Status:** ✅ **APPROVED**

---

## 6. Increase Item Count Target

**Current Plan:**
- Item count not specified

**Recommended Change:**
- **Launch: 80-100 items** (4 rarity tiers)
- **6 months: 120-150 items**
- **12 months: 150-200 items**

**Rationale:**
- Brotato has 177 items
- Item variety = build diversity
- Launch target: 50-60% of Brotato's item count

**Status:** ✅ **APPROVED**

---

## 7. 3-Wave MVP Approach (Scope Reduction)

**Current Scope:**
- 18 major systems
- Estimated: 2,640 hours = 2.5 years solo dev @ 20 hours/week

**Recommended Approach:**

### Wave 1: Core Loop (3 months = Playable Demo)
**Goal:** Brotato clone with ONE unique system

**Include:**
- Core combat (wave-based, shop between waves)
- 5 character types (3 free, 2 premium)
- 40 weapons (30 free, 10 premium)
- 80 items (4 rarity tiers)
- 10 enemy types
- Basic progression (Advancement Hall, Banking)
- **ONE unique system: Perks OR Minions** (not both)

**Skip:** All other 17 systems

---

### Wave 2: Monetization (6 months)
**Goal:** Premium tier worth $4.99

**Add:**
- Workshop System (recycling, crafting, fusion)
- Inventory durability (if keeping system)
- Black Market (gambling)
- Achievements (40, not 120)
- 8 more character types (13 total)
- 20 more weapons (60 total)
- 30 more items (110 total)

---

### Wave 3: Depth Features (12 months)
**Goal:** Subscription tier + endgame content

**Add:**
- Subscription Services (Quantum Banking, Hall of Fame)
- Goals System (daily/weekly/seasonal)
- Special Events (seasonal modifiers)
- Radioactivity System
- Minions OR Perks (whichever wasn't in Wave 1)
- Atomic Vending Machine
- Friend leaderboards
- 15 more weapons (75 total)
- 40 more items (150 total)

---

### Wave 4: Post-Launch (12+ months)
**Add:**
- Guilds/Clans
- Personalization System (AI classification)
- Advisor System (AI feedback)
- Trading Cards (social sharing)
- Feature Request System (democratic voting)
- Battle Pass (seasonal)
- 25 more weapons (100+ total)
- 50 more items (200+ total)

**Status:** ✅ **APPROVED** (aligns with user's "production mindset, progressive iterative progress")

---

## 8. Add Friend Leaderboards (Pre-Launch)

**New Feature:**
- Add friends via code or social login
- See friends' best runs per character type
- "Beat Your Friend" bonus scrap reward

**Rationale:**
- Industry data: Guilds = 40% retention boost, 3x LTV
- Brotato is single-player only (our differentiator)
- Social features = retention

**Implementation:**
- ~40 hours development
- Add before launch (Wave 2 or 3)

**Status:** ✅ **APPROVED**

---

## 9. Strengthen Subscription Value (TBD)

**Current Subscription:**
- $2.99/month ($35.88/year)
- Features: Quantum Banking/Storage, Atomic Vending Machine, Hall of Fame, 50 slots

**Issue:**
- Brotato is $4.99 one-time (all content forever)
- Your subscription is 7x more expensive annually
- Only appeals to whales (5% of players)

**Recommended:** Add ONE killer feature

**Options:**
- **A) Offline progression** (idle game lite) - RECOMMENDED
- **B) Exclusive cosmetics** (1/month, permanent)
- **C) Battle Pass** (seasonal content)
- **D) Cross-platform sync** (priority)

**Status:** → **PENDING TIER DISCUSSION**

---

## 10. Death Penalties (TBD)

**Conflicting Information:**
- brainstorm.md: Stat loss + currency wipe + durability loss
- Current docs: Durability loss only (10%)
- Brotato: ZERO penalties

**Needs Clarification:**
- Should death result in stat loss?
- Should un-banked currency be wiped?
- Should durability loss exist at all?

**Status:** → **PENDING USER DECISION**

---

## 11. Idle Game Systems (TBD)

**From brainstorm.md:**
- Cultivation Pod (offline stat gain)
- Murder Hobo mode (offline currency)
- Mr Fix-It (passive repair)
- Minion Fabricator (clone minions)

**Question:** Were these deliberately cut or should they be designed?

**Status:** → **PENDING USER DECISION**

---

## Changes Implemented in Documentation

### New Documents Created:
1. ✅ [ADVANCEMENT-HALL-SYSTEM.md](game-design/systems/ADVANCEMENT-HALL-SYSTEM.md)
2. ✅ [BROTATO-COMPARISON.md](competitive-analysis/BROTATO-COMPARISON.md)
3. ✅ [PROFESSIONAL-OPINION-ANALYSIS.md](PROFESSIONAL-OPINION-ANALYSIS.md)
4. ✅ [DOCUMENTATION-RECONCILIATION-FINDINGS.md](DOCUMENTATION-RECONCILIATION-FINDINGS.md)

### Documents to Update (After Tier Discussion):
- [ ] Free Tier - Add Advancement Hall limits, weapon counts
- [ ] Premium Tier - Add Advancement Hall limits, weapon counts
- [ ] Subscription Tier - Add Advancement Hall limits, add killer feature
- [ ] Inventory System - Update durability mechanics (remove/reduce)
- [ ] Combat System - Add weapon class system
- [ ] Character System - Add item tags

---

## Next Steps

1. **Tier Experience Discussion** (this session)
   - Align on Free/Premium/Subscription value
   - Decide on subscription killer feature
   - Finalize Advancement Hall tier limits

2. **Critical Decisions Needed:**
   - Durability system (remove, reduce, or keep?)
   - Death penalties (what's final design?)
   - Idle game systems (cut or design?)
   - Subscription killer feature (which to add?)

3. **Update Documentation** (after decisions)
   - Update tier experience documents
   - Update system documents with changes
   - Create implementation roadmap

4. **Commit and Push**
   - Commit all documentation changes
   - Push to remote repository

---

**Ready for tier experience discussion!**
