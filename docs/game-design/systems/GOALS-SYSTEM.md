# Goals System

**Status:** MID-TERM - Implement after core loop stable
**Tier Access:** All tiers (scaled by tier)
**Implementation Phase:** Weeks 12-14 (retention/engagement)
**Internal Tool Required:** Goal Builder/Scheduler

---

## 1. System Overview

The Goals System provides **daily, weekly, and monthly quests** to drive engagement and retention. Goals reward players for completing specific activities (login, combat, crafting, etc.) and create recurring content without new development.

**Key Features:**
- Daily login bonuses
- Daily/weekly/monthly quests
- Personalized goals (Subscription)
- Operator-managed (internal tool)
- Tier-scaled rewards and frequency

---

## 2. Core Concepts

### 2.1 What is a Goal?

A **goal** is a task players complete for rewards.

**Example Goals:**
- "Log in 3 days in a row" → Reward: 500 scrap
- "Kill 100 enemies in The Wasteland" → Reward: 1000 scrap + 50 components
- "Reach wave 20 with Scavenger" → Reward: Rare weapon blueprint
- "Fuse 5 weapons in Workshop" → Reward: 200 components

### 2.2 Goal Properties

```gdscript
class Goal:
    var id: String                  # Unique goal ID
    var name: String                # Display name
    var description: String         # Task description
    var type: String                # "daily", "weekly", "monthly", "login"
    var frequency: String           # "daily", "weekly", "monthly", "once"
    var target_tier: int            # Minimum tier (0=Free, 1=Premium, 2=Sub)
    var target_criteria: Dictionary # Region, character type, etc.
    var requirements: Dictionary    # Task requirements
    var progress: int = 0           # Current progress
    var progress_max: int           # Required progress
    var rewards: Dictionary         # Rewards on completion
    var is_active: bool             # Currently active
    var expires_at: String          # Expiration timestamp
    var completed_at: String        # Completion timestamp (null if not complete)
    var created_at: String          # Creation timestamp
```

### 2.3 Goal Types

| Type | Frequency | Duration | Example |
|------|-----------|----------|---------|
| **Login** | Daily | Permanent | "Log in today" |
| **Daily** | Daily | 24 hours | "Kill 50 enemies" |
| **Weekly** | Weekly | 7 days | "Reach wave 15" |
| **Monthly** | Monthly | 30 days | "Craft 10 weapons" |
| **Streak** | Daily | Ongoing | "Log in 7 days in a row" |
| **Seasonal** | Special | Limited | "Halloween: Kill 200 zombies" |

---

## 3. Tier-Specific Goals

### 3.1 Free Tier

**Access:**
- Daily login bonuses (basic rewards)
- Random infrequent goals (2-3x per week)
- Holiday-related goals (Halloween, Christmas, etc.)

**Reward Scale:** Low (100-500 scrap, 10-25 components)

**Example Free Goals:**
- "Log in today" → 100 scrap
- "Kill 25 enemies" → 250 scrap
- "Reach wave 5" → 500 scrap + 25 components
- "Halloween: Survive 13 waves" → Rare weapon

**Purpose:** Drive retention, encourage upgrades to Premium

### 3.2 Premium Tier

**Access:**
- Daily login bonuses (better rewards)
- Daily goals (1-2 per day)
- Weekly goals (3-5 per week)
- All Free tier goals

**Reward Scale:** Medium (500-2000 scrap, 50-100 components)

**Example Premium Goals:**
- "Log in today" → 500 scrap
- "Kill 100 enemies" → 1000 scrap + 50 components
- "Fuse 3 weapons" → 1500 scrap + 75 components
- "Reach wave 15" → Epic weapon + 100 components

**Purpose:** Daily engagement, reward investment in Premium

### 3.3 Subscription Tier

**Access:**
- All Premium tier goals
- Monthly goals (beginning and end of month)
- **Personalized goals** (uses Personalization System)

**Reward Scale:** High (2000-5000 scrap, 100-250 components, rare items)

**Example Subscription Goals:**
- "Log in today" → 1000 scrap
- "Weekly: Reach wave 20" → 3000 scrap + 150 components
- **"Monthly: Your Scavenger reaches wave 25"** (personalized) → Legendary weapon
- "End of month: Complete 30 daily goals" → 5000 scrap + 250 components + Epic minion

**Purpose:** Justify subscription cost, create FOMO for non-subscribers

---

## 4. Goal Tracking

### 4.1 Progress Tracking

Goals track progress via **event hooks:**

```gdscript
# Hook into game events
signal enemy_killed(enemy_id: String, character_id: String)
signal wave_completed(character_id: String, wave_number: int)
signal item_crafted(character_id: String, item_id: String)
signal weapon_fused(character_id: String, weapon_id: String)
signal login_recorded(user_id: String)

# Update goal progress
func _on_enemy_killed(enemy_id: String, character_id: String):
    var active_goals = get_active_goals_for_user(current_user_id)
    for goal in active_goals:
        if goal.type == "kill_enemies":
            goal.progress += 1
            if goal.progress >= goal.progress_max:
                complete_goal(goal)
```

### 4.2 Goal Completion

When a goal is completed:
1. Mark goal as completed
2. Award rewards to user
3. Emit `goal_completed` signal
4. Show completion UI (toast, modal)
5. Log analytics event

```gdscript
func complete_goal(goal: Goal):
    goal.completed_at = Time.get_datetime_string_from_system()

    # Award rewards
    var character = CharacterService.get_active_character()
    if "scrap" in goal.rewards:
        character.currency += goal.rewards.scrap
    if "components" in goal.rewards:
        character.workshop_components += goal.rewards.components
    if "items" in goal.rewards:
        for item_id in goal.rewards.items:
            InventoryService.add_item(character.id, item_id)

    # Save
    await GoalsService.save_goal(goal)
    await CharacterService.update_character(character)

    # Notify
    goal_completed.emit(goal)

    # Analytics
    AnalyticsService.track_event("goal_completed", {
        "goal_id": goal.id,
        "goal_type": goal.type,
        "rewards": goal.rewards
    })
```

### 4.3 Goal Expiration

Goals expire automatically:
- Daily goals: 24 hours after creation
- Weekly goals: 7 days after creation
- Monthly goals: 30 days after creation

```gdscript
func check_expired_goals():
    var active_goals = get_active_goals_for_user(current_user_id)
    var now = Time.get_unix_time_from_system()

    for goal in active_goals:
        var expires_at = Time.get_unix_time_from_datetime_string(goal.expires_at)
        if now >= expires_at and not goal.completed_at:
            expire_goal(goal)

func expire_goal(goal: Goal):
    goal.is_active = false
    await GoalsService.save_goal(goal)
    goal_expired.emit(goal)
```

---

## 5. Personalized Goals (Subscription)

### 5.1 How Personalization Works

Subscription users get **personalized goals** based on their **Personalization System** profile.

**Example:**
```gdscript
# User's personalization profile
var profile = {
    "favorite_character_type": "scavenger",
    "preferred_playstyle": "ranged_dps",
    "high_score_wave": 18
}

# Generate personalized goal
func generate_personalized_goal(profile: Dictionary) -> Goal:
    var goal = Goal.new()
    goal.name = "Scavenger Specialist"
    goal.description = "Reach wave " + str(profile.high_score_wave + 2) + " with your Scavenger"
    goal.requirements = {
        "wave_number": profile.high_score_wave + 2,
        "character_type": profile.favorite_character_type
    }
    goal.rewards = {
        "scrap": 5000,
        "components": 250,
        "items": ["legendary_ranged_weapon"]  # Tailored to playstyle
    }
    goal.frequency = "monthly"
    goal.target_tier = 2  # Subscription only
    return goal
```

### 5.2 Personalization Integration

**Beginning of month:** Generate personalized goal
**End of month:** Generate summary/achievement goal

**Example Monthly Cycle:**
- **Day 1:** "Personalized: Your Scavenger reaches wave 20" (based on profile)
- **Day 30:** "Complete 25 daily goals this month" (meta-goal)

---

## 6. Internal Goal Management Tool

### 6.1 Goal Builder

The operator needs a tool to create goals without code:

**Features:**
- Goal template library (kill enemies, reach wave, craft items, etc.)
- Target criteria builder (tier, region, date range)
- Reward editor (scrap, components, items, blueprints)
- Frequency selector (daily, weekly, monthly, once)
- Preview mode (test goal before activation)
- Scheduling (activate at specific date/time)

**Example Goal Creation Flow:**
1. Select template: "Kill Enemies"
2. Configure: 100 enemies
3. Set rewards: 1000 scrap + 50 components
4. Set frequency: Daily
5. Set tier: Premium
6. Set duration: Nov 1 - Nov 30 (November goals)
7. Preview & Test
8. Schedule activation

### 6.2 Goal Scheduler

**Features:**
- Calendar view (see all scheduled goals)
- Activate/deactivate goals
- Clone goals (quick iteration)
- Bulk operations (create month of daily goals at once)

**Example Bulk Creation:**
- Create 30 daily goals for November
- Randomize rewards (keep players engaged)
- Alternate between combat, crafting, progression goals

### 6.3 Goal Analytics

**Metrics to track:**
- Goal completion rate (% of users who complete)
- Time to complete (average duration)
- Reward distribution (how much scrap/components given out)
- Engagement impact (session length, retention)

---

## 7. Login Streaks

### 7.1 Streak Tracking

Track consecutive daily logins:

```gdscript
class LoginStreak:
    var user_id: String
    var current_streak: int = 0
    var longest_streak: int = 0
    var last_login: String  # Date only (YYYY-MM-DD)

func record_login(user_id: String):
    var streak = get_or_create_streak(user_id)
    var today = Time.get_date_string_from_system()
    var yesterday = get_yesterday_date()

    if streak.last_login == yesterday:
        # Consecutive login
        streak.current_streak += 1
        if streak.current_streak > streak.longest_streak:
            streak.longest_streak = streak.current_streak
    elif streak.last_login == today:
        # Already logged in today
        return
    else:
        # Streak broken
        streak.current_streak = 1

    streak.last_login = today
    await save_streak(streak)

    # Award login bonus
    award_login_bonus(user_id, streak.current_streak)
```

### 7.2 Streak Rewards

Reward players for consecutive logins:

```gdscript
func award_login_bonus(user_id: String, streak: int):
    var bonus = calculate_login_bonus(streak)
    var character = CharacterService.get_active_character()
    character.currency += bonus.scrap
    character.workshop_components += bonus.components
    await CharacterService.update_character(character)

func calculate_login_bonus(streak: int) -> Dictionary:
    # Reward scales with streak
    var base_scrap = 100
    var base_components = 10

    return {
        "scrap": base_scrap * streak,
        "components": base_components * streak
    }

# Example rewards:
# Day 1: 100 scrap + 10 components
# Day 2: 200 scrap + 20 components
# Day 7: 700 scrap + 70 components
# Day 30: 3000 scrap + 300 components
```

### 7.3 Streak Milestones

Award bonus rewards at milestones:

```gdscript
var milestone_rewards = {
    7: { "scrap": 5000, "items": ["rare_weapon"] },      # 1 week
    14: { "scrap": 10000, "items": ["epic_weapon"] },    # 2 weeks
    30: { "scrap": 25000, "items": ["legendary_weapon"] } # 1 month
}

func check_milestone_rewards(user_id: String, streak: int):
    if streak in milestone_rewards:
        var rewards = milestone_rewards[streak]
        award_rewards(user_id, rewards)
        show_milestone_modal(streak, rewards)
```

---

## 8. Data Model

### 8.1 Local Storage

```gdscript
class Goal:
    var id: String
    var name: String
    var description: String
    var type: String
    var frequency: String
    var target_tier: int
    var target_criteria: Dictionary
    var requirements: Dictionary
    var progress: int
    var progress_max: int
    var rewards: Dictionary
    var is_active: bool
    var expires_at: String
    var completed_at: String
    var created_at: String

class LoginStreak:
    var user_id: String
    var current_streak: int
    var longest_streak: int
    var last_login: String
```

### 8.2 Supabase Sync

```sql
-- Goals table
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  frequency VARCHAR(50) NOT NULL,
  target_tier INT DEFAULT 0,
  target_criteria JSONB,
  requirements JSONB NOT NULL,
  progress_max INT NOT NULL,
  rewards JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User goals (progress tracking)
CREATE TABLE user_goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  goal_id UUID REFERENCES goals(id) NOT NULL,
  progress INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  completed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, goal_id)
);

-- Login streaks
CREATE TABLE login_streaks (
  user_id UUID PRIMARY KEY REFERENCES user_accounts(id),
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  last_login DATE NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_goals_user_id ON user_goals(user_id);
CREATE INDEX idx_user_goals_active ON user_goals(is_active) WHERE is_active = true;
```

---

## 9. Integration with Other Systems

### 9.1 Personalization System

- Subscription goals use personalization profile
- Tailor goals to favorite character type, playstyle, progress

### 9.2 Perks System

Perks can affect goals:
- "Double goal rewards this week"
- "Complete daily goals 50% faster"
- "Bonus goal: Exclusive perk unlock"

**Hook point:** `goal_completed`, `goal_progress_updated`

### 9.3 Analytics

Track goal engagement:
- Completion rates by tier
- Popular goal types
- Reward distribution
- Impact on retention

---

## 10. Implementation Phases

### Phase 1: Data Model & Tracking (Week 12)
- Create Goal and LoginStreak classes
- Add GoalsService
- Hook into game events (kills, waves, crafting)
- Login streak tracking

### Phase 2: Basic Goals (Week 13)
- Daily login bonuses
- Simple daily goals (kill enemies, reach wave)
- Goal completion UI
- Reward distribution

### Phase 3: Tier-Scaled Goals (Week 14)
- Premium daily/weekly goals
- Subscription monthly goals
- Tier-based reward scaling
- Goal expiration

### Phase 4: Personalization (Week 15+)
- Integrate with Personalization System
- Personalized goal generation
- Monthly personalized goals

### Phase 5: Internal Tools (Post-Launch)
- Goal Builder UI
- Goal Scheduler
- Analytics dashboard

---

## 11. Open Questions

1. **Goal Limits:** How many active goals can a user have at once?
2. **Goal Stacking:** Can multiple goals track the same event (e.g., 2 "kill enemies" goals)?
3. **Missed Streaks:** Should there be a "grace period" to preserve streaks (e.g., 1 missed day allowed)?
4. **Goal Rerolls:** Can users reroll goals they don't want (premium feature)?
5. **Community Goals:** Should there be server-wide goals (e.g., "Community: Kill 1 million enemies")?

---

## 12. Summary

The Goals System provides:
- **Daily/Weekly/Monthly quests** for all tiers (scaled by tier)
- **Login streak bonuses** to drive daily engagement
- **Personalized goals** (Subscription) via Personalization System
- **Internal tool** for operator to create/schedule goals
- **Retention driver** (daily reasons to log in)

**Next Steps:**
1. Create Goal data model (Week 12)
2. Implement GoalsService and tracking
3. Build goal completion UI
4. Design internal goal builder tool

**Status:** Ready for Week 12 implementation planning.
