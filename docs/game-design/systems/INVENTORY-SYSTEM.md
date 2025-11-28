# Inventory System Design Document

**Version:** 1.0  
**Date:** January 10, 2025  
**Status:** Design Approved by Alan

---

## Core Design Philosophy

**Model:** Brotato-inspired auto-active inventory system with persistent progression and item durability consequences.

**Key Principles:**

1. **Auto-Active:** If you own an item, its stats are active (no equip/unequip)
2. **Persistent:** Items survive between runs (unlike Brotato)
3. **Consequential:** Items have durability and can be destroyed
4. **Strategic:** Stack limits force build diversity
5. **Monetizable:** Tier-based features provide clear upgrade path

---

## 1. Inventory Model (Option A - Auto-Active)

### How It Works

```
Player picks up item → Item added to inventory → Stats immediately active
```

**No Equip/Unequip Concept:**

- If you have it, it's working
- Can't toggle items on/off
- Can only remove by selling/destroying

**Stat Calculation:**

```typescript
finalStat = baseStat + Σ(allItemBonuses)

Example:
- Base Armor: 0
- 3x Armor Plate (+2 each): +6
- 1x Steel Boots (+1): +1
- Final Armor: 7
```

**Benefits:**

- Simple, easy to understand
- Fast gameplay (no menu fiddling mid-combat)
- Forces commitment to builds
- Matches Brotato's elegant simplicity

---

## 2. Item Slot Limits (Option C - Character Type Based)

### Slot System

**Concept:** Each character type has different slot allocations and focuses.

```typescript
interface CharacterInventoryLimits {
  totalSlots: number;
  preferredTypes?: ItemType[]; // Gets bonus slots for these types
}

Example Limits:
Tank:
  - Total: 30 slots
  - Defensive items: 15 slots (preference)
  - Offensive items: 10 slots
  - Utility items: 5 slots

DPS:
  - Total: 30 slots
  - Offensive items: 15 slots (preference)
  - Defensive items: 10 slots
  - Utility items: 5 slots

Support:
  - Total: 30 slots
  - Utility items: 15 slots (preference)
  - Defensive items: 10 slots
  - Offensive items: 5 slots
```

### Tier Differentiation (CRITICAL FOR MONETIZATION)

**Software Engineering Concept: Feature Gating**
Tiers unlock MORE CHARACTER TYPES, which indirectly provides more build variety and gameplay options.

```
Free Tier:
  - 3 character slots
  - Access to: Tank, DPS, Support (basic types)
  - 30 item slots per character

Premium Tier:
  - 10 character slots
  - Access to: Tank, DPS, Support, Specialist, Hybrid (5 types)
  - 30 item slots per character
  - Can have multiple of the same type with different builds

Subscription Tier:
  - Unlimited character slots
  - Access to: All character types including unique variants
  - 30 item slots per character
  - Quantum Banking/Storage features (see below)
```

**Monetization Logic:**

- More characters = more builds = more experimentation = more fun
- Each character type plays differently
- Power comes from variety, not pay-to-win raw stats
- Subscription provides convenience (banking) not power

---

## 3. Equipment Stacking Limits (Option C + Rarity Rules)

### Stacking Rules by Rarity

**Concept:** Common items stack freely, rare items have stricter limits.

```typescript
enum Rarity {
  COMMON = 'common', // Gray
  UNCOMMON = 'uncommon', // Green
  RARE = 'rare', // Blue
  EPIC = 'epic', // Purple
  LEGENDARY = 'legendary', // Gold
}

interface StackLimits {
  [Rarity.COMMON]: 5; // Can have 5x Rusty Armor
  [Rarity.UNCOMMON]: 4; // Can have 4x Steel Plate
  [Rarity.RARE]: 3; // Can have 3x Titanium Shield
  [Rarity.EPIC]: 2; // Can have 2x Plasma Deflector
  [Rarity.LEGENDARY]: 1; // Can ONLY have 1x God Armor
}
```

**Examples:**

```
✅ Valid Builds:
- 5x Rusty Sword (common) + 3x Iron Plate (rare) + 1x Excalibur (legendary)
- 4x Health Boost (uncommon) + 2x Adrenaline Shot (epic)

❌ Invalid Builds:
- 2x God Armor (legendary) - BLOCKED at acquisition
- 6x Rusty Sword (common) - BLOCKED at 5th purchase
- 3x Plasma Deflector (epic) - BLOCKED at 2nd purchase
```

**UI Feedback:**

```
When attempting to buy 6th common item of same type:
"❌ Stack Limit Reached: Can only have 5x Rusty Swords.
   Sell one first or choose a different item."

When attempting to buy 2nd legendary:
"❌ Legendary Limit: You already own Excalibur.
   Only 1 legendary of each type allowed."
```

**Game Design Rationale:**

- **Forces Diversity:** Can't stack 5 legendaries for broken builds
- **Progression Curve:** Common items (easy to stack) → Rare items (limited) → Legendary (unique)
- **Strategic Choices:** "Do I replace my 3rd rare with this epic, or keep variety?"

---

## 4. Quantum Banking & Storage (Subscription Tier)

### Feature Overview

**Quantum Banking:** A subscription-exclusive feature suite that allows transfer of resources (items + scrap) between characters.

### 4A. Quantum Storage (Item Transfer)

**Concept:** Move items from Character A to Character B.

**Implementation:**

```typescript
interface QuantumStorage {
  // Shared vault accessible by all characters
  vault: Item[];
  maxVaultSize: number; // Unlimited for subscribers

  // Operations
  depositItem(characterId: string, itemId: string): Promise<void>;
  withdrawItem(characterId: string, itemId: string): Promise<void>;
  transferDirect(fromCharId: string, toCharId: string, itemId: string): Promise<void>;
}
```

**User Flow:**

```
1. Open Quantum Storage scene (subscription gate)
2. Select source character (e.g., Tank)
3. Select items to transfer
4. Select destination character (e.g., DPS)
5. Confirm transfer
6. Items moved instantly
```

**UI Concept:**

```
┌─────────────────────────────────────────┐
│  Quantum Storage                    ╳   │
├─────────────────────────────────────────┤
│  [Tank Character]  →  [DPS Character]   │
│                                         │
│  Tank's Items:          DPS's Items:    │
│  [Item] [Item] [Item]   [Item] [Item]   │
│  [Item] [Item]          [Item]          │
│                                         │
│  [Transfer Selected →]                  │
└─────────────────────────────────────────┘
```

**Business Logic:**

- Items maintain durability when transferred
- Destination must have available slots
- No transfer fee for items (pure convenience)

---

### 4B. Quantum Banking (Scrap Transfer)

**Concept:** Transfer scrap currency between characters at a conversion rate/fee.

**Economic Design:**

```typescript
interface QuantumBankingConfig {
  transferFee: number; // Percentage lost in transfer
  minimumTransfer: number; // Minimum scrap to transfer
  feeModel: 'flat' | 'percentage' | 'tiered';
}

// Example: Tiered Fee Model
const TRANSFER_FEES = {
  '0-1000': 0.1, // 10% fee for small transfers
  '1001-5000': 0.05, // 5% fee for medium transfers
  '5001+': 0.02, // 2% fee for large transfers
};
```

**Example Transfer:**

```
Tank has 5000 scrap
DPS has 100 scrap

Transfer 3000 scrap from Tank to DPS:
  - Fee: 5% (medium tier) = 150 scrap
  - Tank loses: 3000 scrap
  - DPS gains: 2850 scrap (3000 - 150 fee)
  - Fee destroyed (sink, not paid to anyone)
```

**Game Design Rationale:**

- **Fee acts as economy sink** (prevents infinite money shuffling)
- **Encourages specialization** (feed your main character)
- **Subscription value** (convenience worth the fee)
- **Balancing lever** (can adjust fees to control economy)

---

### 4C. Tier Placement Discussion

**Option A: Full Quantum Banking in Subscription Only**

```
Premium Tier:
  - No banking features
  - Items/scrap stay with each character

Subscription Tier:
  - Quantum Storage (item transfer)
  - Quantum Banking (scrap transfer)
```

**Option B: Storage in Premium, Banking in Subscription**

```
Premium Tier:
  - Quantum Storage (item transfer) - LIMITED
  - Max 10 items in vault
  - No scrap transfer

Subscription Tier:
  - Quantum Storage (item transfer) - UNLIMITED
  - Unlimited vault size
  - Quantum Banking (scrap transfer)
```

**Recommendation:** **Option A** (both features subscription-only)

**Reasoning:**

- Clear value proposition (subscription = resource sharing)
- Premium already has good features (10 character slots, more character types)
- Subscription needs "killer feature" to justify recurring payment
- Resource transfer is HIGH value (worth monthly fee)
- Simpler to communicate ("Subscription = Quantum Banking Package")

**Marketing Copy:**

```
Premium:
  "Unlock more characters and build variety"

Subscription:
  "Master the multiverse - share resources across all your characters with Quantum Banking"
```

---

## 5. Weapons System (Option A - Passive/Auto-Active)

### Implementation

**Concept:** Weapons work like items - own them, they're active.

```typescript
interface Weapon extends Item {
  type: 'weapon';
  damageType: 'physical' | 'energy' | 'explosive';
  fireRate: number;  // Attacks per second
  range: number;     // Attack range
  special?: string;  // Special effect description
}

// All weapons contribute to damage calculations
finalDPS = Σ(allWeaponDPS) + Σ(damageBoostItems)

Example:
- Rusty Pistol: 10 DPS
- Plasma Rifle: 25 DPS
- Damage Boost Item: +20% = 7 bonus DPS
- Final DPS: 42 DPS (10 + 25 + 7)
```

**Benefits:**

- Simple, like Brotato
- No "active weapon" concept to manage mid-combat
- Every weapon you buy makes you stronger
- Encourages experimentation ("try every weapon!")

**Alternative (Future Consideration):**

- Could add "weapon switching" in a later sprint if combat feels too passive
- For now, keep it simple

---

## 6. Item Durability & Death Consequences (NEW MECHANIC!)

### Overview

**Concept:** Items have HP. Death damages items. Destroyed items are lost forever.

**This is BRILLIANT game design:**

- Adds consequence to death (not just losing progress)
- Creates item attachment ("I love this sword, can't let it break!")
- Adds economy sink (items leave the game)
- Subscription value (Mr Fix-It repair service)

---

### 6A. Item Durability System

**Implementation:**

```typescript
interface ItemDurability {
  currentHP: number;
  maxHP: number;
  durabilityPercent: number; // currentHP / maxHP
}

interface Item {
  id: string;
  name: string;
  rarity: Rarity;
  stats: ItemStats;
  durability: ItemDurability;
}

// Durability varies by rarity
const BASE_DURABILITY = {
  [Rarity.COMMON]: 100,
  [Rarity.UNCOMMON]: 200,
  [Rarity.RARE]: 400,
  [Rarity.EPIC]: 800,
  [Rarity.LEGENDARY]: 1600,
};
```

**Visual Indicators:**

```
Item Card Display:

100% HP: [████████████] (green bar)
 75% HP: [████████░░░░] (yellow bar)
 50% HP: [██████░░░░░░] (orange bar)
 25% HP: [███░░░░░░░░░] (red bar, pulsing)
  0% HP: [DESTROYED] (item removed)
```

---

### 6B. Death Penalty - Durability Loss (AUTHORITATIVE)

**Tier-Based Death Penalty (APPROVED)**:

The durability loss on death is determined by the player's subscription tier, providing clear monetization value while maintaining consequence for all players.

```gdscript
const DEATH_PENALTY_BY_TIER = {
    UserTier.FREE: 0.10,           # 10% durability loss per death
    UserTier.PREMIUM: 0.05,        # 5% durability loss per death
    UserTier.SUBSCRIPTION: 0.02,   # 2% durability loss per death
}

func apply_death_penalty(character: Dictionary) -> Dictionary:
    var tier = CharacterService.get_tier()
    var loss_percent = DEATH_PENALTY_BY_TIER[tier]
    var damaged_items = []
    
    for item in character.inventory:
        var loss = int(item.durability.max_hp * loss_percent)
        item.durability.current_hp -= loss
        
        if item.durability.current_hp <= 0:
            destroyed_items.append(item)
        else:
            damaged_items.append({"item": item, "loss": loss})
    
    return {
        "damaged": damaged_items,
        "destroyed": destroyed_items,
        "tier": tier,
        "loss_percent": loss_percent
    }
```

**Example Death Scenarios**:

| Tier | Death Penalty | 100 HP Item | 400 HP Item | 1600 HP Item |
|------|---------------|-------------|-------------|--------------|
| Free | 10% | -10 HP (10 deaths to destroy) | -40 HP | -160 HP |
| Premium | 5% | -5 HP (20 deaths to destroy) | -20 HP | -80 HP |
| Subscription | 2% | -2 HP (50 deaths to destroy) | -8 HP | -32 HP |

**Game Design Rationale**:
- **Free tier feels consequential** - 10 deaths destroys common items
- **Premium tier provides safety** - Double the item lifespan
- **Subscription tier is generous** - Items last 5x longer than free
- **Clear upgrade path** - Each tier offers tangible protection
- **Still has consequence** - Even subscribers can lose items eventually

---

### 6C. Mr Fix-It Repair Service (Subscription Feature)

**Concept:** Passive background repair service for subscribers.

**Implementation:**

```typescript
interface MrFixItService {
  repairRate: number; // HP per hour
  simultaneousRepairs: number; // How many items repair at once
  costPerRepair: number; // Scrap cost per repair session
}

const MR_FIX_IT_CONFIG = {
  repairRate: 5, // 5 HP per hour (very slow!)
  simultaneousRepairs: 3, // Repairs 3 items at a time
  costPerRepair: 0, // Free for subscribers (or small fee?)
};

// Repair calculation (offline progression)
function calculateRepairs(lastLoginTime: Date, currentTime: Date, items: Item[]) {
  const hoursOffline = (currentTime - lastLoginTime) / (1000 * 60 * 60);
  const hpRestored = hoursOffline * MR_FIX_IT_CONFIG.repairRate;

  // Pick 3 most damaged items
  const damagedItems = items
    .filter((i) => i.durability.currentHP < i.durability.maxHP)
    .sort((a, b) => a.durability.durabilityPercent - b.durability.durabilityPercent)
    .slice(0, 3);

  damagedItems.forEach((item) => {
    item.durability.currentHP = Math.min(
      item.durability.currentHP + hpRestored,
      item.durability.maxHP
    );
  });

  return damagedItems;
}
```

**User Flow:**

```
1. Player dies → Items damaged
2. Player logs out
3. Mr Fix-It works while offline (subscription perk!)
4. Player logs in:
   "Mr Fix-It repaired 3 items while you were away!"
   - Legendary Sword: +40 HP
   - Epic Armor: +40 HP
   - Rare Boots: +40 HP (fully repaired!)
```

**UI Concept:**

```
┌─────────────────────────────────────┐
│  Mr Fix-It's Workshop  🔧           │
├─────────────────────────────────────┤
│  Currently Repairing:               │
│                                     │
│  [Legendary Sword]                  │
│  HP: 850/1600 ████████░░░░░░        │
│  Repair: +5 HP/hour                 │
│                                     │
│  [Epic Armor]                       │
│  HP: 400/800 ██████░░░░░░           │
│  Repair: +5 HP/hour                 │
│                                     │
│  [Rare Boots]                       │
│  HP: 200/400 ██████░░░░░░           │
│  Repair: +5 HP/hour                 │
│                                     │
│  ℹ️ Mr Fix-It repairs items slowly  │
│     while you're offline!           │
└─────────────────────────────────────┘
```

**Game Design Rationale:**

- **Subscription value:** Saves your items from destruction
- **Very slow:** 5 HP/hour = 20 hours to repair 100 HP
  - This is INTENTIONAL - prevents abuse
  - Legendary sword might take weeks to fully repair
  - Encourages "don't die!" gameplay
- **Offline progression:** Rewards coming back to the game
- **Strategic:** Prioritizes most damaged items first
- **Not pay-to-win:** Free players can just avoid death or re-farm items

**Free Player Alternative:**

- Free players can't repair items
- Items naturally degrade and eventually break
- Must re-acquire items through gameplay
- **This is OK** - creates economy, encourages re-engagement

---

### 6D. Component Yields from Recycling (AUTHORITATIVE)

**Concept:** Players can recycle unwanted items for components. Yield is based on item tier plus a luck bonus.

**Base Yields by Item Tier:**

| Item Tier | Base Components |
|-----------|-----------------|
| Tier 1 (Common) | 8 components |
| Tier 2 (Uncommon) | 20 components |
| Tier 3 (Rare) | 40 components |
| Tier 4 (Epic) | 80 components |

**Luck Bonus Formula:**

The player's luck stat provides up to +50% additional components at 100 luck.

```gdscript
const BASE_YIELDS = {
    1: 8,
    2: 20,
    3: 40,
    4: 80,
}

func calculate_component_yield(item_tier: int, luck: int) -> int:
    var base = BASE_YIELDS[item_tier]
    var luck_bonus = base * (luck / 100.0) * 0.5  # Up to +50% at 100 luck
    return base + int(luck_bonus)
```

**Yield Table by Luck:**

| Tier | 0 Luck | 25 Luck | 50 Luck | 75 Luck | 100 Luck |
|------|--------|---------|---------|---------|----------|
| 1 | 8 | 9 | 10 | 11 | 12 |
| 2 | 20 | 22 | 25 | 27 | 30 |
| 3 | 40 | 45 | 50 | 55 | 60 |
| 4 | 80 | 90 | 100 | 110 | 120 |

**Game Design Rationale:**
- **Base yields are meaningful** - Even 0 luck gives useful returns
- **Luck investment rewarded** - Players who build luck get 50% more components
- **Tier scaling is exponential** - Higher tier items = more valuable recycling
- **Economy sink** - Encourages item turnover instead of hoarding
- **Build diversity** - Luck builds have recycling advantage

---

## 7. Implementation Priority & Sprint Breakdown

### Inventory Sprint 1: Foundation (8-10 hours)

**Goal:** Core item system with durability

**Deliverables:**

1. **Item Database Service**
   - Item definitions (all types, rarities, stats)
   - Stack limit rules (by rarity)
   - Slot limit rules (by character type)
   - Weapon definitions

2. **Item Durability System**
   - Add `durability` field to Item model
   - Implement death penalty logic (rarity + type based)
   - Add durability UI indicators to ItemCard
   - Migration script (add durability to existing items)

3. **Character Inventory Limits**
   - Implement slot limits per character
   - Validate purchases against limits
   - UI feedback for limit violations

**Testing:**

- Unit tests for durability calculations
- Integration tests for death penalty
- Edge cases (item at 1 HP, destroy on next death)

---

### Inventory Sprint 2: UI & Polish (6-8 hours)

**Goal:** Player-facing inventory experience

**Deliverables:**

1. **Inventory Screen Redesign**
   - Use ItemCard components
   - Show durability bars on items
   - Sort/filter options (type, rarity, condition)
   - Item details modal (stats, durability, lore)

2. **Shop Integration**
   - Already using ItemCard (from Sprint 7B Task 2)
   - Add stack limit validation
   - Preview durability on new items (always 100%)

3. **Death Feedback**
   - Durability loss animation on death screen
   - List of damaged/destroyed items
   - "Your Legendary Sword took damage!" notifications

**Polish:**

- Item card animations (durability loss, destroy)
- Sound effects (item break is sad sound)
- Visual feedback (red flash on damaged items)

---

### Inventory Sprint 3: Quantum Banking (6-8 hours)

**Goal:** Subscription-tier features

**Deliverables:**

1. **Quantum Storage Scene**
   - Character selector (from/to)
   - Item transfer interface
   - Vault storage UI (unlimited for subscribers)
   - Transfer confirmation dialogs

2. **Quantum Banking Scene**
   - Scrap transfer interface
   - Fee calculator (show conversion rate)
   - Transfer history log
   - Balance preview (before/after)

3. **Mr Fix-It Service**
   - Offline repair calculations
   - Login reward screen ("Mr Fix-It Report")
   - Workshop UI (see repairs in progress)
   - Repair priority algorithm (most damaged first)

**Testing:**

- Subscription gate verification
- Transfer validations (enough slots, etc.)
- Fee calculations
- Offline progression accuracy

---

## 8. Technical Implementation Notes

### Database Schema Updates

```typescript
// Item Model (Updated)
interface Item {
  id: string;
  itemDefinitionId: string; // FK to item_definitions table
  characterId: string; // Which character owns this
  acquiredAt: Date;
  durability: {
    currentHP: number;
    maxHP: number;
  };
}

// Item Definition (Template)
interface ItemDefinition {
  id: string;
  name: string;
  description: string;
  rarity: Rarity;
  type: 'weapon' | 'armor' | 'utility';
  stats: ItemStats;
  baseDurability: number; // Varies by rarity
  stackLimit: number; // Varies by rarity
  cost: number;
  iconUrl: string;
}

// Character Inventory Metadata
interface CharacterInventoryConfig {
  characterType: string;
  totalSlots: number;
  slotsByType: {
    weapon: number;
    armor: number;
    utility: number;
  };
}
```

### Services to Create

```typescript
// ItemDurabilityService
class ItemDurabilityService {
  applyDeathPenalty(items: Item[]): DeathPenaltyResult;
  calculateRepairs(items: Item[], hoursOffline: number): RepairResult;
  destroyItem(itemId: string): void;
  getItemCondition(item: Item): 'excellent' | 'good' | 'fair' | 'poor' | 'critical';
}

// QuantumBankingService (Subscription only)
class QuantumBankingService {
  transferItem(fromCharId: string, toCharId: string, itemId: string): Promise<void>;
  transferScrap(fromCharId: string, toCharId: string, amount: number): Promise<TransferResult>;
  calculateFee(amount: number): number;
  getVaultItems(userId: string): Promise<Item[]>;
}

// ItemLimitService
class ItemLimitService {
  canAcquireItem(characterId: string, itemDefId: string): ValidationResult;
  getAvailableSlots(characterId: string): SlotInfo;
  validateStackLimit(characterId: string, itemDefId: string): boolean;
}
```

---

## 9. Monetization Strategy Summary

### Tier Comparison

| Feature             | Free        | Premium     | Subscription      |
| ------------------- | ----------- | ----------- | ----------------- |
| **Character Slots** | 3           | 10          | Unlimited         |
| **Character Types** | 3 basic     | 5 types     | All types         |
| **Item Slots/Char** | 30          | 30          | 30                |
| **Quantum Storage** | ❌          | ❌          | ✅ Unlimited      |
| **Quantum Banking** | ❌          | ❌          | ✅ With fees      |
| **Mr Fix-It**       | ❌          | ❌          | ✅ Passive repair |
| **Item Durability** | ✅ Degrades | ✅ Degrades | ✅ Auto-repair    |

### Value Proposition

**Free → Premium ($9.99 one-time):**

- "Build 10 different characters with unique playstyles"
- "Unlock specialist character types"
- Value: More variety, more replayability

**Premium → Subscription ($4.99/month):**

- "Master resource management across all characters"
- "Never lose your legendary items with Mr Fix-It"
- "Transfer items and scrap freely between characters"
- Value: Convenience + item protection

---

## 10. Future Considerations

### Potential Future Features

1. **Item Enhancement System**
   - Upgrade items to increase stats
   - Costs scrap + another item as "fuel"
   - Increases max durability too

2. **Item Insurance (Premium Feature?)**
   - Pay scrap to "insure" an item
   - If destroyed, get 50% of cost back
   - Adds strategic choice ("insure my legendary?")

3. **Weapon Loadouts**
   - Save/load item builds
   - Quick-swap between builds
   - Subscription feature?

4. **Item Trading (Multiplayer)**
   - Player-to-player trades
   - Requires both players premium+
   - Trade history, scam protection

5. **Item Skins/Cosmetics**
   - Visual customization
   - No stat changes
   - Monetization opportunity

---

## 11. Key Design Decisions Summary

✅ **Decisions Made (Alan Approved):**

1. **Inventory Model:** Brotato-style auto-active (Option A)
2. **Item Limits:** Character-type based slots (Option C)
3. **Tier Differentiation:** More character types per tier
4. **Stacking:** Hard limits by rarity (Option C)
   - Common: 5, Uncommon: 4, Rare: 3, Epic: 2, Legendary: 1
5. **Quantum Banking:** Full suite in Subscription tier only (Option A)
   - Storage + Banking both subscription
6. **Weapons:** Passive/auto-active like items (Option A)
7. **Durability:** Rarity-based + Type-based formula
8. **Mr Fix-It:** Subscription perk, 5 HP/hour, 3 items at once
9. **Death Penalty:** Random 80-120% of base penalty

---

## Next Steps

**Immediate:**

1. ✅ Complete Sprint 7B Tasks 2 & 3
2. Create database migration for durability system
3. Begin Inventory Sprint 1 (Foundation)

**Documentation:**

- This design doc is the spec
- Will be updated as implementation progresses
- All team members (current: Alan + Claude) must follow this

---

**Document Status:** ✅ APPROVED  
**Ready for Implementation:** YES  
**Sprint Target:** Inventory Sprints (11-13) after Premium Features (Sprint 8-9)
