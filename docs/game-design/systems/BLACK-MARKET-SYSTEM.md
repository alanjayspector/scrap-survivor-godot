# Black Market System

**Status:** MID-TERM - Premium economy feature
**Tier Access:** Premium + Subscription
**Implementation Phase:** Week 12-13 (after Shop system)

---

## 1. System Overview

The Black Market is a **Premium/Subscription shop** offering high-tier items at inflated costs. It's an alternative to the regular Shop with better quality but higher prices.

**Key Features:**
- High-tier items (Rare/Epic/Legendary)
- Inflated pricing (2-3x normal shop)
- Occasional curse removal scrolls
- Premium/Subscription exclusive

---

## 2. Differences from Regular Shop

| Feature | Regular Shop | Black Market |
|---------|-------------|--------------|
| **Access** | All tiers | Premium+ only |
| **Item Quality** | Common/Uncommon/Rare | Rare/Epic/Legendary |
| **Pricing** | Standard | 2-3x markup |
| **Reroll Cost** | 50 scrap | 200 scrap |
| **Stock Refresh** | Every wave | Every wave |
| **Special Items** | No | Curse removal scrolls |

---

## 3. Item Pricing

### 3.1 Pricing Formula

```gdscript
# Black Market markup
var markup_multiplier = 2.5

func get_black_market_price(item_base_price: int) -> int:
    return int(item_base_price * markup_multiplier)
```

### 3.2 Pricing Tiers

| Item Type | Regular Shop Price | Black Market Price | Markup |
|-----------|-------------------|-------------------|--------|
| **Rare Weapon** | 2,000 | 5,000 | 2.5x |
| **Rare Armor** | 2,500 | 6,250 | 2.5x |
| **Epic Weapon** | 5,000 | 12,500 | 2.5x |
| **Epic Armor** | 6,000 | 15,000 | 2.5x |
| **Legendary Weapon** | 10,000 | 25,000 | 2.5x |
| **Legendary Armor** | 12,000 | 30,000 | 2.5x |
| **Curse Removal Scroll** | N/A (exclusive) | 50,000 | N/A |

### 3.3 Why Expensive?

**Design Rationale:**
- **Quality Over Quantity:** Black Market guarantees high-tier items (no Common/Uncommon)
- **Premium Exclusive:** Justifies Premium/Subscription tier value
- **Scrap Sink:** Prevents scrap inflation (players need to farm more)
- **Risk/Reward:** High prices create meaningful purchasing decisions

**Player Psychology:**
- Seeing expensive items creates aspiration ("I need to earn more scrap")
- Purchasing a legendary item feels prestigious
- Creates FOMO if user can't afford before shop refreshes

---

## 4. Curse Removal Scrolls

**Purpose:** Remove curse from cursed items

**Properties:**
- **Very rare spawn** (5% chance per Black Market refresh)
- **Expensive** (50,000 scrap)
- **One-time use consumable**
- **Uncurses any item** (removes curse attribute)

**How it works:**
```gdscript
func use_curse_removal_scroll(item_id: String):
    var item = InventoryService.get_item(item_id)
    if not item.is_cursed:
        return Result.error("Item is not cursed")

    item.is_cursed = false
    await InventoryService.update_item(item)

    # Consume scroll
    InventoryService.remove_consumable("curse_removal_scroll")
```

### 4.2 Cursed Item Detection

**UI Indicator:**
- Cursed items show red skull icon (☠️)
- Warning tooltip: "Cursed: Cannot sell or bank"
- Option to use Curse Removal Scroll (if owned)

```gdscript
# ui/InventoryItemCard.gd
func display_item(item: Item):
    if item.is_cursed:
        curse_indicator.show()
        curse_indicator.texture = load("res://assets/icons/skull_red.png")

        # Add tooltip
        set_tooltip_text("⚠️ CURSED: Cannot sell or bank\n\nUse a Curse Removal Scroll to uncurse")

        # Show uncurse button if user has scroll
        if InventoryService.has_item("curse_removal_scroll"):
            uncurse_button.show()
            uncurse_button.pressed.connect(_on_uncurse_pressed.bind(item))
```

### 4.3 Curse Removal Flow

```gdscript
# services/CurseRemovalService.gd
class_name CurseRemovalService
extends Node

signal curse_removed(item_id: String)

func use_curse_removal_scroll(item_id: String) -> Result:
    var item = InventoryService.get_item(item_id)

    # Validate item is cursed
    if not item or not item.is_cursed:
        return Result.error("Item is not cursed")

    # Check if user has scroll
    if not InventoryService.has_item("curse_removal_scroll"):
        return Result.error("No Curse Removal Scroll in inventory")

    # Show confirmation dialog
    var confirmed = await show_confirmation_dialog(
        "Remove curse from %s?" % item.name,
        "This will consume your Curse Removal Scroll."
    )

    if not confirmed:
        return Result.error("User cancelled")

    # Remove curse
    item.is_cursed = false
    await InventoryService.update_item(item)

    # Consume scroll
    InventoryService.remove_consumable("curse_removal_scroll")

    # Show success
    show_notification("Curse removed from %s!" % item.name)
    curse_removed.emit(item_id)

    return Result.success(item)
```

---

## 5. Black Market Inventory System

### 5.1 Inventory Generation

**Shop Refresh:** Every wave (same as regular shop)

**Inventory Composition:**
- **3 weapons** (Rare: 60%, Epic: 30%, Legendary: 10%)
- **3 armor pieces** (Rare: 60%, Epic: 30%, Legendary: 10%)
- **2 consumables** (Rare/Epic quality)
- **1 special slot** (5% chance for Curse Removal Scroll, else another weapon/armor)

```gdscript
# services/BlackMarketService.gd
class_name BlackMarketService
extends Node

const INVENTORY_SIZE = 9
const CURSE_SCROLL_SPAWN_CHANCE = 0.05

func generate_black_market_inventory() -> Array[Item]:
    var inventory: Array[Item] = []

    # Generate 3 weapons
    for i in range(3):
        var weapon = generate_random_weapon(get_rare_epic_legendary_rarity())
        inventory.append(weapon)

    # Generate 3 armor pieces
    for i in range(3):
        var armor = generate_random_armor(get_rare_epic_legendary_rarity())
        inventory.append(armor)

    # Generate 2 consumables
    for i in range(2):
        var consumable = generate_random_consumable("rare")
        inventory.append(consumable)

    # Special slot (5% chance for Curse Removal Scroll)
    if randf() < CURSE_SCROLL_SPAWN_CHANCE:
        var scroll = create_curse_removal_scroll()
        inventory.append(scroll)
    else:
        var item = generate_random_item(get_rare_epic_legendary_rarity())
        inventory.append(item)

    return inventory

func get_rare_epic_legendary_rarity() -> String:
    var roll = randf()
    if roll < 0.60:
        return "rare"
    elif roll < 0.90:
        return "epic"
    else:
        return "legendary"

func create_curse_removal_scroll() -> Item:
    return Item.new({
        "id": "curse_removal_scroll",
        "name": "Curse Removal Scroll",
        "type": "consumable",
        "rarity": "rare",
        "price": 50000,
        "description": "Removes curse from any cursed item",
        "icon": "res://assets/items/curse_removal_scroll.png"
    })
```

### 5.2 Shop Refresh Logic

```gdscript
# Refresh Black Market inventory on wave completion
func _on_wave_completed():
    if UserService.has_premium_access():
        refresh_black_market_inventory()

func refresh_black_market_inventory():
    var new_inventory = generate_black_market_inventory()

    # Apply Black Market markup
    for item in new_inventory:
        item.price = get_black_market_price(item.base_price)

    # Store in session
    current_black_market_inventory = new_inventory

    # Notify UI
    black_market_refreshed.emit(new_inventory)
```

### 5.3 Reroll System

**Reroll Cost:** 200 scrap (4x regular shop reroll cost)

**Reroll Behavior:**
- Generates completely new inventory
- Does NOT guarantee better items
- Can reroll multiple times (no limit except scrap)

```gdscript
func reroll_black_market() -> Result:
    var user = UserService.get_current_user()
    var character = CharacterService.get_active_character()

    # Check user has Premium access
    if not user.has_premium_access():
        return Result.error("Black Market requires Premium tier")

    # Check scrap
    const REROLL_COST = 200
    if character.currency < REROLL_COST:
        return Result.error("Insufficient scrap (need %d)" % REROLL_COST)

    # Deduct scrap
    character.currency -= REROLL_COST
    await CharacterService.update_character(character)

    # Generate new inventory
    refresh_black_market_inventory()

    return Result.success("Black Market rerolled")
```

---

## 6. Cursed Items (Recap)

**What are cursed items?**
- Items with `is_cursed: true` attribute
- Have negative stat modifiers or drawbacks
- **Cannot be sold** (stuck with them)
- **Cannot be banked** (can't protect from death)
- Only removable via curse removal scroll

**Why cursed items exist?**
- Creates risk/reward (powerful item with drawback)
- Economy sink (expensive to remove curse)
- Black Market purpose (exclusive cure source)

---

## 7. Tier-Specific Features

### 7.1 Premium Tier

**Access:** ✅ Full Black Market access

**Features:**
- Browse all Black Market inventory
- Purchase any item (if sufficient scrap)
- Reroll inventory (200 scrap per reroll)
- Curse Removal Scrolls available

**No additional bonuses** (same prices as Subscription)

### 7.2 Subscription Tier

**Access:** ✅ All Premium features + bonuses

**Exclusive Features:**
- **+10% higher Legendary spawn rate** (10% → 11%)
- **Early access** (Black Market refreshes 5 minutes before Premium)
- **Reroll discount** (200 → 150 scrap)
- **Notification** when Curse Removal Scroll spawns

```gdscript
# Subscription bonuses
func get_legendary_spawn_rate(user: User) -> float:
    var base_rate = 0.10
    if user.tier >= UserTier.SUBSCRIPTION:
        return base_rate * 1.1  # +10% bonus = 11%
    return base_rate

func get_reroll_cost(user: User) -> int:
    const BASE_COST = 200
    if user.tier >= UserTier.SUBSCRIPTION:
        return 150  # 25% discount
    return BASE_COST

func refresh_black_market_for_subscriptions():
    # Refresh 5 minutes early for Subscription users
    await get_tree().create_timer(300).timeout  # 5 min wait
    refresh_black_market_for_premium()
```

### 7.3 Free Tier

**Access:** ❌ No Black Market access

**What Free Users See:**
- Locked Black Market button in Scrapyard
- "Premium Required" message
- Preview of Black Market items (blurred, can't interact)
- CTA to upgrade

```gdscript
# ui/BlackMarketLockedView.gd
func show_locked_black_market():
    title_label.text = "Black Market (Premium Only)"
    description_label.text = "Upgrade to Premium for access to high-tier items!"

    # Show blurred preview
    var preview_items = BlackMarketService.generate_black_market_inventory()
    for item in preview_items.slice(0, 3):  # Show first 3 items
        var item_card = create_blurred_item_card(item)
        preview_container.add_child(item_card)

    upgrade_button.show()
    upgrade_button.pressed.connect(_on_upgrade_pressed)
```

---

## 8. UI Implementation

### 8.1 Black Market Shop Scene

**Location:** Scrapyard → Black Market

```gdscript
# scenes/BlackMarketShop.gd
extends Control

@onready var inventory_grid = $InventoryGrid
@onready var reroll_button = $RerollButton
@onready var user_scrap_label = $UserScrapLabel

var current_inventory: Array[Item] = []

func _ready():
    # Check access
    var user = UserService.get_current_user()
    if not user.has_premium_access():
        show_locked_view()
        return

    # Load inventory
    load_black_market_inventory()

    # Setup reroll button
    reroll_button.text = "Reroll (%d scrap)" % BlackMarketService.get_reroll_cost(user)
    reroll_button.pressed.connect(_on_reroll_pressed)

    # Update scrap display
    update_scrap_display()

func load_black_market_inventory():
    current_inventory = BlackMarketService.get_current_inventory()

    # Clear existing items
    for child in inventory_grid.get_children():
        child.queue_free()

    # Display items
    for item in current_inventory:
        var item_card = create_item_card(item)
        inventory_grid.add_child(item_card)

func create_item_card(item: Item) -> Control:
    var card = preload("res://scenes/ShopItemCard.tscn").instantiate()
    card.set_item_data(item)
    card.purchase_requested.connect(_on_purchase_requested.bind(item))

    # Highlight if Curse Removal Scroll
    if item.id == "curse_removal_scroll":
        card.add_highlight_border(Color.GOLD)
        card.add_label("RARE!", Color.GOLD)

    return card

func _on_purchase_requested(item: Item):
    var character = CharacterService.get_active_character()

    if character.currency < item.price:
        show_insufficient_scrap_error(item.price)
        return

    # Confirm purchase
    var confirmed = await show_confirmation_dialog(
        "Purchase %s for %d scrap?" % [item.name, item.price],
        "This is a Black Market item (high price)"
    )

    if not confirmed:
        return

    # Deduct scrap
    character.currency -= item.price
    await CharacterService.update_character(character)

    # Add item to inventory
    InventoryService.add_item(character.id, item)

    # Remove from Black Market inventory
    BlackMarketService.remove_item_from_inventory(item.id)

    # Update UI
    load_black_market_inventory()
    update_scrap_display()
    show_purchase_success(item.name)

func _on_reroll_pressed():
    var result = await BlackMarketService.reroll_black_market()
    if result.success:
        load_black_market_inventory()
        update_scrap_display()
        show_notification("Black Market inventory rerolled!")
    else:
        show_error(result.error)

func update_scrap_display():
    var character = CharacterService.get_active_character()
    user_scrap_label.text = "💰 %d scrap" % character.currency
```

### 8.2 Curse Removal UI

```gdscript
# ui/CurseRemovalDialog.gd
extends PopupPanel

@onready var item_name_label = $ItemNameLabel
@onready var item_icon = $ItemIcon
@onready var curse_description = $CurseDescription
@onready var confirm_button = $ConfirmButton
@onready var cancel_button = $CancelButton

var target_item: Item

func show_curse_removal_dialog(item: Item):
    target_item = item

    item_name_label.text = item.name
    item_icon.texture = load(item.icon)
    curse_description.text = "Remove curse from this item?\n\nThis will consume your Curse Removal Scroll."

    popup_centered()

func _on_confirm_pressed():
    var result = await CurseRemovalService.use_curse_removal_scroll(target_item.id)
    if result.success:
        hide()
        show_notification("Curse removed!")
    else:
        show_error(result.error)

func _on_cancel_pressed():
    hide()
```

---

## 9. Implementation Strategy

### 9.1 Phase 1: Black Market Foundation (Week 12) - 12 hours

**Goal:** Build Black Market shop system

**Tasks:**
1. **BlackMarketService (4h)**
   - Create `BlackMarketService.gd` singleton
   - Implement inventory generation
   - Apply markup pricing (2.5x multiplier)
   - Refresh logic (on wave completion)

2. **Shop UI (6h)**
   - Create `BlackMarketShop.tscn` scene
   - Inventory grid display (9 items)
   - Reroll button with cost display
   - Purchase flow (confirmation, scrap deduction)

3. **Tier Gating (2h)**
   - Check Premium/Subscription access
   - Show locked view for Free users
   - Subscription bonuses (spawn rate, reroll discount)

**Deliverables:**
- ✅ Black Market shop functional
- ✅ Inventory generates and refreshes correctly
- ✅ Tier gating works (Premium+ only)

### 9.2 Phase 2: Curse Removal System (Week 13) - 8 hours

**Goal:** Implement cursed items and cure mechanic

**Tasks:**
1. **Cursed Item System (3h)**
   - Add `is_cursed` attribute to Item class
   - Cursed items cannot be sold/banked
   - UI indicators (red skull icon, tooltip)

2. **Curse Removal Scroll (3h)**
   - Add Curse Removal Scroll item (5% spawn rate)
   - Implement `CurseRemovalService.gd`
   - Use scroll to uncurse item flow

3. **UI Integration (2h)**
   - Curse removal dialog
   - Success/failure notifications
   - Inventory updates after uncursing

**Deliverables:**
- ✅ Cursed items work correctly
- ✅ Curse Removal Scrolls spawn and function
- ✅ Users can uncurse items

### 9.3 Phase 3: Polish & Testing (Week 13) - 4 hours

**Goal:** Balance and polish

**Tasks:**
1. **Balancing (2h)**
   - Adjust spawn rates (Rare/Epic/Legendary)
   - Test pricing (ensure items feel expensive but attainable)
   - Tune Curse Removal Scroll spawn rate (5% feels rare)

2. **Testing (2h)**
   - Test reroll multiple times
   - Test Subscription bonuses
   - Test curse removal flow end-to-end

**Deliverables:**
- ✅ Black Market balanced and fun
- ✅ No major bugs

**Total Implementation Time:** ~24 hours (~3 days of focused work)

---

## 10. Balancing Considerations

### 10.1 Pricing Balance

**Problem:** Prices must feel expensive but not impossible

**Solution:**
- Average scrap earned per wave: 500-1000 scrap (base game)
- Black Market legendary item: 25,000 scrap
- User needs to play ~25-50 waves to afford one legendary
- Creates long-term goal ("I'm saving for that legendary weapon")

**Tuning Formula:**
```gdscript
# Average scrap per wave (varies by wave difficulty)
func get_avg_scrap_per_wave(wave_number: int) -> int:
    return 500 + (wave_number * 10)  # Scales with wave

# Legendary item: ~25-50 waves of farming
# Epic item: ~12-25 waves
# Rare item: ~5-10 waves
```

### 10.2 Curse Removal Scroll Spawn Rate

**Problem:** How rare should Curse Removal Scrolls be?

**Current:** 5% spawn rate per Black Market refresh

**Rationale:**
- User sees Black Market ~100 times (if they play 100 waves)
- Expected scrolls: ~5 scrolls over 100 waves
- Feels rare but not impossible
- High price (50,000 scrap) adds additional scarcity

**Alternative Rates:**
- **Too common (10%):** Scrolls lose value, cursed items become trivial
- **Too rare (1%):** Users never see scrolls, cursed items feel permanent
- **Sweet spot (5%):** Rare enough to feel special, common enough to be attainable

### 10.3 Legendary Spawn Rate

**Problem:** How often should Legendary items appear?

**Current:** 10% chance per item slot (9 slots = ~60% chance for at least one legendary per refresh)

**Subscription Bonus:** +10% spawn rate (10% → 11%, slight advantage)

**Rationale:**
- Users want to see legendary items occasionally (creates excitement)
- 10% per slot means most refreshes have 0-1 legendary items
- Subscription bonus is noticeable but not overpowered

### 10.4 Black Market vs Regular Shop Balance

**Problem:** Why use Black Market if it's more expensive?

**Answer:**
- **Quality guarantee:** Regular shop has Common/Uncommon items (filler)
- **Black Market only has Rare+:** Every item is useful
- **Exclusive items:** Curse Removal Scrolls only spawn in Black Market
- **Premium feel:** Players want exclusive access

**Tradeoff:**
- Regular Shop: Cheap, but low quality
- Black Market: Expensive, but high quality
- Both have value depending on player's scrap and needs

---

## 11. Open Questions & Future Enhancements

### 11.1 Open Questions

**Q1: Should Black Market have daily deals?**
- Option A: One featured item per day at 50% off
- Option B: No deals, keep pricing consistent
- **Recommendation:** Option A (adds variety, creates login incentive)

**Q2: Should cursed items have positive stats to offset the curse?**
- Option A: Yes, cursed items are high-risk/high-reward (e.g., +50 damage but -20 HP)
- Option B: No, cursed items are purely negative (bad luck drops)
- **Recommendation:** Option A (makes cursed items interesting, not just annoying)

**Q3: Should there be a "Black Market exclusive" item pool?**
- Option A: Yes, some legendary items ONLY spawn in Black Market
- Option B: No, Black Market uses same item pool as regular game
- **Recommendation:** Option A (adds exclusivity, FOMO)

**Q4: Should Subscription users get a weekly Black Market discount token?**
- Option A: Yes, 1 free token per week (50% off one item)
- Option B: No, keep pricing consistent
- **Recommendation:** Option A (adds Subscription value without breaking economy)

**Q5: Should there be a Black Market "wanted list" (wishlist feature)?**
- Option A: Yes, users can wishlist items and get notified when they spawn
- Option B: No, keep it simple
- **Recommendation:** Option A (post-launch enhancement)

### 11.2 Future Enhancements (Post-Launch)

**Enhancement 1: Black Market Auctions**
- Weekly auction for ultra-rare item
- Players bid scrap, highest bidder wins
- Creates scrap sink + competitive element

**Enhancement 2: Black Market Reputation System**
- Earn reputation points with each purchase
- Higher reputation unlocks better items
- Encourages repeat purchases

**Enhancement 3: Cursed Item Crafting**
- Combine 3 cursed items → 1 uncursed legendary
- Alternative to Curse Removal Scroll
- Adds depth to curse mechanic

**Enhancement 4: Black Market "Flash Sales"**
- Random 15-minute window with 75% off
- Push notification to Subscription users
- Drives urgency and login frequency

**Enhancement 5: Black Market Trading (Player-to-Player)**
- Players can sell items to each other via Black Market
- Black Market takes 10% commission
- Scrap sink + social feature

---

## 12. Summary

### 12.1 What Black Market Provides

The Black Market System delivers:

1. **Premium Economy**
   - High-tier items only (Rare/Epic/Legendary)
   - Inflated pricing creates scrap sink
   - Premium/Subscription exclusive access

2. **Curse Management**
   - Only source of Curse Removal Scrolls
   - 5% spawn rate (rare but attainable)
   - 50,000 scrap cost (expensive)

3. **Monetization Justification**
   - Clear Premium tier value (access to better items)
   - Subscription bonuses (+10% legendary rate, reroll discount)
   - Drives Free → Premium conversions

4. **Player Engagement**
   - Creates long-term goals (save scrap for legendary)
   - Reroll mechanic adds variety
   - Excitement of seeing legendary items

### 12.2 Key Features Recap

- ✅ **Inventory:** 9 items per refresh (3 weapons, 3 armor, 2 consumables, 1 special)
- ✅ **Pricing:** 2.5x markup (e.g., legendary weapon = 25,000 scrap)
- ✅ **Rarity Distribution:** Rare (60%), Epic (30%), Legendary (10%)
- ✅ **Curse Removal Scrolls:** 5% spawn rate, 50,000 scrap
- ✅ **Reroll:** 200 scrap (Premium), 150 scrap (Subscription)
- ✅ **Tier Gating:** Premium+ access only

### 12.3 Implementation Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1 | Week 12 (12h) | Black Market shop functional |
| Phase 2 | Week 13 (8h) | Curse removal system complete |
| Phase 3 | Week 13 (4h) | Polish and testing done |

**Total:** ~24 hours (~3 days of focused work)

### 12.4 Success Metrics

Track these KPIs to measure system success:

- **Usage Rate:** % of Premium users who visit Black Market
  - Target: >70% usage rate
- **Purchase Rate:** % of Black Market visits that result in purchase
  - Target: >40% purchase rate
- **Reroll Frequency:** Avg rerolls per user per session
  - Target: 1-2 rerolls per session
- **Curse Removal Scroll Sales:** % of scrolls that get sold (vs ignored)
  - Target: >80% of scrolls sell
- **Scrap Sink Impact:** Total scrap removed from economy via Black Market
  - Track: Weekly scrap spent in Black Market vs regular shop

### 12.5 Status & Next Steps

**Current Status:** 📝 Fully documented, ready for implementation

**Prerequisites:**
- ✅ Regular Shop system functional
- ✅ Inventory system supports item purchases
- ✅ Currency (scrap) system working
- ✅ Tier verification (Premium/Subscription checks)

**Next Steps:**
1. Review this document with team
2. Begin Phase 1 implementation (Week 12)
3. Design Black Market UI mockups
4. Define cursed item pool (which items can be cursed?)
5. Test pricing balance (ensure items feel expensive but fair)

**Status:** Ready for Week 12 implementation (after regular Shop is complete).

---

*End of Black Market System Documentation*
