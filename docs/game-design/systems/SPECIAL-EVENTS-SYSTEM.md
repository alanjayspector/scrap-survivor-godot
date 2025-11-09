# Special Events System

**Status:** MID-TERM - Content expansion feature
**Tier Access:** Premium + Subscription
**Implementation Phase:** Weeks 14-16+ (after core gameplay complete)

---

## 1. System Overview

The Special Events System creates **temporary, unique environmental changes in The Wasteland** that add variety, seasonal content, and player retention hooks. Events are **operator-controlled** (server-activated) and modify combat without requiring client updates.

**Key Features:**
- Temporary wasteland modifiers (acid pools, lava, teleport traps)
- Event-exclusive enemies with special powers
- Limited-time item drops and event currency
- Seasonal/holiday themes (Halloween, Christmas, etc.)
- Server-side activation (no app updates required)
- Premium/Subscription exclusive

**Design Goals:**
1. **Retention:** Create FOMO (fear of missing out) for limited-time content
2. **Variety:** Break monotony of standard wasteland combat
3. **Monetization:** Justify Premium/Subscription with exclusive access
4. **Seasonal Engagement:** Capitalize on holidays/cultural events
5. **Replayability:** Same event can return yearly with slight variations

---

## 2. Event Types

### 2.1 Environmental Hazards

**Acid Pools:**
- Random green zones that deal DoT (damage over time)
- Players must dodge or take 10 damage/second
- Enemies can also take damage

**Lava Zones:**
- Red zones that deal heavy instant damage (50 HP)
- Creates chokepoints, strategic positioning

**Slow Fields:**
- Blue zones that reduce movement speed by 75%
- Forces tactical retreat decisions

**Teleport Traps:**
- Purple circles that randomly teleport player
- Can teleport into danger or safety (RNG)

### 2.2 Weather Events

**Radiation Storm:**
- Entire wasteland glows green
- All entities take 5 damage/second
- Rewards: +50% scrap drops

**Electromagnetic Pulse:**
- Energy weapons disabled for 30 seconds
- Forces weapon switching

**Scrap Tornado:**
- Scrap pickups spawn 5x more frequently
- High risk (more enemies), high reward

### 2.3 Themed Events (Seasonal/Holiday)

**Halloween: "Zombie Horde"**
- **Duration:** Oct 25 - Nov 5 (annual)
- **Theme:** Undead apocalypse
- **Wasteland Changes:**
  - Zombie enemies replace 75% of normal spawns
  - Fog effects reduce visibility
  - Pumpkins spawn as currency pickups
- **Exclusive Drops:**
  - Necro Staff (Epic weapon, life steal)
  - Bone Club (Rare weapon, knockback)
  - Zombie Armor (Uncommon, +15% damage vs undead)
  - Candy Consumable (+50 HP + speed boost)
- **Event Currency:** Pumpkin Coins (used in event shop)
- **Event Shop:** Exclusive Halloween cosmetics, weapons

**Christmas: "Frostbite Wasteland"**
- **Duration:** Dec 20 - Jan 5 (annual)
- **Theme:** Winter wonderland survival
- **Wasteland Changes:**
  - Snow particle effects
  - Ice patches (slip/slide movement physics)
  - Frost enemies spawn (slow attacks, ice armor)
- **Exclusive Drops:**
  - Icicle Spear (Epic weapon, freeze effect)
  - Winter Coat (Rare armor, cold resistance)
  - Gift Boxes (random rewards: scrap, items, currency)
  - Hot Cocoa Consumable (+25 HP over time)
- **Event Currency:** Candy Canes
- **Event Shop:** Snowman minion, festive weapon skins

**Lunar New Year: "Dragon's Blessing"**
- **Duration:** Region-specific (Jan 25 - Feb 8 in 2025)
- **Theme:** Chinese New Year celebration
- **Wasteland Changes:**
  - Dragon-themed enemies (flying, fire breath)
  - Red/gold visual theme
  - Firework explosions (visual + AoE damage bonus)
- **Global Buff:** +20 Luck for all characters (stacks with perks)
- **Exclusive Drops:**
  - Dragon Scale Armor (Legendary, fire resistance)
  - Jade Sword (Epic weapon, crit bonus)
  - Red Envelope (bonus scrap + components)
- **Event Currency:** Gold Coins
- **Event Shop:** Dragon minion, lucky charms

**Día de los Muertos: "Day of the Dead"** (NEW)
- **Duration:** Oct 31 - Nov 2 (annual)
- **Theme:** Mexican Day of the Dead
- **Region:** Latin America + opt-in for others
- **Wasteland Changes:**
  - Skeleton enemies (lightweight, fast)
  - Marigold flowers grant temporary buffs
  - Sugar skull pickups (heal + bonus XP)
- **Exclusive Drops:**
  - Skull Staff (Rare weapon, summon skeleton ally)
  - Mariachi Hat (Uncommon armor, +10% XP gain)
  - Pan Dulce Consumable (+30 HP)
- **Event Currency:** Marigolds
- **Event Shop:** Catrina cosmetic armor, Day of the Dead weapon skins

### 2.4 Subscription-Exclusive Events

These events are **only accessible to Subscription tier** users:

**"Quantum Flux" Event**
- **Frequency:** Monthly (first weekend of each month)
- **Duration:** 48 hours
- **Theme:** Reality-bending chaos
- **Wasteland Changes:**
  - Random teleportation zones
  - Time dilation zones (slow/fast motion)
  - Quantum enemies (phase through walls)
- **Exclusive Drops:**
  - Quantum Rifle (Legendary, teleports enemies)
  - Flux Armor (Epic, dodge chance +25%)
- **Rewards:** 2x scrap + 2x components for duration

**"Mutant Mayhem" Event** (Subscription Only)
- **Frequency:** Bi-weekly
- **Duration:** 72 hours
- **Theme:** Extreme mutant spawns
- **Wasteland Changes:**
  - All enemies are elite/mutant variants
  - Increased enemy density (150% spawns)
  - Mutagen pools (grant temporary mutations)
- **Exclusive Drops:**
  - Mutagen Injector (Rare consumable, random mutation)
  - Bio-Hazard Armor (Epic, mutant damage resistance)
- **Rewards:** 3x item drop rate

---

## 3. Event Scheduling & Distribution

### 3.1 Server-Side Event Calendar

Events are scheduled and activated **server-side** without client updates:

```sql
-- Supabase table
CREATE TABLE special_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  event_type VARCHAR(50) NOT NULL, -- 'environmental', 'weather', 'themed'
  is_active BOOLEAN DEFAULT false,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  target_tier INT DEFAULT 1, -- 0=Free, 1=Premium, 2=Subscription
  target_regions TEXT[], -- ['us', 'eu', 'asia'] or NULL for global
  modifiers JSONB NOT NULL, -- Wasteland changes
  exclusive_enemies JSONB, -- Event-specific enemies
  exclusive_loot JSONB, -- Event-specific items
  event_currency VARCHAR(100), -- 'pumpkin_coins', 'candy_canes', etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_special_events_active ON special_events(is_active) WHERE is_active = true;
CREATE INDEX idx_special_events_dates ON special_events(start_date, end_date);
```

### 3.2 Event Activation

**Automatic Activation:**
```typescript
// Supabase Edge Function (runs every hour)
// /api/events/activate

export async function activateEvents() {
  const now = new Date();

  // Activate events that should be running
  await supabase
    .from('special_events')
    .update({ is_active: true })
    .lte('start_date', now.toISOString())
    .gte('end_date', now.toISOString())
    .eq('is_active', false);

  // Deactivate expired events
  await supabase
    .from('special_events')
    .update({ is_active: false })
    .lt('end_date', now.toISOString())
    .eq('is_active', true);

  // Broadcast activation to all clients
  const activeEvents = await getActiveEvents();
  supabase.channel('events').send({
    type: 'broadcast',
    event: 'events_updated',
    payload: { events: activeEvents }
  });
}
```

**Manual Activation (Operator Override):**
```typescript
// Admin panel: Activate event immediately (testing, emergency)
export async function forceActivateEvent(eventId: string) {
  await supabase
    .from('special_events')
    .update({ is_active: true })
    .eq('id', eventId);

  broadcastEventsUpdate();
}
```

### 3.3 Client-Side Event Sync

```gdscript
# services/EventsService.gd
class_name EventsService
extends Node

signal events_updated(events: Array[SpecialEvent])
signal event_activated(event: SpecialEvent)
signal event_deactivated(event_id: String)

var active_events: Array[SpecialEvent] = []

func _ready():
    # Sync events on startup
    sync_events()

    # Subscribe to realtime updates
    SupabaseService.subscribe_to_channel("events", _on_events_update)

    # Poll every 30 minutes (fallback if realtime fails)
    create_timer(1800).timeout.connect(sync_events)

func sync_events():
    var response = await SupabaseService.call_edge_function("events/active")
    if response.success:
        var new_events = _parse_events(response.data)

        # Detect newly activated events
        for event in new_events:
            if not _has_event(event.id):
                event_activated.emit(event)

        # Detect deactivated events
        for old_event in active_events:
            if not _has_event_in_array(old_event.id, new_events):
                event_deactivated.emit(old_event.id)

        active_events = new_events
        events_updated.emit(active_events)

func _on_events_update(payload: Dictionary):
    if payload.event == "events_updated":
        active_events = _parse_events(payload.events)
        events_updated.emit(active_events)

func get_active_events() -> Array[SpecialEvent]:
    return active_events

func is_event_active(event_id: String) -> bool:
    return _has_event(event_id)
```

---

## 4. Event Activation Logic

### 4.1 Wasteland Modifier Application

When an event is active, The Wasteland must apply its modifiers:

```gdscript
# scenes/Wasteland.gd
extends Node2D

@onready var events_service = EventsService

var current_event: SpecialEvent = null

func _ready():
    events_service.event_activated.connect(_on_event_activated)
    events_service.event_deactivated.connect(_on_event_deactivated)

    # Check for active events on load
    var active_events = events_service.get_active_events()
    if not active_events.is_empty():
        apply_event(active_events[0]) # Apply first event

func _on_event_activated(event: SpecialEvent):
    GameLogger.log_info("Event activated: " + event.name)
    apply_event(event)

func _on_event_deactivated(event_id: String):
    GameLogger.log_info("Event deactivated: " + event_id)
    clear_event_modifiers()

func apply_event(event: SpecialEvent):
    current_event = event

    # Apply environmental hazards
    if "acid_pools" in event.modifiers:
        spawn_acid_pools(event.modifiers.acid_pools)
    if "lava_zones" in event.modifiers:
        spawn_lava_zones(event.modifiers.lava_zones)
    if "slow_fields" in event.modifiers:
        spawn_slow_fields(event.modifiers.slow_fields)

    # Apply weather effects
    if "radiation_storm" in event.modifiers:
        enable_radiation_storm(event.modifiers.radiation_storm)
    if "scrap_tornado" in event.modifiers:
        increase_scrap_spawns(event.modifiers.scrap_tornado.multiplier)

    # Modify enemy spawns
    if event.exclusive_enemies:
        override_enemy_pool(event.exclusive_enemies)

    # Apply global buffs
    if "global_buff" in event.modifiers:
        apply_global_buff(event.modifiers.global_buff)

    # Show event notification
    show_event_banner(event)

func clear_event_modifiers():
    remove_all_hazards()
    reset_enemy_pool()
    remove_global_buffs()
    current_event = null
```

### 4.2 Event Enemy Spawning

```gdscript
# services/EnemySpawnService.gd

var base_enemy_pool: Array[String] = ["grunt", "runner", "tank", "sniper"]
var event_enemy_pool: Array[String] = []
var use_event_pool: bool = false

func override_enemy_pool(event_enemies: Array):
    event_enemy_pool = event_enemies
    use_event_pool = true

func reset_enemy_pool():
    use_event_pool = false
    event_enemy_pool = []

func spawn_enemy() -> Enemy:
    var pool = event_enemy_pool if use_event_pool else base_enemy_pool
    var enemy_type = pool[randi() % pool.size()]
    return create_enemy(enemy_type)
```

---

## 5. Event-Exclusive Loot

### 5.1 Event Items

Items that only drop during events:

```gdscript
var halloween_items = [
    "pumpkin_launcher",      # Rare weapon
    "zombie_armor",          # Uncommon armor
    "candy_consumable",      # +50 HP, sugar rush (speed boost)
    "haunted_trinket"        # +10% crit vs undead
]
```

**Properties:**
- Event items persist after event ends
- Can be used/equipped normally
- Tradeable via Quantum Storage (Subscription)
- Often have event-themed effects

**Drop Rate Modifiers:**
```gdscript
# Base drop rates during event
var event_drop_rates = {
    "common": 0.30,      # 30% per enemy kill
    "uncommon": 0.15,    # 15%
    "rare": 0.05,        # 5%
    "epic": 0.01,        # 1%
    "legendary": 0.001   # 0.1%
}

# Subscription bonus (applies to Premium too, but Sub gets higher)
var tier_multipliers = {
    "free": 1.0,      # No events access
    "premium": 1.0,   # Base rate
    "subscription": 1.25  # +25% drop rate
}
```

### 5.2 Event Currency

Some events have exclusive currency that expires when the event ends:

**Example: Pumpkin Coins (Halloween)**
- Drop from zombie enemies (10-50 coins per kill)
- Spend in event shop (exclusive items)
- **Expire when event ends** (use it or lose it creates urgency)

**Currency Tracking:**
```gdscript
class EventCurrency:
    var currency_id: String  # "pumpkin_coins"
    var amount: int = 0
    var event_id: String     # Links to event
    var expires_at: String   # Auto-delete after event

func add_event_currency(currency_id: String, amount: int):
    var currency = get_or_create_event_currency(currency_id)
    currency.amount += amount
    await save_event_currency(currency)

func spend_event_currency(currency_id: String, amount: int) -> bool:
    var currency = get_event_currency(currency_id)
    if not currency or currency.amount < amount:
        return false

    currency.amount -= amount
    await save_event_currency(currency)
    return true
```

---

## 6. Event Currency & Shop System

### 6.1 Event Shop

Each themed event has an exclusive shop accessible from Scrapyard:

**UI Location:** Scrapyard → Event Shop (only visible during event)

**Shop Contents:**
```gdscript
# Halloween Event Shop (example)
var halloween_shop_items = [
    {
        "name": "Pumpkin King Crown",
        "type": "armor",
        "rarity": "legendary",
        "cost": {"pumpkin_coins": 1000},
        "stats": {"luck": 30, "max_hp": 20},
        "limited": true,  # Only 1 per user
        "event_exclusive": true  # Never available again
    },
    {
        "name": "Zombie Slayer Bundle",
        "type": "bundle",
        "cost": {"pumpkin_coins": 500, "scrap": 5000},
        "contains": ["zombie_slayer_sword", "zombie_armor", "undead_trinket"],
        "limited": true
    },
    {
        "name": "Candy Pack",
        "type": "consumable",
        "cost": {"pumpkin_coins": 50},
        "quantity": 10,  # Stack of 10 candies
        "limited": false  # Can buy multiple
    }
]
```

### 6.2 Event Shop UI

```gdscript
# scenes/EventShop.gd
extends Control

@onready var shop_items_list = $ItemsList
@onready var currency_label = $CurrencyLabel
@onready var event_timer_label = $EventTimerLabel

var current_event: SpecialEvent

func _ready():
    current_event = EventsService.get_active_events()[0]
    load_shop_items()
    update_currency_display()
    start_countdown_timer()

func load_shop_items():
    var shop_data = await load_event_shop_data(current_event.id)
    for item in shop_data:
        var item_ui = create_shop_item_ui(item)
        shop_items_list.add_child(item_ui)

func create_shop_item_ui(item: Dictionary) -> Control:
    var item_node = preload("res://scenes/ShopItemCard.tscn").instantiate()
    item_node.set_item_data(item)
    item_node.purchase_requested.connect(_on_purchase_requested.bind(item))
    return item_node

func _on_purchase_requested(item: Dictionary):
    var currency_id = current_event.event_currency
    var cost = item.cost[currency_id]

    if EventCurrencyService.has_sufficient_currency(currency_id, cost):
        # Deduct currency
        await EventCurrencyService.spend_currency(currency_id, cost)

        # Add item to inventory
        if item.limited:
            item.purchased = true  # Mark as purchased (can't buy again)

        InventoryService.add_item(current_character_id, item)
        update_currency_display()
        show_purchase_success(item.name)
    else:
        show_insufficient_currency_error()

func start_countdown_timer():
    var end_time = Time.get_unix_time_from_datetime_string(current_event.end_date)
    var now = Time.get_unix_time_from_system()
    var remaining = end_time - now

    var timer = Timer.new()
    timer.timeout.connect(update_countdown)
    add_child(timer)
    timer.start(1.0)  # Update every second

func update_countdown():
    var end_time = Time.get_unix_time_from_datetime_string(current_event.end_date)
    var now = Time.get_unix_time_from_system()
    var remaining = end_time - now

    if remaining <= 0:
        event_timer_label.text = "EVENT ENDED"
        disable_shop()
    else:
        var days = int(remaining / 86400)
        var hours = int((remaining % 86400) / 3600)
        var minutes = int((remaining % 3600) / 60)
        event_timer_label.text = "Ends in: %dd %dh %dm" % [days, hours, minutes]
```

---

## 7. Event UI/UX

### 7.1 Event Banner Notification

When an event activates, show a full-screen banner:

```gdscript
# ui/EventBanner.gd
extends CanvasLayer

@onready var banner_image = $BannerImage
@onready var event_title = $Title
@onready var event_description = $Description
@onready var event_timer = $Timer
@onready var cta_button = $CTAButton  # "Enter Wasteland" button

func show_event_banner(event: SpecialEvent):
    event_title.text = event.name
    event_description.text = event.description

    # Load event-specific banner image
    var banner_path = "res://assets/events/" + event.id + "_banner.png"
    banner_image.texture = load(banner_path)

    # Show countdown
    update_event_timer(event)

    # Animate in
    play_banner_animation()

    # Auto-hide after 10 seconds (or user dismisses)
    await get_tree().create_timer(10.0).timeout
    hide_banner()

func _on_cta_button_pressed():
    # Take user to Wasteland to experience event
    get_tree().change_scene_to_file("res://scenes/Wasteland.tscn")
```

### 7.2 Event HUD Indicator

During combat, show active event info in HUD:

```
┌─────────────────────────────────────┐
│ ⚡ EVENT: Halloween Zombie Horde    │
│ 🎃 Pumpkin Coins: 245              │
│ ⏰ Ends in: 2d 14h 32m             │
└─────────────────────────────────────┘
```

### 7.3 Event History (Scrapyard Menu)

**Location:** Scrapyard → Event History

- View past events user participated in
- See event items collected
- Total event currency earned (historical)
- Achievements during events

---

## 8. Event Analytics

### 8.1 Metrics to Track

```sql
-- Event participation tracking
CREATE TABLE event_participation (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  event_id UUID REFERENCES special_events(id) NOT NULL,
  first_played_at TIMESTAMPTZ DEFAULT NOW(),
  last_played_at TIMESTAMPTZ DEFAULT NOW(),
  total_playtime INT DEFAULT 0, -- Seconds
  event_currency_earned INT DEFAULT 0,
  event_items_obtained INT DEFAULT 0,
  event_shop_purchases INT DEFAULT 0,
  highest_wave_during_event INT DEFAULT 0
);

CREATE INDEX idx_event_participation_user_id ON event_participation(user_id);
CREATE INDEX idx_event_participation_event_id ON event_participation(event_id);
```

### 8.2 Analytics Dashboard (Internal)

**Operator wants to see:**
- Participation rate (% of active users who played event)
- Average playtime during event
- Event currency economy (earned vs spent vs expired)
- Event item drop distribution
- Conversion impact (did event drive Premium/Subscription sign-ups?)
- Most popular events (for re-running)

**Example Query:**
```sql
-- Event participation summary
SELECT
  e.name AS event_name,
  COUNT(DISTINCT ep.user_id) AS unique_participants,
  AVG(ep.total_playtime) AS avg_playtime_seconds,
  SUM(ep.event_currency_earned) AS total_currency_earned,
  SUM(ep.event_shop_purchases) AS total_shop_purchases
FROM special_events e
LEFT JOIN event_participation ep ON e.id = ep.event_id
WHERE e.end_date > NOW() - INTERVAL '30 days'
GROUP BY e.id, e.name
ORDER BY unique_participants DESC;
```

---

## 9. Integration with Other Systems

### 9.1 Goals System Integration

Events can trigger special goals:

```gdscript
# Auto-create event goals when event activates
func create_event_goals(event: SpecialEvent):
    var goals = [
        {
            "name": "Halloween Survivor",
            "description": "Complete 10 waves during Halloween event",
            "requirements": {"waves_during_event": 10},
            "rewards": {"scrap": 5000, "pumpkin_coins": 100}
        },
        {
            "name": "Zombie Slayer",
            "description": "Kill 500 zombies during Halloween",
            "requirements": {"zombie_kills": 500},
            "rewards": {"scrap": 10000, "items": ["zombie_slayer_title"]}
        }
    ]

    for goal_data in goals:
        GoalsService.create_goal(goal_data, event.id)
```

### 9.2 Perks System Integration

Perks can affect events:

**Example Perk:** "Event Hunter"
- +50% event currency drops
- +10% event item drop rate
- Duration: Active event duration

**Hook Point:** `event_currency_dropped`, `event_item_dropped`

### 9.3 Trading Cards Integration

Event participation appears on trading cards:

```gdscript
# Card metadata
var card_metadata = {
    "events_participated": 5,
    "rarest_event_item": "Pumpkin King Crown (Legendary)",
    "total_event_currency_earned": 5420
}
```

---

## 10. Data Model (Complete)

```gdscript
class SpecialEvent:
    var id: String
    var name: String
    var description: String
    var type: String  # "environmental", "weather", "themed", "subscription_exclusive"
    var is_active: bool
    var start_date: String
    var end_date: String
    var target_tier: int  # 0=Free (no access), 1=Premium, 2=Subscription
    var target_regions: Array[String]  # ["us", "eu", "asia"] or [] for global
    var modifiers: Dictionary  # Wasteland changes
    var exclusive_enemies: Array[String]
    var exclusive_loot: Array[Dictionary]
    var event_currency: String  # "pumpkin_coins", "candy_canes", null if no currency
    var event_shop_items: Array[Dictionary]
    var created_at: String
```

**Supabase Schema:**
```sql
-- (Already defined in Section 3.1, repeated here for completeness)
CREATE TABLE special_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT false,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  target_tier INT DEFAULT 1,
  target_regions TEXT[],
  modifiers JSONB NOT NULL,
  exclusive_enemies JSONB,
  exclusive_loot JSONB,
  event_currency VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event currency tracking (per user)
CREATE TABLE user_event_currency (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  event_id UUID REFERENCES special_events(id) NOT NULL,
  currency_id VARCHAR(100) NOT NULL,
  amount INT DEFAULT 0,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, event_id, currency_id)
);

-- Event shop purchases (prevent duplicate limited purchases)
CREATE TABLE event_shop_purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  event_id UUID REFERENCES special_events(id) NOT NULL,
  item_id VARCHAR(255) NOT NULL,
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, event_id, item_id) -- Can only buy limited items once
);
```

---

## 11. Tier Access & Gating

### 11.1 Free Tier
**Access:** ❌ No access to Special Events

**Why Gated:**
- Events require server resources (tracking, analytics, shop)
- Premium/Subscription justification
- Creates upgrade incentive

**What Free Users See:**
- Event banner with "Premium Required" message
- Teaser video/preview of event content
- Countdown timer showing when event ends
- CTA button to upgrade

```gdscript
# ui/EventLockedBanner.gd
func show_locked_event_banner(event: SpecialEvent):
    title_label.text = event.name + " (Premium Required)"
    description_label.text = "Upgrade to Premium to participate in limited-time events!"
    upgrade_button.show()
    upgrade_button.pressed.connect(_on_upgrade_pressed)
```

### 11.2 Premium Tier
**Access:** ✅ Full access to all standard events

**Features:**
- Environmental hazard events (acid pools, lava, slow fields)
- Weather events (radiation storm, EMP, scrap tornado)
- Themed/seasonal events (Halloween, Christmas, Lunar New Year, etc.)
- Event-exclusive loot drops (base rates)
- Event shop access
- Event currency collection (base rates)
- Event goals and achievements

**Drop Rates:**
```gdscript
var premium_drop_multiplier = 1.0  # Base rate
var premium_currency_multiplier = 1.0  # Base rate
```

### 11.3 Subscription Tier
**Access:** ✅ All Premium features + Subscription-exclusive events

**Exclusive Features:**
- **Subscription-only events** (Quantum Flux, Mutant Mayhem)
- **+25% event item drop rate bonus**
- **+50% event currency bonus**
- **Priority event access** (1 hour early access before event goes live for Premium)
- **Event currency rollover** (up to 500 units carry to next instance of same event)
- **Exclusive event cosmetics** (available in event shop)

**Drop Rates:**
```gdscript
var subscription_drop_multiplier = 1.25  # +25% items
var subscription_currency_multiplier = 1.50  # +50% currency
```

**Currency Rollover Example:**
```gdscript
# When Halloween 2025 ends, save up to 500 pumpkin coins
# When Halloween 2026 starts, user starts with those saved coins
func save_event_currency_rollover(user_id: String, event_id: String):
    var currency = get_event_currency(user_id, event_id)
    if currency.amount > 500:
        currency.rollover_amount = 500
    else:
        currency.rollover_amount = currency.amount

    await save_to_database(currency)

func apply_rollover_on_event_start(user_id: String, event_id: String):
    var last_year_currency = get_previous_event_currency(user_id, event_id)
    if last_year_currency and last_year_currency.rollover_amount > 0:
        add_event_currency(user_id, event_id, last_year_currency.rollover_amount)
        show_notification("Rollover Bonus: +" + str(last_year_currency.rollover_amount) + " event currency!")
```

### 11.4 Tier Verification

```gdscript
# services/EventAccessService.gd
class_name EventAccessService
extends Node

func can_access_event(user: User, event: SpecialEvent) -> bool:
    # Check tier requirement
    if event.target_tier == 2:  # Subscription only
        return user.tier >= UserTier.SUBSCRIPTION
    elif event.target_tier == 1:  # Premium+
        return user.tier >= UserTier.PREMIUM
    else:  # Free (should never happen for events)
        return true

func get_drop_rate_multiplier(user: User) -> float:
    match user.tier:
        UserTier.SUBSCRIPTION:
            return 1.25
        UserTier.PREMIUM:
            return 1.0
        _:
            return 0.0  # Free users can't access events

func get_currency_multiplier(user: User) -> float:
    match user.tier:
        UserTier.SUBSCRIPTION:
            return 1.50
        UserTier.PREMIUM:
            return 1.0
        _:
            return 0.0
```

---

## 12. Implementation Strategy

### 12.1 Phase 1: Foundation (Week 14) - 20 hours

**Goal:** Server-side event infrastructure

**Tasks:**
1. **Database Schema (2h)**
   - Create `special_events` table
   - Create `user_event_currency` table
   - Create `event_participation` table
   - Create `event_shop_purchases` table
   - Add indexes and constraints

2. **Supabase Edge Functions (4h)**
   - `events/active` - Fetch active events
   - `events/activate` - Auto-activate events (cron job)
   - `events/participation/track` - Log user participation
   - Test edge functions locally

3. **GDScript EventsService (8h)**
   - Create `EventsService.gd` (singleton)
   - Implement event syncing with Supabase
   - Implement realtime subscription
   - Add event activation/deactivation signals
   - Unit tests for EventsService

4. **Admin Panel (6h)**
   - Create event management UI (Next.js)
   - CRUD operations for events
   - Manual event activation/deactivation
   - Event analytics dashboard (basic)

**Deliverables:**
- ✅ Events infrastructure fully functional
- ✅ Can create and activate events from admin panel
- ✅ Client can sync events in real-time

### 12.2 Phase 2: Environmental Hazards (Week 15) - 16 hours

**Goal:** Implement first event type (environmental hazards)

**Tasks:**
1. **Hazard Entities (8h)**
   - Create `AcidPool.gd` scene (Area2D, DoT logic)
   - Create `LavaZone.gd` scene (instant damage)
   - Create `SlowField.gd` scene (movement modifier)
   - Create `TeleportTrap.gd` scene (random teleport)
   - Visual effects for each hazard (particles, shaders)

2. **Wasteland Integration (4h)**
   - Update `Wasteland.gd` to spawn hazards based on event modifiers
   - Implement hazard spawning logic (random positions, safe zones)
   - Add hazard cleanup on event end

3. **UI Indicators (4h)**
   - HUD indicator showing active event
   - Hazard warnings (tooltips on hover)
   - Event timer display

**Deliverables:**
- ✅ 4 environmental hazards fully functional
- ✅ Hazards spawn during events
- ✅ UI shows event status

### 12.3 Phase 3: Event Currency & Shop (Week 16) - 24 hours

**Goal:** Implement event-specific economy

**Tasks:**
1. **Event Currency System (8h)**
   - Create `EventCurrency.gd` class
   - Implement currency drops from enemies
   - Add currency persistence (Supabase)
   - Currency expiration logic
   - Subscription rollover feature

2. **Event Shop (12h)**
   - Create `EventShop.gd` scene (UI)
   - Implement shop item loading from server
   - Purchase logic (currency spending)
   - Limited item tracking (1 per user)
   - Shop countdown timer
   - Shop item preview (3D renders, stats)

3. **Event Items (4h)**
   - Design 5-10 event-exclusive items (data only)
   - Add event item metadata (rarity, stats, costs)
   - Item drop logic during events
   - Event item persistence in inventory

**Deliverables:**
- ✅ Event currency collection working
- ✅ Event shop fully functional
- ✅ Event items can be purchased and used

### 12.4 Phase 4: First Themed Event (Week 17-18) - 32 hours

**Goal:** Launch first complete themed event (Halloween)

**Tasks:**
1. **Event Design (4h)**
   - Finalize Halloween event spec (enemies, items, shop)
   - Write event narrative/description
   - Design event banner artwork (commission or AI)

2. **Event Enemies (12h)**
   - Create `ZombieEnemy.gd` (unique AI, slower but tankier)
   - Create `SkeletonEnemy.gd` (fast, low HP)
   - Create `PumpkinKingBoss.gd` (mini-boss, rare spawn)
   - Enemy animations and visual effects

3. **Event Items (8h)**
   - Model/texture 5 Halloween items:
     - Pumpkin Launcher (weapon)
     - Zombie Armor (armor)
     - Necro Staff (weapon)
     - Haunted Trinket (trinket)
     - Pumpkin King Crown (legendary armor)
   - Implement item effects (life steal, bonus vs undead, etc.)

4. **Event Shop (4h)**
   - Populate Halloween shop with 8-10 items
   - Set pricing (balance currency earn rate vs costs)
   - Add shop exclusive cosmetics

5. **Testing & Balancing (4h)**
   - Playtest event multiple times
   - Balance currency drop rates
   - Balance item costs
   - Balance enemy difficulty

**Deliverables:**
- ✅ Halloween event fully playable
- ✅ All event systems working together
- ✅ Event is fun and engaging

### 12.5 Phase 5: Event Analytics (Week 19) - 8 hours

**Goal:** Track event success metrics

**Tasks:**
1. **Analytics Implementation (4h)**
   - Track event participation (first play, last play, playtime)
   - Track currency earned/spent/expired
   - Track shop purchases
   - Track item drops

2. **Analytics Dashboard (4h)**
   - Build analytics dashboard in admin panel
   - Show participation rate, engagement metrics
   - Event ROI (did it drive conversions?)
   - Export analytics to CSV

**Deliverables:**
- ✅ Full event analytics tracking
- ✅ Dashboard for monitoring event success

### 12.6 Phase 6: Event Rotation System (Week 20+) - 12 hours

**Goal:** Automate event calendar and rotation

**Tasks:**
1. **Event Calendar (6h)**
   - Define annual event schedule (JSON config)
   - Auto-schedule events for next 12 months
   - Community event voting system (optional)

2. **Event Templates (6h)**
   - Create reusable event templates
   - Allow variations of same event (Halloween 2025 vs 2026)
   - A/B testing framework for events

**Deliverables:**
- ✅ Events rotate automatically
- ✅ Easy to create new events from templates

**Total Implementation Time:** ~112 hours (14 days of full-time work)

---

## 13. Balancing Considerations

### 13.1 Event Difficulty

**Problem:** Events should feel challenging but not punishing

**Solution:**
- Environmental hazards deal manageable damage (10-50 HP)
- Hazards are clearly telegraphed (visual indicators, sound cues)
- Always provide escape routes (no insta-kill corners)
- Event enemies have 10-20% more HP than standard enemies
- Boss enemies (Pumpkin King) are optional encounters

**Balancing Formula:**
```gdscript
# Event enemy HP scaling
var event_enemy_hp_multiplier = 1.15  # +15% HP
var event_boss_hp_multiplier = 3.0    # 3x HP for bosses

# Hazard damage scaling (relative to average character HP at wave 10)
var avg_hp_wave_10 = 100
var acid_pool_dps = avg_hp_wave_10 * 0.10  # 10% HP/sec = 10 DPS
var lava_zone_damage = avg_hp_wave_10 * 0.50  # 50% HP instant = 50 damage
```

### 13.2 Event Currency Economy

**Problem:** Currency must be scarce enough to drive urgency, but abundant enough to afford 1-2 shop items

**Solution:**
- Average currency per wave: 50-100 coins (base rate)
- Shop items range: 50 (consumables) to 1000 (legendary armor)
- Users should earn 500-800 coins if they play 10-20 waves during event
- Goal: User can afford 1 legendary item OR 2-3 epic items

**Currency Tuning:**
```gdscript
# Currency drop rates (per enemy kill)
var currency_drop_chance = 0.30  # 30% chance per kill
var currency_amount_range = [5, 15]  # 5-15 coins per drop

# Example: 10 waves, 50 enemies per wave, 30% drop rate
# Expected currency: 10 * 50 * 0.30 * 10 (avg) = 1500 coins
# With Subscription bonus (+50%): 2250 coins

# Shop pricing:
# Consumables: 50-100 coins
# Uncommon items: 200-300 coins
# Rare items: 400-600 coins
# Epic items: 700-900 coins
# Legendary items: 1000-1500 coins
```

### 13.3 Event Frequency

**Problem:** Too many events = fatigue, too few = boredom

**Solution:**
- **Max 1 event active at a time**
- **Seasonal events:** 4-5 per year (Halloween, Christmas, Lunar New Year, Summer, Día de los Muertos)
- **Subscription-exclusive events:** 1 per month (48-72 hour duration)
- **Downtime between events:** At least 2 weeks

**Annual Event Calendar (Example):**
| Month | Event | Duration | Type |
|-------|-------|----------|------|
| January | Lunar New Year | 14 days | Seasonal (Themed) |
| February | - | - | - |
| March | - | - | - |
| April | Quantum Flux | 48 hours | Subscription |
| May | - | - | - |
| June | Summer Scorch | 14 days | Seasonal (Weather) |
| July | Mutant Mayhem | 72 hours | Subscription |
| August | - | - | - |
| September | - | - | - |
| October | Halloween: Zombie Horde | 14 days | Seasonal (Themed) |
| November | Día de los Muertos | 3 days | Seasonal (Themed) |
| December | Christmas: Frostbite Wasteland | 14 days | Seasonal (Themed) |

### 13.4 Event Item Power

**Problem:** Event items must feel special without breaking game balance

**Solution:**
- Event items are **sidegrades, not upgrades**
- They have unique effects but similar DPS/stats to standard items
- Legendary event items are on par with standard legendary items
- Event items have cosmetic distinctiveness (glow, particles, unique models)

**Example Comparison:**
```gdscript
# Standard Legendary Weapon
var plasma_rifle = {
    "damage": 50,
    "fire_rate": 2.0,  # Shots per second
    "dps": 100,
    "special": null
}

# Event Legendary Weapon (Halloween)
var necro_staff = {
    "damage": 40,
    "fire_rate": 2.0,
    "dps": 80,  # Lower base DPS
    "special": "10% life steal",  # But has life steal
    "bonus_vs_undead": 25  # +25 damage vs zombies/skeletons (situational)
}
# Net result: ~Equal power, different playstyle
```

### 13.5 Subscription Event Balance

**Problem:** Subscription events must feel valuable without alienating Premium users

**Solution:**
- Subscription events offer **quantity, not quality**
- More frequent (monthly vs seasonal)
- Shorter duration (48-72 hours vs 14 days)
- Higher rewards (2-3x currency/scrap), but items are similar power
- Premium users see "Upgrade to Subscription" prompt during Sub events

**Messaging:**
```gdscript
# Premium users see during Subscription event:
"🚀 Quantum Flux Event (Subscription Only)
Subscribers get 2x scrap and exclusive Quantum items!
Upgrade to Subscription to participate.
[Upgrade Now] [Maybe Later]"
```

---

## 14. Open Questions & Future Enhancements

### 14.1 Open Questions

**Q1: Should events scale with character level/wave progression?**
- Option A: Events are fixed difficulty (wave 1 feels hard, wave 30 feels easy)
- Option B: Event hazards scale with current wave (always challenging)
- **Recommendation:** Option B (scale with wave, but cap at wave 20)

**Q2: Can users stockpile event currency across multiple years?**
- Option A: Currency expires completely (use it or lose it)
- Option B: Subscription users keep up to 500 units (rollover)
- **Recommendation:** Option B (implemented in Section 11.3)

**Q3: Should event items be tradeable between characters?**
- Option A: Event items are character-bound (can't transfer)
- Option B: Event items can be banked (Quantum Storage for Subscription)
- **Recommendation:** Option B (aligns with existing Quantum Storage feature)

**Q4: Should there be event leaderboards?**
- Option A: Yes, show top players during event (most currency earned, highest wave)
- Option B: No, keep events casual (no competitive pressure)
- **Recommendation:** Option A (add leaderboards in Phase 6+)

**Q5: Should Free users see event content at all?**
- Option A: Hide events completely from Free users
- Option B: Show locked event banners (teaser + upgrade CTA)
- **Recommendation:** Option B (drives conversions, shown in Section 11.1)

### 14.2 Future Enhancements (Post-Launch)

**Enhancement 1: Event Passes**
- Seasonal "Event Pass" (similar to Battle Pass)
- Premium/Subscription users get pass automatically
- Complete event goals to unlock cosmetic tiers
- Example: "Halloween Pass" with 10 tiers of pumpkin-themed cosmetics

**Enhancement 2: Community-Created Events**
- Allow users to vote on next event theme
- Community challenges during events (global goals)
- Example: "All players must collectively kill 1 million zombies to unlock bonus rewards"

**Enhancement 3: Event Mutators**
- Weekly modifiers that stack on top of events
- Example: "Zombie Horde + Giant Mode" (all enemies 2x size and HP)
- Allows replayability of same events with new challenges

**Enhancement 4: Event PvP**
- Asynchronous PvP during events
- Players compete for highest score (currency earned, waves survived)
- Leaderboard rewards (top 100 get exclusive items)

**Enhancement 5: Event Storyline**
- Each event has a mini-story (3-5 cutscenes)
- Unlocks lore about The Wasteland universe
- Story progress saved between event occurrences

**Enhancement 6: Cross-Event Achievements**
- Meta-achievements spanning multiple events
- Example: "Seasonal Master" (participate in all 4 seasonal events in one year)
- Rewards: Exclusive "All-Season" armor set

**Enhancement 7: Event Challenges**
- Daily/weekly challenges during events
- Example: "Kill 50 zombies with melee weapons only"
- Rewards: Bonus event currency

---

## 15. Summary

### 15.1 What Special Events Provide

The Special Events System delivers:

1. **Variety & Freshness**
   - Breaks up standard wasteland combat
   - Seasonal themes keep content feeling new
   - Environmental hazards add strategic depth

2. **Retention & Engagement**
   - FOMO (fear of missing out) drives login frequency
   - Limited-time rewards encourage active play
   - Event countdown timers create urgency

3. **Monetization Justification**
   - Premium exclusive feature (clear value prop)
   - Subscription bonuses (+25% drops, +50% currency)
   - Drives Free → Premium conversions

4. **Replayability**
   - Same event returns yearly with slight variations
   - Community never fully exhausts event content
   - New events added post-launch (no client updates)

### 15.2 Key Features Recap

- ✅ **Server-activated events** (no client updates required)
- ✅ **Multiple event types** (environmental, weather, themed, subscription-only)
- ✅ **Event-exclusive loot** (items persist after event ends)
- ✅ **Event currency & shop** (limited-time economy)
- ✅ **Tier gating** (Premium+ access, Subscription bonuses)
- ✅ **Full analytics** (participation tracking, success metrics)
- ✅ **Seasonal rotation** (4-5 events per year)

### 15.3 Implementation Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1 | Week 14 (20h) | Event infrastructure complete |
| Phase 2 | Week 15 (16h) | Environmental hazards working |
| Phase 3 | Week 16 (24h) | Event currency & shop functional |
| Phase 4 | Week 17-18 (32h) | First themed event (Halloween) playable |
| Phase 5 | Week 19 (8h) | Event analytics tracking |
| Phase 6 | Week 20+ (12h) | Event rotation system automated |

**Total:** ~112 hours (~14 days of focused work)

### 15.4 Success Metrics

Track these KPIs to measure event success:

- **Participation Rate:** % of Premium/Subscription users who play during event
  - Target: >60% participation
- **Engagement Time:** Average playtime during event vs non-event
  - Target: +30% playtime increase
- **Currency Economy:** % of earned currency that gets spent in shop
  - Target: >70% spent (not expired)
- **Conversion Impact:** % of Free users who upgrade during event window
  - Target: +10% conversion rate
- **Retention Impact:** Day 7 retention for users who played event vs didn't
  - Target: +15% retention for event participants

### 15.5 Status & Next Steps

**Current Status:** 📝 Fully documented, ready for implementation

**Prerequisites:**
- ✅ Core gameplay loop complete (Waves 1-30 balanced)
- ✅ Character Service with inventory/loadouts
- ✅ Shop system functional
- ✅ Supabase integration stable
- ⏳ Perks system (optional, but provides event-specific perks)

**Next Steps:**
1. Review this document with team
2. Validate event calendar and themes
3. Begin Phase 1 implementation (Week 14)
4. Design first event (Halloween recommended)
5. Commission/create event artwork (banners, enemy sprites, item models)

**Status:** Ready for Week 14+ implementation (after Shop system and core gameplay are polished).

---

*End of Special Events System Documentation*
