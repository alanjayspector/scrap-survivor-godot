# Atomic Vending Machine System

**Status:** MID-TERM - Subscription retention feature
**Tier Access:** Subscription only
**Implementation Phase:** Week 13-14 (after personalization)

---

## 1. System Overview

The Atomic Vending Machine is a **Subscription-exclusive weekly shop** offering 3 personalized items tailored to the user's playstyle. It refreshes once per week and includes high-value items/minions.

**Key Features:**
- 3 personalized item choices per week
- Can include rare minions
- Uses Personalization System for targeting
- Subscription exclusive

---

## 2. How It Works

### 2.1 Weekly Refresh

```gdscript
# Refresh every Monday at midnight
var refresh_day = DayOfWeek.MONDAY
var refresh_time = "00:00:00"

# User can purchase 1 of 3 items
var weekly_choices = [
    personalized_item_1,
    personalized_item_2,
    personalized_item_3
]

# After purchase, vending machine is empty until next week
```

### 2.2 Personalization

Items are tailored using the user's **Personalization System** profile:

```gdscript
var profile = {
    "favorite_character_type": "scavenger",
    "preferred_playstyle": "ranged_dps",
    "weapon_preferences": ["plasma_rifle", "nano_swarm"]
}

# Generate personalized items
func generate_weekly_items(profile: Dictionary) -> Array:
    var items = []

    # Item 1: Weapon matching playstyle
    if profile.preferred_playstyle == "ranged_dps":
        items.append(generate_epic_ranged_weapon())

    # Item 2: Character-specific armor
    items.append(generate_armor_for_character(profile.favorite_character_type))

    # Item 3: Minion or rare consumable
    if randf() < 0.3:  # 30% chance for minion
        items.append(generate_rare_minion())
    else:
        items.append(generate_epic_consumable())

    return items
```

### 2.3 Server-Side Refresh Logic

**Refresh Schedule:** Every Monday at 00:00 UTC

```typescript
// Supabase Edge Function: /api/vending-machine/refresh
export async function refreshVendingMachines() {
  const now = new Date();

  // Check if it's Monday
  if (now.getUTCDay() !== 1) {  // 1 = Monday
    return;
  }

  // Get all Subscription users
  const { data: subscriptionUsers } = await supabase
    .from('user_accounts')
    .select('id, tier')
    .gte('tier', 2);  // Subscription = tier 2

  // Generate personalized items for each user
  for (const user of subscriptionUsers) {
    const profile = await getPersonalizationProfile(user.id);
    const items = generateWeeklyItems(profile);

    // Store in vending_machine_inventory table
    await supabase
      .from('vending_machine_inventory')
      .upsert({
        user_id: user.id,
        items: items,
        refresh_date: now.toISOString(),
        purchased: false
      });

    // Send push notification
    await sendNotification(user.id, {
      title: "Atomic Vending Machine Refreshed!",
      body: "3 new personalized items are waiting for you"
    });
  }
}

// Run this function via Supabase cron job (every Monday 00:00 UTC)
```

### 2.4 Push Notifications

**Subscription users get notified when vending machine refreshes:**

```gdscript
# Receive notification
func _on_notification_received(notification: Dictionary):
    if notification.type == "vending_machine_refresh":
        show_vending_machine_banner()

func show_vending_machine_banner():
    var banner = preload("res://ui/VendingMachineBanner.tscn").instantiate()
    banner.title = "Atomic Vending Machine Refreshed!"
    banner.description = "3 new personalized items are waiting"
    banner.cta_button_text = "View Items"
    banner.cta_pressed.connect(_on_view_vending_machine)
    add_child(banner)
```

---

## 3. Item Quality

All items are **Epic or Legendary** rarity:

```gdscript
var item_rarity_pool = [
    { "rarity": "epic", "weight": 70 },      # 70% Epic
    { "rarity": "legendary", "weight": 30 }  # 30% Legendary
]
```

### 3.1 Minion Inclusion

**Minions can appear in vending machine:**
- 30% chance one of the 3 slots is a minion
- Minions are Epic or Legendary tier
- Personalized to user's favorite character type

---

## 4. Pricing

**Atomic Vending Machine uses inflated pricing:**

```gdscript
var atomic_markup = 1.5  # 50% more expensive than Black Market

# Examples:
# Epic weapon → 18,750 scrap (vs 12,500 Black Market)
# Legendary minion → 37,500 scrap (vs 25,000 Black Market)
```

**Why expensive?**
- High quality (Epic/Legendary only)
- Personalized (tailored to playstyle)
- Subscription exclusive (premium feel)

---

## 5. UI Location

**Access:** Scrapyard → Atomic Vending Machine (Subscription only)

**UI Mock:**
```
┌─────────────────────────────────────┐
│  ATOMIC VENDING MACHINE              │
│  (Subscription Feature)              │
├─────────────────────────────────────┤
│ Personalized for Scavenger #1       │
│ Refreshes in: 4d 12h 35m            │
│                                     │
│ Choice 1:                           │
│ [Plasma Rifle +10] Legendary        │
│  Perfect for ranged builds!         │
│  💰 37,500 scrap                   │
│                                     │
│ Choice 2:                           │
│ [Scavenger Armor] Epic              │
│  +20 Luck, +15% scrap find          │
│  💰 18,750 scrap                   │
│                                     │
│ Choice 3:                           │
│ [Mutant Hound Minion] Epic          │
│  Fast melee DPS pet                 │
│  💰 25,000 scrap                   │
│                                     │
│ ⚠ You can only purchase ONE item   │
└─────────────────────────────────────┘
```

---

## 6. Purchase Rules

**One purchase per week:**
```gdscript
func purchase_from_vending_machine(item_id: String) -> Result:
    # Check already purchased this week
    if has_purchased_this_week():
        return Result.error("Already purchased this week")

    # Check subscription tier
    if current_user.tier < UserTier.SUBSCRIPTION:
        return Result.error("Subscription required")

    # Process purchase
    var item = get_vending_machine_item(item_id)
    var character = CharacterService.get_active_character()

    if character.currency < item.price:
        return Result.error("Insufficient scrap")

    # Deduct currency
    character.currency -= item.price

    # Add item to inventory
    if item.type == "minion":
        BarracksService.add_minion(item)
    else:
        InventoryService.add_item(character.id, item)

    # Mark as purchased
    mark_vending_machine_purchased()

    return Result.success(item)
```

---

## 7. Personalization Algorithm

### 7.1 Item Selection Logic

```gdscript
# services/VendingMachineService.gd
class_name VendingMachineService
extends Node

func generate_weekly_items(user_id: String) -> Array[Item]:
    # Get user's personalization profile
    var profile = PersonalizationService.get_profile(user_id)
    var items: Array[Item] = []

    # Slot 1: Weapon (tailored to playstyle)
    items.append(generate_weapon_for_playstyle(profile))

    # Slot 2: Armor or Trinket (tailored to character type)
    items.append(generate_defense_item(profile))

    # Slot 3: Minion (30% chance) or Consumable
    if randf() < 0.30:
        items.append(generate_minion(profile))
    else:
        items.append(generate_consumable(profile))

    # Apply Epic/Legendary rarity
    for item in items:
        item.rarity = get_epic_or_legendary_rarity()
        item.price = get_vending_machine_price(item)

    return items

func generate_weapon_for_playstyle(profile: PersonalizationProfile) -> Weapon:
    match profile.preferred_playstyle:
        "tank":
            return WeaponGenerator.generate("heavy_weapon", "epic")  # Slow, high damage
        "glass_cannon":
            return WeaponGenerator.generate("high_dps_weapon", "epic")  # Fast, crit-focused
        "ranged_dps":
            return WeaponGenerator.generate("ranged_weapon", "epic")  # Long range
        "melee_dps":
            return WeaponGenerator.generate("melee_weapon", "epic")  # Close combat
        "balanced":
            return WeaponGenerator.generate("versatile_weapon", "epic")  # All-arounder
        _:
            return WeaponGenerator.generate_random("epic")

func generate_defense_item(profile: PersonalizationProfile) -> Item:
    # 70% armor, 30% trinket
    if randf() < 0.70:
        return ArmorGenerator.generate_for_character_type(profile.favorite_character_type, "epic")
    else:
        return TrinketGenerator.generate_for_playstyle(profile.preferred_playstyle, "epic")

func generate_minion(profile: PersonalizationProfile) -> Minion:
    # Minions match character type
    return MinionGenerator.generate_for_character_type(profile.favorite_character_type, "epic")

func generate_consumable(profile: PersonalizationProfile) -> Item:
    # Consumables boost weak stats
    if profile.preferred_playstyle == "tank":
        return ConsumableGenerator.generate("healing_boost", "epic")  # HP recovery
    elif profile.preferred_playstyle == "glass_cannon":
        return ConsumableGenerator.generate("damage_boost", "epic")  # Damage increase
    else:
        return ConsumableGenerator.generate_random("epic")

func get_epic_or_legendary_rarity() -> String:
    # 70% Epic, 30% Legendary
    return "legendary" if randf() < 0.30 else "epic"
```

### 7.2 Playstyle Matching Examples

| Playstyle | Weapon Type | Armor Type | Minion Type | Consumable Type |
|-----------|-------------|------------|-------------|-----------------|
| **Tank** | Heavy weapon (slow, high damage) | Heavy armor (+HP, +armor) | Tank minion (absorbs damage) | Health boost |
| **Glass Cannon** | High DPS weapon (fast, crit) | Light armor (+speed, +crit) | DPS minion (high damage) | Damage boost |
| **Ranged DPS** | Ranged weapon (long range) | Medium armor (balanced) | Ranged minion (support fire) | Ammo/energy boost |
| **Melee DPS** | Melee weapon (close combat) | Medium armor (+speed) | Melee minion (front line) | Attack speed boost |
| **Balanced** | Versatile weapon (all-purpose) | Balanced armor | Support minion (utility) | XP boost |

---

## 8. Data Model

```gdscript
class VendingMachineInventory:
    var user_id: String
    var items: Array[Item]  # Always 3 items
    var refresh_date: String  # Monday 00:00 UTC
    var purchased_item_id: String  # null if not purchased yet
    var purchased_at: String  # null if not purchased

func get_current_inventory(user_id: String) -> VendingMachineInventory:
    # Fetch from Supabase
    var response = await SupabaseService.query("vending_machine_inventory")
        .eq("user_id", user_id)
        .order("refresh_date", "desc")
        .limit(1)
        .execute()

    if response.data.is_empty():
        return null  # No inventory yet

    return VendingMachineInventory.from_dict(response.data[0])

func has_purchased_this_week(user_id: String) -> bool:
    var inventory = await get_current_inventory(user_id)
    return inventory != null and inventory.purchased_item_id != null
```

**Supabase Schema:**
```sql
CREATE TABLE vending_machine_inventory (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  items JSONB NOT NULL,  -- Array of 3 items
  refresh_date TIMESTAMPTZ NOT NULL,
  purchased_item_id VARCHAR(255),  -- null if not purchased
  purchased_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, refresh_date)
);

CREATE INDEX idx_vending_machine_user ON vending_machine_inventory(user_id);
CREATE INDEX idx_vending_machine_refresh_date ON vending_machine_inventory(refresh_date);
```

---

## 9. UI Implementation

### 9.1 Vending Machine Scene

```gdscript
# scenes/VendingMachineShop.gd
extends Control

@onready var item_slots = [$ItemSlot1, $ItemSlot2, $ItemSlot3]
@onready var countdown_timer_label = $CountdownLabel
@onready var purchase_warning_label = $PurchaseWarningLabel

var current_inventory: VendingMachineInventory

func _ready():
    # Check Subscription access
    var user = UserService.get_current_user()
    if user.tier < UserTier.SUBSCRIPTION:
        show_locked_view()
        return

    # Load inventory
    load_vending_machine_inventory()

    # Start countdown timer
    start_countdown()

func load_vending_machine_inventory():
    current_inventory = await VendingMachineService.get_current_inventory()

    if current_inventory == null:
        show_error("Vending machine not yet refreshed")
        return

    # Check if already purchased
    if current_inventory.purchased_item_id:
        show_already_purchased_view(current_inventory.purchased_item_id)
        return

    # Display 3 items
    for i in range(3):
        var item = current_inventory.items[i]
        item_slots[i].display_item(item)
        item_slots[i].purchase_requested.connect(_on_purchase_requested.bind(item))

    purchase_warning_label.text = "⚠️ You can only purchase ONE item this week"

func _on_purchase_requested(item: Item):
    var character = CharacterService.get_active_character()

    if character.currency < item.price:
        show_insufficient_scrap_error(item.price)
        return

    # Confirm purchase
    var confirmed = await show_confirmation_dialog(
        "Purchase %s for %d scrap?" % [item.name, item.price],
        "⚠️ This is your ONLY purchase this week!"
    )

    if not confirmed:
        return

    # Process purchase
    var result = await VendingMachineService.purchase_item(item.id)
    if result.success:
        character.currency -= item.price
        await CharacterService.update_character(character)

        # Add item to inventory
        if item.type == "minion":
            BarracksService.add_minion(item)
        else:
            InventoryService.add_item(character.id, item)

        show_purchase_success(item.name)
        load_vending_machine_inventory()  # Refresh to show empty state
    else:
        show_error(result.error)

func show_already_purchased_view(purchased_item_id: String):
    # Gray out all items except purchased one
    for i in range(3):
        var item = current_inventory.items[i]
        if item.id == purchased_item_id:
            item_slots[i].highlight_as_purchased()
        else:
            item_slots[i].gray_out()

    purchase_warning_label.text = "✓ Already purchased this week. Come back next Monday!"

func start_countdown():
    var timer = Timer.new()
    timer.timeout.connect(update_countdown)
    add_child(timer)
    timer.start(1.0)  # Update every second

func update_countdown():
    var next_monday = get_next_monday_utc()
    var now = Time.get_unix_time_from_system()
    var remaining = next_monday - now

    if remaining <= 0:
        countdown_timer_label.text = "Refreshing..."
        load_vending_machine_inventory()  # Reload
    else:
        var days = int(remaining / 86400)
        var hours = int((remaining % 86400) / 3600)
        var minutes = int((remaining % 3600) / 60)
        countdown_timer_label.text = "Refreshes in: %dd %dh %dm" % [days, hours, minutes]

func get_next_monday_utc() -> int:
    var now = Time.get_datetime_dict_from_system(true)  # UTC
    var current_day_of_week = now.weekday  # 0=Sunday, 1=Monday, ...

    var days_until_monday = (7 - current_day_of_week + 1) % 7
    if days_until_monday == 0 and now.hour >= 0:
        days_until_monday = 7  # Already past this week's Monday

    var next_monday = Time.get_unix_time_from_system() + (days_until_monday * 86400)
    return next_monday
```

---

## 10. Implementation Strategy

### 10.1 Phase 1: Foundation (Week 13) - 12 hours

**Goal:** Build vending machine system

**Tasks:**
1. **VendingMachineService (4h)**
   - Create `VendingMachineService.gd` singleton
   - Implement item generation with personalization
   - Integrate with PersonalizationService

2. **Supabase Schema (2h)**
   - Create `vending_machine_inventory` table
   - Add indexes
   - Set up cron job for weekly refresh

3. **Weekly Refresh Logic (4h)**
   - Create Supabase Edge Function for refresh
   - Test refresh on Monday 00:00 UTC
   - Send push notifications

4. **Purchase Flow (2h)**
   - Implement one-purchase-per-week restriction
   - Mark item as purchased
   - Update inventory

**Deliverables:**
- ✅ Vending machine generates personalized items
- ✅ Weekly refresh works
- ✅ One purchase per week enforced

### 10.2 Phase 2: UI (Week 14) - 8 hours

**Goal:** Build vending machine UI

**Tasks:**
1. **Shop Scene (6h)**
   - Create `VendingMachineShop.tscn`
   - Display 3 item slots
   - Countdown timer
   - Purchase confirmation dialog
   - Already purchased state

2. **Locked View (2h)**
   - Show for non-Subscription users
   - "Subscription Required" message
   - Upgrade CTA

**Deliverables:**
- ✅ Vending machine UI complete
- ✅ Countdown timer accurate
- ✅ Tier gating works

### 10.3 Phase 3: Polish & Testing (Week 14) - 4 hours

**Goal:** Balance and test

**Tasks:**
1. **Balancing (2h)**
   - Test personalization accuracy
   - Adjust pricing
   - Tune minion spawn rate (30%)

2. **Testing (2h)**
   - Test full purchase flow
   - Test weekly refresh
   - Test edge cases (subscription expires mid-week, etc.)

**Deliverables:**
- ✅ System balanced
- ✅ No major bugs

**Total Implementation Time:** ~24 hours (~3 days of focused work)

---

## 11. Balancing Considerations

### 11.1 Pricing Balance

**Problem:** How expensive should vending machine items be?

**Solution:**
- Black Market legendary: 25,000 scrap
- Vending Machine legendary: 37,500 scrap (50% more)
- Justification: Personalized (no RNG), Subscription exclusive

**Rationale:**
- Users need to farm ~40-75 waves for one legendary
- Creates long-term goal
- High price makes purchase decision meaningful ("Which one do I want most?")

### 11.2 Weekly Refresh Timing

**Problem:** Why Monday 00:00 UTC?

**Solution:**
- Monday starts the week (fresh start mentality)
- 00:00 UTC avoids timezone confusion
- Weekly cadence creates routine ("Check vending machine every Monday")

**Alternative:**
- Sunday night (users have weekend to farm scrap)
- Friday (start weekend with new items)
- **Recommendation:** Keep Monday (aligns with weekly goals reset)

### 11.3 One Purchase Per Week Limit

**Problem:** Should users buy all 3 items or just 1?

**Solution:** Only 1 purchase per week

**Rationale:**
- Creates meaningful choice ("Which item do I want most?")
- Prevents whales from buying everything
- Keeps scrap economy balanced
- If users could buy all 3, they'd need 75,000-112,500 scrap/week (too much farming)

### 11.4 Minion Spawn Rate

**Problem:** How often should minions appear?

**Current:** 30% chance (slot 3)

**Rationale:**
- Users see minions ~every 3 weeks
- Rare enough to feel special
- Common enough to be attainable

**Alternative Rates:**
- **Too common (50%):** Minions lose value
- **Too rare (10%):** Users never see minions
- **Sweet spot (30%):** Balanced

---

## 12. Open Questions & Future Enhancements

### 12.1 Open Questions

**Q1: Should vending machine refresh mid-week if user cancels subscription?**
- Option A: Yes, refresh immediately (user loses items)
- Option B: No, user keeps items until next Monday
- **Recommendation:** Option B (fair to user)

**Q2: Should users be able to preview next week's items?**
- Option A: Yes, preview on Sunday
- Option B: No, surprise on Monday
- **Recommendation:** Option B (creates excitement, anticipation)

**Q3: Should there be a "reroll" option (for scrap)?**
- Option A: Yes, 5,000 scrap reroll (generates 3 new items)
- Option B: No, items are fixed
- **Recommendation:** Option A (adds flexibility, scrap sink)

**Q4: Should vending machine have "sale weeks" (50% off)?**
- Option A: Yes, once per month
- Option B: No, keep pricing consistent
- **Recommendation:** Option A (adds variety, creates excitement)

**Q5: Should items expire if not purchased?**
- Option A: Yes, items disappear on next refresh
- Option B: No, items carry over until purchased
- **Recommendation:** Option A (creates FOMO, urgency)

### 12.2 Future Enhancements (Post-Launch)

**Enhancement 1: Vending Machine Vouchers**
- Earn vouchers through achievements
- 1 voucher = 50% off one item
- Max 1 voucher per month

**Enhancement 2: "Lucky Week" Event**
- Random weeks have 4 items instead of 3
- All items are Legendary
- Announced in advance

**Enhancement 3: Vending Machine History**
- View past 10 weeks of items
- See what you purchased
- Compare with current week

**Enhancement 4: Friend Recommendations**
- See what items friends got this week
- "Your friend purchased X, it's perfect for your build!"

**Enhancement 5: Vending Machine Achievements**
- "Loyal Customer" (purchase 10 weeks in a row)
- "Big Spender" (spend 500,000 scrap total)
- "Perfect Match" (purchase personalized item)

---

## 13. Summary

### 13.1 What Atomic Vending Machine Provides

The Atomic Vending Machine System delivers:

1. **Personalized Shopping**
   - 3 items tailored to playstyle
   - Uses Personalization System profile
   - Removes RNG frustration

2. **Subscription Retention**
   - Exclusive feature (creates FOMO)
   - Weekly cadence drives logins
   - High-value items justify subscription

3. **Scrap Sink**
   - Inflated pricing (50% more than Black Market)
   - One purchase per week limits spending
   - Balances scrap economy

4. **Player Engagement**
   - Weekly refresh creates routine
   - Countdown timer drives anticipation
   - Push notifications bring users back

### 13.2 Key Features Recap

- ✅ **3 Personalized Items:** Epic/Legendary, tailored to playstyle
- ✅ **Weekly Refresh:** Every Monday 00:00 UTC
- ✅ **One Purchase:** Only 1 item per week (meaningful choice)
- ✅ **Minions:** 30% chance for minion in slot 3
- ✅ **High Pricing:** 1.5x Black Market prices
- ✅ **Subscription Exclusive:** Premium/Free users can't access
- ✅ **Push Notifications:** Alerts when refreshed

### 13.3 Implementation Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1 | Week 13 (12h) | Vending machine system functional |
| Phase 2 | Week 14 (8h) | UI complete |
| Phase 3 | Week 14 (4h) | Polish and testing done |

**Total:** ~24 hours (~3 days of focused work)

### 13.4 Success Metrics

Track these KPIs to measure system success:

- **Usage Rate:** % of Subscription users who check vending machine weekly
  - Target: >80% usage rate
- **Purchase Rate:** % of users who purchase from vending machine
  - Target: >60% purchase rate
- **Personalization Accuracy:** % of users who purchased item matching their profile
  - Target: >70% accuracy
- **Subscription Retention Impact:** Do users with vending machine purchases have higher retention?
  - Target: +15% retention for purchasers
- **Scrap Sink Impact:** Total scrap removed via vending machine
  - Track: Weekly scrap spent

### 13.5 Status & Next Steps

**Current Status:** 📝 Fully documented, ready for implementation

**Prerequisites:**
- ✅ Personalization System complete (provides user profiles)
- ✅ Character Service with inventory
- ✅ Minion system functional
- ✅ Push notification service working

**Next Steps:**
1. Review this document with team
2. Begin Phase 1 implementation (Week 13)
3. Set up Supabase cron job for Monday refresh
4. Test personalization algorithm accuracy
5. Design vending machine UI mockups

**Status:** Ready for Week 13-14 implementation (after Personalization System).

---

*End of Atomic Vending Machine System Documentation*
