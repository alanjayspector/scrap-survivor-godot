# Mutant Power & Mutagen Aura Discussion

**Status:** 📋 Tabled for Discussion
**Date:** 2025-01-09
**Purpose:** Capture design notes for Mutant Power stat system (replacement for Elemental Damage)

---

## Overview

**Mutant Power** is intended to replace Brotato's "Elemental Damage" stat as a **Premium+ tier exclusive feature** that ties into the game's post-apocalyptic mutation/radioactivity theme.

---

## Original Design Intent (from brainstorm.md)

> "Id change elemental damage to mutant power which is a premium tier feature for some of our premium character types. Mutant power will impact items that grant a passive mutant effect to the character or if the character type comes with a mutant effect. Not all character types will have the mutant power stat"

### Key Points from Brainstorm:
1. **Premium+ tier exclusive** - Not all character types have this stat
2. **Affects items with mutant effects** - Items can grant passive mutant effects
3. **Character type dependent** - Some characters come with built-in mutant effects
4. **Replaces Elemental Damage** - Brotato has Elemental Damage, we have Mutant Power

---

## Current Implementation (radioactivity-system.md)

### Mutant Power Effects (Premium Tier):

**From radioactivity system documentation:**

| Feature | Effect |
|---------|--------|
| Mutant Power Boost | Small chance to gain +1 Mutant Power per wave at 30+ radioactivity |
| HP Regen Mitigation | Mutant Power reduces radioactivity's HP regen penalty (1 Mutant Power = +5% HP regen) |

**MetaConvertor Restriction:**
- ❌ **CANNOT convert TO Mutant Power** (can only gain through radioactivity exposure/items)
- ✅ Can convert FROM Mutant Power to other stats

**MetaConvertor Ratio Improvement:**
- Mutant Power stabilizes conversion ratios
- 10 Mutant Power = -1 ratio improvement (e.g., 3:1 → 2:1)

---

## Related System: Mutagen Aura

**From legacy workshop-system.md:**

**Mutagen Aura** is a **crafting proc effect** (separate from Mutant Power stat):
- Small chance during weapon fusion/crafting to proc special bonuses
- Affected by Luck stat and "Mutagen Mastery" perk
- Grants bonus stats or special effects on successful craft

**Questions:**
- Is Mutagen Aura still part of the design?
- Should it tie into Mutant Power stat?
- Is this a Premium+ feature or all tiers?

---

## Open Design Questions

### 1. What IS Mutant Power?

**Potential definitions:**
- **Option A:** Damage multiplier for mutated/biological weapons (like Elemental Damage)
- **Option B:** Stat that enhances mutation effects (passive buffs from radioactivity)
- **Option C:** Power level that scales minion/mutant companion strength
- **Option D:** Hybrid - affects damage, mutations, AND minions

### 2. How is it acquired?

**Current methods:**
- ✅ Radioactivity exposure (30+ radioactivity = chance to gain +1 per wave)
- ✅ Items with mutant effects
- ❌ Cannot be gained via MetaConvertor

**Potential additions:**
- Lab treatments that convert radioactivity → Mutant Power?
- Special character types start with Mutant Power?
- Minions grant Mutant Power?

### 3. Tier Access

**From brainstorm:**
- Premium+ tier exclusive
- Not all character types have it

**Questions:**
- Do Free tier characters NEVER have Mutant Power?
- Do ALL Premium characters have it, or only specific types?
- Do Subscription characters get additional Mutant Power benefits?

### 4. How does it scale?

**Potential scaling:**
- Linear: 1 Mutant Power = +1% mutant damage
- Exponential: 1 Mutant Power = +2% mutant damage (compounds)
- Threshold-based: Every 10 Mutant Power = unlock new mutation effect

### 5. What does it affect?

**Potential effects:**
- ✅ **HP Regen mitigation** (reduces radioactivity penalty) - CONFIRMED
- ✅ **MetaConvertor ratios** (stabilizes stat conversion) - CONFIRMED
- ❓ Damage multiplier for mutant/biological weapons?
- ❓ Minion power scaling?
- ❓ Mutation proc chances (Mutagen Aura)?
- ❓ Radioactivity resistance?
- ❓ Special passive effects (auras, buffs)?

### 6. Mutagen Aura Integration

**Should Mutagen Aura:**
- Be removed entirely?
- Stay as separate crafting proc (unrelated to Mutant Power)?
- Tie into Mutant Power (higher Mutant Power = better Mutagen Aura procs)?
- Become a Mutant Power milestone unlock (10/25/50/100 Mutant Power unlocks tiers)?

### 7. Character Type Design

**Which character types have Mutant Power?**

**Potential character archetypes:**
- **Mutant** - Starts with high Mutant Power, gains more from radioactivity
- **Pure Human** - No Mutant Power, immune to some radioactivity effects
- **Cyborg** - Hybrid, can gain Mutant Power but caps lower
- **Creature** - High Mutant Power, synergizes with curse/radioactivity

**From brainstorm:**
> "Not all character types will have the mutant power stat"

This suggests **intentional character differentiation** based on lore/theme.

---

## Comparison to Brotato's Elemental Damage

### Brotato: Elemental Damage
- Increases damage dealt by elemental weapons
- Available to all characters
- Linear scaling (+1 Elemental Damage = +1% damage)
- Simple, straightforward stat

### Scrap Survivor: Mutant Power (proposed)
- **Tier-exclusive** (Premium+)
- **Character-exclusive** (not all types have it)
- **Multi-functional** (affects damage, minions, mutations, etc.)
- **Thematic** (ties into radioactivity, mutations, post-apocalyptic setting)
- **Complex** (requires strategic investment)

**This creates UNIQUE differentiation from Brotato.**

---

## Potential Design Recommendation

### Option D: Hybrid Mutant Power System

**Mutant Power as a "Mutation Amplifier" stat:**

**Affects:**
1. **Mutant Weapon Damage** (+2% damage per Mutant Power for weapons tagged "Mutant/Biological")
2. **Minion Power** (+5% minion stats per 10 Mutant Power)
3. **Radioactivity Benefits** (HP regen mitigation, XP boost amplification)
4. **Mutation Procs** (improves Mutagen Aura chance, special passive effects)
5. **MetaConvertor Efficiency** (stabilizes ratios)

**Acquisition:**
- Radioactivity exposure (30+ rad = chance for +1 per wave)
- Premium character types start with 5-10 Mutant Power
- Items with "Mutant" tag grant +Mutant Power
- Lab treatments can extract Mutant Power from high radioactivity

**Tier Access:**
- **Free:** CANNOT gain Mutant Power (stat locked)
- **Premium:** Can gain Mutant Power (character type dependent)
- **Subscription:** Enhanced Mutant Power gains (+50% acquisition rate)

**This creates:**
- ✅ Clear tier differentiation (Premium+ exclusive)
- ✅ Strategic depth (invest in radioactivity for Mutant Power gains)
- ✅ Character variety (mutant types vs pure humans)
- ✅ Synergy with multiple systems (weapons, minions, Lab, radioactivity)

---

## Next Steps

**Before finalizing Mutant Power design:**
1. Discuss character type roster (which characters have Mutant Power?)
2. Define "Mutant" weapon tag criteria (biological, radioactive, experimental?)
3. Decide on Mutagen Aura integration (keep, remove, or tie to Mutant Power?)
4. Finalize tier access (Free locked, Premium unlocked, Subscription enhanced?)
5. Balance Mutant Power scaling (linear, exponential, threshold-based?)

**After design finalized:**
1. Update STAT-SYSTEM.md (replace Elemental Damage with Mutant Power)
2. Update character type documents (specify which have Mutant Power)
3. Update weapon tags (add "Mutant" tag to applicable weapons)
4. Update The Lab system (add Mutant Power treatments)
5. Update DLC Packs (add Mutant Power character types)

---

## References

- [brainstorm.md](../../brainstorm.md) - Original Mutant Power vision
- [radioactivity-system.md](/Users/alan/Developer/scrap-survivor/docs/features/planned/radioactivity-system.md) - Legacy radioactivity mechanics
- [workshop-system.md](/Users/alan/Developer/scrap-survivor/docs/features/implemented/workshop-system.md) - Mutagen Aura crafting proc

---

**Status:** Ready for design discussion and finalization
