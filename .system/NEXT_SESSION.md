# Next Session: Phase 10 - Barracks Background Replacement

**Date**: 2025-11-26
**Week Plan**: [docs/migration/week16-implementation-plan.md](../docs/migration/week16-implementation-plan.md)
**Phase 10 Plan**: [docs/design/phase-10-barracks-background.md](../docs/design/phase-10-barracks-background.md)
**Art Asset Guide**: [docs/design/art-asset-usage-guide.md](../docs/design/art-asset-usage-guide.md)
**Current Phase**: Phase 10 - Barracks Background
**Status**: ⏳ **AWAITING ASSET GENERATION**

---

## 🎯 SESSION SUMMARY (2025-11-26)

### Expert Panel Convened

The expert panel (Sr Mobile Game Designer, Sr UI/UX Designer, Sr Product Manager, Sr Godot Developer) analyzed:

1. **The Problem**: Beautiful barracks exterior art is hidden behind 45% overlay AND character cards. Art competes with "the money" (characters players are attached to).

2. **The Solution**: Replace narrative art with UI background (Option C - dark gradient with industrial framing). Characters become the stars.

3. **Key Principle Established**: "Marvel Snap Law" - Cards are brightest, UI serves cards.

### Three Background Options Reviewed

| Option | Score | Verdict |
|--------|-------|---------|
| **A** - Rusty corrugated metal | 17/20 | Clean, functional, less interesting |
| **B** - Interior wall with patches | 16/20 | Rich detail but light fixture competes |
| **C** - Dark gradient + edge framing | 18/20 | ✅ WINNER - Perfect "display case" for cards |

### All Art Assets Cataloged

Complete review of 17 art assets with recommendations:
- Hub backgrounds (scrapyard-topdown - current)
- Building exteriors (barracks, bank, wasteland-gate, etc.)
- UI backgrounds (Option A/B/C)
- Interior scenes (workshop, bunker)
- UI elements (buttons, signs, NPCs)

**Full catalog**: `docs/design/art-asset-usage-guide.md`

### Key Decisions Made

| Decision | Rationale |
|----------|-----------|
| Use Option C for Barracks | Dark center + industrial framing = display case |
| Remove barracks exterior from roster | Narrative art wrong for list screen |
| Keep current Hub layout | Icon buttons work; building tiles deferred |
| 2048×2048 for new textures | Covers all devices, GPU-optimized |

---

## 📋 IMMEDIATE NEXT STEPS

### Step 1: Generate Option C Asset

**Alan Action Required**: Generate asset using Banana Nano

**Prompt**:
```
Illustrated junkpunk style, abstract dark background gradient, 
industrial grunge aesthetic, subtle metal and rust textures fading 
into darkness, muted earth tones, hand-painted brushstroke style, 
vignette effect darker at edges, atmospheric and moody, 
minimalist background for UI overlay, no objects no text,
pipes and cables visible at edges, teal oxidation on rust,
dark center for content overlay, 2048x2048 square format
```

**Requirements**:
- Resolution: 2048×2048 (square)
- File size: ≤1MB
- Format: PNG preferred

### Step 2: Implement Phase 10

Once asset is received:
1. Add to `assets/ui/backgrounds/barracks_interior.png`
2. Update `barracks.tscn` to use new background
3. Remove GradientOverlay (darkness built-in)
4. Device QA on iPhone
5. Commit

**Estimated Time**: 1-2 hours

---

## 📊 Overall Progress

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 8.2c | ✅ Complete | Hub visual transformation |
| Phase 9.1 | ✅ Complete | Selection persistence |
| Phase 9.2 | ✅ Complete | 2-column grid + selection flow |
| Phase 9.3 | ✅ Complete | Hub status panel + barracks rename |
| Phase 9 QA | ⏳ Pending | Awaiting device QA |
| **Phase 10** | 📋 Planned | Barracks background replacement |
| Week 17 | 📋 Planned | Visual polish, animations |

---

## 📚 Documentation Created This Session

1. **Art Asset Usage Guide** (`docs/design/art-asset-usage-guide.md`)
   - Complete catalog of 17 art assets
   - Classification system (Hub BG, Building Exterior, UI BG, etc.)
   - Expert panel analysis and scores
   - Resolution/optimization guidelines
   - Repurposing recommendations

2. **Phase 10 Implementation Plan** (`docs/design/phase-10-barracks-background.md`)
   - Step-by-step implementation
   - Asset generation prompt
   - QA checklist
   - Rollback plan

---

## 🔮 Future Work Identified (Week 17+)

Based on expert panel analysis:

### High Value Repurposing
- **wasteland-gate**: "Start Run" confirmation screen
- **cultivation-chamber**: Character creation background (thematic fit!)
- **detailed-workshop**: Upgrades screen background

### Hub Enhancement (Deferred)
- Building tiles system (tap on buildings in hub)
- Button/sign sprite sheet integration
- NPC integration for atmosphere

### Asset Optimization
- Consider removing unused assets from bundle
- WebP conversion for size savings

---

## 🔧 Development Environment

**Platform**: macOS (MacBook Pro)
**Project Path**: `/Users/alan/Developer/scrap-survivor-godot`
**Engine**: Godot 4, GDScript
**Test Device**: iPhone 15 Pro Max

**Git Status**:
- Branch: main
- Test Status: 671/695 passing
- GDLint: Clean

---

## 🚀 Quick Start Prompt (Next Session)

```
Read these files to continue:
1. .system/CLAUDE_RULES.md (project rules)
2. .system/NEXT_SESSION.md (this file - current state)
3. docs/design/phase-10-barracks-background.md (implementation plan)
4. docs/design/art-asset-usage-guide.md (asset catalog)

Current task: Implement Phase 10 - Barracks Background Replacement
- Alan should have generated the Option C asset
- Follow phase-10-barracks-background.md implementation steps
- Device QA after implementation
```

---

**Last Updated**: 2025-11-26 (Expert Panel Review Complete)
**Status**: Awaiting Option C Asset Generation
