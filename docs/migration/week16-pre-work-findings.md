# Week 16 Pre-Work Findings

**Created:** 2025-11-18
**Purpose:** Supplementary reference for Week 16 Mobile UI Standards Overhaul
**Use with:** `week16-implementation-plan.md`

---

## Brotato Reference Analysis

**File:** `docs/brotato-reference.md` (888 lines)
**Content Type:** Game mechanics data dictionary (characters, weapons, items, enemies)

**Findings:**
- **NOT a UI/mobile patterns reference** - Contains game data structures, stats, character abilities
- **Useful for:** Understanding Brotato's game mechanics, but NOT for mobile UI patterns
- **Recommendation:** For mobile UI patterns, we need to:
  1. Download Brotato app on iPhone 15 Pro Max
  2. Screenshot menus, HUD, dialogs
  3. Measure button sizes, font sizes, spacing in image editor
  4. Document observed patterns (as described in Week 16 Phase 0)

**Action Required:** Phase 0 should prioritize actual app screenshots over this reference doc for UI work.

---

## Current Analytics Coverage

**Files with Analytics.track_event():** 8 files
**Primary location:** `scripts/ui/character_creation.gd` (10+ events)

### Existing Analytics Events

**Character Creation Flow (character_creation.gd):**
1. `character_creation_opened` - When scene loads
2. `character_type_selected` - User selects character type
3. `slot_usage_banner_shown` - Free tier slot warning displayed
4. `name_input_started` - User begins typing name
5. `character_creation_cancelled` - User taps Back button
6. Additional events (need full code read to enumerate all)

**Character Roster (character_roster.gd):**
- Has `Analytics.` references (need to examine for specific events)

**Hub/Scrapyard (hub/scrapyard.gd):**
- Has `Analytics.` references (need to examine for specific events)

**Save Manager (systems/save_manager.gd):**
- Has `Analytics.` references (likely save/load events)

**Tests (tests/analytics_test.gd):**
- `test_event` - Test stub
- `button_click` - Test stub

### Analytics Implementation Status

**Current State:**
- ✅ Analytics autoload EXISTS (`Analytics.track_event()` called throughout code)
- ❓ Backend wired? UNKNOWN (need to check autoload implementation)
- ✅ Event naming convention: `snake_case` with descriptive names
- ✅ Properties passed as Dictionary: `{"key": value}`

**Recommendation for Week 16:**
Since Analytics autoload already exists, we should:
1. **Check if it's a stub or real implementation** (read `scripts/autoload/analytics.gd`)
2. **If stub:** Keep adding events per Week 16 plan
3. **If real:** Understand current backend before adding more events
4. **Document all existing events** for Week 17 wireup reference

---

## Analytics Events to Add in Week 16

**Based on Week 16 plan, we'll add ~30-40 new events:**

### Phase 3 (Touch Targets)
- `button_pressed` - Track all button interactions
  - Properties: `{screen, button, timestamp}`

### Phase 4 (Dialogs)
- `dialog_opened` - Any dialog/modal shown
  - Properties: `{dialog_type, screen}`
- `dialog_confirmed` - User confirmed action
  - Properties: `{dialog_type, action}`
- `dialog_cancelled` - User cancelled
  - Properties: `{dialog_type, method}` (button, swipe, tap_outside)
- `dialog_dismissed` - Non-button dismissal
  - Properties: `{method}` (swipe, tap_outside)
- `delete_confirmation_step_1` - Progressive delete first tap
- `delete_confirmation_confirmed` - Progressive delete second tap
- `delete_confirmation_timeout` - Progressive delete timed out
- `delete_undone` - User used undo toast

### Phase 5 (Visual Feedback)
- `scene_transition_started` - Scene loading begins
  - Properties: `{from_scene, to_scene}`
- `scene_transition_completed` - Scene loaded
  - Properties: `{scene, duration_ms}`
- `animation_preference_changed` - User toggled animations
  - Properties: `{enabled}`
- `haptic_preference_changed` - User toggled haptics
  - Properties: `{enabled}`

### Phase 7 (Combat HUD)
- `pause_button_pressed` - User paused from HUD
  - Properties: `{source, wave, timestamp}`
- `combat_started` - Combat begins
- `combat_ended` - Combat ends
  - Properties: `{duration_seconds, wave_reached}`
- `hud_toggled` - If HUD has show/hide toggle
  - Properties: `{visible}`

**Total New Events:** ~20-25 events (conservative estimate)

**Combined Total:** ~35-40 events ready for Week 17 wireup

---

## Next Steps (Phase 0 Execution)

1. **Check Analytics Implementation:**
   ```bash
   cat scripts/autoload/analytics.gd
   ```
   Determine if stub or real implementation.

2. **Document All Existing Events:**
   Create comprehensive list by grepping:
   ```bash
   grep -r "track_event" scripts/ -A 2 | grep -E "(track_event|{)"
   ```

3. **Download Brotato App:**
   - Install on iPhone 15 Pro Max
   - Screenshot: Main menu, character select, shop, HUD, pause menu
   - Measure in image editor (Figma/Photoshop)

4. **Create Branch:**
   ```bash
   git checkout -b feature/week16-mobile-ui
   git push -u origin feature/week16-mobile-ui
   ```

5. **Set Up Visual Regression:**
   - Implement `scripts/debug/visual_regression.gd` (from Week 16 plan)
   - Capture baseline screenshots
   - Commit to `tests/visual_regression/baseline/`

---

## Token Budget Note

**Current session usage:** ~103k/200k tokens
**Remaining:** ~97k tokens

**Recommendation:** After Phase 0 setup work, start fresh session for Phase 1-7 execution to avoid rollover risk.

---

**End of Pre-Work Findings**


---

## ✅ Phase 0a Status: COMPLETE (2025-11-18)

**Infrastructure Setup Completed:**
- Git branch: `feature/week16-mobile-ui` (created & pushed)
- Visual regression: `scripts/debug/visual_regression.gd` (created)
- Analytics verified: Stub implementation confirmed
- Commits: 
  - docs: Week 16 v2.0 plan + findings doc (main)
  - feat: Phase 0a infrastructure (feature/week16-mobile-ui)

**Ready for Phase 0b (Next Session):**
1. Analyze Brotato YouTube video
2. Capture baseline screenshots
3. Document analytics events
4. Begin Phase 1 audit

