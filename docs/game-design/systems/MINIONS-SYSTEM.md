# Minions System

**Status:** NEAR-TERM - Data model needed soon
**Tier Access:** Premium (3 total slots), Subscription (+1 per character)
**Implementation Phase:** Weeks 8-10 (after core gameplay)

---

## 1. System Overview

The Minions System adds **combat companions** (bots, pets, contractors) that fight alongside characters in The Wasteland. Minions provide different benefits and drawbacks, adding strategic depth and personalization to gameplay.

**Key Features:**
- One active minion per character in combat
- Minions can level, take damage, and die
- Stored in Barracks (accessible from Scrapyard)
- Bound to specific character instances (not global)
- Premium/Subscription exclusive feature

---

## 2. Core Concepts

### 2.1 What is a Minion?

A **minion** is a combat companion with:
- **Stats:** HP, damage, speed, defense
- **Type:** Bot (mechanical), Pet (organic), Contractor (humanoid)
- **Abilities:** Special powers (healing, tanking, DPS)
- **Vulnerabilities:** Weak to specific damage types
- **Leveling:** Gains power through rare food/items
- **Mortality:** Can be damaged and permanently die

### 2.2 Minion vs Weapon/Item

| Aspect | Minion | Weapon/Item |
|--------|--------|-------------|
| **Active in combat** | Acts independently | Player-controlled |
| **Can die** | Yes (permanent loss) | Yes (durability) |
| **Can level** | Yes (special mechanism) | No (fusion instead) |
| **Uses items** | No | N/A |
| **Limit** | 1 active at a time | Multiple |
| **Storage** | Barracks | Inventory |
| **Transferable** | No (character-bound) | Via Quantum Storage (Sub) |

---

## 3. Minion Types

### 3.1 Bot (Mechanical Minion)

**Archetype:** Durable tank, moderate damage

**Strengths:**
- High HP and armor
- Resistant to physical damage
- Can taunt enemies

**Weaknesses:**
- Vulnerable to energy damage (-25%)
- Slow movement speed
- No self-healing

**Example Bots:**
- **Scrap Golem:** Absorbs damage, taunts enemies
- **Turret Drone:** Stationary, high ranged DPS
- **Shield Bot:** Projects damage shield for player

### 3.2 Pet (Organic Minion)

**Archetype:** Fast DPS, low durability

**Strengths:**
- High movement speed
- High attack speed
- Can dodge attacks

**Weaknesses:**
- Vulnerable to physical damage (-25%)
- Low HP
- No armor

**Example Pets:**
- **Mutant Hound:** Fast melee attacks, life steal
- **Scavenger Rat:** Finds extra scrap, fast
- **Acid Wasp:** Ranged poison damage over time

### 3.3 Contractor (Humanoid Minion)

**Archetype:** Balanced, versatile

**Strengths:**
- Can use consumables (limited pool)
- Balanced stats
- Can revive player (once per run)

**Weaknesses:**
- Vulnerable to mutant damage (-25%)
- No specialization (jack of all trades)
- Higher upkeep cost

**Example Contractors:**
- **Merc Soldier:** Balanced fighter, can use medkits
- **Scavenger Scout:** Reveals map, finds loot
- **Mad Scientist:** Throws grenades, buffs player

---

## 4. Minion Stats & Leveling

### 4.1 Base Stats

```gdscript
class Minion:
    var id: String                  # Unique instance ID
    var template_id: String         # Minion type (e.g., "scrap_golem")
    var name: String                # Display name
    var type: String                # "bot", "pet", "contractor"
    var level: int = 1              # Current level (1-20)
    var xp: int = 0                 # XP toward next level
    var max_hp: int                 # Max health
    var current_hp: int             # Current health
    var damage: int                 # Base damage
    var attack_speed: float         # Attacks per second
    var movement_speed: float       # Units per second
    var armor: int                  # Damage reduction
    var abilities: Array[String]    # Special abilities
    var vulnerabilities: Dictionary # Damage type weaknesses
    var character_id: String        # Owning character ID
    var is_alive: bool = true       # Death status
    var created_at: String          # Creation timestamp
```

### 4.2 Leveling Mechanism

**Unlike characters, minions level via rare consumables:**

```gdscript
# Minion leveling items (rare drops)
enum MinionFoodRarity:
    COMMON,      # +10 XP
    UNCOMMON,    # +25 XP
    RARE,        # +50 XP
    EPIC,        # +100 XP
    LEGENDARY    # +250 XP

# XP required scales with level
func get_xp_required(level: int) -> int:
    return 100 * level  # Level 1 → 100 XP, Level 2 → 200 XP, etc.
```

**Why not combat XP?**
- Prevents infinite grinding
- Makes minion leveling strategic (resource management)
- Creates demand for minion food drops

### 4.3 Level-Up Bonuses

Each level grants:
- +10% HP
- +10% damage
- +5% attack speed
- Every 5 levels: Unlock new ability

---

## 5. Combat Mechanics

### 5.1 Minion AI

Minions act independently based on AI behavior:

```gdscript
class MinionAI:
    var behavior: String  # "aggressive", "defensive", "support"
    var target_priority: String  # "nearest", "weakest", "strongest"
    var retreat_threshold: float  # HP % to retreat (0.2 = 20%)

# Example: Scrap Golem (defensive tank)
var golem_ai = MinionAI.new()
golem_ai.behavior = "defensive"
golem_ai.target_priority = "nearest"
golem_ai.retreat_threshold = 0.0  # Never retreats
```

### 5.2 Damage Vulnerabilities

Each minion type is vulnerable to a specific damage type:

| Minion Type | Vulnerable To | Damage Modifier |
|-------------|--------------|-----------------|
| Bot | Energy | +25% damage taken |
| Pet | Physical (melee/ranged) | +25% damage taken |
| Contractor | Mutant | +25% damage taken |

This creates strategic depth - choose minion based on enemy types.

### 5.3 Minion Death

When a minion reaches 0 HP:
1. **Permanent death** - Minion is destroyed
2. **No revival** - Cannot be revived (unlike player)
3. **Loss of investment** - All levels and XP lost
4. **Barracks slot freed** - Slot becomes available

**Exception:** Minion Fabricator (subscription idle feature) can clone minions.

---

## 6. Barracks System

### 6.1 Storage Location

**Barracks** is a Scrapyard feature where minions are stored.

**Access:** Scrapyard → Barracks

**Capacity:**
- **Premium:** 3 minion slots total (shared across all characters)
- **Subscription:** +1 slot per character instance

**Example:**
- Premium user with 5 characters: 3 minion slots total
- Subscription user with 5 characters: 8 minion slots (3 base + 5 character-specific)

### 6.2 Minion Binding

**Minions are bound to the character instance that acquired them:**

```gdscript
# When player finds/buys minion
func acquire_minion(minion_template_id: String, character_id: String):
    var minion = Minion.new()
    minion.template_id = minion_template_id
    minion.character_id = character_id  # Bound to this character
    minion.level = 1
    BarracksService.add_minion(minion)
```

**Cannot transfer minions between characters** (even with Quantum Storage).

### 6.3 Barracks UI

**Features:**
- View all owned minions
- See minion stats (HP, damage, level, XP)
- Equip minion to character (1 active)
- Unequip minion
- Feed minion (level up with food items)
- Delete minion (free up slot)

---

## 7. Acquisition Methods

### 7.1 Drops (Random)

Minions can drop from elite enemies in The Wasteland:

```gdscript
# Drop rates (example)
var drop_rates = {
    "common_minion": 0.05,     # 5% from normal elites
    "uncommon_minion": 0.02,   # 2% from rare elites
    "rare_minion": 0.005,      # 0.5% from bosses
    "epic_minion": 0.001       # 0.1% from raid bosses
}
```

### 7.2 Shop Purchase

Minions occasionally appear in:
- **Shop** (Scrapyard) - Common/Uncommon minions
- **Black Market** (Premium/Sub) - Rare/Epic minions
- **Atomic Vending Machine** (Sub) - Personalized Epic/Legendary minions

### 7.3 Crafting (Workshop)

Players can craft minions using rare blueprints:

```gdscript
# Minion blueprint recipe
var scrap_golem_blueprint = {
    "minion_id": "scrap_golem",
    "requirements": {
        "scrap": 5000,
        "workshop_components": 200,
        "blueprint": "scrap_golem_blueprint"  # Rare drop
    }
}
```

### 7.4 Minion Fabricator (Subscription Idle Feature)

Subscription users can **clone minions** via Minion Fabricator:

**How it works:**
1. Store minion pattern (costs 10,000 scrap + 500 components)
2. Clone minion from pattern (costs 5,000 scrap)
3. Each clone is weaker than previous (-5% to -15% stats, random)
4. Pattern has "viability" stat (starts at 100)
5. Each clone reduces viability by random amount (5-15 points)
6. At 0 viability, pattern is destroyed

**Example:**
- Original minion: Level 10 Scrap Golem (1000 HP, 50 damage)
- Store pattern: 100 viability
- Clone 1: 95 viability, -10% stats (900 HP, 45 damage)
- Clone 2: 82 viability, -8% stats (828 HP, 41 damage)
- ... Clone 8: 0 viability, pattern destroyed

**Why this system?**
- Prevents infinite minion farming
- Creates scarcity (only ~10 clones per pattern)
- Makes original minions more valuable
- Subscription exclusive benefit

---

## 8. Minion Abilities

### 8.1 Common Abilities (Level 1)

- **Taunt** (Bot) - Draws enemy aggro for 5 seconds
- **Dash** (Pet) - Fast movement burst, dodge attacks
- **Heal** (Contractor) - Heals player for 10% max HP

### 8.2 Uncommon Abilities (Level 5)

- **Shield Projection** (Bot) - Projects damage shield (50 HP)
- **Poison Bite** (Pet) - DoT (damage over time) poison
- **Buff Aura** (Contractor) - +10% player damage in radius

### 8.3 Rare Abilities (Level 10)

- **Self-Repair** (Bot) - Regenerates 5% HP per second
- **Life Steal** (Pet) - Steals 20% damage as HP
- **Revive** (Contractor) - Revives player once per run

### 8.4 Epic Abilities (Level 15)

- **Explosion on Death** (Bot) - Deals AoE damage on death
- **Frenzy** (Pet) - 2x attack speed at <50% HP
- **Supply Drop** (Contractor) - Spawns consumables

### 8.5 Legendary Abilities (Level 20)

- **Invulnerability** (Bot) - 3 seconds invincible (1x per run)
- **Execute** (Pet) - Instant kill enemies <10% HP
- **Resurrection** (Contractor) - Revives player with full HP

---

## 9. Data Model

### 9.1 Local Storage

```gdscript
# Stored in SaveSystem (LocalStorage)
class MinionData:
    var id: String
    var template_id: String
    var name: String
    var type: String
    var level: int
    var xp: int
    var max_hp: int
    var current_hp: int
    var damage: int
    var attack_speed: float
    var movement_speed: float
    var armor: int
    var abilities: Array[String]
    var vulnerabilities: Dictionary
    var character_id: String
    var is_alive: bool
    var created_at: String
```

### 9.2 Supabase Sync (Future)

```sql
CREATE TABLE minions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  character_id UUID REFERENCES character_instances(id) NOT NULL,
  template_id VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL,
  level INT DEFAULT 1,
  xp INT DEFAULT 0,
  max_hp INT NOT NULL,
  current_hp INT NOT NULL,
  damage INT NOT NULL,
  attack_speed FLOAT NOT NULL,
  movement_speed FLOAT NOT NULL,
  armor INT NOT NULL,
  abilities JSONB NOT NULL,
  vulnerabilities JSONB NOT NULL,
  is_alive BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_minions_character_id ON minions(character_id);
CREATE INDEX idx_minions_user_id ON minions(user_id);
```

---

## 10. Integration with Other Systems

### 10.1 Combat System

Minions participate in combat:
- Spawn alongside player in The Wasteland
- Target enemies based on AI behavior
- Take damage from enemy attacks
- Deal damage to enemies
- Trigger abilities based on conditions

### 10.2 Quantum Storage (Subscription)

**Minions CANNOT be transferred via Quantum Storage.**
- Minions are permanently bound to character instance
- This is intentional to prevent minion trading exploits

### 10.3 Trading Cards

Minions appear on character trading cards:
- Show active minion portrait
- Display minion name, level, type
- Include minion stats in card data

### 10.4 Workshop

Workshop can craft minions from blueprints:
- Craft new minions
- Cannot repair damaged minions (they must heal naturally or via abilities)

### 10.5 Perks System

Perks can affect minions:
- "+20% minion damage this week"
- "Minions have +50% HP"
- "Minion abilities cooldown 25% faster"

**Hook point:** `minion_spawned`, `minion_damaged`, `minion_ability_used`

---

## 11. Tier-Specific Features

### 11.1 Free Tier
- **Access:** None (minions disabled)

### 11.2 Premium Tier
- **Barracks Slots:** 3 total (shared across all characters)
- **Minion Sources:** Drops, Shop, Crafting
- **Features:**
  - Equip 1 minion per character
  - Feed minions to level up
  - Craft minions from blueprints

### 11.3 Subscription Tier
- **Barracks Slots:** 3 base + 1 per character instance
  - Example: 5 characters = 8 slots total
- **Minion Sources:** All Premium sources + Atomic Vending Machine
- **Features:**
  - All Premium features
  - Personalized minions from Atomic Vending Machine
  - Minion Fabricator (clone minions)
  - Minion idle healing (Mr. FixIT for minions)

---

## 12. Balancing Considerations

### 12.1 Minion Power Level

Minions should be **helpful but not overpowered:**
- Minion DPS should be ~20-30% of player DPS
- Minion HP should be ~50% of player HP
- Minions provide utility, not carry the player

### 12.2 Death Penalty

Minion death is **permanent** to create stakes:
- Encourages careful play
- Makes minion leveling meaningful
- Creates demand for new minions (economy sink)

### 12.3 Leveling Speed

Minion leveling should be **slower than character leveling:**
- Requires rare food items (not combat XP)
- Creates long-term progression goal
- Makes high-level minions prestigious

---

## 13. Implementation Phases

### Phase 1: Data Model & Storage (Week 8)
- Create Minion class and data structures
- Add minion storage to SaveSystem
- Create BarracksService stub
- Add minion templates (10-15 minions)

### Phase 2: Barracks UI (Week 9)
- Build Barracks screen (Scrapyard menu)
- Minion list view
- Minion equip/unequip
- Minion feeding (level up)

### Phase 3: Combat Integration (Week 10)
- Minion spawning in combat
- Minion AI behavior
- Minion damage/death
- Minion abilities

### Phase 4: Acquisition & Crafting (Week 11)
- Minion drops from enemies
- Minion shop listings
- Workshop minion crafting
- Atomic Vending Machine minions

### Phase 5: Advanced Features (Week 12+)
- Minion Fabricator (cloning)
- Minion perks integration
- Minion achievements
- Minion trading cards

---

## 14. Open Questions

1. **Minion Inventory:** Do minions have their own inventory for consumables (Contractors)?
2. **Minion Customization:** Can players rename/recolor minions?
3. **Minion Rarity:** Should minions have rarity tiers (common/uncommon/rare/epic/legendary)?
4. **Minion Evolution:** Can minions evolve into stronger forms at certain levels?
5. **Minion Trading:** Should Quantum Storage allow minion transfers (current answer: NO)?

---

## 15. Summary

The Minions System adds combat companions with:
- **3 types:** Bot (tank), Pet (DPS), Contractor (utility)
- **Leveling:** Via rare food items, not combat XP
- **Death:** Permanent, creates stakes
- **Storage:** Barracks (3 slots Premium, +1/character Subscription)
- **Binding:** Character-bound, no transfers
- **Fabricator:** Subscription can clone minions (limited viability)

**Next Steps:**
1. Create minion data model (Week 8)
2. Build BarracksService
3. Design 10-15 minion templates
4. Plan combat AI integration

**Status:** Ready for data model design in Week 8 planning.
