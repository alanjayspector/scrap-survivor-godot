# Next Session: Week 17 Implementation

**Date**: 2025-11-27 (Updated)
**Week 16 Status**: ✅ **COMPLETE**
**Week 17 Status**: 🔨 **PHASE 3 IN QA** - Brotato-inspired redesign
**Current Branch**: main

---

## 🎯 CURRENT FOCUS: Phase 3 - Character Details Overhaul (QA Pass 13)

### Expert Panel Decisions (Finalized 2025-11-27)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Tap Animation | Custom (0.95 scale, 80ms/120ms asymmetric) | Cards deserve premium feel per Marvel Snap Law |
| Selection Glow | Animated GlowPanel (NOT shader) | Mobile performance, simpler implementation |
| Portrait Display | Silhouette PNGs for BOTH types and players (QA Pass 4 fix) | Visual consistency across screens |
| Component Strategy | NEW `CharacterTypeCard` component | Safe migration, side-by-side operation |
| Detail Views | Type Preview Modal (Phase 2) + Player Details Overhaul (Phase 3) | Two distinct experiences |
| **Layout** | **3-column HBoxContainer** (QA Pass 12) | **Landscape-optimized, Brotato-inspired** |

### Phase 1 Tasks ✅ COMPLETE

- [x] Document expert panel decisions
- [x] Create `CharacterTypeCard` scene via Godot editor
- [x] Implement `character_type_card.gd` script
- [x] Load silhouette textures for type portraits (all 4 types)
- [x] Unit tests for both modes (34 tests, all passing)
- [x] Migrate Character Creation to use new component
- [x] Migrate Barracks to use new component
- [x] QA Pass 4 - Fix "white" portrait issue
- [x] Device QA validation (Pass 5) - Approved
- [x] Deprecate old `CharacterCard`

### Phase 2 Implementation ✅ COMPLETE (Device QA Passed)

- [x] Keyboard UX fix: Tap outside to dismiss keyboard (iOS HIG)
- [x] Name input width: Constrained to 300pt centered
- [x] Background applied: `character_creation_bg.jpg`
- [x] Type Preview Modal: Long-press shows iOS HIG Sheet modal
- [x] Modal stacking fix: Dismisses existing modal before showing new
- [x] Upgrade flow placeholder: Shows alert (IAP integration coming)

### Phase 3 Implementation (2025-11-27) 🔨 IN PROGRESS

#### QA Pass History (Learning Journey)

| Pass | Issue | Root Cause | Fix Applied |
|------|-------|------------|-------------|
| **7** | Content not visible | Type mismatch (`Panel` → `Control`) | Changed variable type in character_details_screen.gd |
| **8** | Content stuck top-left | Layout mode conflict (Mode 2 inside Control parent) | Changed MarginContainer to Mode 1 with anchors |
| **9** | Blue background, emojis missing | ScrollContainer inheriting theme style; emojis don't render on iOS | Added StyleBoxEmpty override |
| **10** | Stats split edge-to-edge | HBoxContainer rows expanding full width | Added CenterContainer wrappers with 280px width |
| **11** | Improvement but still vertical; haptics bug | Vertical stacking wastes space; haptics looping | → Three-column layout; fix haptics |
| **12** | 3-column works, haptic fixed, but too small | Fonts 14-16px, portrait 160px | ✅ Haptic fix confirmed working |
| **13** | Bold accessibility pass | User feedback: "squinting hard" | Portrait 250px, stats 26px, name 32px |

#### Design Pivot: Brotato Reference (2025-11-27)

**User Feedback**: "it looks worse imo... please review brotato's more simplistic approach"

**Key Insight**: Brotato uses the same engine (Godot) and has clean, proven UI patterns.

**Brotato Stats Panel Analysis**:
1. Simple list format (not grid)
2. Left-aligned stat names, right-aligned values
3. Color-coded VALUES (green=positive, red=negative, white=neutral)
4. No emojis - just text labels
5. Small pixel icons OR pure text
6. Primary/Secondary tabs for stat organization
7. Compact, scannable layout

#### NEXT DIRECTION: Three-Column Landscape Layout (Expert Panel Approved)

**Rationale**: Game is ALWAYS landscape. Current vertical stacking wastes horizontal space.

**Confirmed Decisions**:
- Always landscape orientation (no portrait support needed)
- Secondary stats (10 from backlog) will go in Column 3 when implemented
- Gear is a separate idiom (future consideration, different screen/modal)

**Three-Column Layout**:
```
┌──────────────────────────────────────────────────────────────────────────────┐
│  ← Back                                                                Alan  │
├───────────────────┬─────────────────────────┬────────────────────────────────┤
│                   │                         │                                │
│    ┌─────────┐    │    PRIMARY STATS        │    RECORDS                     │
│    │ PORTRAIT│    │                         │                                │
│    │ 180×180 │    │    Max HP         100   │    Total Kills            0    │
│    └─────────┘    │    Damage          10   │    Highest Wave           0    │
│                   │    Armor            0   │    Deaths                 0    │
│       Alan        │    % Speed          0   │                                │
│    Scavenger      │                         │    CURRENCY                    │
│     Level 1       │                         │                                │
│                   │                         │    Scrap                  0    │
│  Collection Aura  │                         │    Nanites                0    │
│  Auto-collects... │                         │    Components             0    │
│                   │                         │                                │
│                   │    (future: more        │    (future: Secondary Stats    │
│                   │     primary stats?)     │     from backlog go here)      │
├───────────────────┴─────────────────────────┴────────────────────────────────┤
│        [✓ Selected]              [Start Run]              [Delete]           │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Column Breakdown**:
| Column | Content | Approx Width |
|--------|---------|--------------|
| **Left** | Portrait, Name, Type/Level, Aura | ~250px |
| **Center** | Primary Stats (HP, DMG, ARM, SPD) | ~280px |
| **Right** | Records + Currency (→ Secondary Stats later) | ~280px |

**Implementation Structure**:
```
MarginContainer
  └─ HBoxContainer (3 columns, size_flags_horizontal = 3)
       ├─ LeftColumn (VBox): Portrait, Name, Type, Aura
       ├─ CenterColumn (VBox): StatsTitle, StatsList
       └─ RightColumn (VBox): RecordsTitle, RecordsList, CurrencyTitle, CurrencyList
```

**Key Implementation Notes**:
- Use `size_flags_horizontal = 3` (EXPAND+FILL) on each column for equal distribution
- Each column is a VBoxContainer
- Stats use Brotato-style: left-aligned names, right-aligned color-coded values
- No emojis (iOS compatibility)
- 280px `custom_minimum_size` width per stat list within columns

#### Design Changes Applied (Pass 13 - Bold Accessibility)

| Element | Pass 12 | Pass 13 | Rationale |
|---------|---------|---------|-----------|
| **Portrait** | 160×160 | **250×250** | Hero showcase |
| **Character Name** | 22px | **32px** | Primary identifier |
| **Type/Level** | 14px | **22px** | Important secondary |
| **Aura Name** | 15px | **22px** | Feature highlight |
| **Aura Desc** | 12px | **18px** | Readable at arm's length |
| **Section Titles** | 14px | **20px** | Clear hierarchy |
| **Stats/Values** | 16px | **26px** | WCAG AA for mobile (40+ users) |
| **Column Alignment** | Top | **Centered** | Use vertical space |
| **Label-Value Gap** | Full width | **Fixed 160+80px** | Tighter pairing |

#### Color Coding Logic

```gdscript
# Base stats for comparison
const BASE_STATS = {
    "max_hp": 100,
    "damage": 10,
    "armor": 0,
    "speed": 0,  # Speed shown as % modifier
}

# Color logic:
# - Value > base → GREEN (0.4, 0.9, 0.4)
# - Value < base → RED (0.9, 0.3, 0.3)
# - Value = base → WHITE

# Special cases:
# - Deaths > 0 → RED (bad)
# - Kills/Waves > 0 → GREEN (good)
# - Currency → Fixed colors (gold/blue/gray)
```

#### Files Modified (Pass 12-13)

| File | Pass 12 | Pass 13 |
|------|---------|---------|
| `scenes/ui/character_details_panel.tscn` | 3-column HBoxContainer layout | Bold fonts (26px stats, 32px name), 250px portrait, vertical centering |
| `scripts/ui/character_details_panel.gd` | Updated node paths | No changes needed |
| `scripts/autoload/haptic_manager.gd` | 50ms cooldown | No changes needed |

#### Validation Status

- [x] GDLint: Clean
- [x] Scene node paths valid
- [x] **Device QA Pass 12**: ✅ Haptic fix working, 3-column layout correct
- [ ] **Device QA Pass 13**: UNDER REVIEW - Bold accessibility pass

---

## 🖼️ ART ASSETS - ALL READY ✅

| Asset | Size | Location |
|-------|------|----------|
| Character Creation BG | 1.3MB | `assets/ui/backgrounds/character_creation_bg.jpg` |
| Character Details BG | 825KB | `assets/ui/backgrounds/character_details_bg.jpg` |
| Barracks Interior | 923KB | `assets/ui/backgrounds/barracks_interior.jpg` |
| Scavenger Silhouette | 380KB | `assets/ui/portraits/silhouette_scavenger.png` |
| Tank Silhouette | 361KB | `assets/ui/portraits/silhouette_tank.png` |
| Commando Silhouette | 419KB | `assets/ui/portraits/silhouette_commando.png` |
| Mutant Silhouette | 406KB | `assets/ui/portraits/silhouette_mutant.png` |

---

## 📋 WEEK 17 PHASES

| Phase | Description | Effort | Priority | Status |
|-------|-------------|--------|----------|--------|
| **Phase 1** | Unified Card Component | 3-4h | CRITICAL | ✅ Complete |
| **Phase 2** | Character Creation Overhaul | 3-4h | HIGH | ✅ Complete |
| **Phase 3** | Character Details Overhaul | 3-4h | HIGH | 🔨 In QA (Pass 13) |
| **Phase 4** | "Enter the Wasteland" Screen | 2-3h | MEDIUM | ⏳ Ready |
| **Phase 5** | Polish & Animation | 2-3h | MEDIUM | ⏳ Ready |
| **Phase 6** | Scrapyard Title Polish | 0.5-1h | LOW | ⏳ Ready |

---

## 🔑 KEY DECISIONS MADE

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Character Creation BG | Barracks Recruitment Interior | Same visual family as roster |
| Run Initiation Copy | "ENTER THE WASTELAND" + "GO" | Title dramatic, button punchy |
| Character Details | Remove sidebar, add Hero Section | Simplify, "proud showcase" moment |
| Card Component | Unified for both screens | Visual consistency, reduced maintenance |
| **Stats Display** | **Brotato-style list format** | **Proven Godot UI pattern, iOS-safe (no emojis)** |
| **Value Colors** | **Green/Red/White based on base** | **Industry standard (Brotato, Diablo, etc.)** |

---

## 📊 PROJECT STATUS

**Tests**: 705/729 passing (24 pending/skipped)
**GDLint**: Clean
**All Validators**: Passing

---

## 📚 KEY DOCUMENTATION

| Document | Purpose |
|----------|---------|
| `docs/migration/week17-plan.md` | Full Week 17 plan with expert panel decisions |
| `docs/migration/backlog-items.md` | Deferred work (IAP, secondary stats, tech debt) |
| `docs/design/art-asset-usage-guide.md` | Art asset catalog |
| `art-docs/Scrapyard_Scene_Art_Bible.md` | Color palette, style guide |

---

## 🚀 QUICK START PROMPT (Next Session)

```
Continuing Week 17 Phase 3 for Scrap Survivor.

Read these files:
1. .system/CLAUDE_RULES.md
2. .system/NEXT_SESSION.md

Phase 1 COMPLETE ✅
Phase 2 COMPLETE ✅
Phase 3 IN QA 🔨 - Pass 13 UNDER REVIEW

COMPLETED THIS SESSION:
✅ Pass 12: 3-column HBoxContainer layout (Left/Center/Right)
✅ Pass 12: 50ms haptic cooldown - FIXED continuous vibration bug
✅ Pass 13: Bold accessibility pass - 250px portrait, 26px stats, 32px name

DEVICE QA RESULTS:
✅ Pass 12: Haptic fix confirmed working
✅ Pass 12: 3-column layout correct
🔍 Pass 13: Under review - font sizes and portrait

If Pass 13 approved, Phase 3 is COMPLETE. Move to Phase 4.
```

---

## ⚠️ REMINDERS

1. **Use Godot editor for scene creation** (per CLAUDE_RULES)
2. **Parent-First Protocol** for dynamic UI nodes
3. **No emojis in UI** - Don't render on iOS
4. **Color-coded values** - Green (good), Red (bad), White (neutral)
5. **Test on iOS device** before marking complete

---

## 🎓 LESSONS LEARNED (Phase 3)

1. **Emojis don't work on iOS** - Use text or texture icons instead
2. **Brotato is a valid reference** - Same engine, proven patterns
3. **List format > Grid format** - More scannable, flexible
4. **Color the VALUES, not the labels** - Industry standard pattern
5. **Layout mode matters** - Control parent needs anchor children (Mode 1)
6. **ScrollContainer inherits theme styles** - Override with StyleBoxEmpty for transparency

---

**Last Updated**: 2025-11-27
**Status**: Phase 3 QA Pass 13 UNDER REVIEW - Bold accessibility pass (250px portrait, 26px stats, 32px name)
