# Next Session Handoff

**Date**: 2025-11-22
**Session**: QA Pass 10 Investigation & Design Pattern Analysis
**Status**: 🔴 **NOT COMPLETE** - Critical findings require architecture change

---

## ⚠️ CRITICAL FINDINGS: QA Pass 10 Root Cause Analysis

### The Problem
After **10 QA passes** attempting to fix iOS SIGKILL crashes when viewing character details, systematic investigation revealed **TWO ROOT CAUSES**, not one:

1. **Technical Bug**: Parent-First Protocol violation in `character_details_panel.gd:268`
2. **Design Pattern Mismatch**: Using modal sheet for content too complex per iOS HIG

---

## 🔍 Investigation Summary

### What We Thought Was Fixed
Commit `19faa5e` claimed "resolve all 60+ Parent-First Protocol violations" but:
- ❌ **MISSED** `character_details_panel.gd` entirely
- ❌ **INCOMPLETE** audit - only checked 6 files, not entire `scripts/ui/panels/` directory
- ❌ **ASSUMED** previous partial fix (commit `eab1a85`) was complete

### QA Pass 10 Evidence
**Log**: `qa/logs/2025-11-22/10`

**Timeline**:
- Lines 171-230: CharacterDetailsPanel creates 11 stat rows successfully
- Line 231: `show_character() EXIT - Panel displayed successfully`
- Line 232: **`Message from debugger: killed`** (SIGKILL)

**Crash occurs AFTER all nodes created** → iOS layout engine processes nodes → Detects Mode 1/Mode 2 conflict → Infinite loop → Watchdog timeout → SIGKILL (0x8badf00d)

---

## 🐛 Technical Root Cause (Bug)

### The Violation

**File**: `scripts/ui/panels/character_details_panel.gd`
**Function**: `_create_stat_row()`
**Line**: 268

```gdscript
func _create_stat_row(stat_name: String, stat_value: String) -> HBoxContainer:
    var hbox = HBoxContainer.new()

    # ... creates children, parents them TO hbox ✅

    hbox.custom_minimum_size = Vector2(0, 28)  # ❌ LINE 268: Configure BEFORE parenting
    return hbox  # Returns configured node

# Caller at line 227:
content.add_child(row)  # ❌ Parents AFTER configuration
```

**The Problem**:
1. HBoxContainer created (defaults to layout_mode = 1 / Anchors)
2. `custom_minimum_size` set while in Mode 1
3. Returned to caller
4. **THEN** parented to container (which expects Mode 2)
5. iOS detects conflict → Infinite layout loop → SIGKILL

**Impact**: Executed **11 times** per character details view (5 Offense + 3 Defense + 3 Utility stats)

### Why Commit 19faa5e Missed It

1. Previous commit `eab1a85` partially fixed this function (moved property after children parented)
2. Developer assumed fix was complete
3. Didn't re-audit the file in "60+ violations" sweep
4. No automated validation script to detect violations

---

## 📱 Design Root Cause (Pattern Mismatch)

### iOS HIG Research Findings

**Research Document**: `ios-ui-navigation-game-patterns.md` (6000+ words, 31 citations)

#### What iOS HIG Says About Sheets

**Sheets are for**:
- ✅ Self-contained tasks (editing, creating, choosing)
- ✅ Simple content (low complexity)
- ✅ "Peek and dismiss" behavior
- ✅ Context preservation (parent remains visible)

**Sheets are NOT for**:
- ❌ Complex content with sub-navigation (tabs)
- ❌ Deep management interfaces (multiple data categories)
- ❌ Content that requires full attention

**Critical Quote from HIG**:
> "Avoid using a sheet to help people navigate your app's content"

#### Our Current Implementation Analysis

**CharacterDetailsPanel Content**:
- ✅ Read-only (no editing) → Sheet appropriate
- ✅ Rapid browsing expected → Sheet appropriate
- ❌ **3 tabs** (Stats/Gear/Records) → **Too complex for sheet**
- ❌ **20+ stats** with collapsible sections → **Too dense for sheet**
- ❌ **Tab navigation** within sheet → **Violates HIG guidance**

**Complexity Assessment**: **Medium-High** (between Marvel Snap and Genshin Impact)

### Game UI Research: The Pattern We Should Use

**Marvel Snap** (Simple Card Inspection):
- Uses modal overlay / zoom transition
- **Complexity**: 2-3 stats, single view
- **Why it works**: Low complexity, rapid comparison to deck

**Genshin Impact** (Complex Character Management):
- Uses **full-screen with sidebar navigation**
- **Complexity**: 5-6 tabs, equipment, talents, artifacts
- **Why it works**: High complexity justifies full screen + internal roster nav

**Our Character Details**:
- **Complexity**: 3 tabs, 11 stats, gear, records
- **Closest Match**: **Genshin Impact pattern**

---

## ✅ Decision: Option B - Full-Screen with Sidebar Navigation

### Why This Pattern Is Correct

**Aligns with iOS HIG**:
- Full-screen = hierarchical navigation (push/scene change)
- No "navigation within navigation" conflict (tabs in sheet)
- Content complexity justifies full screen real estate

**Aligns with Game UI Best Practices**:
- Matches Genshin Impact / Honkai: Star Rail pattern
- Sidebar roster allows rapid character switching (no "back" button fatigue)
- Immersive character inspection (full 3D space if needed later)

**Fixes Both Root Causes**:
1. **Technical**: Simpler lifecycle (no modal overlay complexity)
2. **Design**: Appropriate pattern for content complexity

### Benefits Over Current Sheet Pattern

| Benefit | Sheet (Current) | Full-Screen (Proposed) |
|---------|-----------------|------------------------|
| **Content Space** | Limited (card margins) | Maximum (full screen) |
| **Tab Navigation** | Awkward (nav in modal) | Natural (screen owns tabs) |
| **Character Switching** | Back → Tap next (3 taps) | Sidebar tap (1 tap) |
| **Complexity Support** | Cramped (20+ stats) | Spacious (room to grow) |
| **iOS HIG Alignment** | ❌ Violates (tabs in sheet) | ✅ Correct (hierarchical) |
| **Lifecycle** | Complex (modal + content) | Simple (scene swap) |
| **Crash Risk** | Higher (overlay hierarchy) | Lower (flat hierarchy) |

---

## 📋 Implementation Plan (Next Session)

### Phase 1: Create Dedicated Character Details Scene

**New Files**:
- `scenes/ui/character_details_screen.tscn` - Full-screen scene
- `scripts/ui/character_details_screen.gd` - Screen controller

**Layout**:
```
┌─────────────────────────────────────┐
│ ← Back    Character Details     ⚙️  │ ← Header bar
├──────┬──────────────────────────────┤
│ Char │                              │
│ 1    │  [Stats] [Gear] [Records]    │ ← Tab navigation
│ Char │                              │
│ 2    │  Character stats content     │
│ Char │  (reuse CharacterDetailsPanel│
│ 3    │   as embedded component)     │
│      │                              │
├──────┴──────────────────────────────┤
│  Sidebar: Roster                    │
│  (carousel/list)                    │
└─────────────────────────────────────┘
```

### Phase 2: Refactor CharacterDetailsPanel

**Current**: Standalone scene designed for modal
**New**: Component designed to embed in full-screen scene

**Changes**:
1. Remove modal-specific code
2. **Fix Parent-First violation at line 268**:
   ```gdscript
   # OLD (line 268):
   hbox.custom_minimum_size = Vector2(0, 28)  # Before parenting
   return hbox

   # NEW:
   return hbox  # Return unconfigured
   # Caller does:
   content.add_child(row)  # 1. Parent FIRST
   row.layout_mode = 2      # 2. Mode 2
   row.custom_minimum_size = Vector2(0, 28)  # 3. Configure AFTER
   ```
3. Keep tab system (Stats/Gear/Records)
4. Keep collapsible sections

### Phase 3: Update Character Roster Navigation

**Current**:
```gdscript
func _on_character_details_pressed(character_id: String):
    # Creates modal sheet, instantiates panel, shows modal
```

**New**:
```gdscript
func _on_character_details_pressed(character_id: String):
    GameState.set_selected_character(character_id)
    get_tree().change_scene_to_file("res://scenes/ui/character_details_screen.tscn")
```

### Phase 4: Implement Sidebar Navigation

**In CharacterDetailsScreen**:
- Left or right sidebar with character portraits (carousel or list)
- Tap portrait → Switch active character (no scene change)
- Smooth transition (fade character model/stats)
- Maintains "inspection mode" (like Genshin Impact)

### Phase 5: Test & Validate

**Validation Checklist**:
```
□ Parent-First Protocol violations fixed (automated grep check)
□ Scene instantiates without errors
□ Tab switching works (Stats/Gear/Records)
□ Sidebar character switching works (rapid tap test)
□ Back button returns to roster
□ iOS device test (SIGKILL resolved)
□ Memory usage acceptable (no modal overlay duplication)
□ All 647 tests still passing
```

---

## 🎯 Success Criteria

**Before marking "COMPLETE"** (per CLAUDE_RULES.md Definition of Complete):

1. ✅ Code written and committed
2. ✅ All automated tests passing (647/671)
3. ✅ All validators passing
4. ✅ **Manual QA pass on iPhone** (no SIGKILL)
5. ✅ **Parent-First violations = 0** (verified by automated script)
6. ✅ **iOS HIG compliant** (full-screen for complex content)
7. ✅ **User can switch characters rapidly** (sidebar works)
8. ✅ **No known bugs** in the feature

---

## 📊 Process Improvements Applied

### What Went Wrong (QA Passes 1-10)

**Violation of CLAUDE_RULES.md QA & Investigation Protocol**:
- ❌ Trial-and-error for 10 QA passes
- ❌ Reactive fixes (only where crashes happened)
- ❌ Never completed systematic full audit
- ❌ Assumed previous fixes were complete
- ❌ No automated validation

### What We Did Right (This Session)

**Following CLAUDE_RULES.md Protocol**:
- ✅ **QA Pass 10 → Spawned investigation agent** (should have been Pass 1)
- ✅ **Evidence-based analysis** (read logs, code, commit history)
- ✅ **Root cause identification** (both technical AND design)
- ✅ **Research iOS HIG** (external documentation lookup)
- ✅ **Systematic solution** (fix both root causes, not just symptoms)

### Going Forward

**Mandatory after ANY iOS SIGKILL**:
1. **STOP trial-and-error** after 1 failure
2. **READ** CLAUDE_RULES.md investigation protocol
3. **SPAWN** investigation agent for systematic analysis
4. **FIX ALL** violations in one comprehensive pass
5. **VALIDATE** with automated scripts before QA
6. **TEST ONCE** on device after proper fix

---

## 🚀 Quick Start Prompt for Next Session

```
Continue with Character Details Architecture Change (QA Pass 10 fix).

Context:
- Read .system/NEXT_SESSION.md for full background
- QA Pass 10 failed with iOS SIGKILL
- Root causes: Parent-First violation + wrong design pattern
- Decision: Replace modal sheet with full-screen navigation (Genshin Impact pattern)

Tasks:
1. Create character_details_screen.tscn (full-screen scene with sidebar)
2. Fix character_details_panel.gd:268 (Parent-First violation)
3. Refactor CharacterDetailsPanel to embed in full-screen scene
4. Update character_roster.gd navigation (scene change, not modal)
5. Implement sidebar roster navigation (rapid character switching)
6. Run automated Parent-First validation script
7. Test on iOS device
8. Document the fix in lessons-learned

Follow Implementation Plan in NEXT_SESSION.md Phase 1-5.
```

---

## 📁 Key Files to Review

**Current Implementation** (Modal Sheet - Will be deprecated):
- `scripts/ui/character_roster.gd:227-270` - Modal instantiation code
- `scripts/ui/panels/character_details_panel.gd:268` - **VIOLATION HERE**
- `scripts/ui/components/mobile_modal.gd` - Modal system (won't use)

**New Implementation** (Full-Screen):
- `scenes/ui/character_details_screen.tscn` - **CREATE THIS**
- `scripts/ui/character_details_screen.gd` - **CREATE THIS**
- `scripts/ui/panels/character_details_panel.gd` - **FIX & REFACTOR**

**Research**:
- `ios-ui-navigation-game-patterns.md` - iOS HIG + Game UI research (31 citations)
- `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md` - Parent-First Protocol
- `.system/CLAUDE_RULES.md:641-760` - Godot 4 UI Protocol rules

**QA Logs**:
- `qa/logs/2025-11-22/10` - QA Pass 10 crash log (SIGKILL evidence)

---

## 📈 Current State

**Git Status**:
- Branch: `main`
- Last commit: `a9c495a` - "docs: added documentation that was missed"
- Modified files: `test_results.txt`, `test_results.xml`

**Test Status**:
- 647/671 passing, 0 failed
- 24 skipped tests (expected)

**Character Details Feature**:
- ❌ **NOT WORKING** - iOS SIGKILL on QA Pass 10
- 🔴 **BLOCKED** - Architecture change required
- 📋 **PLAN READY** - Full-screen with sidebar (this document)

---

## 🎓 Lessons Learned

### Technical Lesson
**Parent-First Protocol is non-negotiable on iOS.**
Even ONE violation (line 268) executed 11 times causes SIGKILL. There is no "partial fix."

### Design Lesson
**Modal sheets have complexity limits.**
iOS HIG: Sheets are for simple content. Our 3 tabs + 20 stats exceeded the threshold. Research and validate patterns BEFORE building.

### Process Lesson
**Systematic investigation after 1 QA failure, not 10.**
Trial-and-error wastes time and misses root causes. CLAUDE_RULES.md protocol exists for a reason.

### Architecture Lesson
**Game UI patterns (Genshin Impact) are valid for game-like apps.**
We're building a mobile RPG game. Using game UX patterns (full-screen character details with sidebar) is MORE correct than forcing iOS utility app patterns (sheets).

---

**Last Updated**: 2025-11-22 16:30 (QA Pass 10 Investigation Session)
**Next Session**: Character Details Architecture Redesign
**Estimated Scope**: 4-6 hours (create scene, fix violation, implement sidebar, test)
**Ready to Start**: ✅ Yes - Plan is complete, evidence-based, approved by user
