# Week 17 - Expert Panel Design Session
## Barracks, Character Create, Character Details Overhaul

**Status:** PLANNING COMPLETE - READY TO IMPLEMENT
**Date:** 2025-11-27
**Estimated Effort:** 15-19 hours
**Focus:** Core character management experience polish

---

## 🎯 SESSION OBJECTIVE

Transform three critical screens from "MVP functional" to "emotionally compelling, production-quality" UI that makes players proud of their survivors and excited to create new ones.

### Screens in Scope

| Screen | Current State | Target State |
|--------|---------------|--------------|
| **Barracks (Roster)** | 2-column grid, Option C background, functional | Trophy case that makes players proud |
| **Character Creation** | Basic name + type dropdown, MVP | Card-based type selection, immersive |
| **Character Details** | Awful, doesn't match visual identity | Hero showcase, consistent with Art Bible |

### Design Principle (Established Week 16)

> **"Marvel Snap Law"** - Characters are the stars, UI serves them.

---

## 🧑‍⚖️ EXPERT PANEL

| Role | Focus Area |
|------|------------|
| **Sr Mobile Game Designer** | Player psychology, retention mechanics, competitor analysis |
| **Sr UI/UX Designer** | Visual hierarchy, mobile patterns, iOS HIG compliance |
| **Sr Product Manager** | Feature prioritization, user stories, success metrics |
| **Sr SQA Engineer** | Test coverage, edge cases, QA checklist |
| **Sr Godot Developer** | Technical feasibility, performance, implementation approach |

---

## 📊 CURRENT STATE ANALYSIS

### Screen 1: Barracks (Character Roster)

**File:** `scenes/ui/barracks.tscn`

**Current Implementation:**
- 2-column GridContainer with CharacterCard components
- Option C dark gradient background (`barracks_interior.jpg`)
- Semi-transparent charcoal scroll background
- "Your Survivors" title with slot counter
- "Create New Survivor" and "Back to Hub" buttons

**Expert Panel Assessment:**

| Aspect | Score | Notes |
|--------|-------|-------|
| Visual Identity | 7/10 | Option C background good, cards need polish |
| Mobile UX | 8/10 | 2-column grid appropriate, touch targets good |
| Emotional Impact | 5/10 | Functional but not "proud of my collection" |
| Performance | 9/10 | Works well with current character counts |

**Issues Identified:**
1. CharacterCard uses ColorRect for portrait (not visually compelling)
2. No selection glow/animation (selection feels flat)
3. Card entrance has no animation (feels static)
4. No visual distinction for "selected" character at a glance

---

### Screen 2: Character Creation

**File:** `scenes/ui/character_creation.tscn`

**Current Implementation:**
- Name input (LineEdit) with basic styling
- GridContainer with 4 type cards (text-based buttons)
- "Create & Play" and "Create & Hub" buttons
- Slot usage banner for FREE tier

**Expert Panel Assessment:**

| Aspect | Score | Notes |
|--------|-------|-------|
| Visual Identity | 4/10 | Generic UI, doesn't feel "junkpunk" |
| Mobile UX | 5/10 | Keyboard issues (takes too much space, not dismissable) |
| Emotional Impact | 3/10 | Character creation should feel exciting |
| Type Selection | 4/10 | Text-heavy, no visual preview of types |

**Issues Identified:**
1. **CRITICAL:** Keyboard takes excessive real estate, not dismissable
2. Type cards are text-only (no visual preview)
3. No detailed view when tapping a type card
4. Background is plain (not Art Bible themed)
5. No "glow" selection effect on type cards
6. Feels like a form, not a "recruitment ceremony"

---

### Screen 3: Character Details

**File:** `scenes/ui/character_details_screen.tscn` + `character_details_panel.tscn`

**Current Implementation:**
- ColorRect background (solid color)
- Left sidebar with character list
- TabContainer with Stats/Gear/Records tabs
- Bottom action bar (Select/Start Run/Delete)
- Text-based stats display with icons as `[HP]`, `[DMG]` text

**Expert Panel Assessment:**

| Aspect | Score | Notes |
|--------|-------|-------|
| Visual Identity | 3/10 | **AWFUL** - doesn't match Art Bible at all |
| Mobile UX | 6/10 | Sidebar works but feels cramped |
| Emotional Impact | 2/10 | No "hero showcase" moment |
| Information Architecture | 6/10 | Stats organized but not visually appealing |

**Issues Identified:**
1. **CRITICAL:** No hero portrait section (character should be prominently displayed)
2. ColorRect background (should use Art Bible texture)
3. Stats use text placeholders `[HP]` instead of icons
4. No visual type indicator (type color/badge)
5. Layout feels like a database admin panel, not a character showcase
6. Inconsistent with Barracks visual language

---

## 🎨 EXPERT PANEL RECOMMENDATIONS

### Recommendation 1: Unified Card Component Architecture

**Sr Godot Developer & Sr UI/UX Designer:**

> "Both Barracks and Character Create should use the SAME card component with different data. This ensures visual consistency and reduces maintenance."

**Proposed: `CharacterTypeCard` Component**

```
scenes/ui/components/character_type_card.tscn
├── Button (root, 180×240pt)
├── PanelBg (with glow effect capability)
├── ContentContainer
│   ├── PortraitRect (type silhouette or player portrait)
│   ├── NameLabel (type name or character name)
│   ├── SubLabel (type stats preview or character level)
│   └── BadgeContainer (lock icon or selection badge)
└── GlowOverlay (for selection effect)
```

**Usage:**
- **Barracks:** `CharacterTypeCard.setup_player(character_data)` → Shows player portrait, name, level
- **Character Create:** `CharacterTypeCard.setup_type(type_id)` → Shows type silhouette, name, stat preview
- **Character Details (sidebar):** Smaller variant of same component

---

### Recommendation 2: Character Type Card Design

**Sr Mobile Game Designer:**

> "Character type selection is the first major decision a player makes. It should feel weighty and exciting, not like filling out a form."

**Type Card Visual Specification:**

| Element | Specification |
|---------|---------------|
| Card Size | 170×220pt (fits 2-column grid with margins) |
| Portrait Area | 140×140pt, type-colored silhouette |
| Type Name | 20pt bold, centered |
| Stat Preview | 14pt, "+20 HP, +3 Armor" format |
| Border | 2pt type color, 4pt glow when selected |
| Lock Overlay | 50% dim + lock icon for tier-restricted types |

**Type Silhouettes:**

| Type | Silhouette Description | Color |
|------|------------------------|-------|
| Scavenger | Figure with backpack, hunched posture | Gray (#999999) |
| Tank | Bulky figure with heavy armor | Olive (#4D7A4D) |
| Commando | Lean figure with rifle | Red (#CC3333) |
| Mutant | Figure with glowing aura, twisted pose | Purple (#8033B3) |

**Banana Nano Prompt for Type Silhouettes:**
```
Illustrated junkpunk style, character silhouette, 
[TYPE_DESCRIPTION], orange rim lighting on edges,
dark interior, hand-painted brushstroke style,
no background, transparent PNG, 512x512,
post-apocalyptic wasteland survivor aesthetic
```

---

### Recommendation 3: Character Details Hero Section

**Sr UI/UX Designer:**

> "The detail view needs a 'hero moment' - a large, prominent display of the character that makes the player feel proud. Think Marvel Snap card inspection or Darkest Dungeon character sheet."

**Hero Section Specification:**

```
┌─────────────────────────────────────────────┐
│  ← Back                    CHARACTER DETAILS │  Header (80pt height)
├─────────────────────────────────────────────┤
│                                             │
│         ┌───────────────────┐               │
│         │                   │               │
│         │   [PORTRAIT]      │               │  Hero Section (200pt height)
│         │   200×200pt       │               │
│         │                   │               │
│         └───────────────────┘               │
│         CHARACTER NAME                       │  32pt bold, type color
│         Tank • Level 5                       │  20pt, type badge + level
│                                             │
├─────────────────────────────────────────────┤
│  Stats │ Gear │ Records                     │  Tab Container
│  ─────────────────────────────────────────  │
│  [Stats content with proper icons]          │
│                                             │
├─────────────────────────────────────────────┤
│  [Select]  [Start Run]  [🗑️]                │  Action Bar (80pt height)
└─────────────────────────────────────────────┘
```

**Background:**
- Use Art Bible texture (not solid ColorRect)
- Recommendation: `detailed-workshop.png` or new "character profile" background
- Dark gradient overlay for text readability

---

### Recommendation 4: Keyboard UX Fix

**Sr Mobile Game Designer & Sr Godot Developer:**

> "Keyboard UX is a critical mobile pattern. The current implementation violates iOS HIG."

**Current Problems:**
1. Keyboard takes too much vertical space
2. Can't dismiss keyboard by tapping outside
3. Content doesn't scroll up when keyboard appears

**Solution:**

```gdscript
func _ready() -> void:
    # Make name input dismissable
    name_input.focus_exited.connect(_on_name_focus_lost)
    
    # Tap outside to dismiss
    var tap_catcher = Control.new()
    tap_catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
    tap_catcher.mouse_filter = Control.MOUSE_FILTER_PASS
    tap_catcher.gui_input.connect(_on_background_tap)
    add_child(tap_catcher)
    move_child(tap_catcher, 0)  # Behind everything

func _on_background_tap(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        name_input.release_focus()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_SIZE_CHANGED:
        # Scroll content when keyboard appears
        _adjust_for_keyboard()
```

**Additional:**
- Use `virtual_keyboard_enabled` property
- Implement content scrolling when keyboard appears
- Add "Done" button on keyboard (iOS pattern)

---

### Recommendation 5: "Enter the Wasteland" Confirmation Screen

**Sr Product Manager & Sr Mobile Game Designer:**

> "The transition from Hub to combat is a critical moment. It should feel like you're about to embark on a dangerous journey, not just pressing 'Start'."

**Screen Flow:**
```
Hub → Tap Wasteland Gate → "Enter the Wasteland" Confirmation → Combat
```

**Screen Specification:**

```
┌─────────────────────────────────────────────┐
│                                             │
│         [WASTELAND GATE ART]                │  Full-bleed background
│         wasteland-gate.png                  │  (existing asset!)
│                                             │
│   ┌─────────────────────────────────────┐   │
│   │                                     │   │
│   │  ENTER THE WASTELAND                │   │  Modal overlay (60% height)
│   │                                     │   │
│   │  ┌─────────────────────────┐        │   │
│   │  │ [Selected Character]    │        │   │  Character preview card
│   │  │ Tank • Level 5          │        │   │
│   │  │ HP: 120  DMG: 15        │        │   │
│   │  └─────────────────────────┘        │   │
│   │                                     │   │
│   │  ⚠️ Danger Level: MODERATE          │   │  Optional difficulty indicator
│   │                                     │   │
│   │  ┌──────────┐  ┌──────────────────┐ │   │
│   │  │  Cancel  │  │  ⚔️ SCAVENGE     │ │   │  Action buttons
│   │  └──────────┘  └──────────────────┘ │   │
│   │                                     │   │
│   └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

**Copy:**
- **Title:** "ENTER THE WASTELAND"
- **Primary Action Button:** "GO" (simple, punchy - dramatic context provided by visuals)
- **Cancel Button:** "Cancel"

---

### Recommendation 6: New Art Asset Prompts

**Sr UI/UX Designer:**

**Asset 1: Character Creation Background**

Current state: Plain BackgroundPanel
Target: Immersive "recruitment center" feel

**Option A: Barracks Recruitment Interior (RECOMMENDED)**
```
Illustrated junkpunk style, interior barracks recruitment area,
military recruitment desk with forms and equipment,
"JOIN THE SURVIVORS" poster on corrugated metal wall,
dark atmospheric lighting with single overhead lamp,
hand-painted brushstroke style, muted earth tones,
post-apocalyptic military aesthetic, 2048x2048 square format,
dark vignette edges for UI overlay, space in center for cards
```

**Expert Panel Recommendation:** Option A (Barracks Recruitment Interior) - same visual family as roster screen, reinforces "recruiting a new survivor to your squad" metaphor.

Note: Cultivation Chamber is reserved for a separate Subscription tier feature (character cloning/duplication).

---

**Asset 2: Character Details Background**

Current state: ColorRect solid color
Target: "Character showcase" feel

```
Illustrated junkpunk style, interior workshop spotlight area,
single bright light source from above creating dramatic lighting,
industrial tools and workbench visible at edges (out of focus),
dark background with warm accent light, hand-painted brushstroke,
"character on display" atmosphere, 2048x2048 square format,
portrait orientation optimized, center area dark for content overlay
```

---

**Asset 3: Type Silhouettes (4 images)**

```
# Scavenger
Illustrated junkpunk style, character silhouette front view,
hunched figure with large backpack, goggles on forehead,
orange rim lighting on edges, dark interior fill,
hand-painted brushstroke, transparent background PNG,
512x512, post-apocalyptic survivor aesthetic

# Tank  
Illustrated junkpunk style, character silhouette front view,
bulky heavy-set figure with thick armor plating, helmet,
olive green rim lighting on edges, dark interior fill,
hand-painted brushstroke, transparent background PNG,
512x512, post-apocalyptic survivor aesthetic

# Commando
Illustrated junkpunk style, character silhouette front view,
lean athletic figure with rifle, tactical gear,
red rim lighting on edges, dark interior fill,
hand-painted brushstroke, transparent background PNG,
512x512, post-apocalyptic survivor aesthetic

# Mutant
Illustrated junkpunk style, character silhouette front view,
twisted figure with glowing mutations, asymmetric pose,
purple rim lighting on edges, dark interior fill,
hand-painted brushstroke, transparent background PNG,
512x512, post-apocalyptic survivor aesthetic
```

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: Unified Card Component (3-4 hours)
**Priority:** CRITICAL (foundation for other phases)
**Status:** 🚧 IN PROGRESS (Started 2025-11-27)

#### Expert Panel Decisions (Session 2025-11-27)

**Decision 1: Tap Animation - Custom vs THEME_HELPER**
> **Recommendation:** Custom animation in card component
> 
> **Rationale:** Character cards are "the stars of the show" per Marvel Snap Law. They deserve premium feel distinct from standard buttons.
> 
> **Specification:**
> - Scale: **0.95** (more pronounced than standard 0.97)
> - Duration: **80ms down, 120ms return** (asymmetric for snap feel)
> - Optional: 1-2° rotation for 'lift' feel
> - Haptic: `HapticManager.light()` on press

**Decision 2: Selection Glow - Shader vs Panel**
> **Recommendation:** Animated GlowPanel behind card (NOT shader)
> 
> **Rationale:** Shaders add complexity and can cause issues on older iOS devices. Panel approach achieves 90% of effect with simpler implementation.
> 
> **Specification:**
> ```
> GlowPanel (Panel, visible only when selected)
> ├── Position: Behind card, 4-8px larger on each side
> ├── StyleBoxFlat: type_color or Primary Orange (#FF6600)
> ├── Corner radius: 12px
> ├── Animation: Alpha pulses 0.6 ↔ 1.0 over 800ms, loops
> └── Creates soft "breathing" glow effect
> ```

**Decision 3: Portrait Display - Phase Timing**
> **Recommendation:** Hybrid approach for Phase 1
> 
> | Mode | Portrait Behavior | Phase |
> |------|-------------------|-------|
> | `setup_type()` | Silhouette PNG images | Phase 1 (assets ready!) |
> | `setup_player()` | Type-colored ColorRect | Phase 1 (enhanced Phase 3) |
> 
> **Rationale:** Immediate visual improvement in Character Creation while deferring Barracks portrait enhancement.

**Decision 4: New Component vs Modify Existing**
> **Recommendation:** Create NEW `CharacterTypeCard` component
> 
> **Rationale:** 
> - Existing `CharacterCard` has specific API tightly coupled to player display
> - New component allows side-by-side operation during migration
> - Safer rollback if issues arise
> 
> **Migration Order:**
> 1. Create `CharacterTypeCard` 
> 2. Migrate Character Creation first
> 3. Validate on device
> 4. Migrate Barracks
> 5. Deprecate old `CharacterCard`

**Decision 5: Detail Views Scope**
> **Recommendation:** Two distinct detail experiences
> 
> | View | Type | Phase | Purpose |
> |------|------|-------|---------|
> | **Character Type Preview Modal** | NEW Modal | Phase 2 | Full stats when tapping type in creation |
> | **Player Character Details Screen** | OVERHAUL | Phase 3 | Hero Section + Art Bible compliance |
> 
> **Type Preview Modal Spec (iOS HIG Sheet pattern):**
> - Slides up from bottom (not full screen navigation)
> - Shows full type stats, abilities, starting bonuses
> - Tap outside or 'X' to dismiss
> - Keeps player in creation flow

#### Component Architecture

```
scenes/ui/components/character_type_card.tscn
├── GlowPanel (Panel, behind card, selection glow)
│   └── StyleBoxFlat: type_color, corner_radius=12, alpha pulses
├── CardButton (Button, root, 170×220pt)
│   ├── PanelBg (Panel, card background)
│   ├── ContentContainer (MarginContainer)
│   │   ├── VBoxContainer
│   │   │   ├── PortraitRect (TextureRect, 140×140pt)
│   │   │   ├── NameLabel (Label, 20pt bold)
│   │   │   ├── SubLabel (Label, 14pt, stats or level)
│   │   │   └── BadgeContainer (for selection checkmark)
│   └── LockOverlay (Panel, 50% dim + lock icon, tier-restricted)
```

#### Tasks (Refined)

1. ✅ Document expert panel decisions (this update)
2. ⬜ Create `CharacterTypeCard` scene via Godot editor
3. ⬜ Implement `character_type_card.gd` script
   - `setup_type(type_id: String)` - For Character Creation
   - `setup_player(character_data: Dictionary)` - For Barracks
   - `set_selected(selected: bool)` - Toggle glow effect
   - `set_locked(locked: bool, required_tier: int)` - Lock overlay
   - `_animate_tap()` - Custom tap animation
   - `_start_glow_animation()` / `_stop_glow_animation()`
4. ⬜ Load silhouette textures for type portraits
5. ⬜ Migrate Character Creation to use new component
6. ⬜ Migrate Barracks to use new component  
7. ⬜ Unit tests for both modes
8. ⬜ Device QA validation
9. ⬜ Deprecate old `CharacterCard` (mark for removal)

**Success Criteria:**
- [ ] Both screens use same card component
- [ ] Selection glow visually distinct (breathing animation)
- [ ] Tap animation feels premium (0.95 scale, asymmetric timing)
- [ ] Type silhouettes display in Character Creation
- [ ] Lock overlay works for tier-restricted types
- [ ] Tests passing
- [ ] Device QA passed

---

### Phase 2: Character Creation Overhaul (3-4 hours)
**Priority:** HIGH

**Tasks:**
1. **Keyboard fix** - Dismissable, content scrolls (iOS HIG compliance)
2. Apply `character_creation_bg.jpg` background with gradient overlay
3. **NEW: Character Type Preview Modal** (iOS HIG Sheet pattern)
   - Slides up when tapping type card (long-press or info button)
   - Shows full type stats, abilities, starting bonuses, lore
   - Tap outside or 'X' to dismiss
   - Keeps player in creation flow
4. Integrate silhouettes into type cards (via `CharacterTypeCard.setup_type()`)
5. Selection flow: tap to select, glow indicates selection
6. Device QA

**Note:** Type silhouette assets already generated and ready:
- `assets/ui/portraits/silhouette_scavenger.png`
- `assets/ui/portraits/silhouette_tank.png`
- `assets/ui/portraits/silhouette_commando.png`
- `assets/ui/portraits/silhouette_mutant.png`

**Success Criteria:**
- [ ] Keyboard dismissable by tapping outside
- [ ] Content scrolls when keyboard appears
- [ ] Type cards show silhouette portraits
- [ ] Tap type card → select; long-press/info → detailed preview modal
- [ ] Selection glow on chosen type
- [ ] Art Bible background applied (`character_creation_bg.jpg`)

---

### Phase 3: Character Details Overhaul (3-4 hours)  
**Priority:** HIGH

**Focus:** Player Character Details Screen (`character_details_screen.tscn`)

**Tasks:**
1. Implement Hero Section (200pt portrait area with type silhouette)
2. Apply `character_details_bg.jpg` background with gradient overlay
3. Replace stat text icons `[HP]` with proper icon sprites
4. Type color badge next to character name
5. Unified visual language with Barracks (use `CharacterTypeCard` for any card displays)
6. Remove sidebar (simplify to single character view)
7. Enhance player portrait display (upgrade from ColorRect to silhouette)
8. Device QA

**Success Criteria:**
- [ ] Hero portrait prominently displayed (200pt area)
- [ ] Background matches Art Bible (`character_details_bg.jpg`)
- [ ] Stats use icon sprites (not `[HP]` text placeholders)
- [ ] Type visually indicated (color badge)
- [ ] Consistent with Barracks styling
- [ ] Player portrait uses type silhouette (not ColorRect)
- [ ] Sidebar removed, single-character focus

---

### Phase 4: "Enter the Wasteland" Screen (2-3 hours)
**Priority:** MEDIUM

**Tasks:**
1. Create new scene `enter_wasteland_confirmation.tscn`
2. Use `wasteland-gate.png` as full-bleed background
3. Modal overlay with character preview
4. "SCAVENGE" primary action button
5. Wire up from Hub wasteland gate button
6. Wire up from Character Details "Start Run" button
7. Device QA

**Success Criteria:**
- [ ] Dramatic transition moment before combat
- [ ] Selected character clearly shown
- [ ] "SCAVENGE" action feels impactful
- [ ] Can cancel and return to previous screen

---

### Phase 5: Polish & Animation (2-3 hours)
**Priority:** MEDIUM

**Tasks:**
1. Card entrance animation (fade + slide, 200ms stagger)
2. Card shadow (4pt blur, 25% opacity)
3. Screen transition animations
4. Sound effects for selection
5. Haptic feedback on key interactions
6. Final device QA pass

**Success Criteria:**
- [ ] Animations feel polished, not jarring
- [ ] Consistent 60fps on target devices
- [ ] Audio/haptic feedback enhances UX

---

### Phase 6: Scrapyard Title Polish (30 min - 1 hour)
**Priority:** LOW (quick win)

**Problem:**
The "SCRAP SURVIVOR" title on the Scrapyard hub uses Window Yellow (`#FFC857`) which is meant for "lit windows, interior glow" per Art Bible. It looks out of place with our textures and colors.

**Current:**
```
font_color = Color(0.918, 0.773, 0.239, 1)  # Window Yellow
font_outline_color = Color(0, 0, 0, 1)      # Black outline
outline_size = 4
font_size = 48
```

**Solution Options:**

| Option | Color | Hex | Rationale |
|--------|-------|-----|-----------|
| A: Rust Orange | `#B85C38` | Primary environment color, ties to metal/rust theme |
| B: Primary Orange | `#FF6600` | UI accent color, high visibility |
| C: Corrugated Tan | `#C4A77D` | Subtle, matches metal siding aesthetic |
| D: Premium Gold | `#FFD700` | Rich, premium feel |

**Expert Panel Recommendation:** 
- **Option B (Primary Orange `#FF6600`)** with **Burnt Umber (`#8B4513`) outline** 
- This creates high contrast, ties to UI accent palette, and feels "important"
- Add subtle drop shadow for depth

**Tasks:**
1. Update `scrapyard.tscn` GameTitle color to Primary Orange (`#FF6600`)
2. Change outline color to Burnt Umber (`#8B4513`)
3. Increase outline_size to 6 for better readability
4. Optional: Add drop shadow via Label shadow properties
5. Device QA

**Success Criteria:**
- [ ] Title feels integrated with Art Bible
- [ ] High readability on background
- [ ] Matches visual language of other screens

---

## 🧪 QA CHECKLIST

### Manual Testing Required

**Barracks:**
- [ ] 2-column grid displays correctly on iPhone SE
- [ ] 2-column grid displays correctly on iPhone 15 Pro Max
- [ ] Character cards show glow when selected
- [ ] Tap animation feels responsive
- [ ] Scroll works smoothly with 10+ characters
- [ ] "Create New Survivor" navigates correctly

**Character Creation:**
- [ ] Keyboard dismisses when tapping outside
- [ ] Content scrolls up when keyboard appears
- [ ] All 4 type cards visible without scrolling
- [ ] Type silhouettes display correctly
- [ ] Locked types show lock overlay
- [ ] Selection glow visible
- [ ] Tap type card → detailed view modal
- [ ] Create button works correctly
- [ ] Back button returns to previous screen

**Character Details:**
- [ ] Hero portrait displays correctly
- [ ] Background matches Art Bible
- [ ] Stats display with icons (not text placeholders)
- [ ] Type badge visible
- [ ] Select Survivor works
- [ ] Start Run → Enter Wasteland confirmation
- [ ] Delete → Confirmation modal → Delete works
- [ ] Back button returns to Barracks

**Enter the Wasteland:**
- [ ] Background displays correctly (wasteland-gate.png)
- [ ] Selected character info shown
- [ ] "SCAVENGE" button launches combat
- [ ] "Cancel" returns to previous screen
- [ ] Modal appears centered on all device sizes

---

## 📊 SUCCESS METRICS

**Before Week 17:**
- Character management feels "MVP functional"
- Players use it because they have to
- Visual identity inconsistent across screens

**After Week 17:**
- Character management feels "polished and proud"
- Players enjoy browsing their roster
- Visual identity consistent (Art Bible compliance)
- Character creation feels like an event, not a form

**Qualitative:**
- "Trophy case" feeling for character roster
- "Recruitment ceremony" feeling for character creation
- "Hero showcase" feeling for character details
- "Dangerous journey" feeling for run initiation

---

## 📝 APPROVAL STATUS

| Phase | Status | Reviewer | Date |
|-------|--------|----------|------|
| Phase 1: Card Component | ✅ Complete | Alan | 2025-11-27 |
| Phase 2: Character Creation | ✅ Complete | Alan | 2025-11-27 |
| Phase 3: Character Details | ✅ Complete | Alan | 2025-11-27 |
| Phase 4: Enter Wasteland | ⏳ Pending | Alan | - |
| Phase 5: Polish | 📦 Backlogged | - | - |
| Phase 6: Scrapyard Title | ⏳ Low Priority | Alan | - |

---

**Document Version:** 1.0
**Created:** 2025-11-27
**Next Review:** After Phase 1 completion
