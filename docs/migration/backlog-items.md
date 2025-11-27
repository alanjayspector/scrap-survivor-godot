# Migration Backlog Items

**Status:** Parking Lot for Deferred Work
**Created:** 2025-11-27
**Last Updated:** 2025-11-27

---

## Overview

This document captures deferred work items from weekly planning sessions. Items here are well-scoped but not prioritized for immediate implementation.

---

## 💰 Monetization

### IAP Integration
**Deferred From:** Week 17
**Estimated Effort:** 8-10 hours
**Dependencies:** None
**Priority When Implemented:** HIGH (revenue-critical)

**Scope:**
1. **Tier Upgrade Flow**
   - Replace `_show_purchase_stub()` with real IAP calls
   - StoreKit (iOS) + Google Play integration
   - Receipt validation
   - `TierService.upgrade_tier()` on successful purchase
   - Refresh UI after purchase

2. **Slot Pack Purchases (PREMIUM tier)**
   - +5 slots: $0.99
   - +25 slots: $3.99
   - Update `CharacterService.SLOT_LIMITS` dynamically
   - Store purchased slot packs in save file

3. **Product IDs**
   ```
   com.scrapsurvival.premium          - $4.99 (one-time)
   com.scrapsurvival.subscription     - $2.99/month (recurring)
   com.scrapsurvival.slots_5          - $0.99 (consumable)
   com.scrapsurvival.slots_25         - $3.99 (consumable)
   ```

**Testing Requirements:**
- [ ] IAP receipt validation
- [ ] Tier upgrade state management
- [ ] Slot pack purchase accounting
- [ ] Sandbox testing on iOS/Android

---

## 🧪 Technical Debt

### GameLogger Refactor
**Deferred From:** Week 17
**Estimated Effort:** 2-4 hours
**Dependencies:** None
**Priority:** MEDIUM

**Problem:**
- GameLogger is monolithic static class
- Tight coupling of file I/O and console output
- No configuration for level-based routing
- Adding remote logging requires editing core function
- This is the 3rd time "hack with prints" has occurred

**Solution: Handler Pattern (Log4j, Python logging, Serilog)**
```
Logger (entry point)
  ↓
Handlers (multiple, configurable)
  ├─ FileLogHandler → writes to file
  ├─ ConsoleLogHandler → prints to stdout
  ├─ RemoteLogHandler → sends to analytics/Sentry
  └─ Each handler has:
      - Formatter (JSON, plain text, etc.)
      - Filter (level-based routing)
```

**Implementation:**
1. Create `LogHandler` base class
2. Create `FileLogHandler`, `ConsoleLogHandler`
3. Refactor GameLogger to delegate to handlers
4. Maintain backward compatibility (same public API)

**Benefits:**
- Separation of concerns
- Open/Closed Principle compliance
- Testability improvements
- Extensibility for Sentry/analytics

---

### Projectile Unit Test Coverage
**Deferred From:** Week 17
**Estimated Effort:** 30 minutes
**Dependencies:** None
**Priority:** LOW

**Context:**
- Projectile class: 551 lines of production code
- Unit tests exist but marked as `pending()` with "Week 10 Phase 2" placeholders
- Integration tests provide coverage indirectly

**Missing Unit Tests:**
1. `test_projectile_activates_with_parameters()`
2. `test_projectile_velocity_is_set()`
3. `test_projectile_pierce_is_set()`
4. `test_projectile_remaining_range_is_full()`
5. `test_projectile_deactivates()`

**Implementation:**
- Remove `pending()` calls from entity_classes_test.gd (lines 205-222)
- Implement 5 unit tests using object pooling pattern
- Expected result: 568/592 → 573/592 (+5 tests)

---

### Virtual Scrolling for Character Roster
**Deferred From:** Week 17
**Estimated Effort:** 2-3 hours (Option A: Custom Virtual Scroll)
**Dependencies:** Subscription tier launch
**Priority:** LOW (until subscription tier launches)

**Problem:**
- Current roster renders ALL character cards
- Subscription tier = 50 characters (potential scroll lag)
- Hall of Fame = 200 archived characters (definitely needs virtual scrolling)

**Solution Options:**

| Option | Effort | Trade-off |
|--------|--------|-----------|
| A: Custom Virtual Scroll | 2-3h | Most flexible |
| B: Godot ItemList Widget | 1-2h | Less visual customization |
| C: Paginated Roster | 1h | Worse UX (extra taps) |

**Recommendation:** Option A (custom virtual scroll) when subscription launches.

**Testing:**
- Create 50 mock characters with debug helper
- Test scroll performance on iPhone 8 (A11 chip)
- If FPS < 55, implement immediately

---

## 🎨 UI/UX Enhancements

### Card Entrance Animations
**Deferred From:** Week 17 Phase 5
**Estimated Effort:** 30-45 minutes
**Dependencies:** None
**Priority:** LOW (polish)

**Scope:**
- Fade + slide animation for card appearance
- 200ms stagger between cards in grid
- Applies to Barracks roster and Character Creation type cards

**Implementation:**
```gdscript
func _animate_card_entrance(card: Control, index: int) -> void:
    card.modulate.a = 0.0
    card.position.y += 20
    var tween = create_tween()
    tween.set_delay(index * 0.2)  # 200ms stagger
    tween.parallel().tween_property(card, "modulate:a", 1.0, 0.3)
    tween.parallel().tween_property(card, "position:y", card.position.y - 20, 0.3)
```

---

### Card Drop Shadows
**Deferred From:** Week 17 Phase 5
**Estimated Effort:** 15-30 minutes
**Dependencies:** None
**Priority:** LOW (polish)

**Scope:**
- Add subtle drop shadow to CharacterTypeCard
- 4pt blur, 25% opacity, 2px offset
- Consider performance on older devices

**Implementation Options:**
1. StyleBoxFlat with shadow properties
2. Separate shadow Panel behind card
3. Shader-based shadow (avoid if possible)

---

### Screen Transition Animations
**Deferred From:** Week 17 Phase 5
**Estimated Effort:** 1-2 hours
**Dependencies:** None
**Priority:** LOW (polish)

**Scope:**
- Smooth transitions between screens (Hub → Barracks → Details → etc.)
- Options: Fade, Slide, Scale
- Should feel quick but not jarring

**Screens to Animate:**
- Hub → Barracks
- Barracks → Character Details
- Barracks → Character Creation
- Character Creation → Hub/Barracks
- Character Details → Enter Wasteland

---

### Sound Effects for Selection
**Deferred From:** Week 17 Phase 5
**Estimated Effort:** 30-45 minutes
**Dependencies:** Audio assets
**Priority:** LOW (polish)

**Scope:**
- Card tap sound (satisfying click)
- Card selection sound (confirmation tone)
- Button hover/tap sounds
- Modal open/close sounds

**Note:** Need audio assets first. Consider royalty-free SFX or custom.

---

### Haptic Feedback Refinement
**Deferred From:** Week 17 Phase 5
**Estimated Effort:** 30 minutes
**Dependencies:** None
**Priority:** LOW (polish)

**Scope:**
- Review all haptic feedback points
- Ensure consistent intensity levels
- Add haptics to any missing interactions:
  - Card selection
  - Modal confirmation
  - Destructive action warnings
  - Success/failure feedback

**Current Status:** Basic haptics implemented with 50ms cooldown (fixed continuous vibration bug in Phase 3).

---

### Secondary Stats Display (Character Details)
**Deferred From:** Week 17 Phase 3
**Estimated Effort:** 1-2 hours
**Dependencies:** None
**Priority:** LOW (power users only)

**Context:**
Character Details screen shows 4 primary stats (HP, DMG, ARM, SPD). There are 10 additional secondary stats that power users may want to see.

**Secondary Stats (10 total):**
| Stat | Type | Purpose |
|------|------|---------|
| melee_damage | int | Melee weapon bonus |
| ranged_damage | int | Ranged weapon bonus |
| attack_speed | float | Weapon cooldown reduction % |
| crit_chance | float | Critical hit probability |
| life_steal | float | % damage → HP (capped 90%) |
| hp_regen | int | HP per second |
| dodge | float | Evasion chance % |
| luck | int | Drop rate modifier |
| pickup_range | int | Collection radius |
| scavenging | int | Currency multiplier % |
| resonance | int | Aura power multiplier |

**Implementation Options:**
1. **"View All Stats" Button** → Opens modal with full stat breakdown
2. **Expandable Section** → Tap to reveal secondary stats inline
3. **Swipe Gesture** → Swipe left on stats card to see more

**Recommendation:** Option 1 (modal) - keeps main view clean, power users can deep-dive.

---

## 🎮 Gameplay Features

### Meta Progression System
**Deferred From:** Week 17
**Estimated Effort:** 4-6 hours
**Dependencies:** None
**Priority:** MEDIUM (retention feature)

**Scope:**
1. **MetaProgressionService**
   - Track meta-currency (Chips?) earned per run
   - Post-run conversion from run currency to meta-currency

2. **Permanent Upgrade Shop in Hub**
   - Starting stat bonuses (all characters)
   - Unlock new weapons (permanent availability)
   - Upgrade hub buildings

3. **Apply Upgrades to New Runs**
   - Hook into `character_create_pre` perk signal
   - Modify starting stats based on meta upgrades

**Design Questions:**
- What's the meta-currency called? (Chips? Blueprints? Tech?)
- What's the exchange rate? (100 Scrap = 1 Chip?)
- How many permanent upgrades? (5? 10? 20?)

---

### First-Run Flow
**Deferred From:** Week 15 Phase 4
**Estimated Effort:** 2-3 hours
**Dependencies:** None
**Priority:** MEDIUM (new player experience)

**Scope:**
- Tutorial overlay for first-time players
- Guided character creation
- Hub introduction tour
- First run with hints enabled

---

### Post-Run Flow
**Deferred From:** Week 15 Phase 5
**Estimated Effort:** 2-3 hours
**Dependencies:** None
**Priority:** MEDIUM (feedback loop)

**Scope:**
- Run summary screen
- Stats display (kills, waves, loot)
- XP/level-up celebration
- Currency conversion (if meta progression)
- "Play Again" / "Return to Hub" options

---

## 📊 Analytics & Monitoring

### Remote Logging (Sentry/Crashlytics)
**Deferred From:** Future
**Estimated Effort:** 4-6 hours
**Dependencies:** GameLogger refactor
**Priority:** LOW (until production release)

**Scope:**
- Error reporting to Sentry/Crashlytics
- Production crash monitoring
- User action analytics
- Performance metrics

---

## Document History

| Date | Change |
|------|--------|
| 2025-11-27 | Initial creation from Week 17 planning |
| 2025-11-27 | Added Week 17 Phase 5 polish items (5 items, broken down) |

---

**Next Review:** After Week 17 completion
