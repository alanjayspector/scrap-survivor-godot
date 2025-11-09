# Subscription Services System

**Version:** 1.0
**Date:** January 9, 2025
**Status:** Comprehensive Design Document
**Godot Version:** 4.5.1

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Design Philosophy](#2-design-philosophy)
3. [Subscription Pricing & Value](#3-subscription-pricing--value)
4. [Core Subscription Services](#4-core-subscription-services)
5. [Atomic Vending Machine](#5-atomic-vending-machine)
6. [Quantum Banking Suite](#6-quantum-banking-suite)
7. [Special Events Bonuses](#7-special-events-bonuses)
8. [Black Market Advantages](#8-black-market-advantages)
9. [Trading Cards Features](#9-trading-cards-features)
10. [Priority & Convenience Features](#10-priority--convenience-features)
11. [Subscription Management](#11-subscription-management)
12. [Technical Architecture](#12-technical-architecture)
13. [Implementation Strategy](#13-implementation-strategy)
14. [Balancing Considerations](#14-balancing-considerations)
15. [Open Questions & Future Enhancements](#15-open-questions--future-enhancements)
16. [Summary](#16-summary)

---

## 1. System Overview

### 1.1 What is Subscription Services?

**Subscription Services** is the comprehensive suite of exclusive features, bonuses, and convenience tools available to users who maintain an active monthly subscription ($4.99/month).

**Core Philosophy:** Subscription provides **convenience, exclusivity, and enhanced progression** without crossing into pay-to-win territory.

### 1.2 Key Features

- **Atomic Vending Machine** - Weekly personalized shop with Epic/Legendary items
- **Quantum Banking** - Transfer items and scrap between characters
- **Event Bonuses** - +25% drops, +50% currency, currency rollover
- **Exclusive Events** - Monthly subscription-only events (Quantum Flux, Mutant Mayhem)
- **Hall of Fame** - Archive up to 200 characters (read-only preservation)
- **Black Market Perks** - +10% legendary rate, early access, reroll discount
- **Trading Cards Pro** - Video exports, batch export, exclusive frames
- **Priority Features** - Faster processing, early access to new content

### 1.3 Monetization Model

```
Free Tier (No cost)
  ↓
Premium Pack ($9.99 one-time)
  ↓
Subscription ($4.99/month) ← Recurring revenue, includes all Premium features
```

**Key Insight:** Subscription includes Premium benefits (no separate Premium required)

### 1.4 Target Audience

**Who subscribes?**
- **Engaged players** (30+ hours played, Wave 20+)
- **Power users** (multiple characters, experimenting with builds)
- **Collectors** (want to preserve legacy characters)
- **Convenience seekers** (value time-saving features)
- **Event enthusiasts** (participate in all events)

**Estimated Subscription Rate:** 5-10% of active users

---

## 2. Design Philosophy

### 2.1 Design Principles

**1. Convenience Over Power**
- Subscription features save time and effort
- Don't directly increase damage/HP
- Example: Quantum Banking transfers resources (convenience) vs giving +50 damage (power)

**2. Exclusivity Creates Value**
- Some content is subscription-only (creates FOMO)
- Exclusive events, items, cosmetics
- But: Core gameplay accessible to Premium tier

**3. Long-Term Engagement**
- Weekly cadence (vending machine refresh)
- Monthly events (subscription-exclusive)
- Character archival (preserves progress)

**4. Clear Value Proposition**
- User understands what they get for $4.99/month
- Benefits are visible and tangible
- Marketing messaging emphasizes convenience + exclusivity

### 2.2 Not Pay-to-Win

**How Subscription Avoids Pay-to-Win:**

❌ **What Subscription DOESN'T Give:**
- Higher base damage/HP/stats
- Immunity to death
- Exclusive legendary tier items with higher stats
- Guaranteed wins or progression

✅ **What Subscription DOES Give:**
- More opportunities (weekly shop, more events)
- Convenience (item repair, resource transfer)
- Variety (more builds through Quantum Banking)
- Collectibility (archival)

**Competitive Balance:**
- Premium player with skill > Subscription player without skill
- Subscription enhances experience, doesn't guarantee success

### 2.3 Retention Strategy

**Subscription Retention Hooks:**

1. **Weekly Vending Machine** - "Check back Monday for new items"
2. **Monthly Events** - "Quantum Flux event this weekend!"
3. **Currency Rollover** - "Save your Halloween coins for next year"
5. **Archived Characters** - "Your legacy characters are preserved forever"

**Goal:** Create habitual engagement (check game weekly/monthly)

---

## 3. Subscription Pricing & Value

### 3.1 Pricing Structure

```
Subscription Tier: $4.99/month (USD)
  - Includes all Premium Pack features ($9.99 value)
  - Plus exclusive subscription features

Regional Pricing:
  - US: $4.99
  - EU: €4.99
  - UK: £4.99
  - JP: ¥600
  - Rest of World: Adjusted for purchasing power parity
```

### 3.2 Value Calculation

**What User Gets:**

| Feature | Estimated Value | Frequency |
|---------|----------------|-----------|
| **Premium Pack** (included) | $9.99 | One-time |
| **Atomic Vending Machine** | $2/week | Weekly |
| **Quantum Banking** | $3/month | Continuous |
| **Event Bonuses** | $3/month | Event-dependent |
| **Exclusive Events** | $2/month | Monthly |
| **Hall of Fame** | $1/month | One-time setup |
| **Trading Cards Pro** | $1/month | As-needed |
| **Black Market Perks** | $1/month | Continuous |
| **Total Estimated Value** | **$15-20/month** | - |

**Value Proposition:** Get $15-20 of value for $4.99/month

### 3.3 Subscription Tiers (Future Consideration)

**Potential Future Model:**

```
Subscription Basic: $4.99/month
  - All current subscription features

Subscription Pro: $9.99/month (FUTURE)
  - All Basic features
  - 2x Vending Machine purchases (2 items per week instead of 1)
  - +50% event currency bonus (instead of +50%, now +100%)
  - VIP support (priority customer service)
```

**Recommendation:** Start with single subscription tier, add Pro tier post-launch if demand exists

---

## 4. Core Subscription Services

### 4.1 Service Categories

**1. Economy Services**
- Atomic Vending Machine (personalized shopping)
- Quantum Banking (resource transfer)
- Black Market perks (better deals)

**2. Progression Services**
- Event bonuses (faster progression)
- Exclusive events (more content)

**3. Collection Services**
- Hall of Fame (character archival)
- Trading Cards Pro (enhanced sharing)

**4. Convenience Services**
- Priority processing (faster load times, card generation)
- Early access (new features, events)
- Exclusive cosmetics (frames, borders)

### 4.2 Service Integration

**How Services Work Together:**

```
User subscribes
  ↓
Unlocks Atomic Vending Machine → Buys legendary weapon
  ↓
Uses Quantum Banking → Transfers weapon to main character
  ↓
  ↓
Participates in exclusive event → Earns +50% currency
  ↓
Buys event shop items → Archives old character in Hall of Fame
  ↓
Shares archived character card → Uses Trading Cards Pro (video export)
```

**Synergy:** Each service enhances the value of others

### 4.3 Subscription Gating

**How System Checks Subscription:**

```gdscript
# services/SubscriptionService.gd
class_name SubscriptionService
extends Node

signal subscription_status_changed(is_active: bool)

func is_subscriber() -> bool:
    var user = UserService.get_current_user()
    return user.tier >= UserTier.SUBSCRIPTION

func has_active_subscription() -> bool:
    var user = UserService.get_current_user()
    if user.tier < UserTier.SUBSCRIPTION:
        return false

    # Check subscription expiration
    var now = Time.get_unix_time_from_system()
    var expiration = user.subscription_expires_at

    return expiration > now

func get_subscription_expires_at() -> int:
    var user = UserService.get_current_user()
    return user.subscription_expires_at

func days_until_expiration() -> int:
    if not has_active_subscription():
        return 0

    var now = Time.get_unix_time_from_system()
    var expiration = get_subscription_expires_at()
    var seconds_remaining = expiration - now

    return int(seconds_remaining / 86400)
```

**Subscription States:**
- **Active:** Full access to all features
- **Expiring Soon:** Warning shown (3 days before expiration)
- **Expired:** Features locked, but data preserved
- **Grace Period:** 7 days grace period (can renew without losing benefits)

---

## 5. Atomic Vending Machine

### 5.1 Overview

**Weekly personalized shop** with 3 Epic/Legendary items tailored to user's playstyle.

**Key Features:**
- Refreshes every Monday 00:00 UTC
- 3 items: 1 weapon, 1 armor/trinket, 1 minion/consumable
- Only 1 purchase per week (choice matters)
- Personalized based on playstyle and character type
- Push notifications when refreshed

**See:** [ATOMIC-VENDING-MACHINE.md](ATOMIC-VENDING-MACHINE.md) for full details

### 5.2 Value Proposition

**Why Vending Machine is Valuable:**

1. **No RNG** - Items are tailored to your playstyle (not random)
2. **High Quality** - Only Epic/Legendary rarity
3. **Exclusive Access** - Premium/Free users can't access
4. **Weekly Cadence** - Creates routine ("Check game on Mondays")

**Example User Flow:**

```
Monday morning:
  → Receive push notification ("Vending machine refreshed!")
  → Open app, see 3 personalized items
  → "Perfect! A legendary plasma rifle for my DPS build"
  → Purchase for 37,500 scrap
  → Item added to inventory
  → Come back next Monday for more
```

### 5.3 Implementation Checklist

**Prerequisites:**
- ✅ PersonalizationService (tracks playstyle)
- ✅ ItemGenerationService (creates personalized items)
- ✅ SupabaseService (stores inventory, purchase tracking)
- ✅ PushNotificationService (alerts on refresh)

**Integration Points:**
- Scrapyard hub (vending machine button)
- Weekly refresh cron job (Supabase Edge Function)
- Purchase flow (validate subscription, deduct scrap)

---

## 6. Quantum Banking Suite

### 6.1 Overview

**Transfer items and scrap between characters** (Subscription exclusive)

**Two Sub-Features:**
1. **Quantum Storage** - Item transfer (unlimited, free)
2. **Quantum Banking** - Scrap transfer (with conversion fees)

**See:** [INVENTORY-SYSTEM.md](INVENTORY-SYSTEM.md) Section 4 for full details

### 6.2 Quantum Storage (Item Transfer)

**Concept:** Shared vault accessible by all characters

```gdscript
# services/QuantumStorageService.gd
const MAX_VAULT_SIZE = 999  # Effectively unlimited for subscribers

func deposit_item(character_id: String, item_id: String) -> Result:
    # Check subscription
    if not SubscriptionService.is_subscriber():
        return Result.error("Quantum Storage requires Subscription")

    # Check vault space
    var vault_items = await get_vault_items()
    if vault_items.size() >= MAX_VAULT_SIZE:
        return Result.error("Vault is full")

    # Remove from character, add to vault
    var item = InventoryService.get_item(character_id, item_id)
    await InventoryService.remove_item(character_id, item_id)
    await add_to_vault(item)

    return Result.success("Item deposited")

func withdraw_item(character_id: String, item_id: String) -> Result:
    # Check subscription
    if not SubscriptionService.is_subscriber():
        return Result.error("Quantum Storage requires Subscription")

    # Check character has inventory space
    var character = CharacterService.get_character(character_id)
    if character.inventory.size() >= character.max_inventory_size:
        return Result.error("Character inventory is full")

    # Remove from vault, add to character
    var item = await get_vault_item(item_id)
    await remove_from_vault(item_id)
    await InventoryService.add_item(character_id, item)

    return Result.success("Item withdrawn")
```

**Use Cases:**
- Transfer legendary weapon from retired character to new main
- Move all armor to tank character for specialized build
- Consolidate rare items into single character for selling

### 6.3 Quantum Banking (Scrap Transfer)

**Concept:** Transfer scrap with conversion fees (acts as economy sink)

**Fee Structure:**
```gdscript
const TRANSFER_FEES = {
    "0-1000": 0.10,     # 10% fee for small transfers
    "1001-5000": 0.05,  # 5% fee for medium transfers
    "5001+": 0.02       # 2% fee for large transfers
}

func transfer_scrap(from_character_id: String, to_character_id: String, amount: int) -> Result:
    # Check subscription
    if not SubscriptionService.is_subscriber():
        return Result.error("Quantum Banking requires Subscription")

    # Get source character
    var from_character = CharacterService.get_character(from_character_id)
    if from_character.currency < amount:
        return Result.error("Insufficient scrap")

    # Calculate fee
    var fee_percent = get_fee_percent(amount)
    var fee_amount = int(amount * fee_percent)
    var net_amount = amount - fee_amount

    # Show confirmation
    var confirmed = await show_confirmation_dialog(
        "Transfer %d scrap to %s?" % [amount, to_character.name],
        "Fee: %d scrap (%d%%)\nRecipient receives: %d scrap" % [fee_amount, fee_percent * 100, net_amount]
    )

    if not confirmed:
        return Result.error("User cancelled")

    # Execute transfer
    from_character.currency -= amount
    await CharacterService.update_character(from_character)

    var to_character = CharacterService.get_character(to_character_id)
    to_character.currency += net_amount
    await CharacterService.update_character(to_character)

    # Log transaction (analytics)
    await log_transfer(from_character_id, to_character_id, amount, fee_amount)

    return Result.success("Transfer complete", {"net_amount": net_amount, "fee": fee_amount})
```

**Example Transfer:**
```
Tank character: 50,000 scrap (rarely play anymore)
DPS character: 5,000 scrap (main character)

Transfer 30,000 scrap from Tank → DPS:
  - Amount: 30,000
  - Fee: 5% (medium tier) = 1,500 scrap
  - Tank loses: 30,000 scrap (now 20,000)
  - DPS gains: 28,500 scrap (now 33,500)
  - Fee destroyed (economy sink)
```

**Design Rationale:**
- **Fee prevents abuse** (can't infinitely shuffle scrap)
- **Tiered fees incentivize larger transfers** (more efficient)
- **Economy sink** (removes scrap from game, fights inflation)

### 6.4 UI Implementation

**Quantum Banking Scene:**

```gdscript
# scenes/QuantumBankingHub.gd
extends Control

@onready var storage_tab = $Tabs/StorageTab
@onready var banking_tab = $Tabs/BankingTab
@onready var subscription_required_banner = $SubscriptionBanner

func _ready():
    # Check subscription access
    if not SubscriptionService.is_subscriber():
        show_subscription_required_view()
        return

    load_quantum_banking_ui()

func show_subscription_required_view():
    subscription_required_banner.show()
    subscription_required_banner.title = "Quantum Banking (Subscription Only)"
    subscription_required_banner.description = "Transfer items and scrap between characters!"
    subscription_required_banner.upgrade_button.pressed.connect(_on_upgrade_pressed)

func load_quantum_banking_ui():
    # Load storage tab (item vault)
    storage_tab.load_vault_items()
    storage_tab.load_character_list()

    # Load banking tab (scrap transfers)
    banking_tab.load_character_balances()
    banking_tab.transfer_requested.connect(_on_scrap_transfer_requested)
```

---

## 7. Special Events Bonuses

### 7.1 Overview

**Subscription users get significant bonuses during Special Events:**

- **+25% item drop rate** (more event-exclusive items)
- **+50% event currency** (can afford more shop items)
- **Currency rollover** (save up to 500 units for next year's event)
- **Priority access** (1 hour early access before Premium users)

**See:** [SPECIAL-EVENTS-SYSTEM.md](SPECIAL-EVENTS-SYSTEM.md) Section 11.3 for full details

### 8.2 Drop Rate Multipliers

```gdscript
# services/EventAccessService.gd
func get_drop_rate_multiplier(user: User) -> float:
    match user.tier:
        UserTier.SUBSCRIPTION:
            return 1.25  # +25% more drops
        UserTier.PREMIUM:
            return 1.0   # Base rate
        _:
            return 0.0   # Free users can't access events

func get_currency_multiplier(user: User) -> float:
    match user.tier:
        UserTier.SUBSCRIPTION:
            return 1.50  # +50% more currency
        UserTier.PREMIUM:
            return 1.0   # Base rate
        _:
            return 0.0
```

**Example Event Rewards:**

```
Premium user plays 10 waves during Halloween event:
  - Expected item drops: 3 event items
  - Expected currency: 1,000 pumpkin coins

Subscription user plays 10 waves during Halloween event:
  - Expected item drops: 3.75 event items (+25% = ~1 extra item every 4 waves)
  - Expected currency: 1,500 pumpkin coins (+50%)

Result: Subscription user can afford 1 legendary item (1,500 coins)
        Premium user can only afford 1 epic item (1,000 coins)
```

### 8.3 Currency Rollover

**Problem:** Event currency expires when event ends (use it or lose it)

**Solution:** Subscription users can save up to 500 currency for next year's event

```gdscript
# When Halloween 2025 ends
func save_event_currency_rollover(user_id: String, event_id: String):
    var currency = EventsService.get_event_currency(user_id, event_id)

    # Subscription users get rollover
    if SubscriptionService.is_subscriber():
        var rollover_amount = min(currency.amount, 500)
        currency.rollover_amount = rollover_amount
        await save_to_database(currency)

        show_notification("Rollover Saved: %d %s carried to next year!" % [rollover_amount, currency.currency_name])
    else:
        # Premium users lose all currency
        currency.amount = 0
        await save_to_database(currency)

        show_notification("Event ended. All %s expired." % currency.currency_name)

# When Halloween 2026 starts
func apply_rollover_on_event_start(user_id: String, event_id: String):
    var last_year_currency = get_previous_event_currency(user_id, event_id)

    if last_year_currency and last_year_currency.rollover_amount > 0:
        add_event_currency(user_id, event_id, last_year_currency.rollover_amount)
        show_notification("Welcome back! Rollover Bonus: +%d coins" % last_year_currency.rollover_amount)
```

**Value Proposition:**
- **Rewards consistency** ("If I play every Halloween, I build up savings")
- **Reduces FOMO** ("I didn't finish this event, but I saved 500 coins for next time")
- **Long-term engagement** ("I've saved currency from 3 events, I'm invested")

### 8.4 Subscription-Exclusive Events

**Premium users:** Access to seasonal events (Halloween, Christmas, etc.)
**Subscription users:** Access to ALL events + exclusive monthly events

**Exclusive Events:**
- **Quantum Flux** (48-72 hours, monthly)
- **Mutant Mayhem** (48-72 hours, monthly)
- Future exclusive events TBD

**Why Exclusive Events Matter:**
- **More content** (double the events per year)
- **Higher rewards** (2-3x scrap, exclusive items)
- **Prestige** ("I have items Premium users can't get")

**See:** [SPECIAL-EVENTS-SYSTEM.md](SPECIAL-EVENTS-SYSTEM.md) Section 6 for exclusive event details

---

## 9. Black Market Advantages

### 9.1 Overview

**Subscription users get better deals and access in Black Market:**

- **+10% legendary spawn rate** (10% → 11%)
- **Early access** (5 minutes before Premium users)
- **Reroll discount** (200 → 150 scrap per reroll)
- **Notifications** when Curse Removal Scrolls spawn

**See:** [BLACK-MARKET-SYSTEM.md](BLACK-MARKET-SYSTEM.md) Section 7.2 for full details

### 9.2 Legendary Spawn Rate Bonus

```gdscript
func get_legendary_spawn_rate(user: User) -> float:
    var base_rate = 0.10  # 10% for Premium

    if user.tier >= UserTier.SUBSCRIPTION:
        return base_rate * 1.1  # +10% bonus = 11%

    return base_rate
```

**Impact:**
- Black Market has 9 item slots
- Base legendary chance: 10% per slot = ~60% chance for at least 1 legendary per refresh
- Subscription bonus: 11% per slot = ~65% chance for at least 1 legendary per refresh

**Small but meaningful:** Over 100 refreshes, subscription users see ~5 more legendaries

### 9.3 Early Access

**Concept:** Subscription users get 5-minute early access to Black Market refreshes

```gdscript
# Refresh Black Market on wave completion
func _on_wave_completed():
    if SubscriptionService.is_subscriber():
        # Subscription: immediate access
        refresh_black_market_immediately()
    elif UserService.has_premium_access():
        # Premium: 5-minute delay
        await get_tree().create_timer(300).timeout
        refresh_black_market_for_premium()
```

**Why This Matters:**
- **Competitive advantage:** Subscribers get first pick of best items
- **Prestige:** "I saw the legendary before anyone else"
- **Tangible benefit:** Makes subscription feel worth it

### 9.4 Reroll Discount

```gdscript
func get_reroll_cost(user: User) -> int:
    const BASE_COST = 200

    if user.tier >= UserTier.SUBSCRIPTION:
        return 150  # 25% discount

    return BASE_COST
```

**Impact:**
- Premium user rerolls 10 times: 2,000 scrap
- Subscription user rerolls 10 times: 1,500 scrap
- **Savings: 500 scrap** (enough for 1 rare item)

---

## 10. Trading Cards Features

### 10.1 Overview

**Subscription users get enhanced trading card features:**

- **Video exports** (10-15 second animated card reveals for TikTok)
- **Batch export** (export multiple cards at once)
- **Exclusive frames** (subscriber-only card borders)
- **Priority rendering** (faster card generation)

**See:** [TRADING-CARDS-SYSTEM.md](TRADING-CARDS-SYSTEM.md) Section 7.3 for full details

### 10.2 Video Exports

**Feature:** Export animated trading card video for TikTok/Instagram Reels

```gdscript
# services/CardVideoExportService.gd
func export_video_card(card: TradingCard) -> String:
    # Check subscription
    if not SubscriptionService.is_subscriber():
        return ""  # Feature locked

    # Create animation timeline
    var timeline = [
        {"time": 0.0, "action": "show_card_back"},
        {"time": 1.0, "action": "flip_card"},
        {"time": 2.0, "action": "reveal_stats_sequential"},
        {"time": 8.0, "action": "show_referral_qr_code"},
        {"time": 10.0, "action": "fade_out"}
    ]

    # Render video (1080x1920, 10-15 seconds)
    var video_path = "user://exports/card_video_%s.mp4" % card.character_id
    await VideoExportService.render_animation(card, timeline, video_path)

    return video_path
```

**Value:** TikTok/Reels content creates more viral sharing

### 10.3 Batch Export

**Feature:** Export all character cards at once (vs one at a time)

```gdscript
func batch_export_cards(character_ids: Array[String]) -> Array[String]:
    if not SubscriptionService.is_subscriber():
        return []

    var export_paths: Array[String] = []

    for character_id in character_ids:
        var card = TradingCard.new()
        card.populate_from_character(CharacterService.get_character(character_id))

        var image = CardGenerationService.generate_card(card)
        var path = "user://exports/card_%s.png" % character_id
        image.save_png(path)

        export_paths.append(path)

    return export_paths
```

**Value:** Convenience (save 10 minutes exporting 10 cards)

### 10.4 Exclusive Frames

**Feature:** Subscriber-only card borders and backgrounds

```
Common Frames: Available to all users (achievement unlocks)
Premium Frames: Available to Premium+ users
Subscriber Frames: Exclusive to active subscribers
  - "Quantum Border" (animated particles)
  - "Gold Gilded" (luxury frame)
  - "Neon Glow" (cyberpunk aesthetic)
  - Monthly rotating frame (changes each month)
```

**Value:** Visual prestige, shows off subscription status

---

## 11. Priority & Convenience Features

### 11.1 Overview

**Small quality-of-life improvements** that add up to significant value:

- **Priority card rendering** (2x faster generation)
- **Early access to features** (test new systems 1 week early)
- **Priority support** (faster customer service response)
- **Ad-free experience** (if ads added in future)
- **Cloud save priority** (backup every 5 min instead of 15 min)

### 11.2 Priority Card Rendering

```gdscript
func generate_card(character: Character) -> Image:
    var render_queue_position = 0

    # Subscription users skip to front of queue
    if SubscriptionService.is_subscriber():
        render_queue_position = 0  # First in queue
    else:
        render_queue_position = queue.size()  # End of queue

    await add_to_render_queue(character, render_queue_position)
    var image = await wait_for_render_complete(character.id)

    return image
```

**Impact:**
- Premium user: 2-3 seconds to generate card
- Subscription user: 1-1.5 seconds to generate card

**Small but noticeable improvement**

### 11.3 Early Access

**Feature:** Subscription users test new features 1 week before general release

```gdscript
func is_feature_available(feature_name: String) -> bool:
    var feature_config = get_feature_config(feature_name)

    # Check if feature is in early access period
    if feature_config.is_early_access:
        # Only subscribers can access
        return SubscriptionService.is_subscriber()

    # Feature is generally available
    return true
```

**Examples:**
- New weapon type releases → Subscribers get 1 week early access
- New event type → Subscribers play it first
- New UI redesign → Subscribers test it in beta

**Value:**
- **Feel special** ("I'm testing this before everyone else")
- **Influence development** (feedback shapes final release)
- **Competitive advantage** (learn new mechanics first)

### 11.4 Priority Support

**Feature:** Subscription users get faster customer service

```
Free User Support:
  - Email response: 48-72 hours
  - In-app help: FAQ only

Premium User Support:
  - Email response: 24-48 hours
  - In-app help: FAQ + contact form

Subscription User Support:
  - Email response: 12-24 hours (priority queue)
  - In-app help: FAQ + live chat
  - Dedicated support channel (Discord)
```

**Value:** Peace of mind ("If something breaks, I'll get help fast")

---

## 12. Subscription Management

### 12.1 Subscription Lifecycle

**States:**

1. **Not Subscribed** → Show upgrade prompts
2. **Active** → Full access to all features
3. **Expiring Soon** → Warning banner (3 days before expiration)
4. **Grace Period** → 7 days grace period to renew
5. **Expired** → Features locked, data preserved
6. **Cancelled** → User opted out, features locked at end of billing period

### 12.2 Subscription Purchase Flow

```gdscript
# services/SubscriptionService.gd
func initiate_subscription_purchase() -> Result:
    # Check if already subscribed
    if has_active_subscription():
        return Result.error("Already subscribed")

    # Show subscription offer screen
    var offer = {
        "title": "Scrap Survivor Subscription",
        "price": "$4.99/month",
        "features": [
            "Atomic Vending Machine (weekly personalized shop)",
            "Quantum Banking (transfer items & scrap)",
            "+50% event currency & +25% drops",
            "Exclusive monthly events",
            "Hall of Fame (200 character archive)",
            "All Premium Pack features included"
        ],
        "trial": "7-day free trial"
    }

    show_subscription_offer_dialog(offer)

    # Wait for user response
    var user_accepted = await subscription_offer_accepted
    if not user_accepted:
        return Result.error("User declined")

    # Process IAP via platform (App Store, Google Play)
    var iap_result = await process_subscription_iap("subscription_monthly")

    if iap_result.success:
        # Activate subscription
        await activate_subscription()
        return Result.success("Subscription activated")
    else:
        return Result.error(iap_result.error)

func activate_subscription():
    var user = UserService.get_current_user()
    user.tier = UserTier.SUBSCRIPTION
    user.subscription_expires_at = Time.get_unix_time_from_system() + (30 * 86400)  # 30 days
    user.subscription_auto_renew = true

    await UserService.update_user(user)

    # Emit signal (UI updates)
    subscription_status_changed.emit(true)

    # Show success message
    show_notification("Subscription Activated! Welcome to the elite club.")
```

### 12.3 Subscription Expiration Handling

```gdscript
func check_subscription_expiration():
    if not has_active_subscription():
        return

    var days_remaining = days_until_expiration()

    if days_remaining <= 3 and days_remaining > 0:
        # Show warning banner
        show_expiration_warning(days_remaining)
    elif days_remaining <= 0:
        # Subscription expired
        handle_subscription_expiration()

func handle_subscription_expiration():
    var user = UserService.get_current_user()

    # Check grace period
    var days_since_expiration = (Time.get_unix_time_from_system() - user.subscription_expires_at) / 86400

    if days_since_expiration <= 7:
        # Grace period: Show renewal prompt
        show_grace_period_dialog()
    else:
        # Grace period over: Downgrade to Premium (or Free if never had Premium)
        downgrade_subscription()

func downgrade_subscription():
    var user = UserService.get_current_user()

    # Determine downgrade tier
    if user.has_premium_pack:
        user.tier = UserTier.PREMIUM
    else:
        user.tier = UserTier.FREE

    await UserService.update_user(user)

    # Preserve data but lock features
    # - Vending machine purchases: Keep items, lock future purchases
    # - Quantum Banking: Lock transfers, keep vault items accessible
    # - Hall of Fame: Archive locked, but archived characters preserved

    show_notification("Subscription expired. Renew to restore access!")

    # Show re-subscription offer
    show_resubscribe_offer()
```

### 12.4 Subscription Cancellation

```gdscript
func cancel_subscription():
    var user = UserService.get_current_user()

    # Show confirmation dialog
    var confirmed = await show_confirmation_dialog(
        "Cancel Subscription?",
    )

    if not confirmed:
        return Result.error("User cancelled cancellation")

    # Cancel auto-renew (via App Store/Google Play)
    await cancel_auto_renew_iap()

    user.subscription_auto_renew = false
    await UserService.update_user(user)

    # Features remain active until current billing period ends
    show_notification("Subscription will end on %s" % format_date(user.subscription_expires_at))

    return Result.success("Subscription cancelled")
```

---

## 13. Technical Architecture

### 13.1 Subscription Verification

**Server-Side Verification (Required for Security):**

```typescript
// Supabase Edge Function: /api/subscription/verify
export async function verifySubscription(userId: string) {
  // Fetch user's subscription data
  const { data: user } = await supabase
    .from('user_accounts')
    .select('tier, subscription_expires_at, subscription_receipt')
    .eq('id', userId)
    .single();

  if (!user) {
    return { valid: false, error: 'User not found' };
  }

  // Check subscription tier
  if (user.tier < 2) {  // 2 = Subscription tier
    return { valid: false, error: 'Not subscribed' };
  }

  // Check expiration
  const now = new Date();
  const expiresAt = new Date(user.subscription_expires_at);

  if (now > expiresAt) {
    // Expired: verify receipt with platform
    const receiptValid = await verifyReceiptWithPlatform(user.subscription_receipt);

    if (receiptValid && receiptValid.expiresAt > now) {
      // Receipt says subscription is still active, update DB
      await supabase
        .from('user_accounts')
        .update({ subscription_expires_at: receiptValid.expiresAt })
        .eq('id', userId);

      return { valid: true };
    } else {
      // Subscription truly expired
      return { valid: false, error: 'Subscription expired' };
    }
  }

  return { valid: true };
}
```

**Client-Side Caching:**

```gdscript
# Cache subscription status (avoid hammering server)
var subscription_cache = {
    "is_active": false,
    "expires_at": 0,
    "last_check": 0,
    "cache_ttl": 300  # Re-verify every 5 minutes
}

func is_subscriber() -> bool:
    var now = Time.get_unix_time_from_system()

    # Check if cache is fresh
    if now - subscription_cache.last_check < subscription_cache.cache_ttl:
        return subscription_cache.is_active

    # Cache stale: re-verify with server
    var result = await SupabaseService.call_edge_function("subscription/verify")

    if result.success:
        subscription_cache.is_active = result.data.valid
        subscription_cache.expires_at = result.data.expires_at
        subscription_cache.last_check = now

    return subscription_cache.is_active
```

### 13.2 Feature Gating Pattern

**Consistent gating pattern across all subscription features:**

```gdscript
# Template for subscription-gated features
func access_subscription_feature(feature_name: String) -> Result:
    # 1. Check subscription status
    if not SubscriptionService.is_subscriber():
        # Show upgrade prompt
        show_subscription_required_dialog(feature_name)
        return Result.error("Subscription required")

    # 2. Server-side verification (security critical features)
    if is_critical_feature(feature_name):
        var server_check = await SupabaseService.call_edge_function("subscription/verify")
        if not server_check.data.valid:
            show_error("Subscription verification failed")
            return Result.error("Verification failed")

    # 3. Grant access
    return Result.success("Access granted")
```

### 13.3 Database Schema

```sql
-- User accounts table (add subscription fields)
ALTER TABLE user_accounts
ADD COLUMN subscription_expires_at TIMESTAMPTZ,
ADD COLUMN subscription_auto_renew BOOLEAN DEFAULT true,
ADD COLUMN subscription_receipt TEXT,  -- Store IAP receipt
ADD COLUMN subscription_platform VARCHAR(20),  -- 'apple', 'google', 'stripe'
ADD COLUMN subscription_cancelled_at TIMESTAMPTZ;

-- Subscription transactions log (for analytics)
CREATE TABLE subscription_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  transaction_type VARCHAR(20) NOT NULL,  -- 'purchase', 'renewal', 'cancellation', 'refund'
  amount DECIMAL(10,2),
  currency VARCHAR(3) DEFAULT 'USD',
  platform VARCHAR(20),
  receipt TEXT,
  transaction_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subscription_transactions_user_id ON subscription_transactions(user_id);
CREATE INDEX idx_subscription_transactions_date ON subscription_transactions(transaction_date);

-- Feature usage tracking (analytics)
CREATE TABLE subscription_feature_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  feature_name VARCHAR(50) NOT NULL,
  usage_date TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_feature_usage_user_feature ON subscription_feature_usage(user_id, feature_name);
CREATE INDEX idx_feature_usage_date ON subscription_feature_usage(usage_date);
```

### 13.4 Analytics & Tracking

**Key Metrics to Track:**

```gdscript
# Track feature usage
func track_feature_usage(feature_name: String):
    await SupabaseService.insert("subscription_feature_usage", {
        "user_id": UserService.get_current_user_id(),
        "feature_name": feature_name,
        "usage_date": Time.get_datetime_string_from_system()
    })

# Features to track:
# - "vending_machine_visit"
# - "vending_machine_purchase"
# - "quantum_banking_item_transfer"
# - "quantum_banking_scrap_transfer"
# - "mr_fix_it_workshop_visit"
# - "event_participation"
# - "hall_of_fame_archive"
# - "trading_card_video_export"
```

**Analytics Queries:**

```sql
-- Most popular subscription features
SELECT feature_name, COUNT(*) as usage_count
FROM subscription_feature_usage
WHERE usage_date >= NOW() - INTERVAL '30 days'
GROUP BY feature_name
ORDER BY usage_count DESC;

-- Subscription retention rate
SELECT
  COUNT(CASE WHEN subscription_expires_at > NOW() THEN 1 END) as active_subscriptions,
  COUNT(*) as total_subscribers,
  ROUND(COUNT(CASE WHEN subscription_expires_at > NOW() THEN 1 END)::numeric / COUNT(*) * 100, 2) as retention_rate
FROM user_accounts
WHERE tier >= 2;  -- Subscription tier

-- Average revenue per subscriber (ARPU)
SELECT
  AVG(amount) as avg_revenue,
  COUNT(DISTINCT user_id) as total_subscribers
FROM subscription_transactions
WHERE transaction_type IN ('purchase', 'renewal')
  AND transaction_date >= NOW() - INTERVAL '30 days';
```

---

## 14. Implementation Strategy

### 14.1 Phase 1: Subscription Infrastructure (Week 10) - 16 hours

**Goal:** Build subscription management system

**Tasks:**
1. **SubscriptionService (6h)**
   - Create `SubscriptionService.gd` singleton
   - Subscription status checking (local + server)
   - Expiration handling and grace period
   - Subscription purchase flow

2. **IAP Integration (6h)**
   - Integrate with App Store Connect (iOS)
   - Integrate with Google Play Billing (Android)
   - Receipt verification (server-side)
   - Handle subscription lifecycle events

3. **Database Schema (2h)**
   - Add subscription fields to user_accounts
   - Create subscription_transactions table
   - Create subscription_feature_usage table
   - Set up analytics queries

4. **UI Components (2h)**
   - Subscription offer screen
   - Subscription status indicator (HUD)
   - Expiration warning banner
   - Re-subscribe dialog

**Deliverables:**
- ✅ Users can subscribe via IAP
- ✅ Subscription status verified server-side
- ✅ Expiration handled gracefully

### 14.2 Phase 2: Core Services (Week 11-13) - 48 hours

**Goal:** Implement major subscription features

**Tasks:**
1. **Atomic Vending Machine (12h)**
   - See [ATOMIC-VENDING-MACHINE.md](ATOMIC-VENDING-MACHINE.md) implementation plan

2. **Quantum Banking (12h)**
   - Quantum Storage (item transfer)
   - Quantum Banking (scrap transfer with fees)
   - Vault UI
   - Transaction logging

   - Offline repair calculation
   - Repair rate balancing
   - Workshop UI
   - Repair report on login

4. **Event Bonuses (8h)**
   - Drop rate multipliers
   - Currency multipliers
   - Rollover system
   - Priority access timers

5. **Black Market Perks (8h)**
   - Legendary spawn rate bonus
   - Early access logic
   - Reroll discount
   - Scroll notifications

**Deliverables:**
- ✅ All major subscription features functional
- ✅ Features properly gated (subscribers only)

### 14.3 Phase 3: Collection Services (Week 14-15) - 24 hours

**Goal:** Implement Hall of Fame and Trading Cards Pro

**Tasks:**
1. **Hall of Fame (12h)**
   - Character archival flow
   - Archive storage (200 slot limit)
   - Read-only character viewing
   - Archive UI (separate tab in roster)

2. **Trading Cards Pro (12h)**
   - Video export (TikTok format)
   - Batch export
   - Exclusive frame system
   - Frame selector UI

**Deliverables:**
- ✅ Subscribers can archive characters
- ✅ Video card exports work
- ✅ Exclusive frames display correctly

### 14.4 Phase 4: Priority Features (Week 16) - 8 hours

**Goal:** Add convenience and priority features

**Tasks:**
1. **Priority Rendering (2h)**
   - Render queue system
   - Subscriber priority logic

2. **Early Access (4h)**
   - Feature flag system
   - Early access gate
   - Beta tester UI

3. **Priority Support (2h)**
   - Support ticket prioritization
   - Live chat integration (optional)

**Deliverables:**
- ✅ Subscribers experience faster load times
- ✅ Early access system functional

### 14.5 Phase 5: Polish & Analytics (Week 17) - 12 hours

**Goal:** Refine UX and set up analytics

**Tasks:**
1. **UX Polish (6h)**
   - Subscription onboarding flow
   - Feature discovery tooltips
   - Upgrade prompts (when non-subscribers try features)
   - Cancellation flow (retention)

2. **Analytics Dashboard (6h)**
   - Feature usage metrics
   - Retention dashboard
   - Revenue analytics
   - Churn prediction

**Deliverables:**
- ✅ Subscription experience polished
- ✅ Analytics tracking all key metrics

**Total Implementation Time:** ~108 hours (~13.5 days of focused work)

---

## 15. Balancing Considerations

### 15.1 Subscription Value Balance

**Problem:** How much value should $4.99/month provide?

**Solution:**
- Aim for $15-20 perceived value
- Focus on convenience + exclusivity (not raw power)
- Ensure Premium tier still feels valuable (not obsolete)

**Value Comparison:**

| Feature | Premium ($9.99 one-time) | Subscription ($4.99/month) |
|---------|--------------------------|----------------------------|
| Black Market Access | ✅ | ✅ |
| Special Events | ✅ (base rates) | ✅ (+25% drops, +50% currency) |
| Trading Cards | ✅ (basic) | ✅ (video exports, frames) |
| Character Slots | 50 | 50 + 200 archived |
| Quantum Banking | ❌ | ✅ |
| Vending Machine | ❌ | ✅ |
| Exclusive Events | ❌ | ✅ |

**Premium remains valuable:** Core features, one-time payment, no recurring cost

### 15.2 Subscription Retention

**Problem:** How do we keep subscribers from churning?

**Retention Hooks:**

1. **Weekly Vending Machine** - "Check back Monday"
2. **Event Calendar** - "Next exclusive event in 2 weeks"
3. **Currency Rollover** - "Don't lose your saved event currency"
4. **Archived Characters** - "Your Hall of Fame will be locked if you cancel"

**Churn Prevention:**

```gdscript
# When user tries to cancel
func show_cancellation_retention_offer():
    var offer = {
        "title": "Before you go...",
        "message": "We'd hate to see you leave! Here's what you'll lose:",
        "losses": [
            "Your Hall of Fame archive (200 characters)",
            "500 saved pumpkin coins (rollover)",
            "This Monday's vending machine refresh",
        ],
        "retention_offer": "Stay subscribed and get 1 free Legendary item!",
        "cta": "Keep Subscription"
    }

    show_retention_dialog(offer)
```

**Target Retention Rate:** 70% month-over-month (industry average: 40-60%)

### 15.3 Free-to-Subscription Conversion

**Problem:** How do we convert Free users directly to Subscription (skip Premium)?

**Conversion Funnel:**

```
Free User
  ↓
Sees subscription feature (Vending Machine, Quantum Banking)
  ↓
"This requires Subscription" prompt
  ↓
"Subscribe now and get 7-day free trial + Premium features included!"
  ↓
Conversion
```

**Conversion Rate Targets:**
- Free → Premium: 5-10%
- Free → Subscription: 1-2%
- Premium → Subscription: 10-15%

**Best Conversion Triggers:**
- User reaches Wave 20 (engaged player)
- User has 3+ characters (needs Quantum Banking)
- Exclusive event starts (FOMO)

### 15.4 Pricing Sensitivity

**Problem:** Is $4.99/month the right price?

**Market Research:**

| Game | Subscription Price | Features |
|------|-------------------|----------|
| Clash of Clans Gold Pass | $4.99/month | Exclusive rewards, boosters |
| Brawl Pass (Brawl Stars) | $9.99/season | Battle pass progression |
| Fortnite Crew | $11.99/month | Battle pass + V-Bucks + skin |
| Apple Arcade | $6.99/month | 200+ games |

**Recommendation:** $4.99/month is competitive

**Alternative Pricing:**
- **$2.99/month:** Lower barrier, but may devalue offering
- **$7.99/month:** More revenue, but higher churn
- **$4.99/month with annual option ($49.99/year = $4.17/month):** Incentivize long-term commitment

---

## 16. Open Questions & Future Enhancements

### 16.1 Open Questions

**Q1: Should there be a Subscription Pro tier ($9.99/month)?**
- Option A: Yes, add Pro tier with enhanced benefits (2x vending purchases, unlimited repairs)
- Option B: No, keep single subscription tier (simpler)
- **Recommendation:** Start with single tier, add Pro tier if data shows demand

**Q2: Should subscription include ad removal (if ads added)?**
- Option A: Yes, subscribers never see ads
- Option B: No, ads are removed for Premium tier (not just subscription)
- **Recommendation:** Option A (standard practice)

**Q3: Should there be a family plan (1 subscription, multiple accounts)?**
- Option A: Yes, $9.99/month for up to 5 accounts
- Option B: No, each account needs separate subscription
- **Recommendation:** Option B initially (family sharing is complex)

**Q4: Should subscription currency rollover work for ALL events or just seasonal?**
- Option A: All events (more generous)
- Option B: Only seasonal events (Halloween, Christmas, etc.)
- **Recommendation:** Option B (creates incentive to participate in each event type)

**Q5: Should expired subscribers keep their archived characters accessible (read-only)?**
- Option A: Yes, archive is read-only even after expiration
- Option B: No, archive is fully locked after expiration
- **Recommendation:** Option A (more fair, encourages re-subscription)

### 16.2 Future Enhancements (Post-Launch)

**Enhancement 1: Subscription Gifting**
- Allow users to gift 1-month subscriptions to friends
- Referral program: 3 referred friends = 1 free month

**Enhancement 2: Subscription Perks Rotation**
- Monthly rotating bonus (e.g., "This month: 2x vending machine purchases")
- Keeps subscription fresh and exciting

**Enhancement 3: Subscription-Exclusive Cosmetics**
- Monthly rotating exclusive skins/emotes
- Only available while subscribed (removed if subscription ends)

**Enhancement 4: Subscription Loyalty Program**
- 6 months subscribed: Exclusive "Veteran" badge
- 12 months subscribed: Free legendary item
- 24 months subscribed: Permanent Gold Frame

**Enhancement 5: Subscription Tournaments**
- Monthly subscriber-only PvP tournaments
- Top 10 win exclusive items

**Enhancement 6: Subscriber Discord/Community**
- Private Discord server for subscribers
- Direct line to developers
- Early announcements and sneak peeks

---

## 17. Summary

### 17.1 What Subscription Services Provide

The Subscription Services System delivers:

1. **Exclusive Content & Features**
   - Atomic Vending Machine (weekly personalized shop)
   - Quantum Banking (item/scrap transfer)
   - Subscription-exclusive events
   - Hall of Fame (character archival)

2. **Progression Acceleration**
   - Event bonuses (+25% drops, +50% currency)
   - Black Market perks (better deals)
   - Priority access (early access, faster processing)

3. **Convenience & Quality of Life**
   - Quantum Banking saves time
   - Priority rendering is faster
   - Batch exports save clicks

4. **Collectibility & Prestige**
   - Hall of Fame preserves legacy
   - Exclusive frames show status
   - Video exports enhance sharing
   - Archived characters never lost

### 17.2 Key Features Recap

- ✅ **Atomic Vending Machine:** Weekly personalized shop (3 items, 1 purchase)
- ✅ **Quantum Banking:** Unlimited item transfers, scrap transfers with fees
- ✅ **Event Bonuses:** +25% drops, +50% currency, rollover up to 500
- ✅ **Exclusive Events:** Monthly 48-72 hour events
- ✅ **Hall of Fame:** 200 character archive slots
- ✅ **Black Market Perks:** +10% legendary rate, early access, reroll discount
- ✅ **Trading Cards Pro:** Video exports, batch export, exclusive frames
- ✅ **Priority Features:** Faster processing, early access

### 17.3 Implementation Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1 | Week 10 (16h) | Subscription infrastructure complete |
| Phase 2 | Week 11-13 (48h) | Core services functional (Vending, Banking, Fix-It, Events, Black Market) |
| Phase 3 | Week 14-15 (24h) | Collection services (Hall of Fame, Trading Cards Pro) |
| Phase 4 | Week 16 (8h) | Priority features |
| Phase 5 | Week 17 (12h) | Polish and analytics |

**Total:** ~108 hours (~13.5 days of focused work)

### 17.4 Success Metrics

Track these KPIs to measure subscription success:

- **Conversion Rate:** % of Free/Premium users who subscribe
  - Target: 5-10% of Premium users convert to Subscription
- **Retention Rate:** % of subscribers who remain subscribed month-over-month
  - Target: 70% retention (industry average: 40-60%)
- **Feature Usage:** % of subscribers using each feature monthly
- **Churn Rate:** % of subscribers who cancel per month
  - Target: <30% churn
- **ARPU (Average Revenue Per User):** Average monthly revenue from subscribers
  - Target: $4.50+ (accounting for platform fees)
- **Lifetime Value (LTV):** Average total revenue per subscriber
  - Target: $50+ (10+ months subscribed)

### 17.5 Status & Next Steps

**Current Status:** 📝 Fully documented, ready for implementation

**Prerequisites:**
- ✅ IAP integration (App Store, Google Play)
- ✅ User accounts and tier system
- ✅ Premium features functional (Black Market, Events, Trading Cards)
- ⏳ Personalization System (required for Vending Machine)

**Next Steps:**
1. Review this document with team
2. Validate pricing and value proposition
3. Begin Phase 1 implementation (Week 10)
4. Set up IAP accounts (App Store Connect, Google Play Console)
5. Design subscription offer UI mockups
6. Plan subscription launch marketing campaign

**Status:** Ready for Week 10+ implementation (after core Premium features are complete).

---

*End of Subscription Services System Documentation*
