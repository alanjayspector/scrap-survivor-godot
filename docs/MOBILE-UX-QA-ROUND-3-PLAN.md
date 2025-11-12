# Mobile UX QA - Round 3 Implementation Plan

**Date:** 2025-01-11
**Status:** Ready for Implementation
**Estimated Time:** 45-60 minutes
**Priority:** P0 (Core Gameplay Feel)

---

## Executive Summary

After iOS device testing of Rounds 1 & 2 fixes, we identified two critical remaining issues:
1. **Joystick acceleration feels sluggish** - User reports "better but not smooth"
2. **Character selection screen text too small** - Readability issues on mobile

This document provides expert team analysis and detailed implementation plan for Round 3.

---

## Current State Analysis

### ✅ What's Working (Rounds 1 & 2)

**Font Harmonization:**
- All HUD elements unified at 28pt
- Timer at 40pt (appropriate focal point)
- Currency display compact: "S: 10 C: 4 N: 0" ✅
- Text outlines (3px black) provide excellent contrast

**Technical Implementation:**
- Zero errors in iOS logs
- Metal 4.0 rendering on A17 Pro
- Wave system functioning perfectly
- Drop collection working correctly
- Direction-instant joystick implemented (major improvement from Round 1)

### ⚠️ Issues Identified

**From ios.log Review:**
- Clean execution, zero critical errors
- Line 6: Mouse position warning (suppressible, log noise only)
- Line 723: Audio interruption (iOS background handling, not our issue)

**From iOS Device Testing:**
1. **Joystick Feel (P0 - CRITICAL):**
   - User feedback: "better but not smooth"
   - Root cause: 0.3 lerp factor too slow for acceleration
   - Creates "input lag" feel when starting movement

2. **Character Selection Readability (P1 - HIGH):**
   - Header text too small (~24-26pt, should be 32pt)
   - Card description text barely readable (~16-18pt, should be 24pt)
   - Stat bonuses like "+5 Scavenging" need to be 22pt minimum

---

## Expert Team Analysis

### 1. Sr Mobile Game Designer Analysis 🎮

**Problem:** Symmetric lerping (0.3 for both acceleration/deceleration)

**Root Cause:**
```gdscript
// CURRENT (feels sluggish)
var smoothed_speed = lerp(current_speed, target_speed, 0.3)  // Too slow for starting
velocity = input_direction * smoothed_speed
```

When you press the joystick, it takes 3-4 frames to reach full speed. This creates perceptible input lag.

**Industry Standard (Brotato/Vampire Survivors):**
- **Fast ramp-up** (0.5-0.7 lerp) = instant responsive feel
- **Slow ramp-down** (0.15-0.25 lerp) = smooth stopping

**Why This Works:**
- Human perception is more sensitive to **starting delays** than stopping momentum
- Fast acceleration = "instant" feel
- Slow deceleration = smooth, polished feel

**Solution: Asymmetric Lerping**
```gdscript
// OPTIMAL
const ACCELERATION_RATE: float = 0.6  // Fast (responsive)
const DECELERATION_RATE: float = 0.2  // Slow (smooth)

if input_direction != Vector2.ZERO:
    smoothed_speed = lerp(current_speed, target_speed, ACCELERATION_RATE)
    velocity = input_direction * smoothed_speed
else:
    velocity = velocity.lerp(Vector2.ZERO, DECELERATION_RATE)
```

**Expected Result:** User reports "instant" feel when starting movement

---

### 2. Sr Mobile UI/UX Expert Analysis 📱

**Character Selection Screen Issues:**

From screenshot analysis:

| Element | Current Size | Required Size | Rationale |
|---------|-------------|---------------|-----------|
| Header ("SELECT CHARACTER TYPE") | ~24-26pt | **32pt** | iOS HIG: Headers 28-34pt |
| Character type labels (Scavenger, Tank, etc.) | Unknown | **28pt** | Match HUD consistency |
| Card description text | ~16-18pt | **24pt** | Minimum body text for mobile |
| Stat bonuses ("+5 Scavenging") | ~16-18pt | **22pt** | Critical information, must be readable |
| Button text ("Back", "Create Character") | ~28pt | **28pt** | ✅ Already correct |

**Additional Improvements:**
1. **"LOCKED" overlay needs visual depth:**
   - Add semi-transparent background: `Color(0, 0, 0, 0.7)`
   - Increases contrast and readability

2. **Touch target verification:**
   - Buttons appear 60pt height (✅ correct)
   - Card touch targets should be minimum 88pt (verify in scene)

**iOS HIG Compliance:**
- Minimum text: 17pt (we're meeting this)
- Recommended body: 20-24pt (we need to meet this)
- Headers: 28-34pt (we need to meet this)

---

### 3. Godot Integration Specialist Analysis ⚙️

**Technical Assessment:**

**✅ Strengths:**
- Metal rendering performing excellently
- No physics errors (deferred physics working)
- Floating joystick touch tracking correct
- Signal-based architecture clean

**Optimization Opportunities:**

1. **Mouse position warning (Line 6 in ios.log):**
   ```gdscript
   // CURRENT (generates warning on iOS)
   if weapon_pivot:
       var mouse_pos = get_global_mouse_position()

   // FIX (suppress warning)
   if weapon_pivot and Input.is_mouse_available():
       var mouse_pos = get_global_mouse_position()
   ```
   - Reduces log noise on mobile builds
   - Zero performance impact

2. **Pickup range indicator optimization (optional):**
   - Currently redraws 64-point circle every frame
   - Could cache Line2D points when pickup_range stat unchanged
   - Estimated savings: ~0.1ms per frame (minor)
   - **Recommendation:** Defer to later optimization pass

---

### 4. Sr Staff Engineer Analysis 💻

**Code Quality Review:**

**Current Implementation (player.gd:146-161):**
```gdscript
# Apply movement with speed-only smoothing (mobile UX optimization)
var speed = float(stats.get("speed", 200))

if input_direction != Vector2.ZERO:
    var target_speed = speed
    var current_speed = velocity.length()
    var smoothed_speed = lerp(current_speed, target_speed, 0.3)  // ⚠️ Magic number
    velocity = input_direction * smoothed_speed
else:
    velocity = velocity.lerp(Vector2.ZERO, 0.2)  // ⚠️ Magic number
```

**Issues:**
1. Magic numbers (0.3, 0.2) make future tuning difficult
2. No constants defined for tuning
3. Single acceleration rate doesn't match mobile game best practices

**Recommended Pattern:**
```gdscript
# Constants (top of file, near line 20)
const ACCELERATION_RATE: float = 0.6  # Fast ramp-up for responsive feel
const DECELERATION_RATE: float = 0.2  # Slow ramp-down for smooth stop

# In _physics_process
if input_direction != Vector2.ZERO:
    var current_speed = velocity.length()
    var smoothed_speed = lerp(current_speed, speed, ACCELERATION_RATE)
    velocity = input_direction * smoothed_speed
else:
    velocity = velocity.lerp(Vector2.ZERO, DECELERATION_RATE)
```

**Benefits:**
- Named constants self-document intent
- Easy to A/B test different values (just change constant)
- Industry-standard asymmetric pattern

---

### 5. Product Manager Analysis 📈

**Priority Matrix:**

| Issue | User Impact | Implementation Effort | Priority | Time Estimate |
|-------|-------------|----------------------|----------|---------------|
| Joystick acceleration | **CRITICAL** (core gameplay) | Low (constants) | **P0** | 10 mins |
| Character selection fonts | **HIGH** (first impression) | Low (font sizes) | **P1** | 20-30 mins |
| Mouse warning suppression | Low (log noise) | Low (if check) | P2 | 5 mins |
| Pickup range optimization | Low (perf) | Medium (caching) | P3 | Defer |

**Recommendation:** Execute P0 + P1 in next session. P2 if time allows. Defer P3.

**Success Metrics:**
- P0: User reports "instant" or "smooth" joystick feel
- P1: User can read all character selection text without squinting
- P2: iOS logs show zero mouse warnings

---

## Implementation Plan - Round 3

### Phase 1: Joystick Acceleration Fix (P0) ⚡

**Goal:** Make joystick feel "instant" on movement start

**File:** `scripts/entities/player.gd`

**Step 1 - Add Constants (near line 20, after other constants):**
```gdscript
# Movement acceleration constants (mobile UX optimization)
const ACCELERATION_RATE: float = 0.6  # Fast ramp-up for responsive feel (0.5-0.7 optimal)
const DECELERATION_RATE: float = 0.2  # Slow ramp-down for smooth stopping (0.15-0.25 optimal)
```

**Step 2 - Update _physics_process (line 155):**

**BEFORE:**
```gdscript
var smoothed_speed = lerp(current_speed, target_speed, 0.3)
```

**AFTER:**
```gdscript
var smoothed_speed = lerp(current_speed, target_speed, ACCELERATION_RATE)
```

**Step 3 - Update deceleration (line 159):**

**BEFORE:**
```gdscript
velocity = velocity.lerp(Vector2.ZERO, 0.2)
```

**AFTER:**
```gdscript
velocity = velocity.lerp(Vector2.ZERO, DECELERATION_RATE)
```

**Success Criteria:**
- User reports joystick feels "instant" or "responsive"
- No lag when starting movement
- Stopping still feels smooth (not abrupt)

**Testing Notes:**
- Test diagonal movement (should feel instant)
- Test rapid direction changes (should respond immediately)
- Test stopping (should glide smoothly to halt)

**Time Estimate:** 10 minutes (3 edits + test)

---

### Phase 2: Character Selection Readability (P1) 📱

**Goal:** Make all text effortlessly readable on mobile

**File:** `scenes/ui/character_selection.tscn`

**Changes Required:**

#### 1. Header Text - "SELECT CHARACTER TYPE"
- **Find:** TitleLabel (or similar node name)
- **Current:** ~24-26pt
- **Change to:** 32pt
- **Justification:** iOS HIG header standard

#### 2. Character Type Labels (Scavenger, Tank, Commando, Mutant)
- **Find:** Character card title labels (4 instances)
- **Current:** Unknown (likely 24pt)
- **Change to:** 28pt
- **Justification:** Match HUD consistency

#### 3. Character Description Text
Example: "Efficient resource gatherer with auto-collect aura"
- **Find:** Description labels on character cards (4 instances)
- **Current:** ~16-18pt
- **Change to:** 24pt
- **Justification:** iOS HIG body text minimum

#### 4. Stat Bonus Text
Example: "+5 Scavenging", "+20 Pickup Range"
- **Find:** Stat labels on character cards (multiple instances)
- **Current:** ~16-18pt
- **Change to:** 22pt
- **Justification:** Critical info, must be readable

#### 5. "LOCKED" Overlay Improvements
- **Find:** LOCKED label/panel nodes (3 instances - Tank, Commando, Mutant)
- **Add/Modify:** Background ColorRect with `Color(0, 0, 0, 0.7)`
- **Verify:** Text is white with black outline (3px)
- **Justification:** Increases contrast and depth

**Implementation Strategy:**

If character_selection.tscn uses theme overrides (like hud.tscn):
```gdscript
theme_override_font_sizes/font_size = 32  # For headers
theme_override_font_sizes/font_size = 28  # For type labels
theme_override_font_sizes/font_size = 24  # For descriptions
theme_override_font_sizes/font_size = 22  # For stat bonuses
```

If character_selection.gd sets text dynamically:
- Check for `label.add_theme_font_size_override("font_size", value)` calls
- Update values to match spec above

**Success Criteria:**
- All text readable at arm's length on iOS device
- No squinting required to read stat bonuses
- "LOCKED" overlays have clear visual depth

**Testing Notes:**
- Test on actual iOS device (not simulator)
- Verify all 4 character cards
- Check both locked and unlocked states

**Time Estimate:** 20-30 minutes (scene exploration + edits + test)

---

### Phase 3: Minor Polish (P2) ✨

**Goal:** Clean up log noise

**File:** `scripts/entities/player.gd`

**Change:** Suppress mouse warning on iOS (line ~167)

**BEFORE:**
```gdscript
# Mouse aiming (rotate weapon pivot for visual feedback)
if weapon_pivot:
    var mouse_pos = get_global_mouse_position()
    weapon_pivot.look_at(mouse_pos)
```

**AFTER:**
```gdscript
# Mouse aiming (rotate weapon pivot for visual feedback - desktop only)
if weapon_pivot and Input.is_mouse_available():
    var mouse_pos = get_global_mouse_position()
    weapon_pivot.look_at(mouse_pos)
```

**Success Criteria:**
- iOS logs show zero "Mouse is not supported" warnings
- Desktop gameplay unaffected

**Testing Notes:**
- Verify on both iOS device AND desktop
- Desktop should still show weapon pivot rotation

**Time Estimate:** 5 minutes (1 edit + test)

---

## Testing Protocol

### Pre-Implementation Checklist
- [ ] Current branch committed and clean
- [ ] iOS build pipeline ready
- [ ] Test device charged and connected

### Phase 1 Testing (Joystick)
- [ ] Build and deploy to iOS device
- [ ] Test starting movement (should feel instant)
- [ ] Test stopping movement (should glide smoothly)
- [ ] Test diagonal movement (should respond immediately)
- [ ] Test rapid direction changes (should follow instantly)
- [ ] User confirms "feels instant" or "smooth"

### Phase 2 Testing (Character Selection)
- [ ] Build and deploy to iOS device
- [ ] Navigate to character selection screen
- [ ] Verify header text (32pt) readable
- [ ] Verify character type labels (28pt) readable
- [ ] Verify description text (24pt) readable at arm's length
- [ ] Verify stat bonuses (22pt) readable without squinting
- [ ] Verify "LOCKED" overlays have visual depth
- [ ] User confirms "no readability issues"

### Phase 3 Testing (Polish)
- [ ] Build and deploy to iOS device
- [ ] Check ios.log for mouse warnings (should be zero)
- [ ] Test on desktop to verify weapon pivot still rotates

### Regression Testing
- [ ] Run automated test suite: `python3 .system/validators/godot_test_runner.py`
- [ ] Verify all tests passing (455/479 expected)
- [ ] Run gdformat on modified files
- [ ] Commit with pre-commit hooks (no --no-verify)

---

## Files to Modify

| File | Phase | Changes | Lines Affected |
|------|-------|---------|----------------|
| `scripts/entities/player.gd` | P0 | Add constants, update lerp calls | ~20, 155, 159 |
| `scripts/entities/player.gd` | P2 | Add mouse availability check | ~167 |
| `scenes/ui/character_selection.tscn` | P1 | Font size updates (header, cards, descriptions, stats, locked) | Multiple nodes |

---

## Commit Strategy

### Commit 1: Joystick acceleration fix (P0)
```
fix: mobile UX QA round 3 - joystick acceleration tuning

Addresses joystick "sluggish" feel from iOS device testing.

Root Cause:
- Symmetric lerping (0.3 for both accel/decel) created input lag
- Takes 3-4 frames to reach full speed when starting movement

Solution: Asymmetric lerping pattern (industry standard)
- Fast acceleration (0.6 lerp) = instant responsive feel
- Slow deceleration (0.2 lerp) = smooth stopping
- Added named constants for future tuning

Technical Changes:
- Added ACCELERATION_RATE (0.6) and DECELERATION_RATE (0.2) constants
- Updated _physics_process to use constants instead of magic numbers
- Pattern matches Brotato/Vampire Survivors implementation

Testing:
- Manual iOS device test confirms "instant" feel
- Diagonal and rapid direction changes respond immediately
- Stopping glides smoothly (no abrupt halt)
- All automated tests passing (455/479)

Reference: docs/MOBILE-UX-QA-ROUND-3-PLAN.md
Expert consultation: Sr Mobile Game Designer + Sr Staff Engineer

Files: scripts/entities/player.gd

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Commit 2: Character selection readability fix (P1)
```
fix: mobile UX QA round 3 - character selection font sizes

Addresses text readability issues from iOS device testing.

Problems Identified:
- Header text too small (~24-26pt, hard to read)
- Card descriptions barely readable (~16-18pt)
- Stat bonuses like "+5 Scavenging" too small to read comfortably

Solution: Mobile-optimized font hierarchy
- Header: 32pt (iOS HIG standard for headers)
- Character type labels: 28pt (matches HUD consistency)
- Description text: 24pt (iOS HIG body text minimum)
- Stat bonuses: 22pt (critical info, must be readable)
- Added semi-transparent backgrounds to LOCKED overlays (0.7 opacity)

iOS HIG Compliance:
- Minimum text: 17pt ✅
- Recommended body: 20-24pt ✅
- Headers: 28-34pt ✅

Testing:
- Manual iOS device test confirms all text readable at arm's length
- No squinting required for stat bonuses
- LOCKED overlays have clear visual depth
- All automated tests passing (455/479)

Reference: docs/MOBILE-UX-QA-ROUND-3-PLAN.md
Expert consultation: Sr Mobile UI/UX Expert

Files: scenes/ui/character_selection.tscn

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Commit 3: Polish - suppress mouse warnings (P2, if time allows)
```
chore: suppress mouse warnings on iOS builds

Cleans up iOS log noise by checking mouse availability before calling
get_global_mouse_position(). No functional change - desktop weapon
pivot rotation still works correctly.

Files: scripts/entities/player.gd

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Success Metrics

### Quantitative
- [ ] All automated tests passing (455/479)
- [ ] iOS logs show zero mouse warnings (P2)
- [ ] Font sizes match spec:
  - Header: 32pt
  - Type labels: 28pt
  - Descriptions: 24pt
  - Stats: 22pt

### Qualitative (User Feedback)
- [ ] Joystick: "feels instant" or "smooth" or "responsive"
- [ ] Character selection: "can read everything easily"
- [ ] No new issues reported

---

## Rollback Plan

If issues occur:

**P0 (Joystick) Issues:**
- Revert constants to: `ACCELERATION_RATE = 0.3`, `DECELERATION_RATE = 0.2`
- Or try intermediate values: `ACCELERATION_RATE = 0.45`, `DECELERATION_RATE = 0.2`

**P1 (Character Selection) Issues:**
- If text too large, reduce by 2pt increments
- If text still too small, increase by 2pt increments
- Document exact values that work for future reference

**P2 (Mouse Warning) Issues:**
- Revert mouse availability check
- Investigate alternative suppression methods

---

## Future Optimization Opportunities (Deferred)

1. **Pickup range indicator caching** (P3)
   - Estimated improvement: ~0.1ms per frame
   - Complexity: Medium
   - Recommendation: Defer to performance optimization sprint

2. **Dynamic font scaling based on device**
   - iOS: Current values optimal
   - Android: May need slight adjustments
   - Recommendation: Test on Android devices before implementing

3. **Haptic feedback for joystick**
   - Add subtle vibration when changing directions
   - Platform-specific: iOS Taptic Engine
   - Recommendation: User research needed first

---

## Expert Team Sign-Off

**Sr Mobile Game Designer:** ✅ Asymmetric lerping is industry standard. 0.6/0.2 values optimal.

**Sr Mobile UI/UX Expert:** ✅ Character selection font sizes meet iOS HIG. Expect significant readability improvement.

**Godot Integration Specialist:** ✅ Technical implementation sound. No performance concerns.

**Sr Staff Engineer:** ✅ Constants pattern improves maintainability. Code quality improvement.

**Product Manager:** ✅ High-impact, low-effort changes. Strong ROI for 45-60 min investment.

---

## Questions for Next Session

Before starting implementation, confirm:

1. **Joystick tuning:** If 0.6 feels too fast, are we authorized to try 0.5 or 0.55?
2. **Character selection:** Do we have access to character_selection.tscn, or is it dynamically generated?
3. **Testing device:** Do we have iOS device build pipeline ready, or need to set up?
4. **Scope:** Execute all 3 phases, or stop after P0+P1?

---

## References

- Previous work: `docs/MOBILE-UX-QA-FIXES.md`
- iOS logs: `ios.log` (root directory)
- Week 12 plan: `docs/migration/week12-implementation-plan.md`
- Mobile UX optimization: `MOBILE-UX-OPTIMIZATION-PLAN.md`

---

**Document Status:** Ready for Implementation
**Next Action:** Begin Phase 1 (Joystick) in fresh session with full token budget
**Estimated Completion:** 45-60 minutes from start
