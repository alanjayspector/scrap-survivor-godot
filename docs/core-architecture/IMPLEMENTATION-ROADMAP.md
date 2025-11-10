# Scrap Survivor: Complete Implementation Roadmap

**Status:** Active Development Plan
**Current Week:** Week 6 (CharacterService in progress)
**Target Launch:** Week 20 (MVP), Week 30 (Full Feature Set)
**Last Updated:** November 9, 2025

---

## Table of Contents

1. [Roadmap Overview](#1-roadmap-overview)
2. [Completed Work (Weeks 1-6)](#2-completed-work-weeks-1-6)
3. [Core Systems Phase (Weeks 7-10)](#3-core-systems-phase-weeks-7-10)
4. [Combat & Content Phase (Weeks 11-13)](#4-combat--content-phase-weeks-11-13)
5. [UI & Polish Phase (Weeks 14-16)](#5-ui--polish-phase-weeks-14-16)
6. [Advanced Systems Phase (Weeks 17-20)](#6-advanced-systems-phase-weeks-17-20)
7. [Post-Launch Features (Weeks 21-30)](#7-post-launch-features-weeks-21-30)
8. [Dependencies & Critical Path](#8-dependencies--critical-path)
9. [Risk Mitigation](#9-risk-mitigation)
10. [Testing Milestones](#10-testing-milestones)

---

## ⚠️ TESTING DOCUMENTATION - READ BEFORE IMPLEMENTING

**CRITICAL**: Before writing ANY code or tests, consult the testing documentation:

📚 **[Testing Documentation Index](../TESTING-INDEX.md)** - Central hub for all testing standards

**Key Documents**:
- [godot-testing-research.md](../godot-testing-research.md) - GUT framework patterns and best practices
- [test-file-template.md](../test-file-template.md) - Template for ALL new test files
- [test-quality-enforcement.md](../test-quality-enforcement.md) - Pre-commit checklist and quality gates

**Quality Requirements**:
- ✅ All tests must verify real functionality (no smoke tests)
- ✅ All tests must use Arrange-Act-Assert pattern
- ✅ All assertions must have clear failure messages
- ✅ Integration tests must use correct payment pattern (preview → pay → execute)
- ✅ Run quality validator before EVERY commit: `python3 .system/validators/test_quality_validator.py`

**See Section 10 for testing milestones and coverage targets.**

---

## 1. Roadmap Overview

### 1.1 Development Phases

| Phase | Weeks | Focus | Deliverable |
|-------|-------|-------|-------------|
| **Foundation** | 1-6 | Services, save system, validators | ✅ Core architecture |
| **Core Systems** | 7-10 | Inventory, shop, workshop, perks foundation | Playable economy loop |
| **Combat & Content** | 11-13 | Combat system, items, enemies, waves | Playable combat loop |
| **UI & Polish** | 14-16 | Hub, menus, HUD, controller support | Complete UX |
| **Advanced Systems** | 17-20 | Minions, goals, achievements, events | MVP Launch |
| **Post-Launch** | 21-30 | Black Market, vending machine, advisor, personalization | Feature completeness |

### 1.2 Key Milestones

| Milestone | Week | Description |
|-----------|------|-------------|
| **M1: Core Architecture** | Week 6 | ✅ All foundation services, save system, validators |
| **M2: Economy Loop** | Week 10 | Playable shop/workshop/inventory loop |
| **M3: Combat Loop** | Week 13 | Playable wave-based combat |
| **M4: Complete UX** | Week 16 | Polished UI, controller support, tutorial |
| **M5: MVP Launch** | Week 20 | Core gameplay complete, ready for soft launch |
| **M6: Feature Complete** | Week 30 | All advanced systems, full monetization |

### 1.3 Resource Allocation

**Team Size:** 1 developer (Alan Spector)
**Hours per Week:** 20-30 hours
**Total Estimated Hours:** 600-900 hours

---

## 2. Completed Work (Weeks 1-6)

### Week 1-3: Environment Setup ✅
- [x] Godot 4.5.1 project initialization
- [x] Git repository setup with hooks
- [x] Pre-commit validators (gdlint, gdformat, test runner)
- [x] Project structure (.system/, docs/, tests/)
- [x] Resource definitions (items, weapons, characters)

### Week 4: Foundation Services ✅
- [x] GameState service (global state management)
- [x] ErrorService (error handling, logging)
- [x] Logger (activity logging, debug tools)
- [x] StatService (stat calculations, combat math)
- [x] Unit tests for all foundation services

### Week 5: Business Services ✅
- [x] BankingService (currency management)
- [x] RecyclerService (item dismantling, luck-based yields)
- [x] ShopRerollService (shop reroll mechanics, daily reset)
- [x] Unit tests for business services
- [x] Integration tests (BankingService + RecyclerService)

### Week 6 Days 1-3: Save System ✅
- [x] SaveSystem (low-level save/load, ConfigFile)
- [x] SaveManager (coordinate service saves, auto-save)
- [x] Quality validators (native class checker, API consistency)
- [x] Test method validator (GUT naming conventions)
- [x] Pre-commit integration (BLOCKING hooks)

### Week 6 Days 4-5: CharacterService ⏳ IN PROGRESS
- [ ] Character CRUD (create, read, update, delete)
- [ ] Character persistence (local-only, no Supabase yet)
- [ ] Active character management
- [ ] Character slot limits by tier
- [ ] **CRITICAL: Add 6 perk hooks (character_create_pre/post, level_up_pre/post, death_pre/post)**
- [ ] Unit tests for CharacterService
- [ ] Integration tests (CharacterService + SaveManager)

**Deliverable:** Complete character management (local-only)

---

## 3. Core Systems Phase (Weeks 7-10)

### Week 7: Inventory & Shop Systems

**Goals:**
- Implement InventoryService (item management)
- Implement ShopService (purchasing, rerolls)
- Add TierService (feature gating, IAP)
- **Add perk hooks to all services**

**Tasks:**
- [ ] **InventoryService** (3 days)
  - [ ] Item storage (weapons in CharacterInstance, other items in InventoryService)
  - [ ] Auto-active inventory (all items contribute stats)
  - [ ] Durability tracking
  - [ ] Item stacking (consumables, trinkets)
  - [ ] Perk hooks: `inventory_add_pre/post`, `inventory_remove_pre/post`
  - [ ] Unit tests

- [ ] **ShopService** (2 days)
  - [ ] Item purchasing logic
  - [ ] Tier-gated premium items
  - [ ] Integration with BankingService
  - [ ] Integration with ShopRerollService
  - [ ] **Perk hooks: `shop_purchase_pre/post`** (CRITICAL)
  - [ ] Unit tests

- [ ] **TierService** (1 day)
  - [ ] User tier management (Free, Premium, Subscription)
  - [ ] Feature access checks (`has_feature_access()`)
  - [ ] Character slot limits by tier
  - [ ] IAP integration (stub for now, full implementation Week 14)
  - [ ] Unit tests

**Deliverable:** Playable shop/inventory loop (local-only)

---

### Week 8: Supabase Integration

**Goals:**
- Set up Supabase project
- Implement SupabaseClient service
- Add cloud sync for characters
- Enable remote perk distribution

**Tasks:**
- [ ] **Supabase Setup** (1 day)
  - [ ] Create Supabase project
  - [ ] Define database schema (users, characters, perks, goals, achievements)
  - [ ] Set up Row Level Security (RLS) policies
  - [ ] Create Edge Functions stubs

- [ ] **SupabaseClient** (2 days)
  - [ ] Authentication (anonymous, email, OAuth)
  - [ ] Realtime subscriptions (for perks, events)
  - [ ] CRUD operations wrapper
  - [ ] Error handling and retry logic
  - [ ] Unit tests (mocked Supabase)

- [ ] **CharacterService Cloud Sync** (1 day)
  - [ ] Upload characters to Supabase on save
  - [ ] Download characters on startup
  - [ ] Conflict resolution (last-write-wins)
  - [ ] Integration tests (local + cloud)

- [ ] **PerksService Foundation** (1 day)
  - [ ] Fetch active perks from Supabase
  - [ ] Apply perks to active_perks queue
  - [ ] Listen for perk deletion signals
  - [ ] Hook execution engine (fire_hook, execute_perk)
  - [ ] Unit tests

**Deliverable:** Cloud sync working, perk distribution ready

---

### Week 9: Workshop System

**Goals:**
- Implement WorkshopService (repair, fusion, crafting)
- Add radioactivity irradiation
- Integrate with RecyclerService

**Tasks:**
- [ ] **Workshop: Repair Tab** (1 day)
  - [ ] Restore item durability
  - [ ] Rarity-based pricing (scrap + components)
  - [ ] **Perk hooks: `workshop_repair_pre/post`**
  - [ ] Unit tests

- [ ] **Workshop: Fusion Tab** (1 day)
  - [ ] Combine duplicate items
  - [ ] Increase fusion tier (+10% stats per tier)
  - [ ] Max tier based on rarity
  - [ ] **Perk hooks: `workshop_fusion_pre/post`**
  - [ ] Unit tests

- [ ] **Workshop: Craft Tab** (1 day)
  - [ ] Create items from blueprints
  - [ ] Success chance based on rarity
  - [ ] Blueprint unlocking system
  - [ ] **Perk hooks: `workshop_craft_pre/post`**
  - [ ] Unit tests

- [ ] **Workshop: Irradiate Tab** (1 day)
  - [ ] Irradiate items for stat bonuses + debuffs
  - [ ] Radioactive item tracking (is_radioactive flag)
  - [ ] Debuff table (12 debuffs, luck mitigation)
  - [ ] **Perk hooks: `radioactivity_irradiate_pre/post`**
  - [ ] Unit tests

- [ ] **WorkshopService Integration** (1 day)
  - [ ] UI mockup for 4 tabs (Repair, Fusion, Craft, Irradiate)
  - [ ] Integration tests (Workshop + Banking + Inventory + Recycler)

**Deliverable:** Complete workshop system with all 4 tabs

---

### Week 10: Perks System Integration

**Goals:**
- Complete perk hook implementation across all existing services
- Create test perks for all hook points
- Validate perk stacking behavior

**Tasks:**
- [ ] **Perk Hooks Audit** (1 day)
  - [ ] Verify all 26 hooks implemented so far:
    - CharacterService: 6 hooks
    - ShopService: 2 hooks
    - ShopRerollService: 2 hooks
    - RecyclerService: 2 hooks
    - WorkshopService: 8 hooks
    - BankingService: 4 hooks
    - InventoryService: 2 hooks
  - [ ] Update PERKS-ARCHITECTURE.md with actual implementation status

- [ ] **Test Perks Creation** (2 days)
  - [ ] Create 30+ test perks covering all hooks
  - [ ] Examples: Discount perks, damage perks, resurrection perk
  - [ ] Supabase admin dashboard for perk management
  - [ ] Edge Functions for perk distribution

- [ ] **Perk Stacking Tests** (1 day)
  - [ ] Test multiple perks on same hook
  - [ ] Test perk priority (front vs back)
  - [ ] Test perk expiration
  - [ ] Performance testing (100+ active perks)

- [ ] **Documentation** (1 day)
  - [ ] Developer guide for adding hooks
  - [ ] Operator guide for creating perks
  - [ ] Example perks for marketing campaigns

**Deliverable:** Fully functional perks system, ready for marketing campaigns

---

## 4. Combat & Content Phase (Weeks 11-13)

### Week 11: Combat System Foundation

**Goals:**
- Implement CombatService (damage, healing, life steal)
- Add player controller (movement, auto-fire)
- Create enemy AI (3 enemy types)

**Tasks:**
- [ ] **CombatService** (2 days)
  - [ ] Damage calculation (apply_damage)
  - [ ] Healing system
  - [ ] Life steal mechanic
  - [ ] Status effects (planned for later)
  - [ ] **Perk hooks: `damage_dealt_pre/post`, `damage_received_pre/post`** (CRITICAL)
  - [ ] Unit tests

- [ ] **Player Controller** (2 days)
  - [ ] Top-down movement (WASD/joystick)
  - [ ] Auto-fire toward cursor/touch
  - [ ] Stat integration (CharacterService stats)
  - [ ] Health bar, damage feedback
  - [ ] Death handling

- [ ] **Enemy AI** (1 day)
  - [ ] Direct enemy (straight toward player)
  - [ ] Zigzag enemy (serpentine pattern)
  - [ ] Steady enemy (slow, tanky)
  - [ ] Object pooling for performance
  - [ ] Enemy health bars

**Deliverable:** Playable combat (player vs enemies)

---

### Week 12: Wave System & Combat Integration

**Goals:**
- Implement wave spawning and scaling
- Add shop phase (between waves)
- Integrate combat with progression systems

**Tasks:**
- [ ] **WaveService** (2 days)
  - [ ] Wave spawning (interval-based)
  - [ ] Difficulty scaling (+25% HP, +5% speed, +10% damage per wave)
  - [ ] Max 30 enemies on screen
  - [ ] **Perk hooks: `wave_start_pre/post`, `wave_complete_pre/post`**
  - [ ] Unit tests

- [ ] **Shop Phase** (1 day)
  - [ ] Pause combat between waves
  - [ ] Open shop UI (item purchasing)
  - [ ] Time limit (30 seconds to shop)
  - [ ] Continue to next wave

- [ ] **Combat Loop Integration** (1 day)
  - [ ] Wave → Combat → Shop → Wave loop
  - [ ] Death handling (return to hub)
  - [ ] Victory handling (return to hub)
  - [ ] Durability loss on death

- [ ] **Controller Support** (1 day)
  - [ ] Gamepad input mapping
  - [ ] Twin-stick shooter controls
  - [ ] UI adaptations for controller
  - [ ] Settings for sensitivity, dead zone, vibration

**Deliverable:** Complete combat loop with waves and shop phases

---

### Week 13: Items, Weapons, Drops

**Goals:**
- Implement item/weapon drop system
- Create 23 weapons (15 basic + 8 premium)
- Add item rarities and balance

**Tasks:**
- [ ] **Item Drop System** (1 day)
  - [ ] Drop chance by rarity (Common 50%, Uncommon 30%, Rare 15%, Epic 4%, Legendary 1%)
  - [ ] Luck stat influences drop rates
  - [ ] Drop locations (enemy deaths, wave completion, events)
  - [ ] **Perk hooks: `enemy_death_pre/post`** (boost drop rates)

- [ ] **Weapon Definitions** (2 days)
  - [ ] Create 15 basic weapons (Free tier access)
  - [ ] Create 8 premium weapons (Premium tier)
  - [ ] Balance damage, fire rate, special effects
  - [ ] Visual assets (sprites, animations)

- [ ] **Item Definitions** (1 day)
  - [ ] Armor items (+HP, +armor)
  - [ ] Trinkets (+luck, +XP gain)
  - [ ] Consumables (temporary buffs)
  - [ ] Blueprints (for crafting)

- [ ] **Combat Testing & Balance** (1 day)
  - [ ] Playtest waves 1-20
  - [ ] Balance difficulty curve
  - [ ] Adjust enemy spawn rates
  - [ ] Tune weapon damage

**Deliverable:** Complete combat content (weapons, items, balanced difficulty)

---

## 5. UI & Polish Phase (Weeks 14-16)

### Week 14: Hub & Menus

**Goals:**
- Implement Hub (Scrapyard) UI
- Create main menu and navigation
- Add IAP integration

**Tasks:**
- [ ] **Hub UI** (2 days)
  - [ ] Scrapyard scene layout
  - [ ] Navigation buttons (Combat, Shop, Workshop, Characters, Settings)
  - [ ] Character display (name, level, stats)
  - [ ] Currency display (scrap, premium)
  - [ ] Tier indicator

- [ ] **Main Menu** (1 day)
  - [ ] Title screen
  - [ ] New game / Continue
  - [ ] Settings access
  - [ ] Credits screen

- [ ] **IAP Integration** (1 day)
  - [ ] Godot IAP plugin setup
  - [ ] Premium tier purchase ($4.99)
  - [ ] Subscription tier purchase ($2.99/month)
  - [ ] Character slot expansions ($0.99 / $3.99)
  - [ ] Restore purchases

- [ ] **Settings Menu** (1 day)
  - [ ] Audio settings (music, SFX volume)
  - [ ] Graphics settings (resolution, fullscreen)
  - [ ] Controller settings (sensitivity, dead zone, vibration, remapping)
  - [ ] Account management (logout, delete account)

**Deliverable:** Complete UI navigation, IAP working

---

### Week 15: Combat HUD & Polish

**Goals:**
- Create combat HUD (health, scrap, wave number)
- Add visual effects (particles, screen shake)
- Polish animations and feedback

**Tasks:**
- [ ] **Combat HUD** (1 day)
  - [ ] Health bar (character HP)
  - [ ] Scrap counter
  - [ ] Wave number display
  - [ ] Boss/enemy health bars
  - [ ] Minimap (planned for later)

- [ ] **Visual Effects** (2 days)
  - [ ] Particle systems (explosions, hits, deaths)
  - [ ] Screen shake on damage
  - [ ] Flash effects (damage taken, healing)
  - [ ] Weapon muzzle flashes
  - [ ] Enemy death animations

- [ ] **Audio Integration** (1 day)
  - [ ] Background music (hub, combat)
  - [ ] SFX (gunfire, enemy hits, deaths, UI clicks)
  - [ ] Dynamic audio (music intensity scales with wave number)

- [ ] **Performance Optimization** (1 day)
  - [ ] Object pooling (enemies, projectiles, particles)
  - [ ] Spatial hashing (collision detection)
  - [ ] Profiling (maintain 60 FPS on mobile)

**Deliverable:** Polished combat experience (visuals, audio, performance)

---

### Week 16: Tutorial & Onboarding

**Goals:**
- Create first-time user experience
- Add contextual tutorials
- Implement achievement tracking

**Tasks:**
- [ ] **Tutorial System** (2 days)
  - [ ] First run detection
  - [ ] Step-by-step combat tutorial
  - [ ] Hub navigation tutorial
  - [ ] Shop/workshop tutorials
  - [ ] Skippable for returning players

- [ ] **Tooltips & Help** (1 day)
  - [ ] Item tooltips (stats, rarity)
  - [ ] System explanations (durability, fusion, radioactivity)
  - [ ] Context-sensitive help ("?" buttons)

- [ ] **AchievementsService** (1 day)
  - [ ] Track 120+ achievements
  - [ ] Achievement unlock notifications
  - [ ] Rewards distribution (scrap, premium currency, items)
  - [ ] **Perk hooks: `achievement_unlock_pre/post`**
  - [ ] Unit tests

- [ ] **Soft Launch Prep** (1 day)
  - [ ] Bug fixing
  - [ ] Performance testing on target devices
  - [ ] Analytics integration (Firebase/Unity Analytics)
  - [ ] Crash reporting (Sentry)

**Deliverable:** Ready for soft launch (MVP)

---

## 6. Advanced Systems Phase (Weeks 17-20)

### Week 17: Minions System

**Goals:**
- Implement MinionsService (recruitment, management)
- Add Barracks UI
- Create 6 minion types

**Tasks:**
- [ ] **MinionsService** (2 days)
  - [ ] Minion data structure (stats, level, XP, equipment)
  - [ ] Minion roster management (tier-based slots)
  - [ ] Active minion slots (1/2/3 based on tier)
  - [ ] Formation control (Front/Mid/Back positioning)
  - [ ] **Perk hooks: `minion_spawn_pre`, `minion_death_post`**
  - [ ] Unit tests

- [ ] **Minion AI** (2 days)
  - [ ] 6 minion types (Tank, DPS, Support, Ranged, Melee, Hybrid)
  - [ ] Combat behavior (attack, follow, defend)
  - [ ] Special abilities (taunt, heal, stun, etc.)
  - [ ] Pathfinding (A* or simple follow)

- [ ] **Barracks UI** (1 day)
  - [ ] Minion roster view
  - [ ] Minion equipment screen
  - [ ] Formation editor
  - [ ] Minion recruitment (shop integration)

**Deliverable:** Playable minions system with 6 types

---

### Week 18: Goals & Events Systems

**Goals:**
- Implement GoalsService (daily, weekly, seasonal)
- Add EventsService (special events)
- Create admin dashboard for events

**Tasks:**
- [ ] **GoalsService** (2 days)
  - [ ] Goal tracking (progress, completion)
  - [ ] Auto-reset (daily 00:00 UTC, weekly Monday, monthly)
  - [ ] Tier-based participation (1/3/5 daily goals)
  - [ ] Rewards distribution
  - [ ] **Perk hooks: `goal_complete_pre/post`**
  - [ ] Unit tests

- [ ] **EventsService** (2 days)
  - [ ] Event activation/deactivation (server-controlled)
  - [ ] Event modifiers (enemy types, loot tables, difficulty)
  - [ ] 6 event types (Halloween, Winter, Boss Rush, Horde, Spring, Summer)
  - [ ] **Perk hooks: `event_start_post`, `event_end_post`**
  - [ ] Unit tests

- [ ] **Admin Dashboard** (1 day)
  - [ ] Supabase dashboard for events
  - [ ] Create/edit/delete events
  - [ ] Activate/deactivate events
  - [ ] Preview event stats

**Deliverable:** Goals and events systems operational

---

### Week 19: Trading Cards & Referral System

**Goals:**
- Implement TradingCardsService (milestone cards)
- Add ReferralService (invite tracking)
- Create card sharing UI

**Tasks:**
- [ ] **TradingCardsService** (2 days)
  - [ ] Auto-generate cards on milestones (wave 5, 15, 25, 50)
  - [ ] Card design (character portrait, stats, rarity border)
  - [ ] Export to PNG (shareable image)
  - [ ] Referral code integration (QR code + text)
  - [ ] Unit tests

- [ ] **ReferralService** (1 day)
  - [ ] Unique referral codes per user
  - [ ] Track referrals (who invited whom)
  - [ ] Reward distribution (500 scrap, revive, discount, Premium pack)
  - [ ] Supabase integration (cloud tracking)
  - [ ] Unit tests

- [ ] **Social Sharing** (1 day)
  - [ ] Share card to social media (Twitter, Facebook, Discord)
  - [ ] Deep linking (referral code in URL)
  - [ ] Referral landing page

- [ ] **Referral Rewards UI** (1 day)
  - [ ] Progress tracker (0/1/2/3/5 referrals)
  - [ ] Reward unlock notifications
  - [ ] Invite friends button

**Deliverable:** Viral marketing loop (trading cards + referrals)

---

### Week 20: Subscription Features Part 1

**Goals:**
- Implement Quantum Banking (cross-character currency transfers)
- Implement Quantum Storage (cross-character item transfers)
- Add Hall of Fame (character archiving)

**Tasks:**
- [ ] **Quantum Banking** (1 day)
  - [ ] Transfer currency between characters
  - [ ] Bypass 200k total balance cap
  - [ ] Audit trail (Supabase logging)
  - [ ] UI for transfer selection

- [ ] **Quantum Storage** (1 day)
  - [ ] Transfer items between characters
  - [ ] No durability loss on transfer
  - [ ] UI for item transfer

- [ ] **Hall of Fame** (2 days)
  - [ ] Archive character (active → archived)
  - [ ] 200 archived slots (Subscription tier)
  - [ ] Read-only view of archived characters
  - [ ] Auto-generate legendary trading card on archive
  - [ ] Leaderboard integration (archived characters remain)

- [ ] **MVP Launch** (1 day)
  - [ ] Final bug fixes
  - [ ] Performance optimization
  - [ ] Analytics verification
  - [ ] App store submission (iOS, Android)

**Deliverable:** MVP Launch (core gameplay + Subscription features)

---

## 7. Post-Launch Features (Weeks 21-30)

### Week 21-22: Black Market System

**Goals:**
- Implement Black Market (mystery boxes, gambles)
- Add luck-based success rates
- Premium tier gating

**Tasks:**
- [ ] **Black Market Service** (3 days)
  - [ ] Mystery Box (random item, luck influences rarity)
  - [ ] Mystery Reroll (reroll item rarity, luck affects upgrade chance)
  - [ ] Exclusive Gamble (50/50 legendary or refund)
  - [ ] Premium currency only (no scrap)
  - [ ] Unit tests

- [ ] **Black Market UI** (2 days)
  - [ ] Shop interface (3 services)
  - [ ] Luck stat display
  - [ ] Success rate preview
  - [ ] Transaction history

**Deliverable:** Black Market operational (Premium tier)

---

### Week 23-24: Personalization System

**Goals:**
- Implement PersonalizationService (playstyle classification)
- Add 5 archetypes (Tank, Glass Cannon, Speedrunner, Hoarder, Balanced)
- Integrate with Advisor and Atomic Vending Machine

**Tasks:**
- [ ] **PersonalizationService** (3 days)
  - [ ] Track 20+ metrics (damage, HP, speed, luck, etc.)
  - [ ] Classification Edge Function (analyze last 50 runs)
  - [ ] Archetype assignment (dominant pattern detection)
  - [ ] Archetype storage (Supabase user_profiles.archetype)
  - [ ] Unit tests

- [ ] **Archetype UI** (1 day)
  - [ ] Badge display in hub
  - [ ] Archetype description
  - [ ] Stats breakdown (why you're this archetype)

- [ ] **Metrics Tracking** (1 day)
  - [ ] Log combat metrics (damage, HP, kills)
  - [ ] Log economy metrics (scrap, shop spending, recycler usage)
  - [ ] Log meta metrics (wave reached, deaths, playtime)
  - [ ] Batch upload to Supabase

**Deliverable:** Personalization system classifying players

---

### Week 25-26: Atomic Vending Machine

**Goals:**
- Implement Atomic Vending Machine (personalized weekly shop)
- Integrate with Personalization System
- Subscription tier exclusive

**Tasks:**
- [ ] **Atomic Vending Machine Service** (2 days)
  - [ ] Weekly catalog generation (Monday 00:00 UTC)
  - [ ] Fetch player archetype from Personalization
  - [ ] Query items tagged by archetype
  - [ ] Rarity distribution (50% Common, 30% Rare, 15% Epic, 5% Legendary)
  - [ ] 30% discount vs Black Market
  - [ ] Unit tests

- [ ] **Vending Machine UI** (2 days)
  - [ ] Weekly shop interface
  - [ ] Archetype-specific branding
  - [ ] Countdown timer to next refresh
  - [ ] Purchase history

- [ ] **Archetype Item Tagging** (1 day)
  - [ ] Tag 100+ items with archetypes (Tank, Glass Cannon, etc.)
  - [ ] Database migration (add archetype_tags column)
  - [ ] Admin dashboard for tagging

**Deliverable:** Atomic Vending Machine operational (Subscription tier)

---

### Week 27-28: Advisor System

**Goals:**
- Implement AdvisorService (AI-driven gameplay feedback)
- Add post-run analysis
- Integrate with Personalization System

**Tasks:**
- [ ] **AdvisorService** (3 days)
  - [ ] Real-time tips (shop phase, combat prep)
  - [ ] Post-run analysis (performance summary, strengths, weaknesses)
  - [ ] Archetype alignment scoring
  - [ ] Skill level detection (beginner/intermediate/advanced)
  - [ ] Recommendation engine (3 actionable tips)
  - [ ] Unit tests

- [ ] **Advisor UI** (1 day)
  - [ ] Tip notifications (dismissible)
  - [ ] Post-run report screen
  - [ ] Archetype alignment visualization

- [ ] **Advisor LLM Integration** (1 day)
  - [ ] Supabase Edge Function with OpenAI API
  - [ ] Generate contextual tips based on player state
  - [ ] Cache common tips to reduce API calls

**Deliverable:** Advisor system providing intelligent feedback

---

### Week 29: Feature Request System

**Goals:**
- Implement FeatureRequestService (democratic voting)
- Add tier-based voting power
- Monthly voting cycles

**Tasks:**
- [ ] **FeatureRequestService** (2 days)
  - [ ] Submission system (title, description, category)
  - [ ] Admin curation workflow
  - [ ] Voting system (tier-based weights: 1x/2x/3x)
  - [ ] Monthly cycle management
  - [ ] Results announcement
  - [ ] Unit tests

- [ ] **Feature Request UI** (2 days)
  - [ ] Browse active ballot
  - [ ] Submit new ideas
  - [ ] Vote on features
  - [ ] View results leaderboard
  - [ ] Track implementation progress

- [ ] **Admin Dashboard** (1 day)
  - [ ] Review submissions
  - [ ] Approve/reject ideas
  - [ ] Add to ballot
  - [ ] Announce winners

**Deliverable:** Democratic feature voting operational

---

### Week 30: Final Polish & Feature Completeness

**Goals:**
- Final bug fixes
- Performance optimization
- Documentation updates
- Full feature set complete

**Tasks:**
- [ ] **Bug Fixes** (2 days)
  - [ ] Address all reported bugs
  - [ ] Fix edge cases
  - [ ] Improve error handling

- [ ] **Performance Optimization** (1 day)
  - [ ] Profile all systems
  - [ ] Optimize hot paths
  - [ ] Reduce memory usage

- [ ] **Documentation** (1 day)
  - [ ] Update all game design docs
  - [ ] Create player guides
  - [ ] Write developer handoff docs

- [ ] **App Store Optimization** (1 day)
  - [ ] Screenshots, videos, descriptions
  - [ ] Marketing materials
  - [ ] Press kit

**Deliverable:** Feature-complete game, ready for 1.0 launch

---

## 8. Dependencies & Critical Path

### 8.1 Critical Path (Blocking Dependencies)

```mermaid
graph LR
    W6[Week 6: CharacterService] --> W7[Week 7: Inventory/Shop]
    W7 --> W8[Week 8: Supabase]
    W8 --> W9[Week 9: Workshop]
    W9 --> W10[Week 10: Perks]
    W10 --> W11[Week 11: Combat]
    W11 --> W12[Week 12: Waves]
    W12 --> W13[Week 13: Items/Drops]
    W13 --> W14[Week 14: Hub UI]
    W14 --> W16[Week 16: Tutorial]
    W16 --> W20[Week 20: MVP Launch]
```

### 8.2 Parallel Tracks (Can Work Simultaneously)

**Track A: Core Systems**
- Weeks 7-10: Inventory, Shop, Workshop, Perks

**Track B: Combat Systems**
- Weeks 11-13: Combat, Waves, Items

**Track C: UI/UX**
- Weeks 14-16: Hub, Menus, Tutorial

**Track D: Advanced Features** (Post-Launch)
- Weeks 17-20: Minions, Goals, Events
- Weeks 21-30: Black Market, Personalization, Vending, Advisor

### 8.3 High-Risk Dependencies

| Dependency | Risk | Mitigation |
|------------|------|------------|
| **Supabase Integration** (Week 8) | Cloud service outages, RLS complexity | Implement local-first architecture, thorough error handling |
| **Perks System** (Week 10) | Complex hook architecture, performance | Incremental implementation, extensive testing |
| **Combat System** (Weeks 11-13) | Mobile performance, balance | Object pooling, early profiling, iterative balance |
| **IAP Integration** (Week 14) | Platform-specific bugs, payment failures | Thorough testing, restore purchases, error handling |

---

## 9. Risk Mitigation

### 9.1 Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Mobile Performance** | High | Medium | Object pooling, spatial hashing, profiling early |
| **Supabase Latency** | Medium | Low | Local-first design, caching, optimistic updates |
| **Perk System Complexity** | High | Medium | Incremental rollout, extensive testing, rollback plan |
| **IAP Payment Issues** | High | Low | Restore purchases, error handling, customer support plan |

### 9.2 Schedule Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Scope Creep** | High | High | Strict feature freeze after Week 16 (MVP) |
| **Single Developer Bottleneck** | High | Medium | Prioritize critical path, cut nice-to-have features |
| **Testing Delays** | Medium | Medium | Automated testing, continuous integration |
| **Content Creation** (weapons, items) | Medium | Low | Use procedural generation, reuse assets |

### 9.3 Rollback Plan

**If schedule slips:**
1. **Cut Post-Launch Features** (Weeks 21-30) - Launch with MVP only
2. **Simplify Tutorial** (Week 16) - Use tooltips instead of interactive tutorial
3. **Reduce Content** (Week 13) - Launch with 10 weapons instead of 23
4. **Defer Minions** (Week 17) - Move to post-launch update

**MVP Must-Haves:**
- ✅ Core combat loop (player, enemies, waves)
- ✅ Character progression (XP, levels, stats)
- ✅ Economy loop (shop, workshop, recycler, banking)
- ✅ Tier system (Free, Premium, Subscription)
- ✅ Basic perks (server-controlled)
- ✅ Cloud save (Supabase)

---

## 10. Testing Milestones

**📚 See [TESTING-INDEX.md](../TESTING-INDEX.md) for complete testing documentation, templates, and enforcement protocols.**

### 10.1 Testing Strategy

| Week | Testing Focus | Coverage Target |
|------|---------------|----------------|
| **Ongoing** | Unit tests (every service) | 80% line coverage |
| **Week 10** | Perks integration testing | All 26 hooks tested |
| **Week 13** | Combat playtesting | 20 waves balanced |
| **Week 16** | Full game playtest | End-to-end scenarios |
| **Week 20** | Pre-launch QA | All critical paths tested |

### 10.2 Test Suites

**Unit Tests:**
- All services (CharacterService, ShopService, etc.)
- All hooks (perk execution, context validation)
- All business logic (stat calculations, currency operations)

**Integration Tests:**
- Service interactions (Shop + Banking + Inventory)
- Perk hooks across services
- Cloud sync (local + Supabase)

**Playtesting:**
- Combat balance (waves 1-30)
- Economy balance (scrap earnings vs spending)
- Tier progression (Free → Premium → Subscription)

### 10.3 Quality Gates

**Week 6 (CharacterService):**
- [ ] All unit tests passing
- [ ] 6 perk hooks functional
- [ ] SaveManager integration working

**Week 10 (Perks Complete):**
- [ ] All 26 hooks implemented
- [ ] 30+ test perks created
- [ ] Perk stacking validated

**Week 13 (Combat Playable):**
- [ ] 60 FPS on target devices
- [ ] Wave 1-20 balanced
- [ ] Death/victory flows working

**Week 16 (MVP Complete):**
- [ ] All critical bugs fixed
- [ ] Tutorial functional
- [ ] IAP working
- [ ] Analytics integrated

**Week 20 (Launch):**
- [ ] No P0/P1 bugs
- [ ] All tier features functional
- [ ] App store ready

---

## Appendix: Quick Reference

### Current Status (Week 6)
- ✅ Weeks 1-5: Foundation complete
- ⏳ Week 6 Days 4-5: CharacterService (in progress)
- 📋 Week 7+: Inventory, Shop, Workshop, Combat...

### Next Steps
1. **Finish CharacterService** (Week 6 Days 4-5)
   - Add 6 perk hooks (CRITICAL)
   - Complete unit tests
   - Integrate with SaveManager
2. **Start Week 7** (Inventory + Shop)
   - Implement InventoryService
   - Implement ShopService
   - Add TierService
3. **Plan Week 8** (Supabase Integration)
   - Set up Supabase project
   - Implement SupabaseClient
   - Add cloud sync

### Key Milestones
- **M2: Economy Loop** (Week 10) - 4 weeks away
- **M3: Combat Loop** (Week 13) - 7 weeks away
- **M5: MVP Launch** (Week 20) - 14 weeks away (~3.5 months)

---

**Document Version:** 1.0
**Last Updated:** November 9, 2025
**Next Review:** End of Week 10 (after Perks completion)
