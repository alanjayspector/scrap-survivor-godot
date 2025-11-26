# Art Asset Usage Guide
## Scrap Survivor | Expert Panel Analysis & Recommendations

**Created**: 2025-11-26
**Expert Panel**: Sr Mobile Game Designer, Sr UI/UX Designer, Sr Product Manager, Sr Godot Developer
**Status**: APPROVED - Ready for Implementation

---

## 1. EXECUTIVE SUMMARY

This document catalogs all existing art assets and provides expert panel recommendations for their optimal usage. The core principle established:

> **"Narrative Art vs UI Art"**: Environment/building exteriors are for world-building and navigation. UI screens need recessive backgrounds that let interactive elements (characters, items, buttons) be the stars.

### Key Decisions Made

| Decision | Rationale |
|----------|-----------|
| **Option C** for Barracks roster background | Dark center + industrial framing creates "display case" for character cards |
| **Remove barracks exterior** from roster screen | Narrative art competing with "the money" (character cards) |
| **Keep current Hub layout** for MVP | Icon buttons functional; building tiles deferred to polish phase |
| **2048×2048 resolution** for new textures | Covers all flagship devices, power-of-two GPU optimization |

---

## 2. ASSET INVENTORY & CLASSIFICATION

### 2.1 Classification System

| Type | Definition | Example |
|------|------------|---------|
| **Hub Background** | Main scene backdrop showing settlement overview | scrapyard-topdown |
| **Building Exterior** | Individual building for navigation/identification | barracks-exterior |
| **UI Background** | Recessive texture for screens with interactive content | option-c-barracks |
| **Interior Scene** | Inside-view for immersive feature screens | detailed-workshop |
| **UI Elements** | Buttons, signs, icons | buttons-signs |
| **Character Assets** | NPC silhouettes, portraits | npcs |

### 2.2 Complete Asset Catalog

| Asset File | Type | Recommended Use | Priority |
|------------|------|-----------------|----------|
| `scrapyard-topdown` | Hub Background | ✅ CURRENT: Main hub scene | P1 - Active |
| `scrap-town-sanctuary` | Hub Background | Alternative hub (night variant?) | P3 - Future |
| `scrapyard-panel` | UI Mockup | Reference only (concept with UI overlay) | Reference |
| `barracks-exterior` | Building Exterior | Hub tile OR Character Creation BG | P2 - Defer |
| `wasteland-gate` | Building Exterior | "Start Run" confirmation screen | P2 - Week 17 |
| `advancement-hall` (Upgrades) | Building Exterior | Hub tile for Upgrades feature | P2 - Defer |
| `bank-exterior` | Building Exterior | Hub tile for Bank (Premium) | P3 - Future |
| `black-market-exterior` | Building Exterior | Hub tile for Black Market (Premium) | P3 - Future |
| `atomic-vendor` | Building Exterior | Hub tile for Special Vendor (Sub) | P3 - Future |
| `cultivation-chamber` | Building Exterior | Hub tile for Cloning/Creation (Sub) | P3 - Future |
| `quantum-store` | Building Exterior | Hub tile for Inventory/Stash (Sub) | P3 - Future |
| `scrapyard-store` (Scrap Heap) | Building Exterior | Hub tile for Shop | P2 - Defer |
| `detailed-workshop` | Interior Scene | Upgrades screen background | P2 - Week 17 |
| `poc-inside-workshop` | Interior Scene | Reference/concept art | Reference |
| `option-a-barracks` | UI Background | Alternative for item lists | Backup |
| `option-b-barracks` | UI Background | Rich detail, slight competition | Backup |
| `option-c-barracks` | UI Background | ✅ SELECTED: Barracks roster screen | P1 - Immediate |
| `buttons-signs` | UI Elements | Button/sign sprite sheet | P2 - Week 17 |
| `npcs` | Character Assets | Hub population, vendor portraits | P3 - Future |

---

## 3. DETAILED ASSET ANALYSIS

### 3.1 Option C - Selected for Barracks Roster

**File**: `option-c-barracks-preview.jpg` (need full res version)

**Expert Panel Scores**:
- Recessive (Good for BG): ⭐⭐⭐⭐⭐ (5/5) - Dark center is PERFECT
- Theme Match: ⭐⭐⭐⭐ (4/5) - Industrial framing maintains junkpunk
- Visual Interest: ⭐⭐⭐⭐ (4/5) - Elegant vignette effect
- UI Compatibility: ⭐⭐⭐⭐⭐ (5/5) - Designed for content overlay
- **Total: 18/20**

**Why It Won**:
1. Dark center creates a natural "stage" for character cards
2. Industrial framing (pipes, cables, rust, teal oxidation) provides atmosphere
3. Vignette effect draws eyes to center where cards will be
4. Functions as a "display case" - exactly what character roster needs

**Technical Requirements**:
- Resolution: 2048×2048 (square, power-of-two for GPU optimization)
- Format: PNG (quality) or WebP (size optimization)
- File size target: 500KB - 1MB compressed

### 3.2 Barracks Exterior - Repurposing Recommendations

**File**: `barracks-exterior.png`

**Current Use**: Barracks roster screen background (SUBOPTIMAL)
**Problem**: Narrative art competing with character cards

**Recommended Repurposing**:

| Option | Effort | Value | Panel Verdict |
|--------|--------|-------|---------------|
| Hub building tile | Medium | Medium | ✅ DEFER to Week 17+ |
| Character creation BG | Low | Medium | ✅ GOOD FIT - consider |
| Loading/transition screen | Low | Low | ❌ Scene loads fast |
| Promotional material | None | High | ✅ Already have it |
| Remove from bundle | Low | Reduces APK | Consider for optimization |

**Panel Recommendation**: 
1. Remove from roster screen (replace with Option C)
2. Keep in `art-docs/` for promotional use
3. Consider for character creation screen ("creating survivor at barracks")
4. Defer hub building tile to Week 17+ polish phase

### 3.3 Wasteland Gate - High Value Narrative Art

**File**: `wasteland-gate-preview.jpg`

**Analysis**: 
- Shows the exit from hub with "DANGER: WASTELAND BEYOND" signs
- Guard towers, stacked cars forming walls
- Door opening to dangerous outside world
- Perfect for "Start Run" feature

**Recommended Use**: 
- "Start Run" confirmation screen background
- Pre-run briefing screen
- Run transition screen

**Implementation Priority**: P2 - Week 17 polish phase

### 3.4 Cultivation Chamber - Unique Opportunity

**File**: `cultivation-chamber-exterior-preview.jpg`

**Analysis**:
- Greenhouse with people in stasis pods
- Mutant plants, monitoring equipment
- Green glow, science-fiction aesthetic

**Recommended Use**:
- Character Creation screen background (thematic: "growing" a new survivor)
- Subscription tier feature (Cloning Chamber)
- Could replace barracks exterior for character creation

**Panel Note**: This might be MORE thematically appropriate for character creation than barracks exterior. Creating a new survivor in a "cultivation chamber" feels right.

---

## 4. UI BACKGROUND DESIGN PRINCIPLES

### The "Marvel Snap Law"

> Cards are the brightest elements. UI serves the cards.

Applied to Scrap Survivor:
- **Character cards** = brightest, most detailed elements
- **Background** = recessive, atmospheric, non-competing
- **UI chrome** = functional, not decorative

### Background Requirements for List/Grid Screens

| Requirement | Reason |
|-------------|--------|
| Dark overall value | Characters pop |
| Minimal focal points | No competing interest |
| Subtle texture | Maintains theme without distraction |
| Edge framing optional | Can add depth without center competition |
| Desaturated colors | Foreground elements should have color priority |

### Background Requirements for Narrative Screens

| Requirement | Reason |
|-------------|--------|
| Can be detailed | No competing interactive elements |
| Clear visual focus | Players should look at the scene |
| Thematic storytelling | Builds world immersion |
| Appropriate for the moment | Match emotional beat |

---

## 5. RESOLUTION & OPTIMIZATION GUIDELINES

### Multi-Device Support Matrix

| Device Category | Resolution | Aspect Ratio | Coverage |
|-----------------|------------|--------------|----------|
| iPhone SE (3rd gen) | 1334×750 | 16:9 | ✅ |
| iPhone 14/15 | 2556×1179 | 19.5:9 | ✅ |
| iPhone 14/15 Pro Max | 2796×1290 | 19.5:9 | ✅ |
| iPad | 2048×1536 | 4:3 | ✅ |
| Android Mid-range | 2400×1080 | 20:9 | ✅ |
| Android Flagship | 3088×1440 | 19.3:9 | ✅ |

### Recommended Asset Resolutions

| Asset Type | Resolution | Format | Notes |
|------------|------------|--------|-------|
| Hub Background | 2048×2048 or 2560×1440 | PNG/WebP | Hero image, worth the size |
| UI Background | 2048×2048 | PNG/WebP | Square for flexibility |
| Building Tile | 512×512 | PNG | Small, repeated use |
| Buttons/Icons | 256×256 max | PNG/SVG | Keep sharp at all sizes |

### File Size Targets

| Asset Type | Target Size | Max Size |
|------------|-------------|----------|
| UI Background | 500KB | 1MB |
| Hub Background | 1MB | 2MB |
| Building Tile | 100KB | 200KB |
| Icon/Button | 20KB | 50KB |

---

## 6. IMMEDIATE ACTION ITEMS

### Phase 10: Barracks Background Replacement

**Estimated Effort**: 1-2 hours

**Steps**:
1. ☐ Generate Option C at 2048×2048 resolution
2. ☐ Add to `assets/ui/backgrounds/barracks_interior.png`
3. ☐ Update `barracks.tscn` to use new background
4. ☐ Remove or reduce GradientOverlay (may not be needed)
5. ☐ Device QA on iPhone
6. ☐ Commit with conventional commit message

**Prompt for Banana Nano**:
```
Illustrated junkpunk style, abstract dark background gradient, 
industrial grunge aesthetic, subtle metal and rust textures fading 
into darkness, muted earth tones, hand-painted brushstroke style, 
vignette effect darker at edges, atmospheric and moody, 
minimalist background for UI overlay, no objects no text,
pipes and cables visible at edges, teal oxidation on rust,
dark center for content overlay, 2048x2048 square format
```

### Deferred Work (Week 17+)

1. Hub building tiles system
2. "Start Run" screen with wasteland-gate background
3. Character creation with cultivation-chamber background
4. Button/sign sprite sheet integration

---

## 7. APPENDIX: FULL ASSET PREVIEW REFERENCE

All preview images located in: `art-docs/preview/`

| Filename | Description |
|----------|-------------|
| `scrapyard-topdown-preview.jpg` | Current hub background - settlement overview |
| `scrap-town-sanctuary-preview.jpg` | Alternative hub angle |
| `scrapyard-panel-preview.jpg` | UI mockup with button overlays |
| `barracks-exterior-preview.jpg` | Training area with sandbags, dummies |
| `wasteland-gate-preview.jpg` | Exit gate with danger signs |
| `advancement-hall-preview.jpg` | Upgrades building with welding sparks |
| `bank-exterior-preview.jpg` | Fortified vault building |
| `black-market-exterior-preview.jpg` | Hidden vendor with colored lanterns |
| `atomic-vendor-preview.jpg` | Hazmat vendor with radiation symbols |
| `cultivation-chamber-exterior-preview.jpg` | Greenhouse with stasis pods |
| `quantum-store-exterior-preview.jpg` | Swirling portal for inventory |
| `scrapyard-store-preview.jpg` | Mobile shop truck "Scrap Heap" |
| `detailed-workshop-preview.jpg` | Interior bunker workshop |
| `poc-inside-workshop-preview.jpg` | Diorama-style interior cutaway |
| `option-a-barracks-preview.jpg` | Rusty corrugated metal texture |
| `option-b-barracks-preview.jpg` | Interior wall with patches, light |
| `option-c-barracks-preview.jpg` | ✅ SELECTED: Dark gradient with edge framing |
| `buttons-signs-preview.jpg` | UI button and sign sprite sheet |
| `npcs-preview.jpg` | NPC silhouettes |

---

**Document Version**: 1.0
**Last Updated**: 2025-11-26
**Next Review**: After Week 17 planning
