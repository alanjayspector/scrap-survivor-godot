# Achievements System

## Table of Contents
1. [System Overview](#system-overview)
2. [Design Philosophy](#design-philosophy)
3. [Achievement Categories](#achievement-categories)
4. [Achievement Structure & Tiers](#achievement-structure--tiers)
5. [Reward System](#reward-system)
6. [Tier-Specific Features](#tier-specific-features)
7. [UI Implementation](#ui-implementation)
8. [Social Integration](#social-integration)
9. [Technical Architecture](#technical-architecture)
10. [Implementation Strategy](#implementation-strategy)
11. [Balancing Considerations](#balancing-considerations)
12. [Open Questions & Future Enhancements](#open-questions--future-enhancements)
13. [Summary](#summary)

---

## System Overview

The **Achievements System** provides structured goals that reward players for accomplishments across all aspects of gameplay. Unlike generic achievement spam, our system focuses on meaningful milestones that celebrate player skill, dedication, and exploration while driving engagement with all game features.

### Core Concepts

- **Progressive Milestones**: Achievements scale from easy (first kill) to extreme (wave 100)
- **Multi-Category Coverage**: Combat, collection, social, exploration, challenge, event participation
- **Tangible Rewards**: All achievements grant rewards (scrap, cosmetics, titles, perks)
- **Social Showcase**: Players can display favorite achievements on profile
- **Tier-Based Access**: Free tier gets core achievements, Premium/Subscription unlock exclusive sets

### Value Proposition

**For Players**:
- Clear progression goals beyond "reach higher wave"
- Recognition for different playstyles (not just combat)
- Rewards that have gameplay impact (scrap, perks) or social value (cosmetics, titles)
- Long-term engagement hooks for completionists
- Social bragging rights

**For Business**:
- Increases session length (players chase "just one more achievement")
- Drives feature adoption (achievements guide players to try all features)
- Creates viral moments (sharing rare achievement unlocks)
- Provides upgrade motivation (exclusive achievements for Premium/Subscription)
- Generates data on player behavior and preferences

### Key Features

1. **7 Achievement Categories**: 120+ total achievements across all game aspects
2. **4 Tier Levels**: Bronze → Silver → Gold → Platinum (increasing difficulty)
3. **Meaningful Rewards**: Every achievement grants scrap, cosmetics, titles, or perks
4. **Progress Tracking**: Real-time progress display (e.g., "Kill 500 enemies: 324/500")
5. **Secret Achievements**: Hidden challenges that reward exploration
6. **Event Achievements**: Limited-time achievements during special events
7. **Social Showcase**: Display up to 3 favorite achievements on profile
8. **Completionist Tracking**: Overall completion percentage across all categories

---

## Design Philosophy

The Achievements System must feel rewarding and motivating, not grindy or spammy.

### Core Principles

#### 1. Meaningful, Not Spam

**Problem**: Many games flood players with trivial achievements ("Press Start", "Complete Tutorial").

**Solution**:
- Every achievement requires meaningful effort
- Minimum threshold: 15+ minutes of gameplay or specific skill demonstration
- No achievements for basic tutorial actions
- Focus on milestones that feel like accomplishments

**Example**:
```
❌ Bad: "First Blood" - Kill your first enemy (everyone gets this instantly)
✅ Good: "Centurion" - Kill 100 enemies in a single run (requires skill/survival)

❌ Bad: "Window Shopping" - Open the shop once
✅ Good: "Savvy Shopper" - Purchase optimal items 10 times (requires knowledge)
```

#### 2. Skill-Based, Not Just Time-Gated

**Problem**: Pure grind achievements feel unrewarding ("Kill 10,000 enemies").

**Solution**:
- Mix skill challenges with progression milestones
- Skill achievements: Wave 30 with 0 damage taken, flawless boss kill
- Progression achievements: Reach wave 50, unlock all characters
- Variety achievements: Win with each character type, use every weapon

**Balance**:
- 40% skill-based (requires talent/strategy)
- 40% progression-based (requires time/dedication)
- 20% exploration-based (rewards curiosity)

#### 3. Rewarding, Not Just Badges

**Problem**: Meaningless badges don't motivate most players.

**Solution**:
- **Every achievement grants tangible rewards**
- Scrap rewards scale with difficulty (100-5,000 scrap)
- Rare achievements unlock cosmetics (character skins, weapon skins)
- Elite achievements grant titles displayable on profile
- Secret achievements unlock hidden perks or items

**Reward Tiers**:
| Achievement Tier | Scrap Reward | Additional Rewards |
|------------------|--------------|-------------------|
| Bronze | 100-500 | Common cosmetic or small scrap boost |
| Silver | 500-1,500 | Uncommon cosmetic or title |
| Gold | 1,500-3,000 | Rare cosmetic or perk unlock |
| Platinum | 3,000-5,000 | Legendary cosmetic + unique title |

#### 4. Diverse, Not Monolithic

**Problem**: Combat-only achievements ignore non-combat players.

**Solution**:
- **7 distinct categories** covering all playstyles
- Combat achievements (wave survival, boss kills, damage milestones)
- Collection achievements (unlock items, characters, perks)
- Social achievements (referrals, trading cards, community participation)
- Economy achievements (scrap earned, optimal purchasing)
- Exploration achievements (discover secrets, find easter eggs)
- Challenge achievements (specific restrictions, speedruns)
- Event achievements (participate in seasonal events)

**Player Archetype Coverage**:
- **Achievers**: Combat mastery, wave records
- **Collectors**: Unlock all items/characters
- **Socializers**: Referral milestones, trading cards
- **Explorers**: Secret discoveries, easter eggs

#### 5. Progressive, Not All-or-Nothing

**Problem**: Single-tier achievements feel binary (either you have it or you don't).

**Solution**:
- **Multi-tier progressive achievements**
- Each achievement has 4 levels: Bronze → Silver → Gold → Platinum
- Each level grants incremental rewards
- Players always have next milestone to chase

**Example**:
```
"Wave Master" Achievement Series:

🥉 Bronze: Reach Wave 10
   Reward: 100 scrap + "Survivor" title

🥈 Silver: Reach Wave 20
   Reward: 500 scrap + "Veteran" title

🥇 Gold: Reach Wave 30
   Reward: 1,500 scrap + "Elite" title + Gold border cosmetic

💎 Platinum: Reach Wave 50
   Reward: 5,000 scrap + "Legend" title + Platinum border + Exclusive character skin
```

#### 6. Visible Progress, Not Mystery

**Problem**: Hidden progress feels frustrating ("How close am I?").

**Solution**:
- Show real-time progress for all active achievements
- Display next milestone in UI
- Celebrate incremental progress (25%, 50%, 75% completion notifications)
- Exception: Secret achievements remain hidden until unlocked

**UI Example**:
```
Wave Master: ████████░░ 80% (Wave 24/30)
Centurion: ███████░░░ 74% (372/500 kills)
Collector: █████░░░░░ 52% (26/50 items unlocked)
```

---

## Achievement Categories

The system includes 120+ achievements across 7 categories, ensuring all player types have goals to pursue.

### 1. Progression Achievements (25 achievements)

**Purpose**: Reward players for general advancement and unlocking content.

**Subcategories**:
- **Wave Milestones** (8 achievements)
- **Account Level** (5 achievements)
- **Character Unlocks** (5 achievements)
- **Perk Unlocks** (5 achievements)
- **Content Mastery** (2 achievements)

#### Wave Milestones

Progressive achievements for reaching higher waves.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Survivor | Bronze | Reach Wave 10 | 100 scrap + "Survivor" title |
| Veteran | Silver | Reach Wave 20 | 500 scrap + "Veteran" title |
| Elite | Gold | Reach Wave 30 | 1,500 scrap + "Elite" title + Gold border |
| Champion | Gold | Reach Wave 40 | 2,500 scrap + "Champion" title |
| Legend | Platinum | Reach Wave 50 | 5,000 scrap + "Legend" title + Platinum border + Legendary skin |
| Demigod | Platinum | Reach Wave 75 | 10,000 scrap + "Demigod" title + Exclusive weapon skin |
| Ascended | Platinum | Reach Wave 100 | 25,000 scrap + "Ascended" title + Unique character + Diamond border |
| Immortal | Platinum | Reach Wave 150 | 50,000 scrap + "Immortal" title + All cosmetics unlocked |

**Implementation**:
```gdscript
func _on_wave_completed(wave: int):
    var milestones = {
        10: "survivor",
        20: "veteran",
        30: "elite",
        40: "champion",
        50: "legend",
        75: "demigod",
        100: "ascended",
        150: "immortal"
    }

    if wave in milestones:
        AchievementService.unlock(milestones[wave])
```

#### Account Level

Reward long-term engagement and experience accumulation.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Greenhorn | Bronze | Reach Account Level 10 | 200 scrap |
| Experienced | Silver | Reach Account Level 25 | 500 scrap + Uncommon cosmetic |
| Expert | Gold | Reach Account Level 50 | 1,500 scrap + Rare cosmetic |
| Master | Gold | Reach Account Level 75 | 2,500 scrap + "Master" title |
| Grandmaster | Platinum | Reach Account Level 100 | 5,000 scrap + "Grandmaster" title + Epic cosmetic |

---

### 2. Combat Mastery Achievements (30 achievements)

**Purpose**: Reward skill, strategy, and combat excellence.

**Subcategories**:
- **Kill Count** (8 achievements)
- **Boss Mastery** (6 achievements)
- **Damage Milestones** (5 achievements)
- **Survival Challenges** (6 achievements)
- **Weapon Mastery** (5 achievements)

#### Kill Count

Progressive kill milestones across all runs.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Slayer | Bronze | Kill 1,000 enemies (total) | 100 scrap |
| Exterminator | Silver | Kill 10,000 enemies (total) | 500 scrap + "Exterminator" title |
| Genocide | Gold | Kill 50,000 enemies (total) | 1,500 scrap + Kill counter cosmetic |
| Apocalypse | Platinum | Kill 100,000 enemies (total) | 3,000 scrap + "Harbinger" title + Blood effect cosmetic |

#### Single-Run Kill Challenges

Skill-based achievements for kills in individual runs.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Centurion | Bronze | Kill 100 enemies in a single run | 100 scrap |
| Gladiator | Silver | Kill 500 enemies in a single run | 500 scrap + "Gladiator" title |
| War Machine | Gold | Kill 1,000 enemies in a single run | 1,500 scrap + Weapon trail effect |
| Death Incarnate | Platinum | Kill 2,000 enemies in a single run | 3,000 scrap + "Death Incarnate" title |

#### Boss Mastery

Challenges focused on boss encounters.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Boss Slayer | Bronze | Defeat 10 bosses | 200 scrap |
| Flawless Victory | Silver | Defeat a boss without taking damage | 500 scrap + "Flawless" title |
| Speed Demon | Silver | Defeat a boss in under 30 seconds | 500 scrap + Speed effect cosmetic |
| Boss Hunter | Gold | Defeat 100 bosses | 1,500 scrap + "Hunter" title |
| Titan Killer | Platinum | Defeat Wave 50 boss | 3,000 scrap + Legendary weapon skin |
| Deicide | Platinum | Defeat all unique boss types | 5,000 scrap + "Godslayer" title + Boss trophy cosmetics |

#### Survival Challenges

Skill-based survival achievements.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Untouchable | Bronze | Complete 5 waves without taking damage | 200 scrap |
| Iron Wall | Silver | Survive 10 waves with HP never below 50% | 500 scrap + Shield cosmetic |
| Glass Cannon | Silver | Reach Wave 20 with max HP under 50 | 500 scrap + "Glass Cannon" title |
| Pacifist Run | Gold | Complete Wave 10 without firing a weapon (melee only) | 1,500 scrap + "Pacifist" title |
| Minimalist | Gold | Reach Wave 20 with only 1 weapon | 1,500 scrap + Minimalist border |
| Deathless | Platinum | Reach Wave 30 without dying once | 5,000 scrap + "Deathless" title + Immortal aura cosmetic |

---

### 3. Collection Achievements (20 achievements)

**Purpose**: Reward players for unlocking and collecting content.

**Subcategories**:
- **Item Collection** (6 achievements)
- **Character Roster** (5 achievements)
- **Weapon Arsenal** (5 achievements)
- **Perk Library** (4 achievements)

#### Item Collection

Progressive item unlock achievements.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Hoarder | Bronze | Unlock 25 unique items | 100 scrap |
| Collector | Silver | Unlock 50 unique items | 500 scrap + "Collector" title |
| Curator | Gold | Unlock 75 unique items | 1,500 scrap + Display case cosmetic |
| Completionist | Platinum | Unlock all items in the game | 5,000 scrap + "Completionist" title + Golden item borders |

#### Rarity-Based Collection

Reward collecting rare items.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Rare Find | Bronze | Unlock 10 Rare items | 200 scrap |
| Epic Hunter | Silver | Unlock 5 Epic items | 500 scrap + Rarity glow effect |
| Legendary Collector | Gold | Unlock 3 Legendary items | 1,500 scrap + "Legend Hunter" title |
| The One Percent | Platinum | Unlock all Legendary items | 3,000 scrap + Rainbow rarity effect |

#### Character Roster

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Diverse Roster | Bronze | Unlock 5 characters | 100 scrap |
| Full Team | Silver | Unlock 10 characters | 500 scrap + Team photo cosmetic |
| Character Master | Gold | Win at least once with every character | 1,500 scrap + "Versatile" title |
| Perfect Roster | Platinum | Unlock all characters including secret ones | 3,000 scrap + Character select border |
| Hall of Champions | Platinum | Archive 10 characters in Hall of Fame (Subscription) | 2,000 scrap + "Archivist" title |

---

### 4. Economy Achievements (15 achievements)

**Purpose**: Reward smart resource management and economic success.

**Subcategories**:
- **Scrap Accumulation** (5 achievements)
- **Smart Spending** (5 achievements)
- **Banking & Trading** (5 achievements)

#### Scrap Accumulation

Progressive scrap earning milestones.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Penny Pincher | Bronze | Earn 10,000 total scrap | 100 scrap |
| Wealthy | Silver | Earn 100,000 total scrap | 500 scrap + Coin cosmetic |
| Tycoon | Gold | Earn 500,000 total scrap | 1,500 scrap + "Tycoon" title + Golden scrap effect |
| Millionaire | Platinum | Earn 1,000,000 total scrap | 5,000 scrap + "Millionaire" title + Money shower effect |
| Scrooge McDuck | Platinum | Have 50,000 scrap at once (not spent) | 2,000 scrap + Vault cosmetic |

#### Smart Spending

Reward optimal purchasing decisions (tracked via AdvisorService).

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Savvy Shopper | Bronze | Make 10 "optimal" purchases (high ROI) | 200 scrap |
| Efficiency Expert | Silver | Complete 5 runs with 90%+ spending efficiency | 500 scrap + "Efficient" title |
| No Waste | Gold | Complete run spending exactly 0 scrap (perfect efficiency) | 1,500 scrap + Calculator cosmetic |
| Investment Guru | Gold | Purchase items that result in 200%+ ROI 20 times | 1,500 scrap + Stock market graph cosmetic |
| Perfect Economy | Platinum | Achieve 95%+ spending efficiency across 20 runs | 3,000 scrap + "Economist" title |

#### Banking & Trading (Premium/Subscription)

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Quantum Banker | Bronze | Transfer scrap between characters 10 times (Subscription) | 200 scrap |
| Item Trader | Silver | Transfer items between characters 25 times (Subscription) | 500 scrap + "Trader" title |
| Banking Empire | Gold | Transfer over 100,000 scrap total via Quantum Banking | 1,500 scrap + Bank vault cosmetic |
| Black Market Buyer | Silver | Purchase 50 items from Black Market (Premium) | 500 scrap + Black Market VIP badge |
| Vending Regular | Gold | Use Atomic Vending Machine 20 times (Subscription) | 1,000 scrap + "Regular" title |

---

### 5. Social Achievements (15 achievements)

**Purpose**: Reward community engagement and social features.

**Subcategories**:
- **Referral Program** (5 achievements)
- **Trading Cards** (5 achievements)
- **Community Participation** (5 achievements)

#### Referral Program

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Friendly | Bronze | Refer 1 friend | 200 scrap |
| Popular | Silver | Refer 5 friends (unlock Premium) | 500 scrap + "Recruiter" title |
| Influencer | Gold | Refer 15 friends | 1,500 scrap + Influencer badge cosmetic |
| Viral | Platinum | Refer 50 friends | 5,000 scrap + "Viral" title + Exclusive referral-only skin |
| Community Leader | Platinum | Refer 100 friends | 10,000 scrap + "Leader" title + All referral cosmetics |

#### Trading Cards

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Card Collector | Bronze | Create 10 trading cards | 100 scrap |
| Social Butterfly | Silver | Share 50 trading cards | 500 scrap + "Social" title |
| Gallery Curator | Gold | Create trading cards for 25 different characters | 1,500 scrap + Gallery frame cosmetic |
| Card Master | Gold | Receive 100 views on your trading cards | 1,000 scrap + View counter badge |
| Hall of Fame | Platinum | Create cards for 10 Hall of Fame characters (Subscription) | 2,000 scrap + Golden card border |

#### Community Participation

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Helpful | Bronze | Use Feature Request System 5 times | 100 scrap |
| Contributor | Silver | Have a feature request upvoted 50 times | 500 scrap + "Contributor" title |
| Event Participant | Bronze | Participate in 5 special events | 200 scrap |
| Event Completionist | Gold | Complete all challenges in 3 different events | 1,500 scrap + Event badge collection |
| Community Champion | Platinum | Top 10 on any global leaderboard | 3,000 scrap + "Champion" title + Crown cosmetic |

---

### 6. Challenge Achievements (10 achievements)

**Purpose**: Extreme skill challenges for hardcore players.

**Subcategories**:
- **Restriction Runs** (5 achievements)
- **Speedruns** (5 achievements)

#### Restriction Runs

Self-imposed challenges that limit player options.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Purist | Gold | Reach Wave 20 without purchasing any items | 1,500 scrap + "Purist" title |
| One-Weapon Wonder | Gold | Reach Wave 20 using only 1 weapon type entire run | 1,500 scrap + Focused badge |
| Poverty Run | Gold | Reach Wave 15 without spending any scrap | 1,500 scrap + Monk cosmetic |
| Naked Run | Platinum | Reach Wave 10 with no items equipped | 3,000 scrap + "Naked" title + Birthday suit skin |
| Ironman | Platinum | Reach Wave 30 with permadeath (single life, no continues) | 5,000 scrap + "Ironman" title + Iron armor cosmetic |

#### Speedruns

Time-based challenges.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Speed Runner | Silver | Reach Wave 10 in under 10 minutes | 500 scrap + Stopwatch cosmetic |
| Blitz | Gold | Reach Wave 20 in under 20 minutes | 1,500 scrap + "Speedster" title |
| Time Trial Master | Gold | Complete 10 waves without pausing for more than 5 seconds | 1,500 scrap + Timer UI cosmetic |
| Lightning Fast | Platinum | Reach Wave 30 in under 30 minutes | 3,000 scrap + Lightning effect |
| World Record | Platinum | Top 10 on speedrun leaderboard | 5,000 scrap + "Record Holder" title + Trophy cosmetic |

---

### 7. Secret & Easter Egg Achievements (15 achievements)

**Purpose**: Reward exploration, curiosity, and discovering hidden content.

**Note**: These achievements are hidden until unlocked. Players see "???" in achievement list.

#### Easter Eggs

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Konami Code | Bronze | Enter Konami Code on main menu | 100 scrap + 80s retro skin |
| Developer Shrine | Silver | Find hidden developer room | 500 scrap + Developer autograph cosmetic |
| Secret Room | Silver | Discover secret room in map | 500 scrap + Hidden door cosmetic |
| Lore Master | Gold | Find all 10 hidden lore documents | 1,500 scrap + "Lorekeeper" title + Story book cosmetic |
| Easter Egg Hunter | Platinum | Discover all secret easter eggs | 5,000 scrap + "Hunter" title + Golden egg cosmetic |

#### Weird Achievements

Fun, unexpected challenges.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| Pacifist | Silver | Complete wave without killing any enemies (survive only) | 500 scrap + Peace sign cosmetic |
| Friendly Fire | Bronze | Die to your own explosion | 100 scrap + "Oops" title |
| David vs Goliath | Gold | Kill boss while 20+ levels lower than recommended | 1,500 scrap + Slingshot cosmetic |
| Lucky Streak | Silver | Get 10 critical hits in a row | 500 scrap + Lucky clover cosmetic |
| Against All Odds | Platinum | Win a run with 1 HP remaining | 3,000 scrap + "Clutch" title + Last stand effect |

#### Playstyle Secrets

Hidden achievements for specific playstyle mastery.

| Achievement | Tier | Requirement | Reward |
|-------------|------|-------------|--------|
| True Tank | Gold | Reach Wave 30 with Tank playstyle and 500+ HP | 1,500 scrap + "True Tank" title |
| Glass Cannon Pro | Gold | Reach Wave 30 with Glass Cannon and <50 HP | 1,500 scrap + "Pro Cannon" title |
| Melee Purist | Gold | Reach Wave 30 using only melee weapons | 1,500 scrap + "Blademaster" title |
| Ranged Sniper | Gold | Reach Wave 30 using only ranged weapons | 1,500 scrap + "Marksman" title |
| Balanced Master | Platinum | Reach Wave 50 with Balanced playstyle | 3,000 scrap + "Harmonious" title + Yin-yang cosmetic |

---

## Achievement Structure & Tiers

### Four-Tier System

All achievements follow a 4-tier progressive structure (except secrets).

#### Bronze Tier
- **Difficulty**: Easy, achievable by most players
- **Time Investment**: 1-5 hours of gameplay
- **Rewards**: 100-200 scrap, basic cosmetics
- **Purpose**: Early wins, onboarding, breadcrumb trail

**Examples**: First 100 kills, unlock 5 items, refer 1 friend

#### Silver Tier
- **Difficulty**: Moderate, requires skill or dedication
- **Time Investment**: 10-20 hours of gameplay
- **Rewards**: 500-1,000 scrap, uncommon cosmetics, titles
- **Purpose**: Intermediate goals, feature adoption

**Examples**: Reach Wave 20, defeat boss without damage, unlock 25 items

#### Gold Tier
- **Difficulty**: Hard, requires mastery or significant time
- **Time Investment**: 50-100 hours of gameplay
- **Rewards**: 1,500-2,500 scrap, rare cosmetics, prestigious titles
- **Purpose**: Long-term goals, mastery recognition

**Examples**: Reach Wave 30, unlock all items, top leaderboard placement

#### Platinum Tier
- **Difficulty**: Extreme, only for dedicated players
- **Time Investment**: 100+ hours of gameplay
- **Rewards**: 3,000-5,000+ scrap, legendary cosmetics, unique titles, exclusive content
- **Purpose**: Ultimate bragging rights, completionist endgame

**Examples**: Reach Wave 100, refer 100 friends, all secret achievements

---

### Achievement Data Model

```gdscript
# models/Achievement.gd
class_name Achievement
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var category: AchievementCategory
@export var tier: AchievementTier
@export var is_secret: bool = false
@export var is_progressive: bool = false

# Requirements
@export var requirement_type: RequirementType
@export var requirement_value: int
@export var requirement_data: Dictionary = {}

# Rewards
@export var scrap_reward: int
@export var title_reward: String = ""
@export var cosmetic_rewards: Array[String] = []
@export var perk_unlock: String = ""

# Progression tracking (for progressive achievements)
@export var levels: Array[AchievementLevel] = []

# Metadata
@export var unlock_date: String = ""
@export var unlock_tier_requirement: UserTier = UserTier.FREE

enum AchievementCategory {
    PROGRESSION,
    COMBAT,
    COLLECTION,
    ECONOMY,
    SOCIAL,
    CHALLENGE,
    SECRET
}

enum AchievementTier {
    BRONZE,
    SILVER,
    GOLD,
    PLATINUM
}

enum RequirementType {
    WAVE_REACHED,
    KILLS_TOTAL,
    KILLS_SINGLE_RUN,
    BOSS_DEFEATS,
    ITEMS_UNLOCKED,
    CHARACTERS_UNLOCKED,
    SCRAP_EARNED,
    REFERRALS,
    CUSTOM
}

class AchievementLevel:
    var tier: AchievementTier
    var requirement_value: int
    var scrap_reward: int
    var cosmetic_reward: String
    var title_reward: String
```

---

## Reward System

Every achievement grants tangible rewards that impact gameplay or social standing.

### Reward Types

#### 1. Scrap

**Purpose**: Direct economic benefit.

**Scaling**:
- Bronze: 100-200 scrap (buys 1-2 common items)
- Silver: 500-1,000 scrap (buys 1 rare item or 3-5 common items)
- Gold: 1,500-2,500 scrap (buys 1 epic item or multiple rare items)
- Platinum: 3,000-10,000 scrap (buys legendary items or builds entire character)

**Total Scrap Available**: ~150,000 scrap from all achievements (equivalent to $50-75 value)

**Business Logic**: Generous scrap rewards keep F2P players engaged, but not enough to completely replace purchases.

---

#### 2. Titles

**Purpose**: Social status display on profile and leaderboards.

**Implementation**:
```gdscript
# Profile display
"[Immortal] PlayerName"
"[Glass Cannon Pro] SnipeGod42"
"[Completionist] ItemHoarder"
```

**Rarity Tiers**:
- Bronze: Common titles (10+ available) - "Survivor", "Slayer"
- Silver: Uncommon titles (20+ available) - "Veteran", "Gladiator"
- Gold: Rare titles (15+ available) - "Elite", "Master", "Tycoon"
- Platinum: Legendary titles (10 available) - "Legend", "Immortal", "Godslayer"

**Social Value**: Titles are the primary social currency. Rare titles command respect.

---

#### 3. Cosmetics

**Purpose**: Visual customization and status display.

**Categories**:
- **Borders**: Profile and character select borders (Bronze/Silver/Gold/Platinum/Diamond)
- **Effects**: Particle effects (auras, trails, glows, explosions)
- **Skins**: Character skins and weapon skins
- **Badges**: Small icons displayed on profile
- **Emotes**: Unlockable celebration animations

**Exclusive Cosmetics**: Some cosmetics ONLY available via achievements (not purchasable).

**Examples**:
```
Wave 50 → Platinum border (can't buy, must earn)
100,000 kills → Blood splatter effect
All items collected → Golden item border effect
Speedrun top 10 → Lightning trail
```

**Business Logic**: Achievement-exclusive cosmetics create aspirational goals. Premium cosmetics can still be purchased.

---

#### 4. Perk Unlocks

**Purpose**: Gameplay impact rewards for major achievements.

**Implementation**: Some achievements unlock perks that would otherwise require progression.

**Examples**:
- "Complete all challenge runs" → Unlock "Iron Will" perk (rare)
- "Reach Wave 100" → Unlock "Ascended" perk (legendary, +10% all stats)
- "Refer 50 friends" → Unlock "Community Hero" perk (+5% scrap for you and all referred friends)

**Balance**: Only 5-10 perks unlockable via achievements (not all perks). These are powerful but optional.

---

#### 5. Content Unlocks

**Purpose**: Unlock hidden characters, items, or features.

**Examples**:
- "Discover all secret easter eggs" → Unlock secret character "The Developer"
- "Complete all event achievements" → Unlock exclusive event-themed character
- "Reach Wave 150" → Unlock "Immortal Mode" difficulty

---

### Reward Claim Flow

```gdscript
# services/AchievementService.gd
func unlock_achievement(achievement_id: String):
    var achievement = AchievementDatabase.get(achievement_id)

    # Mark as unlocked
    PlayerProgress.unlock_achievement(achievement_id)

    # Grant rewards
    grant_rewards(achievement)

    # Show notification
    AchievementNotification.show(achievement)

    # Track analytics
    AnalyticsService.track_achievement_unlocked(achievement_id)

func grant_rewards(achievement: Achievement):
    # Scrap
    if achievement.scrap_reward > 0:
        CurrencyService.add_scrap(achievement.scrap_reward, "achievement_%s" % achievement.id)

    # Title
    if achievement.title_reward != "":
        PlayerProfile.unlock_title(achievement.title_reward)

    # Cosmetics
    for cosmetic_id in achievement.cosmetic_rewards:
        CosmeticService.unlock(cosmetic_id)

    # Perk
    if achievement.perk_unlock != "":
        PerkService.unlock_perk(achievement.perk_unlock)

    # Save
    PlayerProgress.save()
```

---

## Tier-Specific Features

Achievement access varies by user tier to provide upgrade motivation.

### Free Tier

**Access**:
- ✅ All Bronze achievements (40+ achievements)
- ✅ All Silver achievements (35+ achievements)
- ✅ Most Gold achievements (20+ achievements)
- ✅ Some Platinum achievements (5+ achievements)
- ✅ Basic achievement tracking
- ✅ Achievement notifications
- ✅ Profile showcase (1 achievement)

**Restrictions**:
- ❌ No Quantum Banking achievements
- ❌ No Hall of Fame achievements
- ❌ No exclusive event achievements
- ❌ No Subscription-only achievements
- ❌ Limited profile showcase (1 achievement vs 3)

**Total Available**: ~100 achievements (80% of all achievements)

**Business Logic**: Free tier gets vast majority of achievements, enough to feel complete without feeling gated.

---

### Premium Tier ($9.99)

**Access**:
- ✅ All Free tier achievements
- ✅ All Gold achievements (30+ achievements)
- ✅ Most Platinum achievements (12+ achievements)
- ✅ Black Market achievements (5 achievements)
- ✅ Event achievements (all basic event achievements)
- ✅ Profile showcase (3 achievements)
- ✅ Achievement leaderboards

**Exclusive Achievements** (Premium-only):
- "Black Market VIP" - Purchase 50 Black Market items
- "Premium Member" - Maintain Premium status for 6 months
- "Event Champion" - Complete all challenges in a Premium event

**Total Available**: ~115 achievements (95% of all achievements)

**Business Logic**: Premium unlocks "completionist" achievements, adds leaderboards and social features.

---

### Subscription Tier ($4.99/month)

**Access**:
- ✅ All achievements (120+ total)
- ✅ Subscription-exclusive achievements (8 achievements)
- ✅ Early access to event achievements
- ✅ Bonus scrap rewards (+50% on all achievement scrap)
- ✅ Profile showcase (3 achievements + animated borders)
- ✅ Global achievement leaderboards

**Exclusive Achievements** (Subscription-only):
```
1. "Quantum Banker" - Transfer 100,000 scrap via Quantum Banking
2. "Hall of Fame Curator" - Archive 10 characters in Hall of Fame
3. "Vending Machine Regular" - Use Atomic Vending Machine 20 times
4. "Event Rollover Master" - Roll over event currency 5 times
5. "Subscriber" - Maintain subscription for 6 consecutive months
6. "Loyal Supporter" - Maintain subscription for 12 consecutive months
7. "Ultimate Completionist" - Unlock every single achievement in game
8. "The One Percent" - Achieve Platinum tier in all 7 categories
```

**Scrap Bonus**: Subscribers earn 50% more scrap from achievements.
- Example: Bronze achievement normally gives 100 scrap → Subscribers get 150 scrap
- Total bonus across all achievements: ~75,000 extra scrap

**Total Available**: 120+ achievements (100%)

**Business Logic**: Subscription unlocks 100% completion, provides significant economic boost, and offers exclusive bragging rights.

---

### Tier Comparison Table

| Feature | Free | Premium | Subscription |
|---------|------|---------|--------------|
| Total achievements available | ~100 (80%) | ~115 (95%) | 120+ (100%) |
| Bronze/Silver achievements | ✅ All | ✅ All | ✅ All |
| Gold achievements | ✅ Most | ✅ All | ✅ All |
| Platinum achievements | ✅ Some | ✅ Most | ✅ All |
| Secret achievements | ✅ Most | ✅ All | ✅ All |
| Black Market achievements | ❌ | ✅ | ✅ |
| Quantum Banking achievements | ❌ | ❌ | ✅ |
| Hall of Fame achievements | ❌ | ❌ | ✅ |
| Subscription-only achievements | ❌ | ❌ | ✅ |
| Scrap bonus | 0% | 0% | +50% |
| Profile showcase slots | 1 | 3 | 3 + animated |
| Leaderboards | ❌ | ✅ | ✅ |

---

## UI Implementation

### Achievement Notification (In-Game)

**Visual**:
```
        ┌────────────────────────────────────┐
        │ 🏆 ACHIEVEMENT UNLOCKED!           │
        ├────────────────────────────────────┤
        │                                    │
        │   [Gold Trophy Icon]               │
        │                                    │
        │   ELITE                            │
        │   Reach Wave 30                    │
        │                                    │
        │   Rewards:                         │
        │   • 1,500 Scrap                    │
        │   • "Elite" Title                  │
        │   • Gold Border                    │
        │                                    │
        │         [Awesome!]                 │
        │                                    │
        └────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/AchievementNotification.gd
extends PanelContainer

@onready var icon = $VBox/Icon
@onready var title_label = $VBox/Title
@onready var description = $VBox/Description
@onready var rewards_list = $VBox/Rewards
@onready var close_button = $VBox/CloseButton
@onready var animation = $AnimationPlayer

func show_achievement(achievement: Achievement):
    # Set content
    icon.texture = get_tier_icon(achievement.tier)
    title_label.text = achievement.name
    description.text = achievement.description

    # Populate rewards
    rewards_list.clear()
    if achievement.scrap_reward > 0:
        add_reward("• %d Scrap" % achievement.scrap_reward)
    if achievement.title_reward != "":
        add_reward("• \"%s\" Title" % achievement.title_reward)
    for cosmetic in achievement.cosmetic_rewards:
        add_reward("• %s" % cosmetic)

    # Show with animation
    show()
    animation.play("slide_in")

    # Play sound
    AudioManager.play_sfx("achievement_unlocked")

    # Auto-close after 5 seconds
    await get_tree().create_timer(5.0).timeout
    fade_out()

func fade_out():
    animation.play("fade_out")
    await animation.animation_finished
    queue_free()
```

**Sound**: Triumphant fanfare (different sound per tier)

---

### Achievement Panel (Full Screen)

**Layout**:
```
┌──────────────────────────────────────────────────────────────┐
│  🏆 Achievements                                      [×]     │
├────────────────────┬─────────────────────────────────────────┤
│                    │                                         │
│  CATEGORIES        │  Progress: 65/120 (54%)                 │
│                    │  [████████████░░░░░░] 54%               │
│  ▶ All (65/120)    │                                         │
│  ▶ Progression     │  ─────────────────────────────────      │
│     (18/25)        │                                         │
│  ▶ Combat          │  🥇 ELITE (Gold)                        │
│     (22/30)        │  Reach Wave 30                          │
│  ▶ Collection      │                                         │
│     (12/20)        │  Unlocked: March 15, 2025               │
│  ▶ Economy         │  Rewards: 1,500 scrap, "Elite" title,  │
│     (8/15)         │           Gold border                   │
│  ▶ Social          │                                         │
│     (3/15)         │  [Equip Title] [View Cosmetics]         │
│  ▶ Challenge       │                                         │
│     (0/10)         │  ─────────────────────────────────      │
│  ▶ Secret          │                                         │
│     (2/15)         │  🥈 BOSS SLAYER (Silver)                │
│                    │  Defeat 10 bosses                       │
│  FILTER            │                                         │
│  ☑ Unlocked        │  Progress: ██████████░ 9/10             │
│  ☑ Locked          │                                         │
│  ☐ Platinum only   │  Rewards: 200 scrap                     │
│                    │                                         │
│                    │  Almost there!                          │
│                    │                                         │
└────────────────────┴─────────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/AchievementPanel.gd
extends Panel

@onready var category_tree = $HSplit/LeftPanel/CategoryTree
@onready var achievement_list = $HSplit/RightPanel/AchievementList
@onready var progress_bar = $HSplit/RightPanel/ProgressBar
@onready var progress_label = $HSplit/RightPanel/ProgressLabel

func _ready():
    populate_categories()
    update_progress()
    load_achievements("All")

func populate_categories():
    category_tree.clear()
    var root = category_tree.create_item()

    var categories = [
        { "name": "All", "unlocked": 65, "total": 120 },
        { "name": "Progression", "unlocked": 18, "total": 25 },
        { "name": "Combat", "unlocked": 22, "total": 30 },
        { "name": "Collection", "unlocked": 12, "total": 20 },
        { "name": "Economy", "unlocked": 8, "total": 15 },
        { "name": "Social", "unlocked": 3, "total": 15 },
        { "name": "Challenge", "unlocked": 0, "total": 10 },
        { "name": "Secret", "unlocked": 2, "total": 15 },
    ]

    for cat in categories:
        var item = category_tree.create_item(root)
        item.set_text(0, "%s (%d/%d)" % [cat.name, cat.unlocked, cat.total])
        item.set_metadata(0, cat.name)

func load_achievements(category: String):
    achievement_list.clear()

    var achievements = AchievementService.get_achievements_by_category(category)

    for achievement in achievements:
        var card = ACHIEVEMENT_CARD_SCENE.instantiate()
        card.set_achievement(achievement)
        achievement_list.add_child(card)

func update_progress():
    var unlocked = PlayerProgress.get_unlocked_achievement_count()
    var total = AchievementDatabase.get_total_count()
    var percent = float(unlocked) / total

    progress_label.text = "Progress: %d/%d (%.0f%%)" % [unlocked, total, percent * 100]
    progress_bar.value = percent
```

---

### Achievement Card Component

**Visual**:
```
┌─────────────────────────────────────────────────┐
│ 🥇 ELITE (Gold)                         ✓       │
│ Reach Wave 30                                   │
│                                                 │
│ Unlocked: March 15, 2025                        │
│ Rewards: 1,500 scrap, "Elite" title, Gold      │
│          border                                 │
│                                                 │
│ [Equip Title] [View Cosmetics]                  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ 🥈 BOSS SLAYER (Silver)                 🔒      │
│ Defeat 10 bosses                                │
│                                                 │
│ Progress: ██████████░ 9/10                      │
│                                                 │
│ Rewards: 200 scrap                              │
│                                                 │
│ Almost there!                                   │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ ❓ ??? (Secret)                          🔒      │
│ ???                                             │
│                                                 │
│ This achievement is secret!                     │
│ Unlock it to reveal details.                    │
└─────────────────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/AchievementCard.gd
extends PanelContainer

@onready var tier_icon = $HBox/TierIcon
@onready var title_label = $HBox/VBox/Title
@onready var description = $HBox/VBox/Description
@onready var progress_bar = $HBox/VBox/ProgressBar
@onready var rewards_label = $HBox/VBox/Rewards
@onready var actions = $HBox/VBox/Actions
@onready var lock_icon = $HBox/LockIcon

var achievement: Achievement

func set_achievement(new_achievement: Achievement):
    achievement = new_achievement

    # Check if unlocked
    var unlocked = PlayerProgress.is_achievement_unlocked(achievement.id)

    if unlocked:
        show_unlocked()
    elif achievement.is_secret:
        show_secret()
    else:
        show_locked()

func show_unlocked():
    tier_icon.texture = get_tier_icon(achievement.tier)
    title_label.text = "%s (%s)" % [achievement.name, get_tier_name(achievement.tier)]
    description.text = achievement.description

    var unlock_date = PlayerProgress.get_achievement_unlock_date(achievement.id)
    rewards_label.text = "Unlocked: %s\nRewards: %s" % [
        unlock_date,
        format_rewards(achievement)
    ]

    lock_icon.hide()
    progress_bar.hide()

    # Show action buttons
    if achievement.title_reward != "":
        var equip_button = Button.new()
        equip_button.text = "Equip Title"
        equip_button.pressed.connect(func(): PlayerProfile.equip_title(achievement.title_reward))
        actions.add_child(equip_button)

func show_locked():
    tier_icon.texture = get_tier_icon(achievement.tier, true)  # Grayed out
    title_label.text = "%s (%s)" % [achievement.name, get_tier_name(achievement.tier)]
    description.text = achievement.description

    # Show progress
    var current = AchievementService.get_progress(achievement.id)
    var required = achievement.requirement_value
    var percent = float(current) / required

    progress_bar.value = percent
    progress_bar.show()

    rewards_label.text = "Rewards: %s" % format_rewards(achievement)

    lock_icon.show()
    actions.hide()

func show_secret():
    tier_icon.texture = load("res://assets/ui/icons/secret.png")
    title_label.text = "??? (Secret)"
    description.text = "???"

    rewards_label.text = "This achievement is secret!\nUnlock it to reveal details."

    lock_icon.show()
    progress_bar.hide()
    actions.hide()
```

---

### Profile Showcase

**Visual**:
```
┌────────────────────────────────────────────┐
│  [Immortal] PlayerName #1234               │
│  Level 87 | Premium Tier                   │
│                                            │
│  Showcase Achievements:                    │
│  🏆 Immortal (Platinum)                    │
│  🏆 Completionist (Platinum)               │
│  🏆 Community Leader (Platinum)            │
│                                            │
│  Achievement Progress: 118/120 (98%)       │
│                                            │
│  [View Full Achievements]                  │
└────────────────────────────────────────────┘
```

**Implementation**:
```gdscript
# UI/ProfileShowcase.gd
extends VBoxContainer

func _ready():
    display_showcase_achievements()

func display_showcase_achievements():
    var showcase = PlayerProfile.get_showcase_achievements()  # Returns array of 1-3 achievement IDs

    for achievement_id in showcase:
        var achievement = AchievementDatabase.get(achievement_id)
        var label = Label.new()
        label.text = "🏆 %s (%s)" % [achievement.name, get_tier_name(achievement.tier)]
        add_child(label)
```

**User Can Choose**: Players select which achievements to showcase in profile settings.

---

## Social Integration

Achievements integrate with social features to create sharing moments and community engagement.

### Trading Card Integration

**Feature**: When creating a trading card, automatically suggest showcasing recent achievements.

**Implementation**:
```gdscript
# When creating trading card
func create_trading_card(character: Character):
    var card = TradingCard.new(character)

    # Add recent achievements to card
    var recent_achievements = AchievementService.get_recently_unlocked(limit = 3)
    for achievement in recent_achievements:
        card.add_badge(achievement.name, achievement.tier_icon)

    return card
```

**Visual on Card**:
```
┌─────────────────────────────┐
│  [Character Image]          │
│  Character Name             │
│  Wave 32 | 4,200 scrap      │
│                             │
│  Recent Achievements:       │
│  🥇 Elite                   │
│  🥈 Boss Slayer             │
│  🥉 Centurion               │
│                             │
│  PlayerName #1234           │
└─────────────────────────────┘
```

---

### Leaderboards

**Feature**: Global and friend leaderboards for achievement completion.

**Categories**:
1. **Total Achievements**: Who has the most achievements unlocked
2. **Category Leaders**: Top players in each category (Combat, Collection, etc.)
3. **Platinum Hunters**: Who has the most Platinum achievements
4. **Recent Unlocks**: Who unlocked the most achievements this week
5. **Rarest Achievements**: Leaderboard for each rare achievement (who unlocked first, fastest, etc.)

**Implementation**:
```sql
-- Leaderboard query
SELECT
    user_id,
    COUNT(*) as total_achievements,
    SUM(CASE WHEN tier = 'platinum' THEN 1 ELSE 0 END) as platinum_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) as rank
FROM user_achievements
GROUP BY user_id
ORDER BY total_achievements DESC
LIMIT 100;
```

---

### Referral Integration

**Feature**: Show achievement progress to referred friends to motivate sign-ups.

**Implementation**:
```gdscript
# Referral link includes achievement showcase
func generate_referral_link() -> String:
    var user_id = UserService.get_current_user_id()
    var top_achievements = AchievementService.get_top_achievements(limit = 3)

    var link = "https://scrapsurvivorgame.com/join?ref=%s" % user_id
    link += "&achievements=%s" % JSON.stringify(top_achievements.map(func(a): return a.id))

    return link
```

**Referral Landing Page**:
```
Your friend PlayerName has unlocked:
🏆 Immortal (Platinum) - Reached Wave 150
🏆 Completionist (Platinum) - Unlocked all items
🏆 Community Leader (Platinum) - Referred 100 friends

Join now and start your own achievement journey!
[Sign Up]
```

---

### Community Events

**Feature**: Community-wide achievement challenges.

**Example**:
```
🎉 COMMUNITY CHALLENGE: Centurion Week

Goal: Community unlocks "Centurion" achievement 10,000 times

Progress: ███████░░░ 7,342 / 10,000 (73%)

Reward: Everyone who participates gets bonus 500 scrap

Time Remaining: 3 days

[Participate Now]
```

**Implementation**: Track achievement unlocks during event period, grant rewards when milestone reached.

---

## Technical Architecture

### Achievement Service

```gdscript
# services/AchievementService.gd
class_name AchievementService
extends Node

signal achievement_unlocked(achievement: Achievement)
signal achievement_progress_updated(achievement_id: String, progress: int)

var unlocked_achievements: Array[String] = []
var achievement_progress: Dictionary = {}

func _ready():
    load_player_progress()
    connect_to_game_events()

func connect_to_game_events():
    # Connect to various game events that trigger achievements
    GameStateService.wave_completed.connect(_on_wave_completed)
    GameStateService.character_died.connect(_on_character_died)
    GameStateService.enemy_killed.connect(_on_enemy_killed)
    GameStateService.boss_defeated.connect(_on_boss_defeated)
    ItemService.item_unlocked.connect(_on_item_unlocked)
    CharacterService.character_unlocked.connect(_on_character_unlocked)
    CurrencyService.scrap_earned.connect(_on_scrap_earned)
    ReferralService.referral_completed.connect(_on_referral_completed)
    ShopService.item_purchased.connect(_on_item_purchased)

func _on_wave_completed(wave: int):
    check_achievement("wave_10", wave >= 10)
    check_achievement("wave_20", wave >= 20)
    check_achievement("wave_30", wave >= 30)
    # ... etc

func _on_enemy_killed(enemy: Enemy):
    increment_achievement("total_kills", 1)
    increment_achievement("run_kills", 1)

func check_achievement(achievement_id: String, condition: bool):
    if condition and not is_unlocked(achievement_id):
        unlock_achievement(achievement_id)

func increment_achievement(achievement_id: String, amount: int):
    if is_unlocked(achievement_id):
        return  # Already unlocked

    var achievement = AchievementDatabase.get(achievement_id)
    var current = achievement_progress.get(achievement_id, 0)
    current += amount
    achievement_progress[achievement_id] = current

    # Emit progress update
    emit_signal("achievement_progress_updated", achievement_id, current)

    # Check if requirement met
    if current >= achievement.requirement_value:
        unlock_achievement(achievement_id)

func unlock_achievement(achievement_id: String):
    var achievement = AchievementDatabase.get(achievement_id)

    # Check tier requirement
    if UserService.get_user_tier() < achievement.unlock_tier_requirement:
        return  # Can't unlock yet

    # Mark as unlocked
    unlocked_achievements.append(achievement_id)

    # Grant rewards
    grant_rewards(achievement)

    # Save progress
    save_achievement_unlock(achievement_id)

    # Show notification
    AchievementNotificationUI.show(achievement)

    # Emit signal
    emit_signal("achievement_unlocked", achievement)

    # Track analytics
    AnalyticsService.track_achievement_unlocked(achievement_id)

func grant_rewards(achievement: Achievement):
    # Scrap (with Subscription bonus)
    var scrap = achievement.scrap_reward
    if UserService.is_subscriber():
        scrap = int(scrap * 1.5)  # 50% bonus

    CurrencyService.add_scrap(scrap, "achievement_%s" % achievement.id)

    # Title
    if achievement.title_reward != "":
        PlayerProfile.unlock_title(achievement.title_reward)

    # Cosmetics
    for cosmetic_id in achievement.cosmetic_rewards:
        CosmeticService.unlock(cosmetic_id)

    # Perk
    if achievement.perk_unlock != "":
        PerkService.unlock_perk(achievement.perk_unlock)

func is_unlocked(achievement_id: String) -> bool:
    return achievement_id in unlocked_achievements

func get_progress(achievement_id: String) -> int:
    return achievement_progress.get(achievement_id, 0)

func get_unlocked_count() -> int:
    return unlocked_achievements.size()

func get_category_progress(category: AchievementCategory) -> Dictionary:
    var total = AchievementDatabase.get_count_by_category(category)
    var unlocked = 0

    for achievement_id in unlocked_achievements:
        var achievement = AchievementDatabase.get(achievement_id)
        if achievement.category == category:
            unlocked += 1

    return {
        "unlocked": unlocked,
        "total": total,
        "percent": float(unlocked) / total
    }

func get_recently_unlocked(limit: int = 10) -> Array[Achievement]:
    # Sort by unlock date, return most recent
    var recent = unlocked_achievements.slice(-limit, unlocked_achievements.size())
    return recent.map(func(id): return AchievementDatabase.get(id))

func get_showcase_achievements() -> Array[String]:
    return PlayerProfile.get_showcase_achievement_ids()

func set_showcase_achievements(achievement_ids: Array[String]):
    PlayerProfile.set_showcase_achievements(achievement_ids)
```

---

### Database Schema

```sql
-- Achievement definitions (static data, could be JSON instead)
CREATE TABLE achievement_templates (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(20) NOT NULL,
  tier VARCHAR(20) NOT NULL,
  is_secret BOOLEAN DEFAULT false,

  -- Requirements
  requirement_type VARCHAR(30) NOT NULL,
  requirement_value INT NOT NULL,
  requirement_data JSONB,

  -- Rewards
  scrap_reward INT DEFAULT 0,
  title_reward VARCHAR(50),
  cosmetic_rewards JSONB,
  perk_unlock VARCHAR(50),

  -- Access control
  unlock_tier_requirement VARCHAR(20) DEFAULT 'free',

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Player achievement progress
CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  achievement_id VARCHAR(50) REFERENCES achievement_templates(id) NOT NULL,

  -- Progress tracking
  current_progress INT DEFAULT 0,
  unlocked BOOLEAN DEFAULT false,
  unlocked_at TIMESTAMPTZ,

  -- Rewards claimed
  rewards_claimed BOOLEAN DEFAULT false,
  claimed_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, achievement_id)
);

-- Achievement showcase (profile display)
CREATE TABLE user_achievement_showcase (
  user_id UUID PRIMARY KEY REFERENCES user_accounts(id),
  achievement_1_id VARCHAR(50) REFERENCES achievement_templates(id),
  achievement_2_id VARCHAR(50) REFERENCES achievement_templates(id),
  achievement_3_id VARCHAR(50) REFERENCES achievement_templates(id),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Analytics: Track achievement unlock rates
CREATE TABLE achievement_analytics (
  achievement_id VARCHAR(50) REFERENCES achievement_templates(id),
  date DATE NOT NULL,
  unlock_count INT DEFAULT 0,
  total_players_eligible INT DEFAULT 0,
  unlock_rate FLOAT GENERATED ALWAYS AS (
    CASE
      WHEN total_players_eligible > 0
      THEN unlock_count::FLOAT / total_players_eligible
      ELSE 0
    END
  ) STORED,

  PRIMARY KEY (achievement_id, date)
);
```

---

## Implementation Strategy

### Phase 1: Core Infrastructure (Week 14 Day 1-2) - 2 days

**Goal**: Build achievement tracking foundation.

**Tasks**:
1. Create AchievementService with unlock/progress tracking
2. Implement Achievement data model
3. Create AchievementDatabase (JSON or database)
4. Define all 120+ achievements in data
5. Connect to basic game events (wave completed, kills, etc.)
6. Implement scrap rewards

**Deliverables**:
- AchievementService (300 lines)
- Achievement model (100 lines)
- achievement_data.json (500+ lines)
- Basic event connections (150 lines)

**Testing**:
- Manually trigger achievements
- Verify progress tracking works
- Test scrap rewards granted correctly

---

### Phase 2: Reward System (Week 14 Day 3) - 1 day

**Goal**: Implement all reward types.

**Tasks**:
1. Build title system (unlock, equip, display)
2. Create cosmetic unlock system
3. Implement perk unlock rewards
4. Build profile showcase system

**Deliverables**:
- TitleService (150 lines)
- CosmeticService (200 lines)
- Profile showcase UI (100 lines)

**Testing**:
- Unlock title, equip, verify displays on profile
- Unlock cosmetic, verify available in customization
- Test showcase updates correctly

---

### Phase 3: UI Implementation (Week 14 Day 4-5) - 2 days

**Goal**: Create all achievement UI.

**Tasks**:
1. Build achievement notification popup
2. Create achievement panel with categories
3. Implement achievement card component
4. Add progress bars and tracking UI
5. Create profile showcase display
6. Implement secret achievement masking

**Deliverables**:
- AchievementNotification (150 lines)
- AchievementPanel (300 lines)
- AchievementCard (200 lines)
- Profile showcase (100 lines)

**Testing**:
- Trigger achievement, verify notification shows
- Browse achievement panel, verify filtering works
- Test progress bars update in real-time
- Verify secret achievements hidden correctly

---

### Phase 4: Tier Differentiation (Week 15 Day 1) - 1 day

**Goal**: Implement tier-specific achievements and bonuses.

**Tasks**:
1. Add tier requirement checking to unlocks
2. Implement Subscription 50% scrap bonus
3. Create Premium/Subscription exclusive achievements
4. Build tier comparison in achievement panel
5. Add upsell messaging for locked achievements

**Deliverables**:
- Tier gating logic (50 lines)
- Subscription bonus system (30 lines)
- Exclusive achievements (10 new achievements)
- Upsell UI (80 lines)

**Testing**:
- Test with Free account (verify some achievements locked)
- Test with Premium (verify access increases)
- Test with Subscription (verify scrap bonus, all access)

---

### Phase 5: Social Integration (Week 15 Day 2) - 1 day

**Goal**: Connect achievements to social features.

**Tasks**:
1. Add achievements to trading cards
2. Implement achievement leaderboards
3. Build referral link with achievement showcase
4. Create community challenge system

**Deliverables**:
- Trading card achievement badges (50 lines)
- Leaderboard queries & UI (200 lines)
- Referral showcase (100 lines)
- Community challenge (150 lines)

**Testing**:
- Create trading card, verify achievements shown
- Check leaderboard accuracy
- Test referral link includes achievements

---

### Phase 6: Database & Persistence (Week 15 Day 3) - 1 day

**Goal**: Implement full persistence and analytics.

**Tasks**:
1. Create Supabase tables
2. Implement save/load for achievement progress
3. Build analytics tracking
4. Create developer dashboard for achievement stats
5. Implement cross-device sync

**Deliverables**:
- Supabase migration scripts
- Save/load system (150 lines)
- Analytics queries (100 lines)
- Developer dashboard (web interface)

**Testing**:
- Unlock achievement, restart game, verify persists
- Test cross-device sync (unlock on one device, shows on another)
- Verify analytics dashboard shows correct stats

---

### Phase 7: Content & Polish (Week 15 Day 4) - 1 day

**Goal**: Finalize content and polish UX.

**Tasks**:
1. Write descriptions for all 120+ achievements
2. Create icons/graphics for all tiers
3. Implement sound effects (unlock, progress milestone)
4. Add achievement unlock animations
5. Create "almost there!" motivational messaging
6. Final QA pass

**Deliverables**:
- All achievement descriptions
- Tier icons and graphics
- Sound effects (5 sfx)
- Animations
- Polish (50+ small improvements)

**Testing**:
- Full playthrough unlocking various achievements
- Verify all descriptions clear and motivating
- Test animations and sound feel good
- User testing for clarity and motivation

---

### Timeline Summary

| Phase | Duration | Effort | Dependencies |
|-------|----------|--------|--------------|
| 1. Core Infrastructure | 2 days | 12 hours | None |
| 2. Reward System | 1 day | 8 hours | Phase 1 |
| 3. UI Implementation | 2 days | 12 hours | Phase 1-2 |
| 4. Tier Differentiation | 1 day | 6 hours | UserService, SubscriptionService |
| 5. Social Integration | 1 day | 6 hours | TradingCards, ReferralService |
| 6. Database & Persistence | 1 day | 6 hours | SupabaseService |
| 7. Content & Polish | 1 day | 6 hours | All previous |
| **Total** | **9 days** | **~56 hours** | - |

---

## Balancing Considerations

### Reward Scaling

**Problem**: Rewards must feel meaningful but not break economy.

**Solution**:
- Total scrap from all achievements: ~150,000
- This equals ~50-75 hours of normal gameplay scrap earnings
- Enough to feel generous, not enough to skip progression entirely

**Test**: Complete all achievements, verify player still needs to play game normally for further progression.

---

### Difficulty Curve

**Problem**: Achievements too easy = meaningless, too hard = frustrating.

**Solution**:
- **Bronze**: 80% of players should unlock within first 10 hours
- **Silver**: 50% of players should unlock within 30 hours
- **Gold**: 20% of players should unlock within 100 hours
- **Platinum**: 5% of players should unlock (elite achievements)

**Metrics to Track**:
- Unlock rate per achievement (% of players who unlocked)
- Average time to unlock
- Abandonment rate (players who gave up chasing achievement)

**Adjustment Process**:
- Quarterly review achievement unlock rates
- Reduce requirements for <10% unlock rate achievements (too hard)
- Increase requirements for >90% unlock rate achievements (too easy)

---

### Grind vs Skill Balance

**Problem**: Pure grind achievements feel unrewarding.

**Solution**:
- 60% of achievements require skill or strategy
- 40% of achievements are progression/grind based
- All grind achievements are progressive (small milestones along the way)

**Example of Good Balance**:
```
✅ "Centurion" - Kill 100 enemies in single run (skill: survival)
✅ "Flawless Victory" - Defeat boss without damage (skill: precision)
✅ "Wave Master" - Reach Wave 30 (progression: time investment)
✅ "Collector" - Unlock 50 items (grind: completionist, but rewarding)
```

---

### Secret Achievement Fairness

**Problem**: Completely obscure secrets feel unfair.

**Solution**:
- **Discoverable Secrets**: Clear hints available in-game
  - Example: "Pacifist" achievement - game mentions "you survived without killing" after the fact
- **Community Collaboration**: Expect players to share secrets online
- **Hint System**: After 100+ hours, game can offer hints for missing secret achievements

**No Pure Luck**: No achievements require pure RNG (e.g., "Get 10 legendary drops in a row")

---

### Tier Access Philosophy

**Problem**: Gating too many achievements behind paywall feels unfair.

**Solution**:
- Free tier: 80% of achievements (enough to feel complete)
- Premium: 95% of achievements (completionist territory)
- Subscription: 100% + bonuses (ultimate bragging rights)

**Rule**: Never gate Bronze/Silver achievements behind paywall. Only Gold/Platinum can be exclusive.

---

## Open Questions & Future Enhancements

### Open Questions

1. **Should achievements reset per season/wipe?**
   - Pro: Creates fresh competition
   - Con: Players lose progress, feels bad
   - Possible: Track "legacy" achievements separately from "current season"

2. **Should there be account-wide vs character-specific achievements?**
   - Most achievements: Account-wide (cumulative progress)
   - Some achievements: Character-specific ("Reach Wave 30 with Tank Thompson")
   - Need to clarify in UI which is which

3. **How to handle retroactive achievements?**
   - If we add new achievements, should we grant them to players who already met requirements?
   - Pro: Fair to veteran players
   - Con: Cheap unlock, no "chase" for veterans
   - Possible: Retroactive for progression achievements only, not skill challenges

4. **Should we allow achievement "re-locking" for challenge?**
   - Some players want to re-do achievements
   - Could offer "Prestige" mode that resets achievements for bonus rewards

5. **How to prevent achievement farming/exploitation?**
   - Rate limiting (max X achievements per hour)
   - Anomaly detection (impossible to unlock 50 achievements in 1 minute)
   - Manual review flags (admin dashboard)

6. **Should friends' recent achievements be visible?**
   - Social feed showing "PlayerName unlocked Elite!"
   - Could drive FOMO and engagement
   - Risk: Privacy concerns

---

### Future Enhancements

#### 1. Daily/Weekly Achievements (Post-MVP)

**Concept**: Rotating achievements that refresh daily/weekly.

**Example**:
```
Daily Challenge: "Kill 200 enemies today"
Reward: 100 scrap

Weekly Challenge: "Reach Wave 25 this week"
Reward: 500 scrap
```

**Business Logic**: Drives daily engagement, login retention.

---

#### 2. Community Achievements (Post-MVP)

**Concept**: Achievements requiring community collaboration.

**Example**:
```
Community Goal: "Kill 1,000,000 enemies as a community this week"
Progress: 742,523 / 1,000,000 (74%)
Reward: Everyone who participated gets 500 scrap + exclusive badge
```

**Implementation**: Track global stats, grant rewards when milestone reached.

---

#### 3. Achievement Chains (Post-MVP)

**Concept**: Achievements that unlock others (quest chains).

**Example**:
```
1. "Wave Walker" - Reach Wave 10
   ↓
2. "Wave Runner" - Reach Wave 20 (unlocked after Wave Walker)
   ↓
3. "Wave Champion" - Reach Wave 30 (unlocked after Wave Runner)
```

**UI**: Show chain progression visually.

---

#### 4. Rarity-Based Bragging Rights (Post-MVP)

**Concept**: Dynamically adjust achievement value based on unlock rate.

**Example**:
```
"Deathless" achievement unlocked by only 2% of players
→ Display: "Rarity: 2% (Ultra Rare)"
→ Grant special "Ultra Rare" badge
```

**Implementation**: Query database for unlock rates, categorize achievements.

---

#### 5. Achievement Milestones (Post-MVP)

**Concept**: Meta-achievements for unlocking X achievements.

**Example**:
```
"Achievement Hunter" - Unlock 25 achievements (Bronze)
"Achievement Master" - Unlock 50 achievements (Silver)
"Achievement God" - Unlock 100 achievements (Gold)
"True Completionist" - Unlock all 120 achievements (Platinum)
```

---

#### 6. Trading Card Gallery Achievements (Post-MVP)

**Concept**: Achievements for collecting trading cards from others.

**Example**:
```
"Card Collector" - Receive 50 trading cards from other players
"Fan Favorite" - Your cards viewed 1,000 times
"Trading Master" - Exchange 20 cards with friends
```

---

#### 7. Seasonal Prestige System (Post-MVP)

**Concept**: Reset achievements seasonally for prestige rewards.

**Example**:
```
Season 1: Complete all achievements → Unlock "Season 1 Champion" legacy badge
Season 2: Achievements reset, chase again for "Season 2 Champion"
```

**Retention**: Gives veteran players reason to continue engagement.

---

## Summary

The **Achievements System** provides structured progression goals that reward players for accomplishments across combat, collection, social engagement, and exploration. With 120+ achievements across 7 categories and 4 difficulty tiers, the system ensures all player types (achievers, collectors, socializers, explorers) have meaningful goals to pursue.

### Key Features

1. **120+ Achievements**: Comprehensive coverage across Progression (25), Combat (30), Collection (20), Economy (15), Social (15), Challenge (10), Secret (15)
2. **Progressive Tiers**: Bronze → Silver → Gold → Platinum with increasing difficulty and rewards
3. **Tangible Rewards**: Every achievement grants scrap (100-5,000), plus titles, cosmetics, or perk unlocks
4. **Tier Differentiation**: Free (80% access), Premium (95% access), Subscription (100% + 50% scrap bonus)
5. **Social Integration**: Achievement showcase on profile, trading card badges, leaderboards, referral links
6. **Real-Time Progress**: Visible progress bars and milestone notifications for non-secret achievements

### Technical Architecture

- **AchievementService**: Central service managing unlocks, progress tracking, rewards
- **Database Schema**: Supabase tables for achievement definitions, user progress, showcase, analytics
- **Event-Driven**: Connects to 15+ game events (wave completed, kills, unlocks, purchases)
- **Reward System**: Automatic scrap, title, cosmetic, and perk granting upon unlock

### Implementation Timeline

- **Phase 1-2** (3 days): Core infrastructure + reward system
- **Phase 3-4** (3 days): UI implementation + tier differentiation
- **Phase 5-7** (3 days): Social integration + database + content/polish
- **Total**: ~9 days / ~56 hours

### Success Metrics

- **Engagement**: 70%+ of players unlock at least 10 achievements in first month
- **Completion Rate**: 20% of players chase 50+ achievements (completionist segment)
- **Social Sharing**: 30%+ of achievement unlocks result in trading card creation or social share
- **Retention**: Players actively pursuing achievements have 20%+ higher 30-day retention
- **Monetization**: Achievement exclusivity drives 5-10% of Premium/Subscription upgrades

### Business Value

The Achievements System increases engagement, retention, and monetization by:
- **Extending Session Length**: "Just one more achievement" psychology
- **Guiding Feature Adoption**: Achievements direct players to try all features (Black Market, Trading Cards, Events)
- **Creating Viral Moments**: Rare achievement unlocks shared on social media
- **Driving Upgrades**: Exclusive achievements for Premium/Subscription create FOMO
- **Building Community**: Leaderboards, showcase profiles, community challenges

By balancing skill challenges, progression milestones, and exploration rewards with generous scrap payouts and exclusive cosmetics, the Achievements System becomes a core engagement driver that motivates all player types.
