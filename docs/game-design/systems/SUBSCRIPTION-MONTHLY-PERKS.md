# Subscription Monthly Perks System

**Status:** Draft - Subscription Tier Feature
**Date:** 2025-01-09
**Purpose:** Monthly rotating exclusive perks for Subscription tier players

---

## Overview

Subscription tier players receive **1 exclusive perk per month** that lasts for the duration of their subscription. These perks rotate monthly, creating seasonal variety and FOMO (fear of missing out) that drives retention.

**Key Characteristics:**
- ✅ **Server-injected** (can't be hacked or spoofed)
- ✅ **Auto-activates** on subscription renewal
- ✅ **Rotates monthly** (different perk each month)
- ✅ **Deactivates** if subscription lapses
- ✅ **Reactivates** if subscription renewed (current month's perk)

**Brotato comparison:**
🟢 **UNIQUE TO SCRAP SURVIVOR** (Brotato has no subscription)

---

## Monthly Perk Calendar (Year 1)

### January: "New Year's Fortune"
**Theme:** Luck and prosperity for the new year

**Effects:**
- +100% Luck stat
- +50% crate drop rate from trees
- +25% chance of Tier 4 items in shop

**Playstyle:** High-risk gambling builds, Black Market focus

**Why this month:** New year = fresh start, fortune, luck themes

---

### February: "Lover's Lifesteal"
**Theme:** Love and vampiric themes

**Effects:**
- +25% Life Steal
- Healing creates hearts that orbit player (damage nearby enemies for 5 DMG/sec)
- +10% HP Regeneration while above 75% HP

**Playstyle:** Sustain builds, tank builds, close-range combat

**Why this month:** Valentine's Day = hearts, love, life themes

---

### March: "Spring Harvest"
**Theme:** Growth and abundance

**Effects:**
- +100% Harvesting
- Trees drop 2x materials
- +5% XP Gain per 100 scrap collected

**Playstyle:** Economic builds, farming-focused characters

**Why this month:** Spring = growth, harvest, renewal

---

### April: "Fool's Chaos"
**Theme:** Unpredictability and randomness

**Effects:**
- Random stat boost each wave (+50% to random stat)
- +25% Damage, but random weapon disabled each wave
- Shop rerolls cost 0 scrap (unlimited free rerolls)

**Playstyle:** High-risk builds, adaptable players

**Why this month:** April Fool's Day = chaos, pranks, randomness

---

### May: "Engineer's Day"
**Theme:** Construction and machinery

**Effects:**
- +50% Engineering
- Minions gain +2 levels
- Structures (turrets) gain +100% damage

**Playstyle:** Minion builds, Engineering builds, Technomage

**Why this month:** Labor Day (in some countries) = building, engineering

---

### June: "Summer Speed"
**Theme:** Heat and velocity

**Effects:**
- +50% Speed
- +25% Attack Speed
- +1 Melee Damage per 2% Speed (Speedy character synergy)

**Playstyle:** Speedster builds, kiting builds, melee rushdown

**Why this month:** Summer = heat, energy, speed

---

### July: "Independence Firepower"
**Theme:** Explosions and ranged combat

**Effects:**
- +50% Ranged Damage
- +50% Explosion Size
- Ranged weapons have 20% chance to explode on hit

**Playstyle:** Ranged builds, explosive builds, gun-focused

**Why this month:** July 4th (Independence Day) = fireworks, explosions

---

### August: "Radioactive Summer"
**Theme:** Nuclear heat and radiation

**Effects:**
- +30 Radioactivity
- +15% XP Gain (radioactivity bonus stacks)
- -50% radioactivity debuff severity

**Playstyle:** Radioactive builds, high-risk high-reward

**Why this month:** Summer heat = radiation theme, late summer intensity

---

### September: "Back to School"
**Theme:** Learning and experience

**Effects:**
- +100% XP Gain
- +5 advancements available (Free: 10, Premium: 20, Subscription: 25)
- Start each run at level 5

**Playstyle:** Fast-leveling builds, stat-stacking builds

**Why this month:** Back to school = learning, growth

---

### October: "Spooky Curse"
**Theme:** Halloween, curses, fear

**Effects:**
- +10 Curse
- +35% Damage per Curse point (Creature character synergy)
- Enemies have 10% chance to drop cursed items (high power, high risk)

**Playstyle:** Curse builds, Creature character, high-risk builds

**Why this month:** Halloween = spooky, curses, darkness

---

### November: "Thankful Harvest"
**Theme:** Gratitude and abundance

**Effects:**
- +50% Harvesting
- +10% Max HP per 100 harvesting points
- Consumables (fruits) drop 3x more often

**Playstyle:** Economic builds, consumable builds, survivability

**Why this month:** Thanksgiving = harvest, gratitude, abundance

---

### December: "Winter's Resilience"
**Theme:** Cold, endurance, survival

**Effects:**
- +50 Armor
- +25 Max HP
- +10% Dodge
- Immune to knockback

**Playstyle:** Tank builds, survivability builds, defensive

**Why this month:** Winter = cold, endurance, survival themes

---

## Technical Implementation

### Server-Side Perk Injection

**Perk definitions stored in Supabase:**
```sql
CREATE TABLE subscription_monthly_perks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    month INTEGER NOT NULL,  -- 1-12
    year INTEGER NOT NULL,   -- 2025, 2026, etc.
    perk_name TEXT NOT NULL,
    perk_data JSONB NOT NULL,  -- Effects, modifiers, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example perk data
{
    "name": "New Year's Fortune",
    "effects": {
        "luck": 100,
        "crate_drop_rate": 0.50,
        "tier_4_shop_chance": 0.25
    },
    "hook_modifiers": {
        "shop_tier_selection_pre": {
            "tier_4_weight_multiplier": 1.25
        },
        "crate_drop_pre": {
            "drop_rate_multiplier": 1.50
        }
    }
}
```

---

### Client-Side Activation

**Godot fetches current month's perk:**
```gdscript
# SubscriptionService.gd
var current_monthly_perk: Dictionary = {}

func fetch_monthly_perk() -> void:
    if not is_subscription_active():
        current_monthly_perk = {}
        return

    var current_month = Time.get_date_dict_from_system()["month"]
    var current_year = Time.get_date_dict_from_system()["year"]

    var response = await supabase.from("subscription_monthly_perks") \
        .select("*") \
        .eq("month", current_month) \
        .eq("year", current_year) \
        .single() \
        .execute()

    if response.data:
        current_monthly_perk = response.data.perk_data
        apply_monthly_perk()

func apply_monthly_perk() -> void:
    # Apply stat modifiers
    for stat in current_monthly_perk.effects:
        StatService.add_modifier("monthly_perk", stat, current_monthly_perk.effects[stat])

    # Register perk hooks
    PerkService.register_monthly_perk(current_monthly_perk)
```

---

### Perk Hook Integration

**Monthly perks integrate with Perk System hooks:**
```gdscript
# PerkService.gd
func register_monthly_perk(perk_data: Dictionary) -> void:
    for hook_name in perk_data.hook_modifiers:
        var modifiers = perk_data.hook_modifiers[hook_name]
        register_hook_modifier(hook_name, "monthly_perk", modifiers)

# Example: "New Year's Fortune" modifies shop selection
signal shop_tier_selection_pre(context: Dictionary)

func _on_shop_tier_selection_pre(context: Dictionary):
    if monthly_perk_active and monthly_perk.has("tier_4_weight_multiplier"):
        context.tier_4_weight *= monthly_perk.tier_4_weight_multiplier
```

---

## Subscription Lifecycle

### Activation

**When player subscribes:**
```
1. Subscription payment processed (App Store / Google Play)
2. Backend updates user_tier = "subscription"
3. Client fetches current month's perk
4. Perk auto-activates (stat modifiers + hook registration)
5. Notification: "Monthly Perk Active: New Year's Fortune!"
```

---

### Deactivation

**When subscription lapses:**
```
1. Subscription expires (no renewal)
2. Backend updates user_tier = "premium" (keep Premium tier)
3. Client removes monthly perk
4. Stat modifiers cleared
5. Hook registrations removed
6. Notification: "Monthly Perk expired. Renew to reactivate!"
```

---

### Renewal

**When player renews subscription:**
```
1. Subscription renewed
2. Backend updates user_tier = "subscription"
3. Client fetches CURRENT month's perk (not previous month)
4. Perk auto-activates
5. Notification: "Monthly Perk Active: [Current Month]"
```

**Example:**
- January: Subscribed, got "New Year's Fortune"
- February: Forgot to renew, perk deactivated
- March: Renewed, got "Spring Harvest" (current month, not February's perk)

---

## UI Display

### Main Menu Badge

```
[Main Menu]

Characters  Shop  Workshop  Bank  Settings

                    💎 SUBSCRIPTION ACTIVE
                    Monthly Perk: Spring Harvest
                    +100% Harvesting | Trees drop 2x materials
                    [View Details]
```

---

### Character Select Screen

```
[Character Select]

Bruiser (Level 15)
HP: 150  Damage: 25  Speed: 100%

💎 Monthly Perk Active: Spring Harvest
   +100% Harvesting (200% total)
   +5% XP per 100 scrap collected

[Start Run]
```

---

### In-Game HUD

```
[Top-right corner during run]

💎 Spring Harvest Active
   Harvesting: +200%
   Scrap collected: 450 (+22% XP bonus)
```

---

## Marketing & Retention

### FOMO (Fear of Missing Out)

**Premium players see:**
```
[Shop Screen - Premium Tier]

💡 Upgrade to Subscription:
   🌟 January: New Year's Fortune (+100% Luck, +50% crate drops)
   🌟 February: Lover's Lifesteal (+25% Life Steal, heart orbital damage)
   🌟 March: Spring Harvest (+100% Harvesting, trees drop 2x materials)

   Don't miss this month's exclusive perk!

   [Start Free Trial - $2.99/month]
```

---

### Social Sharing

**Encourage players to share:**
```
[Post-Run Screen - Subscription Tier]

🏆 Wave 20 Cleared!
💎 Monthly Perk: Spring Harvest
   Harvesting: +200%
   Scrap earned: 3,500 (best run!)

[Share on Twitter/Discord]
→ "Just cleared Wave 20 with Spring Harvest perk! +200% harvesting is INSANE! #ScrapSurvivor"
```

---

### Seasonal Events Synergy

**Monthly perks can tie into Special Events:**

**October Example:**
- Monthly Perk: "Spooky Curse" (+10 Curse, +35% DMG/Curse)
- Special Event: "Halloween Horde" (more enemies, cursed item drops)
- Synergy: Curse builds are META this month!

**Result:** Subscription feels essential during seasonal events

---

## Balancing Considerations

### Power Level Constraints

**Monthly perks should:**
- ✅ Be powerful enough to feel special (+50-100% stat boost)
- ✅ Enable new builds (not just "+X% damage")
- ✅ NOT be mandatory for competitive play
- ✅ Rotate strategies (different playstyles each month)

**Power Budget:**
```
Monthly Perk ~= 2-3 Tier 4 items in power
BUT more specialized (enables specific builds)
```

---

### Free/Premium Balance

**Without monthly perk:**
- Free tier: Can still clear Wave 20 (complete game)
- Premium tier: Can still clear Wave 20 with good builds

**With monthly perk:**
- Subscription tier: Easier Wave 20 clears, faster progression
- BUT not mandatory (skill > perk)

**Test metrics:**
- Free: 20% Wave 20 clear rate
- Premium: 35% Wave 20 clear rate
- Subscription: 50% Wave 20 clear rate (monthly perk helps, but not P2W)

---

## Year 2+ Content

### New Perk Rotation

**After 12 months, create new perks:**
- Keep popular perks (player voting?)
- Rotate out least-used perks
- Add new perks based on meta shifts

**Example Year 2:**
- January 2026: "New Year's Fortune II" (upgraded version)
- OR: "New Year's Resistance" (completely new perk)

---

### DLC Tie-Ins

**DLC packs can add monthly perk synergies:**

**Example:**
- DLC Pack: "Energy Weapons Pack" ($2.99)
- Monthly Perk: "May: Engineer's Day" (+50% Engineering)
- Synergy: Energy weapons scale with Engineering
- Result: DLC feels more valuable during May

---

## Analytics Tracking

### Key Metrics

**Perk engagement:**
- % of subscribers using monthly perk actively
- Most popular perk (highest engagement)
- Least popular perk (rotation candidate)

**Retention:**
- Subscription renewal rate per perk month
- Churn rate during specific perk months
- Resubscription rate (came back for specific perk)

**Conversion:**
- Premium → Subscription conversion during FOMO perk months
- Free → Subscription conversion (skip Premium)

---

## Open Questions

**For discussion:**
1. Should monthly perks stack with other perks, or replace them?
   - **Recommendation:** Stack (more fun, more powerful)

2. Should players be able to choose from 2-3 monthly perks?
   - **Recommendation:** No, single perk (simpler, more FOMO)

3. Should monthly perks unlock permanently after 12 months subscribed?
   - **Recommendation:** No, keeps subscription valuable

4. Should there be "Legendary" months with 2 perks active?
   - **Recommendation:** Yes, December (holiday season) = 2 perks active

---

## Summary

Monthly Unique Perks provide:
- ✅ Rotating gameplay variety (different meta each month)
- ✅ FOMO retention driver (don't miss this month's perk!)
- ✅ Seasonal theming (ties into holidays, events)
- ✅ Server-injected security (can't be hacked)
- ✅ Subscription value justification ($2.99/month feels worth it)

**Subscription tier is now:**
- Quantum Banking/Storage
- Murder Hobo, Cultivation Pod, Minion Fabricator (idle systems)
- Atomic Vending Machine (personalized shop)
- Hall of Fame (archived characters)
- **Monthly Unique Perk** (NEW!)
- Unlimited advancement

**This is now a STRONG $2.99/month value proposition.**

---

## References

- [PERKS-ARCHITECTURE.md](../../core-architecture/PERKS-ARCHITECTURE.md) - Perk hook system
- [SUBSCRIPTION-SERVICES.md](./SUBSCRIPTION-SERVICES.md) - Other subscription features
- [SPECIAL-EVENTS-SYSTEM.md](./SPECIAL-EVENTS-SYSTEM.md) - Seasonal event synergies
