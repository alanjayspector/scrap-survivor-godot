# Perks System

**Status:** CRITICAL - Architectural hooks needed NOW
**Tier Access:** Premium (TBD), Subscription (1x/week)
**Implementation Phase:** Foundation hooks in Week 6, full system in Phase 4

---

## 1. System Overview

The Perks System allows server-side injection of temporary gameplay modifiers ("perks") without requiring client updates. This enables:
- Dynamic gameplay changes (weekly subscription perks)
- Marketing campaigns (regional/holiday perks)
- A/B testing of game balance
- Personalized player experiences

Think of perks as **scheduled mods** that the operator can turn on/off remotely for specific user segments.

---

## 2. Core Concepts

### 2.1 What is a Perk?

A perk is a **server-defined gameplay modifier** that hooks into specific game events to alter behavior.

**Example Perks:**
- "+10 HP to all new characters created this week"
- "Double scrap drops on Día de los Muertos (Latin America only)"
- "25% faster workshop repairs for Premium users"
- "+5% crit chance when using ranged weapons"

### 2.2 Perk Properties

```gdscript
class Perk:
    var id: String                    # Unique perk ID
    var name: String                  # Display name
    var description: String           # Player-facing description
    var is_active: bool               # Current activation status
    var created_at: String            # Server timestamp
    var expires_at: String            # Expiration (null = permanent)
    var source: String                # "marketing", "subscription", "admin"
    var target_criteria: Dictionary   # User filtering (tier, region, etc)
    var hook_points: Array[String]    # Which hooks this perk uses
    var config: Dictionary            # Perk-specific parameters
    var priority: String              # "front" or "back" (FIFO insertion)
```

### 2.3 Perk Lifecycle

1. **Creation** - Operator creates perk via admin tool
2. **Distribution** - Server sends perk to matching clients
3. **Activation** - Client applies perk to active perks queue
4. **Execution** - Perk hooks fire during gameplay events
5. **Expiration** - Perk auto-removes at expiry time
6. **Deletion** - Operator can force-delete perk from all clients

---

## 3. Hook Points (CRITICAL ARCHITECTURE)

Perks must be able to inject behavior at these game events:

### 3.1 Character Lifecycle Hooks

```gdscript
# CharacterService.create_character()
signal character_created(character_data: Dictionary)
# Perks can: Modify stats, add items, grant currency

# CharacterService.level_up()
signal character_leveled_up(character_id: String, new_level: int)
# Perks can: Add bonus stat points, unlock features

# CharacterService.on_death()
signal character_died(character_id: String, death_context: Dictionary)
# Perks can: Reduce death penalties, grant resurrection, bonus XP
```

### 3.2 Combat Hooks (The Wasteland)

```gdscript
# CombatService.apply_damage()
signal damage_dealt(attacker_id: String, target_id: String, damage: float, type: String)
# Perks can: Modify damage, add effects, trigger special abilities

signal damage_received(character_id: String, damage: float, source: String)
# Perks can: Reduce damage, trigger shields, activate counters

# CombatService.heal()
signal character_healed(character_id: String, amount: float, source: String)
# Perks can: Increase healing, add buffs, trigger regeneration

# CombatService.life_steal()
signal life_stolen(character_id: String, amount: float)
# Perks can: Increase life steal %, add bonus effects
```

### 3.3 Movement Hooks

```gdscript
# MovementService.move()
signal character_moved(character_id: String, old_pos: Vector2, new_pos: Vector2)
# Perks can: Grant speed boosts, create trails, trigger events
```

### 3.4 Economy Hooks

```gdscript
# Shop, Black Market, Atomic Vending Machine
signal shop_purchase(character_id: String, item_id: String, cost: int)
# Perks can: Discounts, free items, bonus purchases

# Workshop
signal workshop_action(character_id: String, action: String, item_id: String)
# Perks can: Reduce costs, speed up operations, improve results
```

### 3.5 Complete Hook List

| Hook Point | Service | Event | Perk Can Modify |
|-----------|---------|-------|-----------------|
| `character_created` | CharacterService | New character | Stats, items, currency |
| `character_leveled_up` | CharacterService | Level up | Stat bonuses, unlocks |
| `character_died` | CharacterService | Death | Penalties, rewards |
| `damage_dealt` | CombatService | Attack lands | Damage amount, effects |
| `damage_received` | CombatService | Takes damage | Damage reduction, shields |
| `character_healed` | CombatService | Healing | Heal amount, buffs |
| `life_stolen` | CombatService | Life steal | Steal %, bonus effects |
| `character_moved` | MovementService | Movement | Speed, trails, events |
| `shop_purchase` | ShopService | Buy item | Cost, bonus items |
| `workshop_action` | WorkshopService | Repair/fuse/craft | Cost, speed, quality |

**CRITICAL:** All these hooks MUST be added to services during implementation.

---

## 4. Perk Application (FIFO with Priority)

### 4.1 Perk Queue

Perks are stored in a FIFO queue and applied in order:

```gdscript
var active_perks: Array[Perk] = []

func apply_perk(perk: Perk):
    if perk.priority == "front":
        active_perks.push_front(perk)  # First to execute
    else:  # priority == "back"
        active_perks.push_back(perk)   # Last to execute
```

### 4.2 Hook Execution

When a hook fires, all perks listening to that hook execute in queue order:

```gdscript
func _fire_hook(hook_name: String, context: Dictionary):
    for perk in active_perks:
        if perk.is_active and hook_name in perk.hook_points:
            _execute_perk(perk, hook_name, context)
```

### 4.3 Perk Execution

Each perk has a config that defines its behavior:

```gdscript
func _execute_perk(perk: Perk, hook_name: String, context: Dictionary):
    match hook_name:
        "character_created":
            if "bonus_hp" in perk.config:
                context.stats.max_hp += perk.config.bonus_hp
        "damage_dealt":
            if "damage_multiplier" in perk.config:
                context.damage *= perk.config.damage_multiplier
        # ... etc for all hook points
```

---

## 5. Server-Client Architecture

### 5.1 Server (Supabase Edge Functions)

**Perk Distribution:**
```typescript
// Edge Function: GET /api/perks/active
// Returns perks matching user criteria

function getActivePerks(userId: string): Perk[] {
  const user = getUser(userId);
  const allPerks = db.query("SELECT * FROM perks WHERE is_active = true");

  return allPerks.filter(perk => {
    // Filter by tier
    if (perk.target_criteria.tier && user.tier < perk.target_criteria.tier) {
      return false;
    }

    // Filter by region
    if (perk.target_criteria.region && user.region !== perk.target_criteria.region) {
      return false;
    }

    // Check expiration
    if (perk.expires_at && new Date(perk.expires_at) < new Date()) {
      return false;
    }

    return true;
  });
}
```

**Perk Deletion Signal:**
```typescript
// Edge Function: POST /api/perks/:perk_id/delete
// Triggers delete signal to all clients
function deletePerk(perkId: string) {
  db.update("perks", { is_active: false, deleted_at: new Date() }, { id: perkId });

  // Send realtime deletion signal
  supabase.channel("perks").send({
    type: "broadcast",
    event: "perk_deleted",
    payload: { perk_id: perkId }
  });
}
```

### 5.2 Client (Godot)

**Perk Sync Service:**
```gdscript
# services/PerksService.gd
class_name PerksService
extends Node

signal perks_updated(perks: Array[Perk])
signal perk_deleted(perk_id: String)

var active_perks: Array[Perk] = []

func _ready():
    # Sync perks on startup
    sync_perks()

    # Subscribe to realtime updates
    SupabaseService.subscribe_to_channel("perks", _on_perk_update)

func sync_perks():
    var response = await SupabaseService.call_edge_function("perks/active")
    if response.success:
        active_perks = _parse_perks(response.data)
        perks_updated.emit(active_perks)

func _on_perk_update(payload: Dictionary):
    if payload.event == "perk_deleted":
        remove_perk(payload.perk_id)
    elif payload.event == "perk_created":
        add_perk(payload.perk)
```

---

## 6. Tier-Specific Perk Rules

### 6.1 Free Tier
- **Access:** None (perks disabled)
- **Marketing Exception:** Promotional perks can target Free tier

### 6.2 Premium Tier
- **Access:** TBD (to be defined with Alan)
- **Frequency:** TBD
- **Type:** Permanent or limited-time
- **Examples:**
  - Holiday perks (Halloween, Christmas)
  - Regional perks (Día de los Muertos for Latin America)
  - Marketing campaign perks

### 6.3 Subscription Tier
- **Access:** 1 perk per week
- **Duration:** 7 days (auto-expires)
- **Type:** Always positive gameplay modifiers
- **Personalization:** Uses Personalization System to tailor perks
- **Examples:**
  - "Your Scavenger gets +15% luck this week" (personalized)
  - "All ranged weapons deal +10% damage"
  - "Workshop repairs are 50% faster"

### 6.4 Perk Opt-Out

**All tiers can opt out of perks:**
- Settings toggle: "Enable Perks" (default: ON)
- If disabled, no perks are presented to the user
- Opt-out is all-or-nothing (can't pick specific perks)

---

## 7. Admin Tools (Internal System)

### 7.1 Perk Builder Wizard

The operator needs a tool to create perks without code deployment:

**Required Features:**
- Perk template library (common perk patterns)
- Target criteria builder (tier, region, date range)
- Hook configuration (which events to modify)
- Parameter editor (damage multipliers, stat bonuses, etc.)
- Preview mode (test perk before activation)
- Scheduling (activate at specific date/time)

**Example Perk Creation Flow:**
1. Select template: "Stat Bonus Perk"
2. Configure: +10 HP to new characters
3. Set criteria: Premium tier, US region
4. Set duration: Oct 31 - Nov 7 (Halloween week)
5. Set priority: "back" (apply after other perks)
6. Preview & Test
7. Schedule activation

### 7.2 Perk Management Dashboard

**Features:**
- List all active perks
- View perk usage stats (how many users have it)
- Deactivate/delete perks
- Clone perks for quick iteration
- A/B testing support (create perk variants)

### 7.3 Perk Analytics

**Metrics to track:**
- Perk adoption rate (% of eligible users who have it)
- Gameplay impact (damage dealt, death rate, etc.)
- Engagement impact (session length, retention)
- Conversion impact (Premium/Sub sign-ups during perk period)

---

## 8. Personalization Integration

Subscription perks use the **Personalization System** to tailor recommendations.

**Example:**
```gdscript
# User's personalization profile (from Personalization System)
var profile = {
    "favorite_character_type": "scavenger",
    "preferred_playstyle": "ranged_dps",
    "preferred_perks": ["damage_boost", "speed_increase"]
}

# Perk recommendation engine
func recommend_weekly_perk(profile: Dictionary) -> Perk:
    if profile.preferred_playstyle == "ranged_dps":
        return create_perk({
            "name": "Sharpshooter",
            "description": "Your ranged weapons deal +15% damage",
            "hook_points": ["damage_dealt"],
            "config": {
                "damage_multiplier": 1.15,
                "weapon_type_filter": "ranged"
            }
        })
    # ... other personalizations
```

---

## 9. Security & Validation

### 9.1 Client-Side Validation

**Perks must be validated on client to prevent cheating:**

```gdscript
func validate_perk(perk: Perk) -> bool:
    # Verify perk signature (cryptographic hash)
    if not _verify_signature(perk):
        GameLogger.log_warning("Invalid perk signature: " + perk.id)
        return false

    # Verify perk hasn't expired
    if perk.expires_at and Time.get_unix_time_from_system() > perk.expires_at:
        return false

    # Verify user meets criteria
    if not _meets_criteria(perk.target_criteria):
        return false

    return true
```

### 9.2 Server-Side Enforcement

**Critical gameplay actions must re-validate perks on server:**

```typescript
// When processing damage, re-check perks server-side
function applyDamage(attackerId: string, damage: float): float {
  const perks = getActivePerks(attackerId);
  let modifiedDamage = damage;

  for (const perk of perks) {
    if (perk.hook_points.includes("damage_dealt")) {
      modifiedDamage *= perk.config.damage_multiplier || 1.0;
    }
  }

  return modifiedDamage;
}
```

---

## 10. Example Perks

### 10.1 Marketing Perk: "Lunar New Year Luck"
```json
{
  "id": "perk_lunar_2026",
  "name": "Lunar New Year Luck",
  "description": "+20 Luck for all characters during Lunar New Year",
  "is_active": true,
  "expires_at": "2026-02-17T23:59:59Z",
  "source": "marketing",
  "target_criteria": {
    "region": "asia_pacific",
    "tier": 0
  },
  "hook_points": ["character_created"],
  "config": {
    "bonus_stats": {
      "luck": 20
    }
  },
  "priority": "back"
}
```

### 10.2 Subscription Perk: "Wasteland Warrior"
```json
{
  "id": "perk_sub_week_23",
  "name": "Wasteland Warrior",
  "description": "Deal 15% more damage in The Wasteland",
  "is_active": true,
  "expires_at": "2025-11-16T23:59:59Z",
  "source": "subscription",
  "target_criteria": {
    "tier": 2
  },
  "hook_points": ["damage_dealt"],
  "config": {
    "damage_multiplier": 1.15
  },
  "priority": "back"
}
```

### 10.3 Personalized Perk: "Scavenger's Bounty"
```json
{
  "id": "perk_personalized_user_12345",
  "name": "Scavenger's Bounty",
  "description": "Your Scavenger finds 25% more scrap",
  "is_active": true,
  "expires_at": "2025-11-16T23:59:59Z",
  "source": "subscription",
  "target_criteria": {
    "tier": 2,
    "user_id": "12345"
  },
  "hook_points": ["damage_dealt"],
  "config": {
    "scrap_drop_multiplier": 1.25,
    "character_type_filter": "scavenger"
  },
  "priority": "back"
}
```

---

## 11. Implementation Phases

### Phase 1: Foundation (Week 6 - CharacterService)
- ✅ Add signal hooks to CharacterService
- ✅ Create PerksService stub (no perks loaded yet)
- ✅ Document hook points for other services

### Phase 2: Basic Perks (Weeks 8-10)
- Implement PerksService with server sync
- Add hooks to CombatService, ShopService, WorkshopService
- Create perk validation and execution logic
- Test with simple perks (stat bonuses)

### Phase 3: Full System (Weeks 12-14)
- Build admin perk builder tool
- Implement personalization integration
- Add analytics and A/B testing
- Test complex perks (multi-hook perks)

### Phase 4: Advanced Features (Post-Launch)
- Perk marketplace (users can vote on perks)
- Community-created perks (modding support)
- Advanced personalization (ML-based recommendations)

---

## 12. Database Schema

```sql
-- Perks table (Supabase)
CREATE TABLE perks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  source VARCHAR(50) NOT NULL, -- 'marketing', 'subscription', 'admin'
  target_criteria JSONB NOT NULL, -- {tier: 2, region: 'us', etc}
  hook_points TEXT[] NOT NULL, -- ['character_created', 'damage_dealt']
  config JSONB NOT NULL, -- Perk-specific parameters
  priority VARCHAR(10) NOT NULL DEFAULT 'back', -- 'front' or 'back'
  signature VARCHAR(255) NOT NULL -- Cryptographic hash for validation
);

-- User perks (many-to-many)
CREATE TABLE user_perks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  perk_id UUID REFERENCES perks(id) NOT NULL,
  activated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ, -- Copied from perk for fast queries
  is_opted_out BOOLEAN DEFAULT false
);

-- Perk analytics
CREATE TABLE perk_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  perk_id UUID REFERENCES perks(id) NOT NULL,
  user_id UUID REFERENCES user_accounts(id),
  event VARCHAR(50) NOT NULL, -- 'activated', 'executed', 'expired'
  context JSONB, -- Event-specific data
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_perks_active ON perks(is_active) WHERE is_active = true;
CREATE INDEX idx_user_perks_user_id ON user_perks(user_id);
CREATE INDEX idx_user_perks_expires_at ON user_perks(expires_at);
```

---

## 13. Testing Strategy

### 13.1 Unit Tests
- Perk validation logic
- Hook execution order (FIFO)
- Perk application (stat modifiers, damage multipliers)
- Expiration handling

### 13.2 Integration Tests
- Server-client perk sync
- Realtime perk deletion
- Multi-perk interactions (stacking, conflicts)
- Personalization integration

### 13.3 E2E Tests
- Full perk lifecycle (create → distribute → activate → execute → expire)
- Admin tool perk creation
- A/B testing scenarios

---

## 14. Open Questions

1. **Perk Stacking:** If two perks both modify damage, do they stack additively or multiplicatively?
2. **Perk Conflicts:** What happens if two perks conflict (e.g., one increases HP, one decreases HP)?
3. **Perk Limits:** Should there be a limit to how many perks a user can have active?
4. **Perk Rollback:** If a perk is deleted mid-session, do we rollback its effects immediately?
5. **Premium Perk Strategy:** What types of perks should Premium tier get? How often?

---

## 15. Summary

The Perks System is a **critical architectural decision** that requires hooks in ALL services. It enables:
- Weekly subscription value (changing gameplay)
- Marketing campaigns without app updates
- Personalized player experiences
- A/B testing and experimentation

**Next Steps:**
1. Add signal hooks to CharacterService (Week 6)
2. Document hook points for all services
3. Create PerksService stub
4. Plan admin tool development

**Status:** Ready for hook implementation in Week 6 CharacterService work.
