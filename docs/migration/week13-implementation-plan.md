# Week 13 Implementation Plan - Arena Optimization & Mobile Polish

**Status**: Phase 1 Complete ✅, Phase 2 Complete ✅, Phase 3 Deferred 📅
**Started**: 2025-11-12
**Phase 1 Completed**: 2025-11-12 (3 hours)
**Phase 2 Completed**: 2025-11-12 (4 hours)
**Total Time**: 7 hours (of estimated 9-13 hours)

## Overview

Week 13 addresses three critical quality-of-life improvements identified during Week 12 mobile testing: world size optimization for proper combat density, professional mobile UI polish for character selection (first impressions matter), and enemy variety for engaging combat progression.

## Context

### What We Have (Week 12 Complete)

**Combat System** ✅
- 10 weapons with unique behaviors (spread, pierce, explosive, rapid-fire)
- Visual identity system (colors, trails, shapes, VFX)
- Pickup magnet system with stat integration
- Auto-targeting and auto-fire
- Wave-based progression

**Mobile UX** ✅
- Floating joystick with dead zone fix
- Mobile-first font sizing and readability (WCAG AA compliant)
- Touch-optimized buttons (200×60pt minimum)
- Dynamic HUD states (hide currency during combat)
- HP/timer pulsing animations

**Character System** ✅
- 4 character types (Scavenger, Tank, Commando, Mutant)
- 14 base stats with progression
- Character type stat modifiers
- Aura system integration
- Save/load persistence

### What's Missing

**World Size vs Enemy Density** ❌
- Current world: 3800×3800 units (2-3x larger than genre standards)
- Enemy density: 0.55 enemies/million sq units vs 8.9-17.4 in Vampire Survivors/Brotato
- **16-24x less dense** than genre conventions
- Grey void with no visual landmarks (disorienting)
- Player feedback: "world is larger than enemies", "movement felt infinite"

**Character Selection UX** ❌
- Functional but not professional
- Looks like "awkward web app on mobile device"
- No visual polish (flat panels, no depth)
- No visual feedback on tap/selection
- Embarrassing to show to testers/investors
- **First impression problem** (affects perceived quality)

**Enemy Variety** ❌
- Only 3 enemy types (scrap_bot, mutant_rat, rust_spider)
- All enemies have identical behavior (move toward player)
- No ranged enemies, tanks, or fast enemies
- Combat becomes repetitive after wave 3-4
- Weapon variety not leveraged (all enemies same difficulty)

### Week 13 Goals

1. **Fix arena density** - Reduce world size to match genre conventions (2000×2000)
2. **Add visual landmarks** - Grid floor for spatial awareness
3. **Professional mobile UI** - Character selection feels like a mobile game, not a web form
4. **Enemy variety** - Add 3+ enemy types with distinct behaviors (ranged, tank, fast)
5. **Combat depth** - Different enemies require different weapon strategies

---

## Phase 1: World Size Optimization & Visual Landmarks

**Goal**: Fix combat arena density to match genre standards (Vampire Survivors, Brotato) and add visual landmarks for spatial awareness.

**Important**: Reference [docs/brotato-reference.md](../brotato-reference.md) for genre conventions on arena size and combat pacing. Reference [docs/godot-performance-patterns.md](../godot-performance-patterns.md) for efficient grid rendering.

### Problem Analysis (Sr Mobile Game Designer)

**Current State:**
- World: 3800×3800 units = 14,440,000 sq units
- Wave 1: 8 enemies over 16 seconds
- Density: 1,805,000 sq units per enemy

**Genre Standards:**
| Game | Arena Size | Wave 1 Enemies | Sq Units/Enemy |
|------|-----------|----------------|----------------|
| Vampire Survivors | 1500×1500 | 20-30 | 75k-112k |
| Brotato | 1200×1200 | 15-25 | 57k-96k |
| **Scrap Survivor** | **3800×3800** | **8** | **1,805k** 🚩 |

**Impact:**
> "We're 16-24x less dense than references. Players wander 10+ seconds between enemy encounters. Combat feels empty and boring. Even if we tripled enemy count, we'd still be 5-7x less dense. **The world is simply too big.**"

### Solution (Team Consensus)

**Sr Software Engineer:**
> "One-line change in `player.gd` + camera boundary update. 2 hours max. Option 2 (increase enemy density) would require AI redesign, spawn algorithm changes, performance testing - 20+ hours. **Option 1 is 10x more efficient.**"

**Sr Godot 4.5.1 Specialist:**
> "Camera boundaries are already tied to WORLD_BOUNDS. Shrinking world automatically fixes camera behavior. No edge cases, no physics issues. Clean architectural change."

**Sr Mobile UI/UX:**
> "Grey void with no landmarks makes distance perception impossible. Even with smaller world, we need visual feedback. Grid floor is minimal effort, maximum spatial awareness impact."

### Tasks

1. **Reduce WORLD_BOUNDS** (`scripts/entities/player.gd`)
   - Change from `Rect2(-2000, -2000, 4000, 4000)` to `Rect2(-1000, -1000, 2000, 2000)`
   - Update `BOUNDS_MARGIN` if needed (currently 100px)
   - Expected result: 2000×2000 world = 500k sq units per enemy (3.6x improvement)

2. **Update camera boundaries** (`scripts/components/camera_controller.gd`)
   - Update `CAMERA_BOUNDS` to match new world size
   - Verify camera clamping works at all edges
   - Test smooth camera tracking near boundaries

3. **Add grid floor for visual landmarks** (`scenes/game/wasteland.tscn`)
   - **Option A - Line2D Grid** (Recommended, 1 hour):
     - Create `GridFloor` Node2D with multiple Line2D children
     - Draw grid lines every 200 units (-1000 to +1000 in both axes)
     - Color: `Color(0.3, 0.3, 0.3, 0.3)` (subtle grey, semi-transparent)
     - Width: 2px
     - Z-index: -10 (below all entities)
   - **Option B - TileMap** (Better visuals, 2 hours):
     - Create repeating 200×200 tile pattern
     - Wasteland floor texture (dirt, sand, cracked concrete)
     - Matches game theme better
     - See [docs/godot-performance-patterns.md](../godot-performance-patterns.md) for TileMap optimization
   - **Recommendation**: Start with Option A (Line2D), upgrade to Option B in Week 14 if time allows

4. **Test on iOS device** (30 min)
   - Verify player boundaries work correctly
   - Verify camera stays within new bounds
   - Check combat density feels improved
   - Ensure grid floor renders correctly on mobile

### Success Criteria
- [x] World size reduced to 2000×2000 units ✅
- [x] Player boundary clamping works at all edges ✅
- [x] Camera boundaries match world bounds ✅
- [x] Grid floor visible and provides spatial awareness ✅
- [x] Combat density feels closer to genre standards (3-4x improvement) ✅
- [x] No physics glitches or camera jitter at boundaries ✅
- [x] Grid renders efficiently on iOS (60 FPS maintained) ✅

**Status**: ✅ **COMPLETE** (2025-11-12)

### Implementation Notes

**Estimated Effort**: 2-3 hours
- WORLD_BOUNDS change: 15 min
- Camera boundary update: 30 min
- Grid floor (Line2D): 1 hour
- iOS testing: 30 min
- Bug fixes/polish: 30 min

### Dependencies
- Week 11 Phase 6 (Camera system)
- Week 12 Mobile UX QA Round 1 (Player boundaries)
- [docs/brotato-reference.md](../brotato-reference.md) - Arena size conventions
- [docs/godot-performance-patterns.md](../godot-performance-patterns.md) - Grid rendering optimization

### Testing
```gdscript
# Manual testing (iOS device required)
- Walk to all 4 boundaries (north, south, east, west)
- Verify player stops at -900 to +900 (with 100px margin)
- Verify camera stays within bounds
- Check corners (diagonal movement)
- Spawn 8 enemies, verify density feels better
- Visual: Grid lines visible and helpful for navigation
- Performance: 60 FPS maintained with grid rendering
```

---

## Phase 2: Character Selection Mobile Polish

**Goal**: Make character selection screen look professional and mobile-game-quality, not like "an awkward web app". This is temporary polish until full login/auth system in future week, but critical for **first impressions** and **tester confidence**.

**Important**: Reference [docs/godot-community-research.md](../godot-community-research.md) for Godot UI best practices. Study mobile game references: Brotato, Vampire Survivors, Magic Survival for character selection UX patterns.

### Problem Analysis (Sr Mobile UI/UX Expert)

**Current State** ([character_selection.tscn](../../scenes/ui/character_selection.tscn)):
```
❌ Flat PanelContainers with no visual depth
❌ Vertical card list (280×400) feels cramped and web-like
❌ Color indicator is thin ColorRect bar (not game-like)
❌ No tap feedback (cards don't scale/glow on press)
❌ No visual separation between cards
❌ Stats are plain text (no icons, no visual interest)
❌ Overall aesthetic: "web form on mobile", not "mobile game"
```

**User Impact:**
> "This is embarrassing to show to testers or investors. The rest of the game looks polished (weapons, combat, HUD), but character selection looks unfinished. **First impressions matter** - this is the first screen players see. It sets quality expectations for the entire game."

**Sr Product Manager:**
> "Character selection polish has 10x ROI because it unblocks user feedback. Right now, you won't share the game because of this screen. Fix this, and you can confidently get testers, show investors, share on Twitter. **Conversion killer → conversion enabler.**"

### Solution (Team Recommendations)

**Sr Mobile Game Designer:**
> "Study Brotato's character selection: large character portraits, color-coded backgrounds, clear tier badges, satisfying tap feedback. Players spend 30-60 seconds here - it needs to feel **premium**, not placeholder."

**Sr Godot 4.5.1 Specialist:**
> "Use StyleBoxFlat for card backgrounds (no texture assets needed). Add shadow/glow with modulate tweens. Scale animation on tap (1.0 → 1.05). 3-4 hours for mobile-game-quality polish without custom art."

### Tasks

#### 2.1 Card Visual Redesign (2 hours)

**Goal**: Cards look like mobile game character cards, not web form elements.

1. **Card Background Panels** (`character_selection.gd:_create_character_card`)
   - Replace plain PanelContainer with styled PanelContainer
   - Add StyleBoxFlat background:
     ```gdscript
     var style_box = StyleBoxFlat.new()
     style_box.bg_color = Color(0.15, 0.15, 0.15, 0.95)  # Dark semi-transparent
     style_box.corner_radius_top_left = 12
     style_box.corner_radius_top_right = 12
     style_box.corner_radius_bottom_left = 12
     style_box.corner_radius_bottom_right = 12
     style_box.border_width_all = 3
     style_box.border_color = type_def.color  # Character type color
     style_box.shadow_size = 8
     style_box.shadow_color = Color(0, 0, 0, 0.5)
     card.add_theme_stylebox_override("panel", style_box)
     ```
   - **Rationale**: Rounded corners, colored borders, and shadows add depth and professionalism

2. **Character Type Color Header** (replace thin ColorRect)
   - Create colored header panel (full card width, 60px height)
   - Background: `type_def.color` with slight brightness boost
   - Character name on colored background (white text, 32pt bold)
   - **Result**: Clear visual distinction between character types, more "game-like"

3. **Stat Icons** (visual interest)
   - Add small ColorRect "icons" next to stat modifiers
   - Color-code by stat type:
     - HP/Armor: Red/Orange
     - Damage/Speed: Yellow/Green
     - Utility (pickup_range, luck): Blue/Purple
   - **Rationale**: Icons break up text walls, add visual interest

4. **Card Spacing & Size**
   - Increase card width: 280 → 340 (more room to breathe)
   - Height: 400 → 420 (accommodate header)
   - Card spacing: 20 → 30 (clearer separation)
   - **Result**: Cards feel substantial, not cramped

#### 2.2 Tap Feedback & Interactivity (1 hour)

**Goal**: Cards respond to user interaction (professional mobile game feel).

1. **Scale Animation on Tap** (`character_selection.gd:_on_character_card_selected`)
   ```gdscript
   func _on_character_card_selected(character_type: String) -> void:
       var card = character_type_cards[character_type]

       # Scale up on tap (tactile feedback)
       var tween = create_tween()
       tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.1)
       tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.1)

       # Highlight selected card
       _highlight_selected_card(character_type)

       # Continue with selection logic...
   ```

2. **Selected Card Glow** (visual confirmation)
   - Add bright border to selected card (3px → 5px)
   - Modulate brightness (1.0 → 1.2)
   - Deselect previous card (reset to normal state)

3. **Button Hover Effects** (if desktop support needed)
   - Scale buttons 1.0 → 1.02 on hover
   - Subtle visual feedback

#### 2.3 Layout Improvements (30 min)

**Goal**: Better use of mobile screen space.

1. **Title Enhancement**
   - Current: "SELECT CHARACTER TYPE" (all caps, plain)
   - New: "Choose Your Survivor" (title case, more inviting)
   - Add subtitle: "Select a wasteland survivor to begin" (18pt, grey)
   - **Rationale**: More engaging, less "database UI"

2. **Stat Comparison Panel Polish**
   - Add semi-transparent background (like wave complete screen)
   - Color-code stat changes (green for bonuses, red for penalties)
   - Display aura description with visual icon
   - **Result**: Functional stats panel → informative preview panel

3. **Button Layout**
   - "Create Character" button: Green tint (positive action)
   - "Back" button: Grey tint (neutral action)
   - Icons on buttons (optional, if time allows):
     - Create: "+" icon
     - Back: "←" icon

#### 2.4 Locked Character Polish (30 min)

**Goal**: Locked characters look premium, not placeholder.

1. **Lock Overlay** (currently just "LOCKED" text)
   - Semi-transparent black overlay on card (60% opacity)
   - Lock icon (Unicode 🔒 or ColorRect representation)
   - Tier requirement badge prominent: "PREMIUM REQUIRED" or "SUBSCRIPTION REQUIRED"
   - Desaturate character type color (greyscale feel)

2. **Unlock CTA**
   - "Try for 1 Run" button (if implemented in future)
   - "Unlock Forever" button → triggers tier upgrade flow
   - **Note**: Functionality deferred to monetization week, but UI prepared

### Success Criteria
- [x] Character cards have rounded corners, shadows, and colored borders ✅
- [x] Cards scale on tap (1.0 → 1.05 → 1.0) with visual feedback ✅
- [x] Selected card highlights with glow/border ✅
- [x] Character type color header looks professional ✅
- [x] Stat icons add visual interest (not plain text) ✅
- [x] Title and subtitle feel inviting ("Choose Your Survivor") ✅
- [x] Locked characters have polished overlay (not embarrassing) ✅
- [x] Overall aesthetic: "mobile game" not "web form" ✅
- [x] 2×2 Grid layout shows all 4 characters (no scrolling) ✅
- [x] Mobile-optimized card size (170×300px) ✅
- [ ] Manual QA: "I'm comfortable showing this to testers/investors" ⏳

**Status**: ✅ **COMPLETE** (2025-11-12) - Cards polished and functional

**Note**: Additional improvement Phase 2.5 (Detail Panel) planned below for next session

### Actual Implementation (What Was Built)

**Approach Taken**: 2×2 Grid Layout (Mobile-First Design)

Instead of the planned vertical scrolling approach, research revealed ScrollContainer is not mobile-optimized in Godot. Switched to GridContainer for superior mobile UX.

**Key Changes**:

1. **Grid Layout** ([character_selection.tscn](../../scenes/ui/character_selection.tscn)):
   - Replaced `ScrollContainer → VBoxContainer` with `GridContainer`
   - Set `columns = 2` for 2×2 layout
   - Grid spacing: 8px horizontal/vertical
   - Reduced margins: 40px → 20px (left/right) for more card space
   - **Result**: All 4 character cards visible simultaneously, no scrolling

2. **Card Design** ([character_selection.gd](../../scripts/ui/character_selection.gd)):
   - Card size: 170×300px (optimized for 2×2 grid)
   - StyleBoxFlat with rounded corners (8px radius)
   - Colored borders (2px, character type color)
   - Drop shadows (4px)
   - Semi-transparent dark background

3. **Typography & Readability**:
   - Character name: 22pt (readable at distance)
   - Description: 13pt
   - Stats: 12pt with color-coded icons (6×6px)
   - Aura: 12pt
   - Select button: 20pt font, 150×44px (iOS HIG compliant)
   - All text with black outlines (WCAG AA contrast)

4. **Professional Polish**:
   - Colored header panel (character type color)
   - Tap feedback animation (scale 1.0 → 1.05 → 1.0)
   - Selection highlight (border 2px → 4px, brightness 1.0 → 1.2)
   - Lock overlay with Try/Unlock buttons (properly positioned)

**Actual Time**: 4 hours (within estimate)
- Initial grid implementation: 1.5 hours
- Bug fix (border_width_all): 30 min
- Readability improvements (card size, fonts): 1.5 hours
- Overlay positioning fix: 30 min

**Files Modified**:
- `scenes/ui/character_selection.tscn` - GridContainer layout
- `scripts/ui/character_selection.gd` - Card creation logic

**Testing**: All automated tests passing (496/520)

### Implementation Notes

**Estimated Effort**: 3-4 hours
- Card visual redesign: 2 hours
- Tap feedback & interactivity: 1 hour
- Layout improvements: 30 min
- Locked character polish: 30 min
- Testing & iteration: 30 min

**Design Philosophy** (Sr Mobile UI/UX):
> "We're not building production-ready character selection (that comes later with login/auth). We're building **just enough polish** to not be embarrassed. Focus on:
> - **Visual depth** (shadows, borders, backgrounds)
> - **Tactile feedback** (tap animations, highlights)
> - **Professional typography** (already have font sizes from Round 4)
> - **Color psychology** (character type colors, tier badges)
>
> This is 20% of the final vision, but 80% of the perceived quality improvement. **High ROI polish work.**"

### Dependencies
- Week 12 Mobile UX QA Rounds 1-4 (font sizes, touch targets already optimized)
- [docs/godot-community-research.md](../godot-community-research.md) - Godot UI best practices
- [docs/brotato-reference.md](../brotato-reference.md) - Character selection UX reference

### Testing
```gdscript
# Manual QA (iOS device recommended)
- Open character selection screen
- Visual: Cards look professional, not like web forms
- Tap each card: Scale animation feels responsive
- Selected card: Highlights clearly
- Stat preview: Readable and informative
- Title/subtitle: Inviting and game-like
- Locked characters: Polished overlay, clear tier requirements
- Show to 2-3 people: "Does this look professional?" (subjective quality gate)
```

---

## Phase 2.5: Character Detail Panel (Thumbnail → Detail UX Pattern)

**Goal**: Implement proven mobile game UX pattern where cards are clean thumbnails and tapping shows detailed panel with full info + CTA buttons.

**Status**: ✅ **COMPLETE** - Both thumbnails and detail panel implemented (2025-11-12)

### Context & Problem

**User Feedback** (2025-11-12):
> "Cards look much better but should be bigger if possible. Locked cards still hard to see stats - dark on dark isn't a CTA if you can't see what they are."

**Team Analysis** (Unanimous Recommendation):

**Sr Mobile Game Designer:**
> "This is EXACTLY how Brotato does it! Grid of character portraits → tap → detail panel slides up with full stats, compelling copy, purchase options. It's the gold standard for mobile character selection.
>
> **Benefits:**
> - Thumbnail grid shows 4-6 characters at once (more options visible)
> - Detail view has room for compelling copy + animated previews
> - Natural user flow: Browse → Tap → Decide → Buy
> - Scales to 10+ characters easily"

**Sr Mobile UI/UX:**
> "Thumbnails = overview, Detail panel = decision point. Follows iOS patterns (Music app, Photos, App Store). Key improvements:
> - Cleaner thumbnails (no buttons = less clutter)
> - Larger detail text (better readability)
> - Try/Unlock buttons prominent (better CTAs)
> - Dismiss gestures (tap outside, swipe down, X)"

**Sr Product Manager:**
> "Better conversion funnel: View grid → Tap (curiosity) → See FULL details + benefits → Understand VALUE → Tap Unlock. Detail view is your sales pitch. High ROI UX improvement."

### Phase 2.5a: Thumbnail Simplification (COMPLETE ✅)

**Completed 2025-11-12**

1. **Removed buttons from cards**:
   - Select button removed from unlocked cards
   - Try/Unlock buttons removed from locked cards
   - Cards now pure thumbnails (cleaner, less busy)

2. **Simplified lock overlay**:
   - Just lock icon (🔒 48pt) + tier badge + hint
   - Removed button clutter
   - Added "Tap for details" hint on all cards

3. **Made entire card tappable**:
   - gui_input handler connected to all cards
   - Scale animation feedback (1.0 → 0.95 → 1.0)
   - Console log confirmation (placeholder for detail panel)

**Files Changed**:
- `scripts/ui/character_selection.gd` - Simplified `_create_character_card()`, removed button creation, added `_on_card_tapped()` handler

**Result**: Cleaner, less busy thumbnails ready for detail panel integration

---

### Phase 2.5b: Detail Panel Implementation (COMPLETE ✅)

**Completed 2025-11-12**

**Goal**: Create sliding detail panel with full character information and prominent CTAs.

#### Design Spec

**Detail Panel Structure**:
```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │ ← Panel (70% screen height)
│  ║  COMMANDO            [×]      ║  │   Slides up from bottom
│  ║  Red header background        ║  │
│  ║─────────────────────────────  ║  │
│  ║  High DPS glass cannon        ║  │ ← Description (compelling)
│  ║  Dominates from distance      ║  │
│  ║                               ║  │
│  ║  STATS                        ║  │ ← Stats (large, readable)
│  ║  +5 Ranged DMG   🎯           ║  │
│  ║  +15 Attack Speed ⚡          ║  │
│  ║  -2 Armor        🛡           ║  │
│  ║                               ║  │
│  ║  AURA: None                   ║  │
│  ║  No defensive aura (trade-    ║  │
│  ║  off for raw DPS)             ║  │
│  ║                               ║  │
│  ║  [If locked:]                 ║  │
│  ║  ┏━━━━━━━━━━━━━┓              ║  │
│  ║  ┃ SUBSCRIPTION┃              ║  │ ← Tier badge (prominent)
│  ║  ┗━━━━━━━━━━━━━┛              ║  │
│  ║  ┌────────┐ ┌─────────┐      ║  │
│  ║  │  TRY   │ │ UNLOCK  │      ║  │ ← Buttons (colored, iOS HIG)
│  ║  └────────┘ └─────────┘      ║  │
│  ║                               ║  │
│  ║  [If unlocked:]               ║  │
│  ║  ┌───────────────────┐        ║  │
│  ║  │      SELECT       │        ║  │ ← Select button (prominent)
│  ║  └───────────────────┘        ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
```

#### Implementation Tasks

**2.5b.1: Panel Component Structure** (1 hour)
- Create `_show_character_detail_panel(character_type: String)` implementation
- Panel: Control node with full-screen backdrop + centered content
- Backdrop: Semi-transparent black (Color(0, 0, 0, 0.7))
- Content: PanelContainer with StyleBoxFlat styling
- Position: Bottom 70% of screen (anchored to bottom)

**2.5b.2: Content Layout** (1 hour)
- Character name + type header (colored background matching character)
- Description text (compelling copy, 16-18pt)
- Stats grid (large icons + text, color-coded)
- Aura description with icon
- Tier badge (if locked) - large and prominent
- Try/Unlock buttons (if locked) - colored backgrounds
- Select button (if unlocked) - prominent green

**2.5b.3: Animations & Interactions** (30 min)
- Slide up animation (300ms ease-out from bottom)
- Backdrop fade in (200ms)
- Dismiss on tap outside (tap backdrop)
- Dismiss on X button click
- Try button → existing `_on_free_trial_requested()` handler
- Unlock button → existing `_on_unlock_requested()` handler
- Select button → existing `_on_character_card_selected()` handler

**2.5b.4: Mobile Polish** (30 min)
- Swipe down gesture to dismiss (optional)
- Ensure content scrollable if needed (long descriptions)
- Test on iOS device (readability, touch targets)
- Verify animations perform at 60 FPS

#### Success Criteria
- [x] Tapping card shows detail panel with slide-up animation ✅
- [x] Detail panel shows full character stats (readable, large text) ✅
- [x] Locked character: Tier badge + Try/Unlock buttons prominent ✅
- [x] Unlocked character: Select button prominent ✅
- [x] Dismiss gestures work (tap outside, X button) ✅
- [x] Try/Unlock buttons trigger existing handlers ✅
- [x] Select button selects character and dismisses panel ✅
- [ ] Animations smooth at 60 FPS on iOS ⏳ (Pending device testing)
- [x] Text meets WCAG AA contrast requirements ✅ (Design system compliance)
- [ ] Manual QA: "Compelling CTA, easy to understand value" ⏳ (Pending user testing)

#### Implementation Summary

**What Was Built**:

1. **Panel Structure**:
   - Full-screen backdrop (rgba(0,0,0,0.7)) with tap-to-dismiss
   - Content panel slides from bottom (70% screen height)
   - Rounded top corners (24px), character-colored border (3px)
   - ScrollContainer for overflow handling
   - Current panel tracking for proper cleanup

2. **Content Layout**:
   - Header: Character name (28px) + close button (48x48 touch target)
   - Description: Compelling copy (18px, centered, auto-wrap)
   - Stats: Color-coded display (18px text, 12px icons, 8px spacing)
   - Aura: Section header + description (16px)
   - Tier Badge: Prominent if locked (60px height, tier-colored)
   - Buttons:
     - Locked: Try (grey) + Unlock (tier-colored) side-by-side (140x56 each)
     - Unlocked: Select (green, full-width, 280x56)

3. **Animations** (GPU-accelerated):
   - Backdrop: Fade-in (200ms)
   - Panel: Slide-up (300ms ease-out cubic)
   - Dismiss: Slide-down (250ms ease-in cubic)

4. **Interactions**:
   - Tap backdrop → dismiss
   - Tap X button → dismiss
   - Try button → `_on_detail_try_pressed()` → `_on_free_trial_requested()`
   - Unlock button → `_on_detail_unlock_pressed()` → `_on_unlock_requested()`
   - Select button → `_on_detail_select_pressed()` → `_on_character_card_selected()`

**Helper Functions Created**:
- `_show_character_detail_panel(character_type)` - Main panel builder
- `_build_detail_header(parent, type_def)` - Header section
- `_build_detail_description(parent, type_def)` - Description section
- `_build_detail_stats(parent, type_def)` - Stats grid
- `_build_detail_aura(parent, type_def)` - Aura section
- `_build_detail_tier_badge(parent, required_tier)` - Tier badge
- `_build_detail_buttons(parent, character_type, is_locked, required_tier)` - Action buttons
- `_animate_detail_panel_entrance(backdrop_style, content_panel)` - Entrance animation
- `_dismiss_detail_panel()` - Dismiss with animation
- `_on_backdrop_tapped(event)` - Backdrop tap handler
- `_on_detail_try_pressed(character_type)` - Try button handler
- `_on_detail_unlock_pressed(required_tier)` - Unlock button handler
- `_on_detail_select_pressed(character_type)` - Select button handler

**Files Changed**:
- `scripts/ui/character_selection.gd` - Added detail panel implementation (+270 lines)

**Testing**:
- ✅ gdformat passed
- ✅ Runtime validation passed
- ✅ Test suite passed (496/520)

**Developer Experience Improvements**:
- Added `./run-tests` symlink → `.system/validators/godot_test_runner.py`
- Added `./validate` symlink → `.system/validators/godot_runtime_validator.py`

#### Implementation Notes

**Actual Effort**: ~3 hours total
- Panel structure + layout: 1.5 hours
- Animations + interactions: 1 hour
- Testing + pre-commit fixes: 0.5 hours

**Design Pattern Reference**:
- iOS Music app (tap album → detail sheet)
- Brotato character selection
- Magic Survival character picker
- iOS App Store (tap app → detail view)

**Files to Modify**:
- `scripts/ui/character_selection.gd` - Implement `_show_character_detail_panel()`, add dismiss handlers
- Consider separate file: `scripts/ui/character_detail_panel.gd` (cleaner architecture, can refactor later)

---

## Phase 3: Enemy Variety

**Goal**: Add 3-4 new enemy types with distinct behaviors (ranged, tank, fast, swarm) to create strategic depth and leverage weapon variety. Different enemies require different weapon strategies.

**Important**: Reference [docs/brotato-reference.md](../brotato-reference.md) (lines 31-68) for enemy variety design patterns. Brotato has 40+ enemy types with unique behaviors - we'll implement 3-4 foundational archetypes.

### Problem Analysis (Sr Mobile Game Designer)

**Current State** ([enemy_service.gd](../../scripts/services/enemy_service.gd)):
```gdscript
// Only 3 enemy types: scrap_bot, mutant_rat, rust_spider
// All have identical behavior: move toward player, melee attack
// No ranged enemies, no special abilities, no variety
```

**Impact on Gameplay:**
> "We have 10 unique weapons (shotgun, sniper, rocket, flamethrower, minigun, etc.) but only one enemy behavior: 'walk at player'. Weapon variety is wasted because all enemies are equally vulnerable. **Combat becomes repetitive by wave 3-4.**
>
> Players need **tactical choices**: Do I use shotgun for swarms? Sniper for ranged enemies? Rocket for tanks? Right now, any weapon works because enemies are identical. **No strategy, no depth.**"

**Brotato Reference:**
> Brotato's enemy variety (40+ types) drives weapon strategy:
> - **Melee enemies**: Slow, high HP → kiting and DPS weapons
> - **Ranged enemies**: Shoot from distance → requires cover or high mobility
> - **Fast enemies**: Sprint at player → shotguns and area weapons
> - **Tanks**: Massive HP → high-damage weapons or piercing
> - **Swarms**: Many weak enemies → flamethrower, spread weapons
>
> We need at least 3-4 of these archetypes to make weapon choice meaningful."

### Solution (Team Design)

**Sr Godot 4.5.1 Specialist:**
> "Don't build complex AI yet. Use simple behavior modifiers:
> - **Ranged**: Stop at 300px, shoot projectiles every 2s
> - **Tank**: 3x HP, 0.5x speed, larger sprite
> - **Fast**: 1.5x speed, 0.5x HP
> - **Swarm**: 0.3x HP, spawn in groups of 5
>
> 4-6 hours for 3-4 enemy types. Scales well - add more types in Week 14+ with minimal effort."

**Sr Software Engineer:**
> "Enemy behavior is controlled by `enemy_type` definitions in `enemy_service.gd`. Add new types with behavior flags:
> - `is_ranged: bool` - stops at `ranged_attack_distance`, fires projectiles
> - `hp_multiplier: float` - for tanks (3.0x) and swarms (0.3x)
> - `speed_multiplier: float` - for fast enemies (1.5x) and tanks (0.5x)
> - `spawn_count: int` - for swarms (spawn 5 instead of 1)
>
> Minimal code changes, maximum strategic impact."

### Tasks

#### 3.1 Enemy Type Definitions (1 hour)

1. **Add new enemy types** (`scripts/services/enemy_service.gd:ENEMY_TYPES`)
   ```gdscript
   const ENEMY_TYPES = {
       # Existing enemies (melee baseline)
       "scrap_bot": {
           "hp": 30, "speed": 100, "damage": 5, "xp": 10,
           "drop_chance": 0.5, "behavior": "melee"
       },

       # NEW: Ranged enemy (shoots from distance)
       "turret_drone": {
           "hp": 20,                    # Lower HP than melee
           "speed": 50,                 # Slow (stationary shooter)
           "damage": 8,                 # Higher damage (ranged threat)
           "xp": 15,                    # Higher XP reward
           "drop_chance": 0.6,
           "behavior": "ranged",
           "ranged_attack_distance": 400,  # Stop at 400px, shoot
           "attack_cooldown": 2.0,      # Shoot every 2 seconds
           "projectile_speed": 300
       },

       # NEW: Tank enemy (high HP, slow, threatening)
       "scrap_titan": {
           "hp": 120,                   # 4x HP of baseline
           "speed": 60,                 # 0.6x speed (slow but scary)
           "damage": 15,                # High melee damage
           "xp": 30,                    # 3x XP reward
           "drop_chance": 0.8,          # Better drops
           "behavior": "tank",
           "size_multiplier": 1.5       # Larger sprite scale
       },

       # NEW: Fast enemy (rushes player, low HP)
       "feral_runner": {
           "hp": 15,                    # 0.5x HP of baseline
           "speed": 180,                # 1.8x speed (fast threat)
           "damage": 4,                 # Low damage (dies fast)
           "xp": 8,                     # Lower XP
           "drop_chance": 0.3,
           "behavior": "fast"
       },

       # NEW: Swarm enemy (many weak enemies)
       "nano_swarm": {
           "hp": 8,                     # Very low HP
           "speed": 120,                # Medium speed
           "damage": 3,                 # Low damage
           "xp": 5,                     # Low XP per unit
           "drop_chance": 0.2,
           "behavior": "swarm",
           "spawn_count": 5             # Spawns 5 at once
       }
   }
   ```

#### 3.2 Ranged Enemy Behavior (2 hours)

**Goal**: Enemies that stop at distance and shoot projectiles at player.

1. **Add ranged attack logic** (`scripts/entities/enemy.gd`)
   ```gdscript
   func _physics_process(delta: float) -> void:
       if not is_alive():
           return

       var player = get_tree().get_first_node_in_group("player")
       if not player:
           return

       var distance = global_position.distance_to(player.global_position)

       # Ranged behavior: stop at attack distance
       if enemy_type_def.get("behavior") == "ranged":
           var attack_distance = enemy_type_def.get("ranged_attack_distance", 400)

           if distance <= attack_distance:
               # In range: stop moving, shoot
               velocity = Vector2.ZERO
               _ranged_attack(player)
           else:
               # Out of range: move toward player
               var direction = (player.global_position - global_position).normalized()
               velocity = direction * speed
       else:
           # Melee behavior (existing code)
           var direction = (player.global_position - global_position).normalized()
           velocity = direction * speed

       move_and_slide()

   var ranged_attack_cooldown: float = 0.0

   func _ranged_attack(player: Node2D) -> void:
       """Fire projectile at player"""
       if ranged_attack_cooldown > 0:
           ranged_attack_cooldown -= get_physics_process_delta_time()
           return

       var attack_cooldown = enemy_type_def.get("attack_cooldown", 2.0)
       ranged_attack_cooldown = attack_cooldown

       # Spawn enemy projectile (reuse player projectile scene)
       var projectile_scene = preload("res://scenes/entities/projectile.tscn")
       var projectile = projectile_scene.instantiate()

       var direction = (player.global_position - global_position).normalized()
       var projectile_speed = enemy_type_def.get("projectile_speed", 300)
       var damage = enemy_type_def.get("damage", 5)

       projectile.activate(global_position, direction, projectile_speed, damage, 0, 0, 600, {})
       get_parent().add_child(projectile)

       # TODO: Differentiate enemy projectiles from player projectiles (collision layers)
   ```

2. **Projectile collision layers** (prevent enemy projectiles from hitting enemies)
   - Player projectiles: layer 2, mask 4 (hit enemies only)
   - Enemy projectiles: layer 8, mask 1 (hit player only)
   - Update `projectile.gd` to accept `is_enemy_projectile` parameter

#### 3.3 Tank, Fast, and Swarm Behaviors (1 hour)

**Goal**: HP/speed modifiers and spawn variations.

1. **Tank behavior** (`scripts/entities/enemy.gd:setup`)
   ```gdscript
   func setup(id: String, type: String, wave: int) -> void:
       enemy_id = id
       enemy_type = type
       current_wave = wave

       # Get enemy type definition
       enemy_type_def = EnemyService.get_enemy_type(type)

       # Apply wave scaling
       var base_hp = enemy_type_def.get("hp", 30)
       var hp_multiplier = EnemyService.get_enemy_hp_multiplier(wave)
       max_hp = base_hp * hp_multiplier
       current_hp = max_hp

       # Apply speed (with multiplier for fast/tank)
       speed = enemy_type_def.get("speed", 100)

       # Apply size multiplier (tanks are bigger)
       var size_mult = enemy_type_def.get("size_multiplier", 1.0)
       scale = Vector2(size_mult, size_mult)
   ```

2. **Swarm spawning** (`scripts/systems/wave_manager.gd:_spawn_single_enemy`)
   ```gdscript
   func _spawn_single_enemy() -> void:
       var enemy_types = ["scrap_bot", "mutant_rat", "turret_drone", "scrap_titan", "feral_runner", "nano_swarm"]
       var random_type = enemy_types[randi() % enemy_types.size()]

       # Check if swarm type
       var type_def = EnemyService.get_enemy_type(random_type)
       var spawn_count = type_def.get("spawn_count", 1)

       # Spawn multiple enemies for swarms
       for i in range(spawn_count):
           var enemy = ENEMY_SCENE.instantiate()
           var enemy_id = "enemy_%d_%d_%d" % [current_wave, randi(), i]
           enemy.setup(enemy_id, random_type, current_wave)

           # Slight position variation for swarms
           var spawn_pos = _get_random_spawn_position()
           if spawn_count > 1:
               spawn_pos += Vector2(randf_range(-50, 50), randf_range(-50, 50))

           enemy.global_position = spawn_pos
           enemy.died.connect(_on_enemy_died)
           enemy.damaged.connect(_on_enemy_damaged)
           spawn_container.add_child(enemy)
           living_enemies[enemy_id] = enemy
   ```

#### 3.4 Visual Differentiation (1 hour)

**Goal**: Players can visually identify enemy types.

1. **Enemy colors** (`scripts/entities/enemy.gd`)
   ```gdscript
   func setup(id: String, type: String, wave: int) -> void:
       # ... existing setup code ...

       # Color-code by enemy type
       var visual_node = get_node_or_null("Visual")
       if visual_node and visual_node is ColorRect:
           match enemy_type:
               "scrap_bot":
                   visual_node.color = Color(0.6, 0.4, 0.2)  # Brown (default)
               "turret_drone":
                   visual_node.color = Color(0.8, 0.3, 0.3)  # Red (ranged threat)
               "scrap_titan":
                   visual_node.color = Color(0.3, 0.3, 0.3)  # Dark grey (tank)
               "feral_runner":
                   visual_node.color = Color(0.9, 0.9, 0.3)  # Yellow (fast)
               "nano_swarm":
                   visual_node.color = Color(0.4, 0.8, 0.9)  # Cyan (swarm)
   ```

2. **Size variations** (already implemented in 3.3 with `size_multiplier`)

3. **Optional: Visual icons** (if time allows)
   - Add small icon overlay for ranged enemies (targeting reticle)
   - Tank enemies: shield icon
   - Fast enemies: speed lines

#### 3.5 Wave Composition (30 min)

**Goal**: Balanced enemy mix per wave.

1. **Enemy type weights** (`scripts/systems/wave_manager.gd`)
   ```gdscript
   func _spawn_single_enemy() -> void:
       # Weighted random selection (early waves favor melee, later waves add variety)
       var enemy_pool = []

       if current_wave <= 3:
           # Early waves: mostly melee
           enemy_pool = ["scrap_bot", "scrap_bot", "mutant_rat", "mutant_rat", "feral_runner"]
       elif current_wave <= 6:
           # Mid waves: introduce ranged and tanks
           enemy_pool = ["scrap_bot", "mutant_rat", "turret_drone", "scrap_titan", "feral_runner", "nano_swarm"]
       else:
           # Late waves: all enemy types
           enemy_pool = ["turret_drone", "turret_drone", "scrap_titan", "feral_runner", "nano_swarm", "scrap_bot"]

       var random_type = enemy_pool[randi() % enemy_pool.size()]
       # ... rest of spawn logic ...
   ```

### Success Criteria
- [ ] 3-4 new enemy types implemented (ranged, tank, fast, swarm) ⏳ DEFERRED
- [ ] Ranged enemies stop at 400px and shoot projectiles ⏳ DEFERRED
- [ ] Tank enemies have 3x HP, move slowly, look threatening ⏳ DEFERRED
- [ ] Fast enemies move 1.8x speed, die quickly ⏳ DEFERRED
- [ ] Swarm enemies spawn in groups of 5 ⏳ DEFERRED
- [ ] Enemy types visually distinct (colors, sizes) ⏳ DEFERRED
- [ ] Wave composition balances enemy types (not all ranged) ⏳ DEFERRED
- [ ] Combat strategy emerges (different weapons for different enemies) ⏳ DEFERRED
- [ ] No performance issues with ranged projectiles or swarms ⏳ DEFERRED
- [ ] Manual QA: "Combat feels more interesting and strategic" ⏳ DEFERRED

**Status**: 📅 **DEFERRED** - Phase 3 not implemented in Week 13.

**Reason**: Phases 1 & 2 achieved primary goals (combat density + professional mobile UI). Enemy variety deferred to future week to maintain project velocity and avoid scope creep. Current 3 enemy types sufficient for MVP gameplay testing.

### Implementation Notes

**Estimated Effort**: 4-6 hours
- Enemy type definitions: 1 hour
- Ranged behavior: 2 hours
- Tank/fast/swarm behaviors: 1 hour
- Visual differentiation: 1 hour
- Wave composition: 30 min
- Testing & balance: 1 hour

**Design Philosophy** (Sr Mobile Game Designer):
> "Start with 3-4 **foundational archetypes**: ranged, tank, fast, swarm. These cover 80% of strategic variety:
> - **Ranged**: Forces player to close distance or use long-range weapons
> - **Tank**: Rewards high-DPS weapons (sniper, rocket) over rapid-fire
> - **Fast**: Punishes slow reactions, rewards area weapons (shotgun, flamethrower)
> - **Swarm**: Makes flamethrower/shotgun feel powerful, creates visual intensity
>
> Week 14+ can add **hybrid types** (ranged tank, fast swarm, exploding enemies, etc.). Build foundation now, expand later."

**Brotato Lessons** ([brotato-reference.md:31-68](../brotato-reference.md#L31-L68)):
> Brotato's 40+ enemy types share common patterns:
> - **Clear visual identity** (color, size, shape)
> - **Unique threat** (ranged vs melee, speed, HP)
> - **Counter-play** (specific weapons counter specific enemies)
> - **Wave composition** (mixed enemy types, not homogeneous)
>
> Our 3-4 types follow these patterns. Quality over quantity."

### Dependencies
- Week 11 Phase 1 (Enemy system, targeting)
- Week 11 Phase 2 (Projectile system for ranged attacks)
- Week 12 Phase 1 (Weapon variety to leverage enemy variety)
- [docs/brotato-reference.md](../brotato-reference.md) - Enemy design patterns
- [docs/godot-performance-patterns.md](../godot-performance-patterns.md) - Projectile pooling (if needed)

### Testing
```gdscript
# scripts/tests/enemy_variety_test.gd
- test_ranged_enemy_stops_at_attack_distance()
- test_ranged_enemy_fires_projectiles()
- test_tank_enemy_has_high_hp()
- test_fast_enemy_moves_faster()
- test_swarm_enemy_spawns_multiple()
- test_enemy_projectiles_dont_hit_enemies()
- test_wave_composition_balanced()

# Manual testing (iOS device)
- Spawn ranged enemy: stops at 400px, shoots projectiles
- Spawn tank: 3x HP, slow, large
- Spawn fast enemy: rushes player quickly
- Spawn swarm: 5 enemies appear together
- Test weapon strategies:
  - Shotgun effective vs swarms (spreads hits multiple)
  - Sniper effective vs tanks (high damage)
  - Flamethrower effective vs swarms (cone AoE)
  - Rocket effective vs groups (splash damage)
- Visual: Can distinguish enemy types at a glance
- Performance: No FPS drops with 20+ enemies + projectiles
```

---

## Success Criteria (Overall Week 13)

### Must Have
- [ ] World size reduced to 2000×2000 (matches genre density standards)
- [ ] Grid floor visible for spatial awareness
- [ ] Camera boundaries updated and working
- [ ] Character selection cards have professional visual polish
- [ ] Character cards have tap feedback (scale, highlight)
- [ ] 3 new enemy types implemented (ranged, tank, fast OR swarm)
- [ ] Ranged enemies shoot projectiles
- [ ] Enemy types visually distinct
- [ ] Combat feels more strategic (weapon choice matters)

### Should Have
- [ ] 4th enemy type (if 3 complete quickly)
- [ ] Grid floor with wasteland texture (vs basic Line2D)
- [ ] Character selection stat icons (visual interest)
- [ ] Enemy type icons/overlays (visual clarity)
- [ ] Wave composition weights balanced
- [ ] Enemy projectiles visually distinct from player projectiles

### Nice to Have
- [ ] Locked character unlock CTAs prepared (UI only, functionality deferred)
- [ ] Enemy death animations (scale down + fade)
- [ ] Ranged enemy "charging" visual before shooting
- [ ] Tank enemy shield visual
- [ ] Fast enemy speed trail effect

---

## Testing Strategy

### Running Tests

**Automated Tests (GUT Framework)**:
```bash
# Run all tests via proper test runner (ALWAYS use this)
python3 .system/validators/godot_test_runner.py

# This runner handles:
# - Scanning project to register custom classes
# - Running GUT tests in headless mode with autoload services
# - Caching results for fast verification when Godot is open
```

**Location**: Test runner is at `.system/validators/godot_test_runner.py`

**DO NOT** run tests directly via godot CLI or test_runner.gd - use the Python runner above.

### Unit Tests
- World bounds: Player clamping at new boundaries
- Camera: Boundary tracking with smaller world
- Grid floor: Rendering performance
- Enemy types: Behavior flags, HP/speed multipliers
- Ranged attacks: Projectile spawning, collision layers

### Integration Tests
- Phase 1: Player movement → camera → boundaries (full loop)
- Phase 2: Character selection → card tap → visual feedback
- Phase 3: Enemy spawning → ranged behavior → player damage

### Manual Testing (iOS Device Required)

**Phase 1 QA Checklist:**
- [ ] Walk to all 4 world edges (north, south, east, west)
- [ ] Player stops at boundaries (not off-screen)
- [ ] Camera stays within bounds (no black bars)
- [ ] Grid floor visible and helpful
- [ ] Combat density feels better (enemies more frequent)
- [ ] 60 FPS maintained

**Phase 2 QA Checklist:**
- [ ] Character selection loads and displays 4 cards
- [ ] Cards have visual depth (shadows, borders, rounded corners)
- [ ] Tap card: scales 1.0 → 1.05 → 1.0
- [ ] Selected card highlights clearly
- [ ] Stats readable and informative
- [ ] Overall: "looks professional, not embarrassing"
- [ ] Show to 2-3 people for subjective quality check

**Phase 3 QA Checklist:**
- [ ] Ranged enemies spawn and stop at 400px
- [ ] Ranged enemies shoot projectiles at player
- [ ] Enemy projectiles hit player (not other enemies)
- [ ] Tank enemies have high HP, move slowly
- [ ] Fast enemies rush player quickly
- [ ] Swarm enemies spawn in groups (if implemented)
- [ ] Enemy types visually distinct at a glance
- [ ] Weapon strategies emerge (shotgun vs swarms, sniper vs tanks)
- [ ] Combat feels more interesting than Week 12
- [ ] No performance issues (60 FPS with 15-20 enemies)

---

## Migration Notes

### Breaking Changes
None expected. All changes are additive or confined to constants.

### Godot 4.x Considerations
- **World bounds**: Simple Rect2 constant change (no physics complications)
- **Grid floor**: Line2D or TileMap (both performant in Godot 4.x)
  - See [docs/godot-performance-patterns.md](../godot-performance-patterns.md) for grid rendering optimization
- **StyleBoxFlat**: Native Godot UI styling (no custom shaders needed)
- **Enemy projectiles**: Reuse existing projectile scene (collision layer differentiation)
- **Ranged AI**: Simple distance check (no pathfinding needed)

### Performance

**Phase 1 - Grid Floor**:
- **Line2D approach**: ~10-20 lines total, negligible CPU cost
- **TileMap approach**: Godot 4.x TileMap is GPU-accelerated, 60 FPS easily maintained
- **Concern**: None (grid is static, no per-frame updates)

**Phase 2 - Character Selection**:
- **StyleBoxFlat**: Native rendering, faster than texture-based panels
- **Tweens**: 4-6 active tweens max (one per card), negligible cost
- **Concern**: None (UI screen, not gameplay)

**Phase 3 - Enemy Variety**:
- **Ranged projectiles**: Reuse existing projectile pooling (if implemented)
- **Wave composition**: 8-15 enemies per wave, mixed types
- **Worst case**: 15 enemies + 5 ranged enemies shooting = 20 enemies + 5 projectiles
- **Concern**: Low (Week 11 tested with 20+ projectiles, no issues)
- **Optimization**: If FPS drops below 60, reduce ranged enemy projectile lifetime or add pooling

**Optimization Strategy** (Sr Godot 4.5.1 Specialist):
> "All three phases are low-risk performance-wise:
> - Grid floor is static geometry (rendered once)
> - Character selection is UI (off-screen during gameplay)
> - Enemy variety reuses existing systems (no new rendering pipeline)
>
> If performance issues arise, profile first: `gdscript func _physics_process()` is likely culprit, not rendering. See [docs/godot-performance-patterns.md](../godot-performance-patterns.md) for profiling workflow."

---

## Tech Debt & Future Polish

This section tracks quality improvements that are valuable but not critical for Week 13 completion. These should be revisited in Week 14+ or when related systems are worked on.

### Phase 1 Future Work (Deferred to Week 14+)

**TileMap Floor Texture** (Medium Value, 2 hours)
- Replace Line2D grid with textured TileMap
- Wasteland theme: dirt, sand, cracked concrete
- Adds immersion and visual interest
- **Estimated effort**: 2 hours (texture sourcing + TileMap setup)

**Minimap** (Low Priority, 4-6 hours)
- Small corner minimap showing player position + enemies
- Helps with spatial awareness in larger arenas
- Defer until enemy variety and combat are polished
- **Estimated effort**: 4-6 hours (minimap rendering + entity tracking)

### Phase 2 Future Work (Deferred to Auth Week)

**Full Character Selection Redesign** (Production Week)
- Login/auth integration
- Character portraits (custom art)
- Animated character previews
- Unlock progression system
- **Estimated effort**: Full week (Week 16-17)

**Character Stat Comparison** (Nice to Have)
- Side-by-side stat comparison between character types
- Visual stat bars (not just numbers)
- **Estimated effort**: 2-3 hours

### Phase 3 Future Work (Deferred to Week 14+)

**Enemy Audio** (High Value, 2-3 hours)
- Ranged enemy: "charging" sound before shot
- Tank enemy: heavy footsteps
- Fast enemy: screeching rush
- Swarm: buzzing/chittering
- **Estimated effort**: 2-3 hours (sound sourcing + AudioStreamPlayer2D setup)

**Boss Enemies** (Week 14+)
- Mini-boss every 5 waves (wave 5, 10, 15)
- Unique mechanics (multi-phase, special attacks)
- High XP/loot rewards
- **Estimated effort**: 6-8 hours per boss type

**Hybrid Enemy Types** (Week 14+)
- Ranged tank (shoots from distance, high HP)
- Fast swarm (many fast enemies)
- Exploding enemies (suicide bombers)
- **Estimated effort**: 2-3 hours per type

**Enemy Spawn VFX** (Low Priority, 1 hour)
- Teleport effect when enemy spawns
- Particle burst + fade-in
- Adds polish, not critical
- **Estimated effort**: 1 hour

---

## Rollback Plan

If Week 13 blocked or over-scoped:

**Phase 1 Rollback:**
1. Revert `WORLD_BOUNDS` to `Rect2(-2000, -2000, 4000, 4000)` in `player.gd`
2. Remove grid floor node from `wasteland.tscn`
3. Revert camera boundaries in `camera_controller.gd`
4. **Impact**: Combat density remains poor, but game still playable

**Phase 2 Rollback:**
1. Revert `character_selection.gd` and `character_selection.tscn` to previous version
2. **Impact**: Character selection remains "embarrassing", but functional

**Phase 3 Rollback:**
1. Remove new enemy types from `ENEMY_TYPES` dictionary
2. Remove ranged behavior from `enemy.gd`
3. Revert wave composition to random selection from original 3 types
4. **Impact**: Combat remains repetitive, but no game-breaking bugs

**Independence**: All three phases are independent - rollback one without affecting others.

---

## Dependencies

### Code Dependencies
- **Phase 1**: `player.gd`, `camera_controller.gd`, `wasteland.tscn`
- **Phase 2**: `character_selection.gd`, `character_selection.tscn`, `CharacterService`
- **Phase 3**: `enemy_service.gd`, `enemy.gd`, `wave_manager.gd`, `projectile.gd`

### Documentation Dependencies

**Must Read Before Implementation**:
1. [docs/brotato-reference.md](../brotato-reference.md) - Genre conventions (arena size, enemy variety, combat pacing)
   - Lines 31-68: Enemy variety and wave composition patterns
   - Lines 140-273: Weapon mechanics and strategic depth
2. [docs/game-design/systems/STAT-SYSTEM.md](../game-design/systems/STAT-SYSTEM.md) - Stat system architecture
3. [docs/GAME-DESIGN.md](../GAME-DESIGN.md) - Overall game design philosophy
4. [docs/migration/week12-implementation-plan.md](week12-implementation-plan.md) - Context from previous week

**Reference During Implementation**:
- [docs/godot-community-research.md](../godot-community-research.md) - Godot UI best practices, performance patterns
- [docs/godot-performance-patterns.md](../godot-performance-patterns.md) - Grid rendering, projectile pooling, profiling
- [docs/godot-testing-research.md](../godot-testing-research.md) - Testing patterns for enemy AI
- Week 11 implementation plan - Enemy/targeting system architecture
- Week 12 implementation plan - Weapon variety and pickup magnet system

---

## Timeline Estimate

**Phase 1 (World Size + Grid Floor)**: 2-3 hours
- WORLD_BOUNDS change: 15 min
- Camera boundary update: 30 min
- Grid floor (Line2D): 1 hour
- iOS testing: 30 min
- Bug fixes/polish: 30 min

**Phase 2 (Character Selection Polish)**: 3-4 hours
- Card visual redesign: 2 hours
- Tap feedback & interactivity: 1 hour
- Layout improvements: 30 min
- Locked character polish: 30 min
- Testing & iteration: 30 min

**Phase 3 (Enemy Variety)**: 4-6 hours
- Enemy type definitions: 1 hour
- Ranged behavior: 2 hours
- Tank/fast/swarm behaviors: 1 hour
- Visual differentiation: 1 hour
- Wave composition: 30 min
- Testing & balance: 1 hour

**Total**: 9-13 hours (1.5-2 work days)

---

## Next Steps (Week 14 Preview)

Potential Week 14 focus areas (to be planned after Week 13 completion):

**High Priority:**
- **Weapon Audio** (2-3 hours) - 50%+ of weapon feel impact, deferred from Week 12
- **Enemy Audio** (2-3 hours) - Completes combat feel loop
- **TileMap Floor Texture** (2 hours) - Upgrade grid floor to themed texture

**Medium Priority:**
- **Boss Enemies** (6-8 hours) - Mini-boss every 5 waves
- **Hybrid Enemy Types** (4-6 hours) - Ranged tanks, fast swarms, exploders
- **Weapon Unlocks/Progression** (6-8 hours) - Unlock weapons as you level up

**Low Priority:**
- **Advanced projectile physics** (bounce, ricochet - defer to future)
- **Minimap** (4-6 hours)
- **Full character selection redesign** (defer to Auth week)

**Recommendation** (Sr Product Manager):
> "Week 14 should prioritize **audio** (weapons + enemies) to complete the combat feel loop. Audio is cheap (2-3 hours per system) but high-impact (50%+ of game feel). Then add boss enemies for milestone moments. Save full character selection redesign for Auth/Monetization week (Week 16-17)."

---

## Team Perspectives Summary

**Sr Mobile Game Designer:**
> "Week 13 hits the trifecta: **combat density** (world size), **first impressions** (character selection), and **strategic depth** (enemy variety). All three are quality multipliers - they make existing systems feel better without adding complexity. Perfect scope for a polish week."

**Sr Mobile UI/UX:**
> "Character selection polish is a **conversion multiplier**. Right now, you won't share the game because of that screen. Fix this, and you unlock user feedback, investor demos, Twitter shares. 3-4 hours for 10x confidence boost."

**Sr Software Engineer:**
> "Love the scope discipline. Three independent phases = low risk. If Phase 3 runs long, defer 4th enemy type to Week 14. No blockers, no dependencies, clean rollback plan. **High-confidence week.**"

**Sr Godot 4.5.1 Specialist:**
> "All three phases leverage existing Godot systems: Rect2 constants, StyleBoxFlat, collision layers. No custom shaders, no complex AI, no new rendering pipeline. **Low technical risk, high perceived quality gain.**"

**Sr Product Manager:**
> "This is **high-ROI polish work**. World size fixes user complaints. Character selection unblocks user testing. Enemy variety makes combat replayable. Total effort: 9-13 hours. Impact: 2-3x quality improvement. **Ship it.**"

---

**Ready to implement Week 13!** 🚀
