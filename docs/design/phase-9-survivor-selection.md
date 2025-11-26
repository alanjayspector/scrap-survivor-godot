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

### Session 9.2: Barracks Selection Flow + Detail View Polish (1.5h)

**Objective**: Implement explicit "Select" action in Barracks and polish detail view

**Selection Flow** (Option B - Expert Panel Approved):
```
Barracks List
    ↓ Tap character card
Character Detail View (Full Screen)
    ↓ Tap "Select" button
Return to Hub (with survivor now selected)
```

**Tasks**:

1. **Add "Select" Button to Character Details**
   - Primary action button in detail view
   - Sets `GameState.active_character_id`
   - Returns to Hub after selection
   - Visual feedback (toast: "Survivor Selected!")

2. **Update Character Card Actions**
   - Remove direct "Play" → Wasteland launch
   - Tap card → Opens detail view
   - Detail view has "Select" and "Start Run" options

3. **Polish Character Detail View**
   - Apply Art Bible styling
   - Proper button hierarchy (Select = Primary, Delete = Danger)
   - Better stats presentation
   - Mobile-optimized touch targets

**Files to Modify**:
```
scripts/ui/character_details_screen.gd   # Add Select button
scenes/ui/character_details_screen.tscn  # UI layout updates
scripts/ui/character_roster.gd           # Update card tap behavior
scripts/ui/components/character_card.gd  # Simplify actions
```

**QA Gate**:
- [ ] Tap card → Opens detail view
- [ ] "Select" button sets active survivor
- [ ] Returns to Hub after selection
- [ ] Detail view matches Art Bible styling
- [ ] Touch targets ≥ 44pt

---

### Session 9.3: Hub Visual Indicator + Barracks Background (1h)

**Objective**: Add survivor status panel to Hub, apply Art Bible background to Barracks

**Tasks**:

1. **Hub Survivor Status Panel**
   - Position: Bottom-left (doesn't conflict with buttons)
   - Shows: Character portrait/icon, name, level
   - Tap panel → Opens Barracks
   - Empty state when no survivor selected

2. **Barracks Art Bible Background**
   - Import/create appropriate background
   - Apply consistent styling with Hub
   - Ensure readability of character cards

3. **Full Terminology Update**
   - Rename `character_roster.tscn` → `barracks.tscn`
   - Rename `character_roster.gd` → `barracks.gd`
   - Update all references in codebase
   - Update scene titles and labels

**Files to Create/Modify**:
```
scenes/ui/components/survivor_status_panel.tscn  # NEW
scripts/ui/components/survivor_status_panel.gd   # NEW
scenes/hub/scrapyard.tscn                        # Add status panel
scenes/ui/barracks.tscn                          # Renamed + background
scripts/ui/barracks.gd                           # Renamed
```

**QA Gate**:
- [ ] Hub shows selected survivor panel
- [ ] Panel updates when selection changes
- [ ] Barracks has Art Bible background
- [ ] All terminology updated (Roster → Barracks)
- [ ] No broken scene references

---

## 🎨 Visual Indicator Design (Expert Panel Recommendation)

### Survivor Status Panel

**Position**: Bottom-left corner of Hub
**Size**: ~200×80pt (flexible based on content)
**Contents**:
```
┌─────────────────────────────┐
│ [Portrait] │ Rusty McBlade  │
│    60×60   │ Level 5        │
│            │ ⚔️ Scrapper    │
└─────────────────────────────┘
```

**States**:
- **Selected**: Shows survivor info
- **None Selected**: "No Survivor Selected" with subtle prompt
- **Tapped**: Navigates to Barracks

**Styling**:
- Semi-transparent dark background
- Art Bible border treatment
- Readable text over hub background

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

**Document Version**: 1.0
**Created**: 2025-11-26
**Author**: Expert Panel (Claude)
**Status**: PLANNED
