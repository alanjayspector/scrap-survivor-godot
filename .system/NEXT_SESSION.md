# Next Session: Week 17 Phase 4

**Date**: 2025-11-27
**Week 17 Status**: Phases 1-3 Complete, Phase 4 Ready
**Current Branch**: main

---

## 🎯 CURRENT FOCUS: Phase 4 - "Enter the Wasteland" + Character Creation Polish

### Phase 4 Overview

**Goal:** Complete the thematic pre-combat flow with dramatic confirmation screen + polish Character Creation input visibility.

**Estimated Effort:** 2-3 hours

---

### Part A: "Enter the Wasteland" Confirmation Screen

**New Scene:** `enter_wasteland_confirmation.tscn`

**Purpose:** Dramatic transition moment before combat - "dangerous journey" feeling.

**Design Spec (from week17-plan.md):**
```
┌─────────────────────────────────────────────┐
│                                             │
│         [WASTELAND GATE ART]                │  Full-bleed background
│         wasteland-gate.png                  │  (asset exists!)
│                                             │
│   ┌─────────────────────────────────────┐   │
│   │                                     │   │
│   │  ENTER THE WASTELAND                │   │  Modal overlay
│   │                                     │   │
│   │  ┌─────────────────────────┐        │   │
│   │  │ [Selected Character]    │        │   │  Character preview
│   │  │ Tank • Level 5          │        │   │
│   │  │ HP: 120  DMG: 15        │        │   │
│   │  └─────────────────────────┘        │   │
│   │                                     │   │
│   │  ┌──────────┐  ┌──────────────────┐ │   │
│   │  │  Cancel  │  │      GO          │ │   │  Action buttons
│   │  └──────────┘  └──────────────────┘ │   │
│   │                                     │   │
│   └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

**Tasks:**
1. [ ] Create new scene `scenes/ui/enter_wasteland_confirmation.tscn`
2. [ ] Use `wasteland-gate.png` as full-bleed background
3. [ ] Create modal overlay with character preview (use CharacterTypeCard in player mode)
4. [ ] "GO" primary action button (dramatic, punchy)
5. [ ] "Cancel" secondary button
6. [ ] Wire up from Hub wasteland gate button
7. [ ] Wire up from Character Details "Start Run" button
8. [ ] Device QA

**Success Criteria:**
- [ ] Dramatic transition moment before combat
- [ ] Selected character clearly shown
- [ ] "GO" action feels impactful
- [ ] Can cancel and return to previous screen

---

### Part B: Character Creation Input Polish

**Problem Identified:** Name input field is nearly invisible against busy background after Phase 2 overhaul.

**Issues (from screenshot review):**
| Element | Problem |
|---------|---------|
| Input field | Translucent, nearly invisible |
| Placeholder text | "Enter survivor name..." extremely faint |
| "Survivor Name:" label | Small font, low contrast |
| "Choose a name and type" | Very faint, almost invisible |

**Expert Panel Recommendations:**

1. **Input Field Styling**
   - Solid dark background: `Color(0.1, 0.1, 0.1, 0.95)`
   - Visible border: 2px, Primary Orange or white
   - Corner radius: 8px
   - Brighter placeholder text: 0.5 gray

2. **Font Sizes**
   | Element | Current | Target |
   |---------|---------|--------|
   | "Survivor Name:" | ~16px | **22px** |
   | Input text | ~18px | **24px** |
   | "Choose a name and type" | ~14px | **18px** |

**Tasks:**
1. [ ] Update `character_creation.tscn` name input field styling
2. [ ] Increase font sizes for labels
3. [ ] Add solid dark background to input field
4. [ ] Add visible border to input field
5. [ ] Device QA

---

### Part C: Phase 6 (Low Priority - Whenever Natural)

**Scrapyard Title Polish** - 30-60 minutes when there's a break.

- Change title color from Window Yellow to Primary Orange (`#FF6600`)
- Change outline to Burnt Umber (`#8B4513`)
- Increase outline_size to 6

---

## 🖼️ EXISTING ASSETS

| Asset | Location | Status |
|-------|----------|--------|
| Wasteland Gate | `art-docs/wasteland-gate.png` | Needs import to assets/ |
| Character Creation BG | `assets/ui/backgrounds/character_creation_bg.jpg` | Ready |

---

## 📋 WEEK 17 OVERALL STATUS

| Phase | Status |
|-------|--------|
| Phase 1: Card Component | ✅ Complete |
| Phase 2: Character Creation | ✅ Complete |
| Phase 3: Character Details | ✅ Complete |
| **Phase 4: Enter Wasteland + Input Polish** | **🔨 Ready to Start** |
| Phase 5: Polish | 📦 Backlogged |
| Phase 6: Scrapyard Title | ⏳ Low Priority |

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
| `docs/migration/backlog-items.md` | Deferred work (Phase 5 polish items now here) |
| `.system/archive/NEXT_SESSION_2025-11-27_week17-phase3-character-details-complete.md` | Phase 3 session archive |

---

## 🚀 QUICK START PROMPT (Next Session)

```
Continuing Week 17 Phase 4 for Scrap Survivor.

Read these files:
1. .system/CLAUDE_RULES.md
2. .system/NEXT_SESSION.md
3. docs/migration/week17-plan.md (Phase 4 section)

Phase 4 has TWO parts:
A) "Enter the Wasteland" confirmation screen (new scene)
B) Character Creation input field polish (visibility fix)

Assets needed:
- wasteland-gate.png exists in art-docs/, needs import
- Character preview can use CharacterTypeCard component

Start with Part A (new scene creation) or Part B (quick polish fix)?
```

---

## ⚠️ REMINDERS

1. **Use Godot editor for scene creation** (per CLAUDE_RULES)
2. **Parent-First Protocol** for dynamic UI nodes
3. **Test on iOS device** before marking complete
4. **Phase 6 is low priority** - do when natural, not urgent

---

**Last Updated**: 2025-11-27
**Status**: Phase 4 Ready to Start
