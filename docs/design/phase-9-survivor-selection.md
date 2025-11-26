# Phase 9: Survivor Selection Model & Barracks Polish

**Document Created**: 2025-11-26
**Status**: PLANNED - Ready after Phase 8.2c Complete
**Estimated Effort**: 3-4 hours (across 2-3 sessions)
**Prerequisite**: Phase 8.2c Session 3 Complete

---

## 📋 Overview

Phase 9 implements the **Survivor Selection Model** - a core gameplay mechanic that ensures players must select an active survivor before engaging with hub services or starting combat runs.

### Why This Phase Matters

**Current State** (after Phase 8.2c):
- `GameState.active_character_id` exists but is runtime-only
- Selection lost when app closes/restarts
- Hub buttons use stub messages ("Select a survivor first")
- Barracks (Roster) still uses MVP styling

**Target State** (after Phase 9):
- Selection persists across app sessions
- Hub displays active survivor (visual indicator)
- Barracks has dedicated "Select" flow
- All hub services gate on active survivor
- Barracks matches Art Bible visual standards

---

## 🎮 Survivor Selection Model

### State Matrix

| State | Start Run | Barracks | Settings | Future Services |
|-------|-----------|----------|----------|-----------------|
| **No survivors exist** | ❌ "Recruit a survivor" | ✅ Opens Barracks | ℹ️ "Coming Soon" | ❌ "Recruit a survivor" |
| **Has survivors, none selected** | ❌ "Select a survivor" | ✅ Opens Barracks | ℹ️ "Coming Soon" | ❌ "Select a survivor" |
| **Has survivor selected** | ✅ Launch Wasteland | ✅ Opens Barracks | ℹ️ "Coming Soon" | ✅ Operates on selected |

### Core Principle

The **Selected Survivor** is the active character for ALL hub operations:
- Banking deposits/withdrawals apply to selected survivor
- Recycler operations apply to selected survivor
- Shop purchases apply to selected survivor
- Start Run launches with selected survivor

---

## 🎯 Session Breakdown

### Session 9.1: Selection Persistence + Hub State (1-1.5h)

**Objective**: Persist `active_character_id` and implement full hub button state checking

**Tasks**:

1. **Persist Selection in Save Data**
   - Add `active_character_id` to SaveManager
   - Save on selection change
   - Load on app start
   - Handle edge cases (selected character deleted, save corrupted)

2. **Full Hub Button State Checking**
   - Replace stub messages with full state logic
   - All buttons check selection state on press
   - Consistent messaging across all buttons

3. **Auto-Select Logic** (Optional Enhancement)
   - If only 1 survivor exists → auto-select
   - If selected survivor deleted → clear selection

**Files to Modify**:
```
scripts/systems/save_manager.gd        # Add active_character_id to save data
scripts/autoload/game_state.gd         # Persist selection
scripts/hub/scrapyard.gd               # Full button state logic
```

**QA Gate**:
- [ ] Selection persists after app close/reopen
- [ ] Start Run blocked without selection
- [ ] Clear selection when character deleted
- [ ] Auto-select works (if implemented)

---

### Session 9.2: 2-Column Grid + Selection Flow (1.5h)

**Objective**: Replace list layout with 2-column card grid + add Select button

**UPDATED 2025-11-26**: Based on Expert Panel competitive analysis (Darkest Dungeon, AFK Arena, Marvel Snap), the single-row list layout is being replaced with a 2-column portrait card grid. Visual polish deferred to Week 17.

**Selection Flow**:
```
Barracks Grid (2-column cards)
    ↓ Tap character card
Character Detail View (Full Screen)
    ↓ Tap "Select Survivor" button
Return to Barracks (with selection border visible)
```

**Tasks**:

1. **Convert List to 2-Column Grid** (~30min)
   - Replace VBoxContainer with GridContainer (2 columns)
   - Card size: 180×240pt (portrait 3:4 ratio)
   - Gaps: 16pt horizontal, 16pt vertical
   - Test scrolling with 10+ characters

2. **Simplify Character Card Component** (~30min)
   - Portrait area: 148×148pt ColorRect (character type color)
   - Name: 20pt bold
   - Type/Level: 14pt muted
   - Stats row: HP + Best Wave (14pt)
   - Remove inline action buttons (Details/Play/Delete)
   - Entire card tappable → Opens detail screen

3. **Add Selection State to Cards** (~15min)
   - Unselected: 2pt border in `#5C5C5C`
   - Selected: 4pt border in `#FF6600` (Primary Orange)
   - Corner badge: 32pt circle with checkmark

4. **Update Detail Screen Actions** (~30min)
   - Add fixed bottom action bar (60pt height)
   - "Select Survivor" button: 180pt wide, PRIMARY orange
   - "Start Run" button: 120pt wide, SECONDARY style
   - Overflow menu: Delete action
   - Show "CURRENTLY SELECTED" (disabled gray) if already selected

5. **No Toast Confirmation**
   - Visual state change IS the confirmation
   - Selection border change when returning to grid
   - Badge pulse animation (defer to Week 17)

**Files to Modify**:
```
scenes/ui/character_roster.tscn          # Grid layout conversion
scripts/ui/character_roster.gd           # Grid population logic
scenes/ui/components/character_card.tscn # Simplified card layout
scripts/ui/components/character_card.gd  # Remove inline buttons
scenes/ui/character_details_screen.tscn  # Bottom action bar
scripts/ui/character_details_screen.gd   # Select button logic
```

**QA Gate**:
- [ ] Grid displays 2 columns of cards
- [ ] Scroll works smoothly with 10+ characters
- [ ] Tap card → Opens detail screen
- [ ] "Select Survivor" button sets active character
- [ ] Returns to Barracks after selection
- [ ] Selected card shows orange border + badge
- [ ] All touch targets ≥ 44pt (cards are 180×240pt ✓)

**DEFERRED TO WEEK 17** (Visual Polish):
- Card shadows and glow effects
- Card entrance animations
- Badge pulse animation
- Barracks exterior background image
- Character portrait artwork
- Stats panel redesign
- Hero portrait section in details

---

### Session 9.3: Hub Visual Indicator + Barracks Background (1h)

**Objective**: Add survivor status panel to Hub, apply Art Bible background to Barracks

**UPDATED 2025-11-26**: Expert Panel convened with competitive analysis of Darkest Dungeon, Marvel Snap, AFK Arena, Zenless Zone Zero, Brotato, Vampire Survivors, Hades, and Slay the Spire. Detailed specifications below.

**Tasks**:

1. **Hub Survivor Status Panel** (~30min)
   - Create `survivor_status_panel.tscn/gd` component
   - Position: Bottom-left, INSIDE SafeAreaContainer (iOS HIG requirement)
   - Size: 200×80pt (exceeds 44pt touch target minimum)
   - Tap entire panel → Opens Barracks
   - Subscribe to `GameState.active_character_changed` for reactive updates

2. **Barracks Art Bible Background** (~15min)
   - Copy `art-docs/barracks-exterior.png` to `assets/ui/backgrounds/`
   - Apply as full-bleed background (same pattern as Hub)
   - Add gradient overlay for card readability (Marvel Snap principle)

3. **Full Terminology Update** (~15min, defer if needed)
   - Rename `character_roster.tscn` → `barracks.tscn`
   - Rename `character_roster.gd` → `barracks.gd`
   - Update all references in codebase
   - Update scene titles and labels

**Files to Create/Modify**:
```
scenes/ui/components/survivor_status_panel.tscn  # NEW
scripts/ui/components/survivor_status_panel.gd   # NEW
scenes/hub/scrapyard.tscn                        # Add status panel
assets/ui/backgrounds/barracks_background.png    # NEW (copy from art-docs)
scenes/ui/character_roster.tscn                  # Add background + overlay
```

**QA Gate**:
- [ ] Hub shows selected survivor panel (bottom-left)
- [ ] Panel updates when selection changes (reactive)
- [ ] Empty state shows "No Survivor Selected" + "Tap to choose"
- [ ] Tap panel navigates to Barracks
- [ ] Barracks has Art Bible background with gradient overlay
- [ ] Character cards readable over background (solid card backgrounds)
- [ ] All touch targets ≥ 44pt

---

## 🎨 Session 9.3 Expert Panel Specifications

### Competitive Analysis Summary

| Game | Hub Character Display | Key Pattern |
|------|----------------------|-------------|
| **Marvel Snap** | Dark backgrounds, cards are BRIGHTEST | "Cards are heroes, UI serves cards" |
| **Darkest Dungeon** | Roster in separate building, dark silhouettes | Rim lighting, high contrast |
| **AFK Arena** | Bottom nav, hero portraits with rarity frames | Bottom-left for secondary actions |
| **Zenless Zone Zero** | Minimal hub, dedicated "Agent" section | Clean touch-optimized menus |

**Key Design Principle (Marvel Snap Law)**:
> Cards/portraits are ALWAYS the brightest elements. UI serves cards, never competes.

### Survivor Status Panel - Detailed Spec

**Position**: Bottom-left corner of Hub, INSIDE SafeAreaContainer
```
anchor_left = 0.0
anchor_top = 1.0
anchor_right = 0.0
anchor_bottom = 1.0
offset_left = 0      # SafeAreaContainer already has 44pt margin
offset_top = -80     # Panel height
offset_right = 200   # Panel width
offset_bottom = 0
```

**Size**: 200×80pt (fixed)
- 200pt width = portrait (60×60pt) + info column (124pt) + padding (16pt)
- 80pt height = 3 text lines + padding
- Touch target exceeds iOS HIG 44pt minimum

**Layout - Filled State**:
```
┌─────────────────────────────────────┐
│  ┌────────┐  Rusty McBlade          │
│  │ 60×60  │  Lv.5 Scavenger         │
│  │(color) │  Wave 12 • 100 HP       │
│  └────────┘                          │
└─────────────────────────────────────┘
```

**Content Breakdown**:
1. **Portrait**: 60×60pt ColorRect with character type color (from CharacterService.CHARACTER_TYPES)
   - Scavenger: Color(0.6, 0.6, 0.6) - Gray
   - Tank: Color(0.3, 0.5, 0.3) - Olive Green
   - Commando: Color(0.8, 0.2, 0.2) - Red
   - Mutant: Color(0.5, 0.2, 0.7) - Purple
2. **Name**: 18pt bold, Corrugated Tan (#C4A77D), truncate at 15 chars
3. **Type/Level Row**: 14pt, Scrap Gray (#5C5C5C), format "Lv.X Type"
4. **Stats Row**: 14pt, Scrap Gray (#5C5C5C), format "Wave X • Y HP"

**Background Styling**:
- Color: #1A1A1A at 85% opacity
- Border: 2pt Rust Orange (#B85C38)
- Corner radius: 4pt
- Drop shadow: 4pt (subtle)

**Layout - Empty State**:
```
┌─────────────────────────────────────┐
│  ┌────────┐  No Survivor Selected   │
│  │   ?    │  Tap to choose          │
│  │ 60×60  │                          │
│  └────────┘                          │
└─────────────────────────────────────┘
```

- Portrait: 60×60pt Scrap Gray (#5C5C5C) with "?" in Window Yellow (#FFC857)
- Line 1: "No Survivor Selected" (18pt bold, Scrap Gray)
- Line 2: "Tap to choose" (14pt, Scrap Gray at 80% opacity)

**Interaction**:
- Tap entire panel → `get_tree().change_scene_to_file("res://scenes/ui/character_roster.tscn")`
- Haptic feedback: `HapticManager.light()`
- NO separate "Change" button needed (entire panel is touch target)

**Reactive Updates**:
```gdscript
func _ready() -> void:
    # Signal is on CharacterService, not GameState
    CharacterService.active_character_changed.connect(_on_active_character_changed)
    _refresh_display()

func _on_active_character_changed(_character_id: String) -> void:
    _refresh_display()
```

### Barracks Background - Detailed Spec

**Background Image**: `barracks-exterior.png` (from art-docs/)
- Copy to: `assets/ui/backgrounds/barracks_background.png`
- Stretch mode: KEEP_ASPECT_COVERED (fills screen, crops edges)

**Gradient Overlay** (Critical for readability):
```
Top:    #000000 at 50% opacity
        ↓ (transition at 30% from top)
Bottom: #000000 at 75% opacity
```

**Why Gradient**:
- Lets "BARRACKS" sign show through at top
- Darkens bottom where cards live
- Marvel Snap principle: cards must be brightest elements

**Card Background Treatment**:
- Cards have SOLID backgrounds (not transparent)
- Unselected: #2A2A2A
- Selected: #3D2817 (with orange border)
- 4pt drop shadow ensures cards "float"

### Safe Area Compliance (iOS HIG)

**Requirement**: Interactive elements MUST respect safe area margins
**Current Hub Safe Area Margins**:
- Left: 44pt
- Top: 59pt
- Right: 44pt
- Bottom: 34pt

**Implementation**: Add panel as child of SafeAreaContainer, NOT root Control

**Exception**: Background images CAN bleed to edges (non-interactive)

### Deferred to Week 17 (Polish)

- Panel tap scale animation (0.97 over 50ms)
- Panel idle pulse animation (1s cycle)
- Card entrance animations (200ms stagger)
- Selection badge pulse animation
- Header title styling ("BARRACKS" 36pt Window Yellow)

---

## 📝 Terminology Reference

### Final Naming Convention

| Concept | Term | Used In |
|---------|------|---------|
| Player characters | **Survivors** | All UI, code comments |
| Character list screen | **Barracks** | Button labels, scene names |
| Create character | **Recruit** | Buttons, toasts |
| Select for hub | **Select** | Barracks detail view |
| Start combat | **Start Run** | Hub, Barracks |

### File Renaming (Session 9.3)

| Old Path | New Path |
|----------|----------|
| `scenes/ui/character_roster.tscn` | `scenes/ui/barracks.tscn` |
| `scripts/ui/character_roster.gd` | `scripts/ui/barracks.gd` |
| Icon asset names | Keep as-is (internal) |

---

## 🎯 Success Criteria: Phase 9 Complete

**All must be TRUE**:

- [ ] `active_character_id` persists across app sessions
- [ ] Hub buttons correctly gate on selection state
- [ ] Barracks has explicit "Select" flow (tap → detail → select)
- [ ] Hub displays Survivor Status Panel
- [ ] Barracks has Art Bible background
- [ ] All terminology updated (Roster → Barracks, Characters → Survivors)
- [ ] No broken references after rename
- [ ] All tests passing
- [ ] Device QA passed on iPhone 15 Pro Max

---

## 📊 Dependencies

**Requires Before Starting**:
- ✅ Phase 8.2c Session 3 complete
- ✅ Hub has Art Bible background
- ✅ IconButton component functional
- ✅ ModalFactory for toasts

**Enables After Completion**:
- Banking operations on selected survivor
- Recycler operations on selected survivor
- Shop purchases for selected survivor
- Full hub service ecosystem

---

## 🚀 Quick Reference

### Phase 9 at a Glance

| Session | Focus | Time | Key Deliverable |
|---------|-------|------|-----------------|
| 9.1 | Persistence + Hub State | 1-1.5h | Selection survives app restart |
| 9.2 | Selection Flow + Detail Polish | 1.5h | "Select" button in Barracks |
| 9.3 | Visual Indicator + Background | 1h | Survivor panel on Hub |

**Total**: 3-4 hours across 2-3 sessions

---

**Document Version**: 1.1
**Created**: 2025-11-26
**Updated**: 2025-11-26 (Session 9.3 Expert Panel specifications added)
**Author**: Expert Panel (Claude)
**Status**: IN PROGRESS (Sessions 9.1, 9.2 Complete)
