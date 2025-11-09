# Trading Cards System

**Status:** MID-TERM - Social/marketing feature
**Tier Access:** All tiers (with Free tier referral incentive)
**Implementation Phase:** Week 16+ (after character system polished)

---

## 1. System Overview

The Trading Cards System generates **shareable character cards** featuring stats, equipment, and minions. Cards can be viewed in-app (roster view) or exported for social media sharing with built-in referral marketing.

**Key Features:**
- Character stat cards (digital trading card aesthetic)
- Roster view (flip through all characters)
- Social media export (with referral codes, links)
- Referral rewards (Free users can earn Premium)

---

## 2. Card Contents

### 2.1 Card Layout

```
┌─────────────────────────────────┐
│ ⭐⭐⭐⭐ LEGENDARY               │
├─────────────────────────────────┤
│  [Character Portrait + Items]   │
│  (Full character render with    │
│   equipped items and minion)    │
├─────────────────────────────────┤
│ SCAVENGER #3 - "Lucky Bastard" │
│ Level 18 | Wave 25 | 12 Deaths  │
├─────────────────────────────────┤
│ HP: 150  | Damage: 85          │
│ Speed: 200 | Armor: 25          │
│ Luck: 35 | Crit: 15%            │
├─────────────────────────────────┤
│ Weapons (3):                    │
│  - Plasma Rifle +5             │
│  - Nano Swarm +3               │
│  - Scrap Cannon +7             │
│                                 │
│ Items (8):                      │
│  - Reinforced Armor (Epic)     │
│  - Lucky Charm (Rare)           │
│  - Medkit x3                    │
│                                 │
│ Minion: Scrap Golem (Lv12)     │
├─────────────────────────────────┤
│ Achievements: 23/50             │
│ Total Scrap Earned: 1,245,820  │
└─────────────────────────────────┘
```

### 2.2 Card Rarity

Card visual style changes based on character's achievements:

| Rarity | Criteria | Visual |
|--------|----------|--------|
| **Common** | Wave < 10 | Gray border, simple frame |
| **Uncommon** | Wave 10-19 | Green border, bronze frame |
| **Rare** | Wave 20-29 | Blue border, silver frame |
| **Epic** | Wave 30-39 | Purple border, gold frame |
| **Legendary** | Wave 40+ | Orange border, platinum frame, animated |

### 2.3 Card Visual Design

**Character Portrait:**
- Full-body character render with equipped items visible
- Minion positioned next to character (if equipped)
- Dynamic pose based on character type:
  - Scavenger: Crouched, cautious stance
  - Brute: Standing tall, weapon raised
  - Engineer: Tinkering with tech
- Background: Wasteland scene matching character's highest wave environment

**Rarity Effects:**
- **Common/Uncommon:** Static border
- **Rare:** Subtle glow effect on border
- **Epic:** Animated glow + particle effects
- **Legendary:** Full card animation (border pulses, particles swirl, holographic effect)

**Font & Typography:**
- **Title:** Bold, post-apocalyptic font (e.g., "Broken Console")
- **Stats:** Monospace font for clean readability
- **Rarity Stars:** Unicode stars (⭐) or custom star icons

### 2.4 Card Metadata Display

**Primary Stats (Always Visible):**
- Character Name + Nickname (user-defined)
- Character Type (Scavenger, Brute, Engineer)
- Level and Current Wave
- Death Count

**Secondary Stats (Visible on Flip/Hover):**
- Total Kills
- Total Scrap Earned
- Total Playtime
- Favorite Weapon (most used)
- Achievements Unlocked (count + icons)

**Equipment Display:**
- **Weapons (3 slots):** Show icon + level/rarity
- **Items (8 slots):** Show top 3 rarest items
- **Minion:** Show minion portrait + level

**Card Back (Optional):**
- QR code for referral link
- User's referral stats (total referrals, rewards earned)
- "Scan to Join Scrap Survivor!"

---

## 3. Referral System Integration

### 3.1 Referral Codes

Each user gets a unique referral code:

```gdscript
# User referral code (generated on signup)
var referral_code = "SCAV-X7K9-2M4P"  # Unique 12-char code

# Shareable link
var referral_link = "https://scrapsurvivor.com/r/SCAV-X7K9-2M4P"
```

### 3.2 Referral Ladder (Existing System)

From monetization-architecture.md:

- **1st Referral:** Scrap Bonus (5,000 scrap)
- **2nd Referral:** Permanent Revive Unlocked
- **3rd Referral:** 25% discount code for Premium Pack IAP
- **5th Referral:** **Free Premium Pack** (grants premium entitlement)

**This is the path for Free users to earn Premium!**

### 3.3 Social Media Card Export

When exporting for social media, card includes:

- Character card image (PNG/JPG)
- Overlay text: "Join me in Scrap Survivor!"
- Referral link: scrapsurvivor.com/r/{code}
- QR code (optional)
- Hashtags: #ScrapSurvivor #MobileRPG

**Platforms:**
- Twitter/X
- Instagram
- Facebook
- Discord
- TikTok (video export with card animation)

### 3.4 Referral Tracking

**Database Schema:**
```sql
-- Track referral relationships
CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_user_id UUID REFERENCES user_accounts(id) NOT NULL,
  referred_user_id UUID REFERENCES user_accounts(id) NOT NULL,
  referral_code VARCHAR(20) NOT NULL,
  referred_at TIMESTAMPTZ DEFAULT NOW(),
  reward_tier INT DEFAULT 0, -- Which reward was granted (0-5)
  UNIQUE(referred_user_id) -- User can only be referred once
);

CREATE INDEX idx_referrals_referrer ON referrals(referrer_user_id);
```

**Referral Flow:**
```gdscript
# 1. User shares card with referral link
func share_card_with_referral(card: TradingCard):
    var referral_code = UserService.get_referral_code()
    var referral_link = "https://scrapsurvivor.com/r/" + referral_code

    var card_image = generate_card_image(card)
    var export_data = {
        "image": card_image,
        "text": "Join me in Scrap Survivor!",
        "link": referral_link,
        "hashtags": ["ScrapSurvivor", "MobileRPG"]
    }

    await SocialMediaService.share(export_data)

# 2. New user clicks link, app opens with referral code
func handle_referral_link(referral_code: String):
    # Store referral code in session
    LocalStorage.set("pending_referral_code", referral_code)

    # Show onboarding with referral bonus preview
    show_onboarding_with_bonus()

# 3. After new user signs up, link referral
func complete_referral_signup(new_user_id: String):
    var referral_code = LocalStorage.get("pending_referral_code")
    if referral_code:
        await SupabaseService.call_edge_function("referrals/link", {
            "referral_code": referral_code,
            "new_user_id": new_user_id
        })
        LocalStorage.remove("pending_referral_code")

# 4. Award referrer with ladder rewards
func check_and_award_referral_rewards(referrer_id: String):
    var total_referrals = await get_referral_count(referrer_id)

    match total_referrals:
        1:
            award_scrap(referrer_id, 5000)
            show_notification("Referral Reward: 5,000 scrap!")
        2:
            unlock_permanent_revive(referrer_id)
            show_notification("Referral Reward: Permanent Revive!")
        3:
            grant_premium_discount_code(referrer_id, 0.25)
            show_notification("Referral Reward: 25% off Premium!")
        5:
            grant_premium_entitlement(referrer_id)
            show_notification("Referral Reward: FREE PREMIUM PACK!")
```

---

## 4. Card Generation Engine

### 4.1 Rendering System

**Approach:** Use Godot's `SubViewport` to render card as 2D scene, then export as PNG

```gdscript
# services/CardGenerationService.gd
class_name CardGenerationService
extends Node

const CARD_WIDTH = 800
const CARD_HEIGHT = 1200
const CARD_DPI = 300

func generate_card(character: Character) -> Image:
    # Create card data
    var card_data = TradingCard.new()
    card_data.populate_from_character(character)

    # Render card scene
    var card_scene = preload("res://scenes/TradingCard.tscn").instantiate()
    card_scene.set_card_data(card_data)

    # Create SubViewport for offscreen rendering
    var viewport = SubViewport.new()
    viewport.size = Vector2i(CARD_WIDTH, CARD_HEIGHT)
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    viewport.transparent_bg = false

    add_child(viewport)
    viewport.add_child(card_scene)

    # Wait for rendering
    await RenderingServer.frame_post_draw

    # Extract image
    var image = viewport.get_texture().get_image()

    # Cleanup
    viewport.queue_free()

    return image

func export_card_to_file(image: Image, file_path: String):
    # Save as PNG
    image.save_png(file_path)

func export_card_to_base64(image: Image) -> String:
    # Encode as base64 for web sharing
    var buffer = image.save_png_to_buffer()
    return Marshalls.raw_to_base64(buffer)
```

### 4.2 Card Scene Structure

```gdscript
# scenes/TradingCard.gd
extends Control

@onready var rarity_border = $RarityBorder
@onready var character_portrait = $CharacterPortrait
@onready var character_name_label = $NameLabel
@onready var stats_container = $StatsContainer
@onready var equipment_list = $EquipmentList
@onready var achievements_label = $AchievementsLabel

var card_data: TradingCard

func set_card_data(data: TradingCard):
    card_data = data
    render_card()

func render_card():
    # Set rarity border
    apply_rarity_style(card_data.rarity)

    # Character portrait (3D render or sprite)
    character_portrait.texture = load_character_texture(card_data.character_id)

    # Character name + nickname
    character_name_label.text = "%s - \"%s\"" % [card_data.character_name, card_data.nickname]

    # Stats
    stats_container.set_stats({
        "HP": card_data.stats.max_hp,
        "Damage": card_data.stats.damage,
        "Speed": card_data.stats.speed,
        "Armor": card_data.stats.armor,
        "Luck": card_data.stats.luck,
        "Crit": str(card_data.stats.crit_chance) + "%"
    })

    # Equipment
    for weapon in card_data.weapons:
        equipment_list.add_weapon_entry(weapon)
    for item in card_data.items.slice(0, 3):  # Top 3 items
        equipment_list.add_item_entry(item)

    # Achievements
    achievements_label.text = "Achievements: %d/50" % card_data.achievements_count

func apply_rarity_style(rarity: String):
    match rarity:
        "common":
            rarity_border.modulate = Color.GRAY
        "uncommon":
            rarity_border.modulate = Color.GREEN
        "rare":
            rarity_border.modulate = Color.BLUE
            add_glow_effect()
        "epic":
            rarity_border.modulate = Color.PURPLE
            add_animated_glow()
        "legendary":
            rarity_border.modulate = Color.ORANGE
            add_legendary_animation()

func add_legendary_animation():
    # Particle effects, border pulse, holographic shimmer
    var particles = preload("res://effects/LegendaryCardParticles.tscn").instantiate()
    add_child(particles)
```

### 4.3 Caching Strategy

**Problem:** Generating cards on-demand is expensive (rendering, encoding)

**Solution:** Cache generated card images

```gdscript
# Cache card images locally
var card_cache: Dictionary = {}  # character_id -> Image

func get_or_generate_card(character_id: String) -> Image:
    # Check local cache
    if card_cache.has(character_id):
        var cache_entry = card_cache[character_id]
        # Check if character was modified since last generation
        var character = CharacterService.get_character(character_id)
        if character.updated_at == cache_entry.generated_at:
            return cache_entry.image

    # Generate new card
    var character = CharacterService.get_character(character_id)
    var image = generate_card(character)

    # Store in cache
    card_cache[character_id] = {
        "image": image,
        "generated_at": character.updated_at
    }

    return image

# Also cache on disk
func save_card_to_disk(character_id: String, image: Image):
    var cache_dir = "user://card_cache/"
    DirAccess.make_dir_recursive_absolute(cache_dir)
    var file_path = cache_dir + character_id + ".png"
    image.save_png(file_path)

func load_card_from_disk(character_id: String) -> Image:
    var file_path = "user://card_cache/" + character_id + ".png"
    if FileAccess.file_exists(file_path):
        return Image.load_from_file(file_path)
    return null
```

---

## 5. Social Media Integration

### 5.1 Platform-Specific Export

**Twitter/X:**
- Image: 1200x675 (16:9) for optimal display
- Text: "Check out my character in Scrap Survivor! [stats] Join me: [link]"
- Character limit: 280 chars
- Hashtags: #ScrapSurvivor #MobileRPG

```gdscript
func export_for_twitter(card: TradingCard) -> Dictionary:
    var image = generate_card_image(card, Vector2i(1200, 675))
    var text = "Check out my Lv%d %s (Wave %d)! Join me in Scrap Survivor: %s #ScrapSurvivor" % [
        card.level,
        card.character_type,
        card.highest_wave,
        get_referral_link()
    ]
    return {"image": image, "text": text, "platform": "twitter"}
```

**Instagram:**
- Image: 1080x1080 (1:1 square) or 1080x1350 (4:5 portrait)
- Caption: Longer format with emojis
- Hashtags: Up to 30 hashtags (use popular game hashtags)
- Stories: 1080x1920 (9:16 vertical)

```gdscript
func export_for_instagram(card: TradingCard, format: String = "feed") -> Dictionary:
    var image: Image
    match format:
        "feed":
            image = generate_card_image(card, Vector2i(1080, 1080))
        "story":
            image = generate_card_image_vertical(card, Vector2i(1080, 1920))

    var caption = """
🎮 My %s in Scrap Survivor!
⚔️ Level %d | Wave %d
🏆 %d Achievements Unlocked
💀 %d Deaths (and counting...)

Join me in the wasteland! Link in bio ⬆️
%s

#ScrapSurvivor #MobileRPG #Gaming #IndieGame #PostApocalyptic
""" % [card.character_name, card.level, card.highest_wave, card.achievements_count, card.death_count, get_referral_link()]

    return {"image": image, "caption": caption, "platform": "instagram", "format": format}
```

**Discord:**
- Embed: Rich embed with thumbnail and fields
- Image: Attach card as image
- Message: Clean formatting with Discord markdown

```gdscript
func export_for_discord(card: TradingCard) -> Dictionary:
    var image = generate_card_image(card)

    # Discord rich embed format
    var embed = {
        "title": "%s - %s" % [card.character_name, card.character_type],
        "description": "Join me in Scrap Survivor!",
        "color": get_rarity_color_hex(card.rarity),
        "thumbnail": {"url": "attachment://card.png"},
        "fields": [
            {"name": "Level", "value": str(card.level), "inline": true},
            {"name": "Wave", "value": str(card.highest_wave), "inline": true},
            {"name": "Deaths", "value": str(card.death_count), "inline": true},
            {"name": "Achievements", "value": "%d/50" % card.achievements_count, "inline": true},
            {"name": "Referral Link", "value": get_referral_link(), "inline": false}
        ]
    }

    return {"embed": embed, "image": image, "platform": "discord"}
```

**TikTok (Video Export):**
- Video: 1080x1920 (9:16 vertical)
- Duration: 10-15 seconds
- Animation: Card flip reveal, stats appear sequentially

```gdscript
func export_for_tiktok(card: TradingCard) -> String:
    # Generate video (requires FFmpeg integration or AnimationPlayer export)
    var video_path = "user://exports/card_video.mp4"

    # Create animation timeline
    var timeline = [
        {"time": 0.0, "action": "show_card_back"},
        {"time": 1.0, "action": "flip_card"},
        {"time": 2.0, "action": "reveal_stats_sequential"},
        {"time": 8.0, "action": "show_referral_qr_code"},
        {"time": 10.0, "action": "fade_out"}
    ]

    await VideoExportService.render_animation(card, timeline, video_path)
    return video_path
```

### 5.2 Share Sheet Integration

```gdscript
# Use platform-native share sheet
func share_card_native(card: TradingCard):
    var image = generate_card_image(card)
    var temp_path = "user://temp_card.png"
    image.save_png(temp_path)

    # iOS/Android share sheet
    if OS.has_feature("mobile"):
        var share_text = "Check out my character in Scrap Survivor! " + get_referral_link()
        var files = [temp_path]
        OS.share_text(share_text, files)
    else:
        # Desktop: Copy image to clipboard + show link
        DisplayServer.clipboard_set_image(image)
        show_copy_link_dialog(get_referral_link())
```

---

## 6. Roster View

### 6.1 In-App Card Browser

**Location:** Scrapyard → Roster

**Features:**
- Swipe/flip through all character cards
- Filter by character type, rarity, status (alive/dead)
- Compare characters side-by-side
- Share individual cards

**UI Implementation:**
```gdscript
# scenes/RosterView.gd
extends Control

@onready var card_carousel = $CardCarousel
@onready var filter_buttons = $FilterBar
@onready var share_button = $ShareButton

var all_cards: Array[TradingCard] = []
var filtered_cards: Array[TradingCard] = []
var current_card_index: int = 0

func _ready():
    load_all_cards()
    setup_filters()
    display_current_card()

func load_all_cards():
    var characters = CharacterService.get_all_characters()
    for character in characters:
        var card = TradingCard.new()
        card.populate_from_character(character)
        all_cards.append(card)

    filtered_cards = all_cards.duplicate()

func setup_filters():
    filter_buttons.filter_changed.connect(_on_filter_changed)

func _on_filter_changed(filter_type: String, filter_value: String):
    match filter_type:
        "character_type":
            filtered_cards = all_cards.filter(func(card): return card.character_type == filter_value)
        "rarity":
            filtered_cards = all_cards.filter(func(card): return card.rarity == filter_value)
        "status":
            if filter_value == "alive":
                filtered_cards = all_cards.filter(func(card): return not card.is_dead)
            else:
                filtered_cards = all_cards.filter(func(card): return card.is_dead)

    current_card_index = 0
    display_current_card()

func display_current_card():
    if filtered_cards.is_empty():
        card_carousel.show_empty_state()
        return

    var card = filtered_cards[current_card_index]
    card_carousel.display_card(card)

func _on_swipe_left():
    current_card_index = (current_card_index + 1) % filtered_cards.size()
    display_current_card()

func _on_swipe_right():
    current_card_index = (current_card_index - 1 + filtered_cards.size()) % filtered_cards.size()
    display_current_card()

func _on_share_button_pressed():
    var card = filtered_cards[current_card_index]
    show_share_dialog(card)
```

### 6.2 Hall of Fame (Subscription)

Subscription users get **character archival:**

- 200 archive slots (separate from active 50 slots)
- Archived characters are **read-only cards**
- Can view stats, but can't play with them
- Preserves legacy runs without cluttering roster

**Archival Flow:**
```gdscript
# services/CharacterArchiveService.gd
const MAX_ARCHIVE_SLOTS_SUBSCRIPTION = 200

func archive_character(character_id: String) -> Result:
    var user = UserService.get_current_user()

    # Check subscription tier
    if user.tier < UserTier.SUBSCRIPTION:
        return Result.error("Archival requires Subscription tier")

    # Check archive slots
    var archived_count = await count_archived_characters(user.id)
    if archived_count >= MAX_ARCHIVE_SLOTS_SUBSCRIPTION:
        return Result.error("Archive is full (200/200 slots)")

    # Archive character (marks as archived, removes from active roster)
    var character = CharacterService.get_character(character_id)
    character.is_archived = true
    character.archived_at = Time.get_datetime_string_from_system()

    await SupabaseService.update("characters", character_id, character)

    return Result.success("Character archived")

func view_archived_character(character_id: String) -> TradingCard:
    # Generate read-only card
    var character = await CharacterService.get_character(character_id)
    var card = TradingCard.new()
    card.populate_from_character(character)
    card.is_archived = true  # Mark as read-only
    return card
```

### 6.3 Card Comparison View

**Feature:** Compare two characters side-by-side

```gdscript
# scenes/CardComparisonView.gd
extends Control

@onready var left_card = $LeftCard
@onready var right_card = $RightCard
@onready var comparison_highlights = $ComparisonHighlights

func compare_cards(card_a: TradingCard, card_b: TradingCard):
    left_card.display_card(card_a)
    right_card.display_card(card_b)

    # Highlight stat differences
    highlight_stat_differences(card_a, card_b)

func highlight_stat_differences(card_a: TradingCard, card_b: TradingCard):
    # Highlight higher stats in green
    if card_a.stats.max_hp > card_b.stats.max_hp:
        left_card.highlight_stat("HP", Color.GREEN)
        right_card.highlight_stat("HP", Color.RED)
    elif card_b.stats.max_hp > card_a.stats.max_hp:
        left_card.highlight_stat("HP", Color.RED)
        right_card.highlight_stat("HP", Color.GREEN)

    # Repeat for all stats...
```

---

## 7. Tier-Specific Features

### 7.1 Free Tier

**Access:** ✅ Basic card viewing and sharing

**Features:**
- View own character cards
- Basic roster view (up to 10 characters)
- Share cards to social media (with referral link)
- Referral rewards ladder (earn Premium through referrals)

**Limitations:**
- No card comparison feature
- No archived characters
- No animated legendary cards (static only)

### 7.2 Premium Tier

**Access:** ✅ All Free features + enhanced card features

**Features:**
- Unlimited roster view (50 active characters)
- Card comparison view (side-by-side)
- Animated legendary cards (particles, glow effects)
- Custom card backgrounds (unlock through achievements)
- Export cards in multiple formats (PNG, JPG, WebP)

### 7.3 Subscription Tier

**Access:** ✅ All Premium features + Hall of Fame

**Features:**
- Hall of Fame archival (200 archived characters)
- Video card exports (animated TikTok format)
- Priority card rendering (faster generation)
- Exclusive card frames/borders (subscriber-only cosmetics)
- Batch export (export multiple cards at once)

**Comparison Table:**

| Feature | Free | Premium | Subscription |
|---------|------|---------|--------------|
| View Cards | ✅ | ✅ | ✅ |
| Share Cards | ✅ | ✅ | ✅ |
| Roster Limit | 10 chars | 50 chars | 50 chars |
| Card Comparison | ❌ | ✅ | ✅ |
| Animated Cards | ❌ | ✅ | ✅ |
| Hall of Fame Archive | ❌ | ❌ | ✅ (200 slots) |
| Video Export | ❌ | ❌ | ✅ |
| Custom Frames | ❌ | Some | All |

---

## 8. Data Model (Complete)

```gdscript
class TradingCard:
    var character_id: String
    var character_name: String
    var nickname: String  # User-defined nickname
    var character_type: String  # Scavenger, Brute, Engineer
    var level: int
    var highest_wave: int
    var death_count: int
    var total_kills: int
    var total_playtime: int  # Seconds
    var stats: Dictionary  # HP, Damage, Speed, Armor, Luck, Crit
    var weapons: Array[Weapon]
    var items: Array[Item]
    var minion: Minion  # Can be null
    var achievements_count: int
    var total_scrap_earned: int
    var rarity: String  # Calculated from highest_wave
    var is_archived: bool  # Subscription-only feature
    var generated_at: String
    var updated_at: String

    func populate_from_character(character: Character):
        self.character_id = character.id
        self.character_name = character.name
        self.nickname = character.nickname
        self.character_type = character.type
        self.level = character.level
        self.highest_wave = character.highest_wave
        self.death_count = character.death_count
        self.total_kills = character.total_kills
        self.total_playtime = character.total_playtime
        self.stats = character.stats
        self.weapons = character.equipped_weapons
        self.items = character.inventory_items
        self.minion = character.equipped_minion
        self.achievements_count = character.achievements.size()
        self.total_scrap_earned = character.total_scrap_earned
        self.rarity = calculate_rarity(character.highest_wave)
        self.is_archived = character.is_archived
        self.generated_at = Time.get_datetime_string_from_system()
        self.updated_at = character.updated_at

    func calculate_rarity(highest_wave: int) -> String:
        if highest_wave >= 40:
            return "legendary"
        elif highest_wave >= 30:
            return "epic"
        elif highest_wave >= 20:
            return "rare"
        elif highest_wave >= 10:
            return "uncommon"
        else:
            return "common"

func generate_card_image(card: TradingCard) -> Image:
    return CardGenerationService.generate_card(card)
```

**Supabase Schema:**
```sql
-- Referral tracking (already in Section 3.4)
CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_user_id UUID REFERENCES user_accounts(id) NOT NULL,
  referred_user_id UUID REFERENCES user_accounts(id) NOT NULL,
  referral_code VARCHAR(20) NOT NULL,
  referred_at TIMESTAMPTZ DEFAULT NOW(),
  reward_tier INT DEFAULT 0,
  UNIQUE(referred_user_id)
);

-- Card share analytics
CREATE TABLE card_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  character_id UUID REFERENCES characters(id) NOT NULL,
  platform VARCHAR(50) NOT NULL, -- 'twitter', 'instagram', 'discord', etc.
  shared_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_card_shares_user_id ON card_shares(user_id);
CREATE INDEX idx_card_shares_platform ON card_shares(platform);
```

---

## 9. Implementation Strategy

### 9.1 Phase 1: Card Generation Engine (Week 16) - 16 hours

**Goal:** Build card rendering system

**Tasks:**
1. **Card Scene Design (4h)**
   - Create `TradingCard.tscn` scene (card layout)
   - Design rarity borders (Common → Legendary)
   - Add character portrait placeholder
   - Add stats display containers

2. **Card Rendering (8h)**
   - Implement `CardGenerationService.gd`
   - SubViewport rendering system
   - Image export (PNG, JPG, WebP)
   - Base64 encoding for web sharing

3. **Rarity System (2h)**
   - Calculate rarity from highest_wave
   - Apply rarity visual effects (glow, particles, animations)
   - Test all 5 rarity tiers

4. **Caching (2h)**
   - Implement in-memory cache
   - Implement disk cache (user://card_cache/)
   - Cache invalidation logic

**Deliverables:**
- ✅ Card images can be generated from character data
- ✅ All rarity tiers display correctly
- ✅ Card generation is performant (<2 seconds per card)

### 9.2 Phase 2: Roster View (Week 17) - 12 hours

**Goal:** Build in-app card browser

**Tasks:**
1. **Roster UI (6h)**
   - Create `RosterView.gd` scene
   - Card carousel (swipe left/right)
   - Filter bar (character type, rarity, status)
   - Empty state (no characters)

2. **Card Comparison (4h)**
   - Create `CardComparisonView.gd` scene
   - Side-by-side card display
   - Stat difference highlighting (green/red)

3. **Hall of Fame (2h)**
   - Archive character flow (Subscription only)
   - View archived characters (read-only)
   - Archive UI (separate tab)

**Deliverables:**
- ✅ Users can browse all character cards
- ✅ Filtering and comparison work
- ✅ Subscription users can archive characters

### 9.3 Phase 3: Social Export (Week 18) - 20 hours

**Goal:** Multi-platform sharing with referral integration

**Tasks:**
1. **Platform-Specific Export (12h)**
   - Twitter/X export (1200x675, text formatting)
   - Instagram export (1080x1080 feed, 1080x1920 story)
   - Discord export (rich embeds)
   - TikTok video export (10-15 sec animation)
   - Facebook export (image + caption)

2. **Referral Integration (4h)**
   - Generate referral codes (12-char unique)
   - Embed referral links in exports
   - QR code generation (optional)
   - Track share events (analytics)

3. **Native Share Sheet (2h)**
   - iOS/Android share dialog integration
   - Desktop clipboard copy
   - Share text formatting per platform

4. **Testing (2h)**
   - Test exports on each platform
   - Verify referral links work
   - Check image dimensions/quality

**Deliverables:**
- ✅ Cards can be shared to 5+ platforms
- ✅ Referral links embedded in all exports
- ✅ Native share experience on mobile

### 9.4 Phase 4: Referral Tracking (Week 19) - 12 hours

**Goal:** Track referrals and award rewards

**Tasks:**
1. **Referral Database (2h)**
   - Create `referrals` table (Supabase)
   - Create `card_shares` analytics table
   - Add indexes

2. **Referral Flow (6h)**
   - Deep link handling (scrapsurvivor.com/r/{code})
   - Store pending referral on signup
   - Link referral after account creation
   - Award referral ladder rewards (1, 2, 3, 5 referrals)

3. **Analytics Dashboard (4h)**
   - Show referral count per user
   - Show referral rewards earned
   - Track card shares per platform
   - Referral conversion metrics (admin panel)

**Deliverables:**
- ✅ Referral system fully functional
- ✅ Free users can earn Premium through referrals
- ✅ Analytics track referral success

### 9.5 Phase 5: Polish & Tier Features (Week 20) - 8 hours

**Goal:** Add tier-specific features and polish

**Tasks:**
1. **Tier Gating (2h)**
   - Free: 10 character limit in roster
   - Premium: Animated legendary cards
   - Subscription: Video exports, Hall of Fame

2. **Animated Legendary Cards (4h)**
   - Particle effects (sparkles, glows)
   - Border pulse animation
   - Holographic shimmer effect

3. **Custom Frames (2h)**
   - Unlock frames through achievements
   - Subscription-exclusive frames
   - Frame selection UI

**Deliverables:**
- ✅ Tier features correctly gated
- ✅ Legendary cards look amazing
- ✅ Custom frames available

**Total Implementation Time:** ~68 hours (~8.5 days of focused work)

---

## 10. Balancing Considerations

### 10.1 Roster Size Limits

**Problem:** How many characters should each tier view?

**Solution:**
- **Free:** 10 characters (encourages upgrade when roster grows)
- **Premium:** 50 characters (standard active roster)
- **Subscription:** 50 active + 200 archived (Hall of Fame)

**Rationale:**
- Free users typically have 3-5 active characters
- 10 character limit is generous but creates upgrade pressure
- Premium 50 limit matches character slot system
- Subscription archival preserves legacy characters without bloat

### 10.2 Referral Rewards Balance

**Problem:** How many referrals to earn Premium for free?

**Current Ladder:**
- 1st Referral: 5,000 scrap
- 2nd Referral: Permanent Revive
- 3rd Referral: 25% off Premium IAP
- 5th Referral: **Free Premium Pack**

**Rationale:**
- 5 referrals is achievable but requires effort
- Average conversion rate: ~10% (5 shares → 1 signup)
- User needs to share 50+ times to earn Premium
- Creates viral growth without cannibalizing revenue

**Alternative (if conversion is too easy):**
- Increase to 10 referrals for free Premium
- Or require referrals to make IAP (not just signup)

### 10.3 Card Generation Performance

**Problem:** Rendering cards should be fast

**Target Performance:**
- **Initial generation:** <2 seconds (acceptable for first-time)
- **Cached load:** <100ms (instant from cache)
- **Batch export (Subscription):** <5 seconds for 10 cards

**Optimization Strategies:**
- Use SubViewport with `UPDATE_ONCE` (single frame render)
- Cache aggressively (both memory and disk)
- Pre-generate cards in background (idle time)
- Subscription users get priority queue (faster processing)

### 10.4 Referral Fraud Prevention

**Problem:** Users might create fake accounts to refer themselves

**Solutions:**
1. **Email Verification:** Referred user must verify email
2. **Activity Requirement:** Referred user must reach Wave 5 (or play 30 min)
3. **Device Fingerprinting:** Detect multiple accounts on same device
4. **Rate Limiting:** Max 10 referrals per user per month
5. **Manual Review:** Flag suspicious referral patterns

```gdscript
func validate_referral(referrer_id: String, referred_id: String) -> bool:
    # Check if referred user reached Wave 5
    var referred_character = CharacterService.get_active_character(referred_id)
    if referred_character.highest_wave < 5:
        return false

    # Check if email verified
    var referred_user = UserService.get_user(referred_id)
    if not referred_user.email_verified:
        return false

    # Check device fingerprint (optional, privacy concerns)
    # ...

    return true
```

---

## 11. Open Questions & Future Enhancements

### 11.1 Open Questions

**Q1: Should cards display real-time stats or snapshot at time of death?**
- Option A: Real-time stats (card updates every time character progresses)
- Option B: Snapshot at death (card is "frozen" when character dies)
- **Recommendation:** Option A for alive characters, Option B for dead characters

**Q2: Should users be able to customize card layouts?**
- Option A: Fixed layout (same for all users)
- Option B: Multiple templates (unlock through achievements/IAP)
- **Recommendation:** Option B (adds customization, monetization opportunity)

**Q3: Should there be physical trading cards (print-on-demand)?**
- Option A: Yes, partner with print service (e.g., MakePlayingCards.com)
- Option B: No, keep it digital only
- **Recommendation:** Option A (post-launch, if community demand exists)

**Q4: Should cards have NFC/QR code for offline sharing?**
- Option A: Yes, generate QR code on card back for easy scanning
- Option B: No, too niche
- **Recommendation:** Option A (QR code is low-effort, high-value)

**Q5: Should Free users be able to view other players' cards?**
- Option A: Yes, cards are public (anyone can view via link)
- Option B: No, cards are private (only owner can view)
- **Recommendation:** Option A (drives social sharing, FOMO)

### 11.2 Future Enhancements (Post-Launch)

**Enhancement 1: Card Trading (PvP Marketplace)**
- Users can trade character cards (not characters, just the card item)
- Rare cards have collectible value
- Marketplace with scrap economy

**Enhancement 2: Card Battles (Mini-Game)**
- Turn-based card game using trading cards
- Stats determine battle outcomes
- Earn scrap by winning battles

**Enhancement 3: Physical Card Printing**
- Partner with print-on-demand service
- Users can order physical cards (glossy, holographic)
- $5-10 per card, shipped globally

**Enhancement 4: Animated Card Wallpapers**
- Export card as animated wallpaper (mobile/desktop)
- Live wallpaper integration (Android)
- Dynamic Island integration (iPhone 14+ Pro)

**Enhancement 5: Card Collections & Albums**
- Collect cards from other players (view-only)
- Complete collections unlock achievements
- Album view (like Pokémon card binders)

**Enhancement 6: Event-Exclusive Card Frames**
- Special frames during events (Halloween, Christmas, etc.)
- Limited-time frames create collectibility
- Frames show participation in past events

---

## 12. Summary

### 12.1 What Trading Cards Provide

The Trading Cards System delivers:

1. **Character Showcase**
   - Beautiful visual representation of character progress
   - Shareable achievements and stats
   - Rarity-based visual distinction (Common → Legendary)

2. **Social Marketing Engine**
   - Built-in referral system drives viral growth
   - Multi-platform sharing (Twitter, Instagram, Discord, TikTok)
   - Free users can earn Premium through referrals (5 referrals)

3. **Player Retention**
   - Hall of Fame archival (Subscription) preserves legacy
   - Card collecting creates long-term engagement
   - Roster view encourages character diversity

4. **Monetization Support**
   - Free tier limits (10 characters) create upgrade pressure
   - Premium features (animated cards, comparison view)
   - Subscription exclusives (video exports, archival, custom frames)

### 12.2 Key Features Recap

- ✅ **Card Generation:** Godot SubViewport rendering, 5 rarity tiers
- ✅ **Roster View:** Browse, filter, compare characters
- ✅ **Social Sharing:** Export to Twitter, Instagram, Discord, TikTok
- ✅ **Referral System:** Unique codes, reward ladder (1-5 referrals)
- ✅ **Hall of Fame:** Subscription archival (200 slots)
- ✅ **Tier Gating:** Free (10 chars), Premium (50 chars + features), Subscription (+archival)

### 12.3 Implementation Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1 | Week 16 (16h) | Card generation engine complete |
| Phase 2 | Week 17 (12h) | Roster view functional |
| Phase 3 | Week 18 (20h) | Multi-platform sharing working |
| Phase 4 | Week 19 (12h) | Referral tracking and rewards |
| Phase 5 | Week 20 (8h) | Tier features and polish |

**Total:** ~68 hours (~8.5 days of focused work)

### 12.4 Success Metrics

Track these KPIs to measure system success:

- **Share Rate:** % of users who share at least one card
  - Target: >30% share rate
- **Referral Conversion:** % of referral links that convert to signups
  - Target: >10% conversion rate
- **Viral Coefficient:** Avg referrals per user
  - Target: >0.5 (50% viral growth)
- **Platform Distribution:** Which platforms drive most referrals
  - Track: Twitter, Instagram, Discord, TikTok shares
- **Time to Premium via Referrals:** Avg days for Free user to earn Premium
  - Target: <60 days (to prove referral path works)

### 12.5 Status & Next Steps

**Current Status:** 📝 Fully documented, ready for implementation

**Prerequisites:**
- ✅ Character Service with persistent characters
- ✅ Stats and achievements tracked
- ✅ Inventory and equipment systems functional
- ⏳ Minion system (optional, but enhances cards)

**Next Steps:**
1. Review this document with team
2. Design card visual mockups (commission artist or AI)
3. Begin Phase 1 implementation (Week 16)
4. Set up Supabase referral tables
5. Test referral flow end-to-end

**Status:** Ready for Week 16+ implementation (after characters are polished).

---

*End of Trading Cards System Documentation*
