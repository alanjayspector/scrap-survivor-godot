# Phase 8.2c Hub Visual Transformation - Design Plan

**Date Created**: 2025-11-23
**Phase**: Week 16, Phase 8, Sub-Phase 8.2c
**Status**: APPROVED - Ready for Implementation
**Estimated Time**: 9.5 hours (realistic) across 4 sessions
**Dependencies**: Phase 8.1 (Wasteland Colors ✅), Phase 8.2b (Icon Designs ✅)

---

## Executive Summary

Transform the scrapyard hub from generic purple prototype into an immersive fortified sanctuary with:
- **Environmental Background**: Weathered metal plates, rivets, rust (fortified scrapyard aesthetic)
- **Icon-Based Buttons**: Metal plate components with wasteland materiality (premium tactile feel)
- **Scalable Layout**: Hybrid spatial zones supporting 3 buttons today, 7-10 buttons in 4-8 weeks
- **Environmental Storytelling**: Welding marks, easter eggs, atmospheric details

**Visual Identity**: Industrial. Tactile. Fortified.

**Quality Target**: $10 premium mobile game - matches Hades/Darkest Dungeon environmental storytelling standards

---

## Design Decisions (Expert Panel - Approved)

### 1. Hub Narrative Foundation (User-Defined)

> **"A fortified scrapyard - a last bastion for survivors to find sanctuary from the wasteland."**

**What This Means**:
- **Fortified**: Defenses, reinforced walls, protection from outside threats
- **Scrapyard**: Salvaged materials, repurposed objects, makeshift construction
- **Last Bastion**: Safe haven, refuge (maybe the ONLY safe place)
- **Sanctuary from Wasteland**: Inside = safe, outside = dangerous

**Hub as Narrative Center**:
- Hub is emotional/narrative anchor, not just menu
- Missions are departures FROM sanctuary INTO danger
- Environmental storytelling > abstract UI
- Physical space conveys narrative stakes

---

### 1.5 Spatial Metaphor (CRITICAL - Approved 2025-11-23)

**⚠️ MAJOR DESIGN CLARIFICATION - Read This First**

**The Question:** What is the player actually looking at?

**The Answer:** **Option A - Perimeter Wall with Passages**

```
Player Position: Inside scrapyard courtyard (safe zone)
Looking At: Fortified perimeter wall (barrier between safety and wasteland)
Buttons Are: Physical gates/hatches/access panels IN the wall
```

**Why This Matters:**

This spatial metaphor fundamentally changes the background design:

**CORRECT Understanding:**
- **Background** = Exterior of fortified perimeter wall (rusty metal plates facing the courtyard)
- **Start Run button** = THE GATE ITSELF (literal chain-link gate - the exit to wasteland)
- **Roster button** = Side hatch to barracks (access panel in the wall)
- **Settings button** = Maintenance access panel (smaller hatch)
- **Rivets & seams** = Structural reinforcement (holding the wall panels together)
- **Floor element** = Ground/courtyard floor (you're standing in the yard looking at the wall)

**INCORRECT Understanding (Rejected):**
- ❌ Interior command center with control panels (doesn't match gate icon)
- ❌ Bulletin board metaphor (too abstract)
- ❌ Floating UI on generic background (no spatial coherence)

**Design Implications:**

1. **Background must read as a WALL** - Not abstract texture, but actual metal plates bolted together
2. **Seams must be visible** - Show where plates meet (2-3 large panels)
3. **Rivets need context** - Must be positioned AT seam intersections (structural purpose)
4. **Gate button is special** - It's not "on" the wall, it IS the wall's main gate opening
5. **Perspective matters** - Horizontal seam at bottom = "wall meets ground" (you're standing here)

**Expert Panel Verdict:**
> "This isn't just a visual polish decision - it's the foundation for the entire hub's spatial logic. Get this right in SESSION 1, and everything else flows naturally. Get it wrong, and you're building on quicksand." - Sr Visual Designer

---

### 2. Spatial Layout System: "Hybrid+ with Spatial Zones"

**APPROVED LAYOUT**: Enhanced hybrid combining tiered hierarchy + spatial zones + scalable grid

#### 3-Button State (TODAY - MVP)

```
┌─────────────────────────────────────┐
│                                     │
│         [DEPARTURE GATE]            │ ← Environmental focal point
│            (120x120pt)              │   Hero action (rust-orange glow)
│                                     │
│                                     │
│                                     │
│    [Character    [Settings/         │ ← Secondary actions (flanking)
│     Roster]       Tools]            │   Equal hierarchy (80x80pt)
│    (80x80pt)     (80x80pt)          │
│                                     │
│                                     │
│    ──── SCRAPYARD FLOOR ────        │ ← Environmental divider (metal plate seam)
│                                     │
└─────────────────────────────────────┘

Visual Hierarchy:
- Start Run: Center-top (120x120pt) - HERO ACTION
- Roster/Settings: Lower-third flanking (80x80pt) - SUPPORTING ACTIONS
- Environmental storytelling: Gate imagery, floor plate, spatial depth
```

#### 7-10 Button Future State (WEEKS 17-20)

```
┌─────────────────────────────────────┐
│                                     │
│         [DEPARTURE GATE]            │ ← PRIMARY: Still the hero (120x120pt)
│            (120x120pt)              │   Unchanged position/size (LOCKED)
│                                     │
│  ╔════ OPERATIONS ZONE ════╗        │ ← SECONDARY ZONE (thematic grouping)
│  ║  [Shop]  [Armory]       ║        │   Pre-run preparation actions
│  ║  [Tech]  [Loadout]      ║        │   (4 buttons, 70x70pt grid)
│  ╚═════════════════════════╝        │
│                                     │
│  ╔═══ COMMUNITY ZONE ══════╗        │ ← TERTIARY ZONE (social/meta)
│  ║ [Roster] [Leaderboard]  ║        │   Between-run engagement
│  ╚═════════════════════════╝        │   (2-3 buttons, 70x70pt)
│                                     │
│    ──── SCRAPYARD FLOOR ────        │ ← Environmental anchor (unchanged)
│                                     │
│  [Settings] [Help] [Achievements]   │ ← UTILITY ROW (small, 50x50pt)
└─────────────────────────────────────┘

Spatial Storytelling:
- GATE (top): "The way out" - primary escape route
- OPERATIONS (middle): "Prep area" - workbenches, weapon racks theme
- COMMUNITY (lower-middle): "Gathering area" - survivors, roster boards
- UTILITIES (bottom): "Corner tools" - tucked away, always accessible
```

#### Scalability Path (How to Add Buttons #4-10)

| Button # | Placement Strategy | Visual Impact | When |
|----------|-------------------|---------------|------|
| **#4** | Add "OPERATIONS ZONE" header + Shop button below gate | Introduces zoning concept early | Week 17-18 |
| **#5** | Second OPERATIONS button (Armory) next to Shop | Establishes 2-column grid pattern | Week 18 |
| **#6-7** | Second row in OPERATIONS (Tech Tree, Loadout) | Completes 2x2 grid (Operations Zone full) | Week 19 |
| **#8** | Move Roster to new "COMMUNITY ZONE" + Leaderboards | Roster shifts down, gains thematic neighbor | Week 19-20 |
| **#9-10** | UTILITY ROW expands (Settings, Help, Achievements, Daily) | Small icons, horizontal scroll if >4 | Week 20+ |

**Key Principle**: Each new button joins a **thematic zone**, not a generic grid. Users understand spatial memory ("Shop is in Operations Zone") vs. abstract grid ("Shop is row 2, column 1").

#### Visual Hierarchy Strategy

**How Users Know What's Important**:

1. **Size Hierarchy** (size = importance)
   - 120x120pt = PRIMARY (Start Run only)
   - 70-80pt = SECONDARY (pre-run prep, social)
   - 50x50pt = UTILITY (settings, help)

2. **Positional Hierarchy** (F-pattern reading, center = focus)
   - Top-center = Most important (gate)
   - Middle zones = Thematic groups (operations, community)
   - Bottom-right = Utilities (expected location)

3. **Visual Weight** (environmental reinforcement)
   - Gate has EXTRA decoration (support beam, welding marks)
   - Operations Zone has "workbench" background texture (future)
   - Utilities are clean/minimal (no distraction)

4. **Color Coding** (wasteland palette hierarchy)
   - Primary: RUST_ORANGE glow on gate frame
   - Secondary: DIRTY_WHITE on zone buttons
   - Utility: CONCRETE_GRAY on small icons

#### Mobile Screen Compatibility

**iPhone SE 4.7" (375x667pt - Smallest Target)**:
- 3-Button State: Spacious (gate 120pt, flanking 80pt, 40pt margins)
- 7-Button State: OPERATIONS zone = 2x2 grid (70pt buttons, 10pt gaps) fits in 300pt width
- Scroll: NOT needed (all buttons visible on-screen)
- **Tested Height**: 460pt total (140pt margin on 600pt safe area) ✅

**iPhone 14 Pro Max 6.7" (430x932pt - Largest Target)**:
- 3-Button State: Roomy (can increase gate to 140pt if desired)
- 7-Button State: OPERATIONS zone = 2x2 grid (80pt buttons, 15pt gaps) with breathing room
- Bonus: Can add environmental details (larger floor texture, corner props)

---

### 3. Background Design: "Reinforced Scrap Wall"

#### Concept

The background represents the **interior wall of the fortified scrapyard sanctuary** - the barrier between safety (inside) and danger (wasteland outside).

**Visual Description**:
- **Base Material**: Large weathered metal plates (2-3 visible sections)
  - Oxidation patterns (rust orange bleeding from seams)
  - Welding marks at plate edges (darker burns, rough joints)
  - Scratches, dents, bullet holes (history of attacks)
  - Faded spray-paint markings (survivor territory markers)

- **Structural Elements**:
  - Heavy rivets at plate corners (16-20 visible, CONCRETE_GRAY)
  - Vertical support beam on left or right edge (SOOT_BLACK)
  - Horizontal reinforcement bar across middle third (creates visual shelf for buttons)
  - Subtle corrugated texture (industrial sheeting pattern)

- **Atmospheric Details**:
  - Subtle shadow gradient top-to-bottom (darker at top = overhang/ceiling)
  - Light source from bottom-center (ground-level campfire glow)
  - Faint texture overlay (grime, dust, weathering)
  - NO clutter - background must recede, not compete with buttons

#### Color Palette Application

```gdscript
Base Plates:     CONCRETE_GRAY (#707070) at 85% saturation (slightly desaturated to recede)
Plate Edges:     SOOT_BLACK (#2B2B2B) for seams/depth
Rust Bleeding:   RUST_DARK (#8B4513) at 40% opacity (subtle stains)
Rivets:          CONCRETE_GRAY (#707070) with RUST_ORANGE highlights
Support Beams:   SOOT_BLACK (#2B2B2B) with metallic sheen
Shadow Gradient: HAZARD_BLACK (#1A1A1A) at 30% opacity (top edge)
Glow Hint:       RUST_ORANGE (#D4722B) at 10% opacity (bottom edge)
```

**Rationale**:
- Cool grays create visual calm (sanctuary feeling)
- Warm rust accents provide wasteland authenticity
- Desaturated background ensures buttons POP when using full-saturation RUST_ORANGE

#### Implementation Approach

**APPROVED: Multi-Layer TextureRect Composition**

**Why Multi-Layer** (vs. Gemini-generated image):
- Gemini excels at icons (80x80pt), struggles with adaptive backgrounds (various screen ratios)
- Generated images look "painted" - breaks tactile materiality needed for diegetic UI
- Cannot easily adjust for different screen sizes (iPhone SE vs iPad)
- Performance: Multi-layer approach allows LOD on lower-end devices

**Implementation Structure**:
```
HubBackground (Control node)
├─ BaseLayer (ColorRect) - CONCRETE_GRAY gradient
│  └─ shader: subtle vertical gradient, noise texture
├─ RustOverlay (TextureRect) - rust stain texture, 40% opacity
│  └─ texture: procedural rust pattern or tileable asset
├─ RivetLayer (Control with TextureRects) - positioned rivets
│  └─ 16-20 small circle sprites, CONCRETE_GRAY + RUST_ORANGE
├─ BeamLayer (ColorRect) - vertical support beam, left edge
│  └─ 60px wide, SOOT_BLACK, subtle metallic gradient
└─ VignetteLayer (ColorRect) - shadow edges
   └─ radial gradient shader, HAZARD_BLACK 30% at edges
```

**Alternative (Simpler for MVP)**:
- Single ColorRect with custom shader combining all layers
- **Decision**: Start with Multi-Layer (modular, easier to iterate), optimize to shader if performance issues

#### Performance Budget

**Target Devices**:
- Minimum: iPhone 8 (A11 chip, 2GB RAM, 1334x750 display)
- Optimal: iPhone 12+ (A14+, 4GB RAM, 2532x1170+)

**Performance Targets**:
- Hub scene: < 16ms frame time (60 FPS)
- Background render: < 3ms
- Texture memory: < 10MB total
- Background assets: < 512KB combined

**Optimization Strategies**:
1. Texture compression (VRAM compressed format - BC7/ASTC)
2. LOD tiers (High/Medium/Low based on device)
3. Shader efficiency (built-in gradients, pre-baked lighting)
4. Draw call reduction (texture atlasing, batched materials)

---

### 4. IconButton Component: "Metal Plate Buttons"

#### Component Visual Design

**Metal Plate Aesthetic** (Diegetic UI - buttons ARE physical objects):

```
┌─────────────────────────────────────┐
│ ●                                ● │ ← Rivets (4 corners)
│                                    │
│           ╔════════════╗           │
│           ║            ║           │ ← Icon area (70-85% of button)
│           ║   [ICON]   ║           │   Bold silhouette
│           ║            ║           │   RUST_ORANGE or DIRTY_WHITE
│           ╚════════════╝           │
│                                    │
│             LABEL TEXT             │ ← Label (15-20% of button)
│                                    │   DIRTY_WHITE, stencil font
│ ●                                ● │ ← Rivets (4 corners)
└─────────────────────────────────────┘
 ↑                                   ↑
 Heavy bottom border (4px)           Thin side borders (2px)
 RUST_DARK                           RUST_DARK
```

#### Rivet Specification

- **Count**: 4 rivets (one per corner)
- **Position**: 8pt inset from corner edges
- **Size**: 12pt diameter circles
- **Color**: CONCRETE_GRAY base (#707070)
- **Highlight**: RUST_ORANGE dot at 2 o'clock position (6pt diameter) = light reflection
- **Depth**: Subtle inner shadow (1pt, SOOT_BLACK 50%) = recessed rivet head

**Visual Purpose**: Rivets communicate "this button is a metal plate bolted to the wall" (diegetic interface).

#### Button State Visual Differences

**Normal State** (Default):
```gdscript
Background: SOOT_BLACK (#2B2B2B)
Border: RUST_DARK (#8B4513), 4px bottom / 2px sides
Icon: RUST_ORANGE (#D4722B), 100% opacity
Label: DIRTY_WHITE (#E8E8D0), 100% opacity
Rivets: CONCRETE_GRAY (#707070) + RUST_ORANGE highlight
Position: y = base_position
```

**Pressed State** (Touch/Click):
```gdscript
Background: RUST_DARK (#8B4513), darkens
Border: RUST_LIGHT (#E89B5C), 2px bottom / 4px top (inverted)
Icon: DIRTY_WHITE (#E8E8D0), swaps to light (contrast)
Label: DIRTY_WHITE (unchanged)
Rivets: Dim slightly (CONCRETE_GRAY 70% opacity)
Position: y = base_position + 2 (shifts down 2px)
SFX: Metallic clang sound (0.1s, pitch randomized ±10%)
```

**Disabled State** (Future - Not MVP):
```gdscript
Background: CONCRETE_GRAY (#707070), 50% opacity
Border: SOOT_BLACK (#2B2B2B), 2px all sides (no depth)
Icon: CONCRETE_GRAY (#707070), 40% opacity (faded)
Label: CONCRETE_GRAY (#707070), 40% opacity
Rivets: Barely visible (20% opacity)
```

#### Size Specifications

**Primary Buttons** (Start Run):
- Total Size: 120x140pt (width x height with label)
- Icon Area: 120x120pt (square, 85% of visual weight)
- Label Area: 120x20pt (bottom section, 15% of visual weight)
- Touch Target: 120x140pt (full button clickable)

**Secondary Buttons** (Roster, Settings - Current):
- Total Size: 80x100pt
- Icon Area: 80x80pt
- Label Area: 80x20pt
- Touch Target: 80x100pt

**Secondary Buttons** (Future Operations/Community Zones):
- Total Size: 70x90pt
- Icon Area: 70x70pt
- Label Area: 70x20pt

**Utility Buttons** (Future - Settings, Help, etc.):
- Total Size: 50x65pt
- Icon Area: 50x50pt
- Label Area: 50x15pt

#### Component Code Structure

**IconButton.gd** (Custom Control):
```gdscript
class_name IconButton
extends Control

## Wasteland-themed icon button with metal plate aesthetic
## Phase 8.2c: Hub Button Component

# Exported properties (set in editor)
@export var icon_texture: Texture2D
@export var label_text: String = "BUTTON"
@export var button_size: String = "primary"  # primary, secondary, utility

# Visual constants
const RIVET_SIZE = 12
const RIVET_INSET = 8
const BORDER_NORMAL_BOTTOM = 4
const BORDER_NORMAL_SIDES = 2
const PRESS_SHIFT = 2

# State
var is_pressed: bool = false

# Child nodes (created in _ready)
var background_panel: Panel
var icon_rect: TextureRect
var label_node: Label
var rivets: Array[TextureRect] = []

func _ready():
    _create_background()
    _create_icon()
    _create_label()
    _create_rivets()
    _setup_input()

# Methods: set_icon(), set_label(), set_state(), _on_pressed()
```

---

### 5. Environmental Storytelling Elements

#### Fortification Indicators

**Visual Cues to Include**:

1. **Welded Reinforcements** (High Priority):
   - Thick metal bars welded across background plates
   - Burn marks at weld points (SOOT_BLACK charring)
   - Shows intentional construction, not accidental pile

2. **Rivet Patterns** (High Priority):
   - Clusters of rivets at structural stress points
   - More rivets near edges (reinforcing weak spots)
   - Communicates: "This was engineered to hold"

3. **Defensive Wear** (Medium Priority):
   - Bullet dents in metal (small impact craters)
   - Scratch marks (claw/blade attempts to break in)
   - Shows: "This wall has SURVIVED attacks"

#### Scrapyard Material Indicators

**Visual Cues to Include**:

1. **Repurposed Road Signs** (High Priority):
   - Faded STOP sign fragment visible in one plate (red octagon outline)
   - Spray-painted over, but ghost visible
   - Shows: "We scavenge anything useful"

2. **Mixed Metal Sources** (Medium Priority):
   - Plates have different textures (corrugated vs smooth vs diamond-plate)
   - Color variation (some more rusted than others)
   - Communicates: "Built from whatever we could find"

3. **Visible Weathering** (High Priority):
   - Rust bleeding from seams (RUST_DARK stains)
   - Oxidation patterns (natural aging, not uniform)
   - Shows: "This has been here a while, we're established"

#### Sanctuary Atmosphere Indicators

**Visual Cues to Include**:

1. **Warm Interior Lighting** (High Priority):
   - Bottom-edge glow (RUST_ORANGE 10% opacity) = campfire/generator light
   - Top-edge shadow (HAZARD_BLACK 30%) = protective overhang
   - Creates: "We're in a sheltered space, lit from within"

2. **Inside vs Outside Visual Language** (Medium Priority):
   - Background plates face INWARD (clean side visible)
   - Outer side implied (we see interior mounting brackets)
   - Subtle: "We're on the SAFE side of the wall"

#### Easter Eggs (1-2 Hidden Details)

**Approved for Inclusion**:

1. **Survivor Tally Marks** (High Priority):
   - Scratched into metal in corner plate (lower-left)
   - "////  ////  ///" (17 survivors? Days survived?)
   - Barely visible, requires attention to notice
   - Storytelling: Someone is counting something important

2. **"Lucky" Rivet** (Low Priority - Optional):
   - One rivet slightly bent/off-center (lower-right corner)
   - Suggests: Hasty repair or previous impact
   - Subtle imperfection adds authenticity

**RED LINE**: Maximum 2 easter eggs. Background must stay CLEAN to support buttons.

---

## Implementation Strategy (APPROVED)

### Approach: Iterative Phases with Feedback Loops

**Total Time**: 9.5 hours realistic (11-13 hours with buffer)
**Sessions**: 4 focused sessions (2.5-3 hours each)
**Commits**: 4 incremental commits (clear progression)
**QA Gates**: After each session (catch issues early)

**Why Iterative**:
- ✅ 4 feedback loops (user approval after each major piece)
- ✅ Matches proven quality process (incremental validation = one-shot success)
- ✅ Low risk (revert one session max, not entire 11-hour build)
- ✅ Natural pause points (can handoff between sessions)
- ✅ Clear documentation (4 commits showing progression)
- ✅ Fatigue protection (2-3 hour focused sessions vs 7-11 hour marathon)

**User's Historical Evidence**: "Evidence-based incremental approach = one-shot success, rushing = 99% QA failure"

---

### Session 1: Wall Structure Foundation (2.5-3 hours) - REVISED

**Scope**:
- Metal plate base with visible seam structure
- Rivets positioned at seam intersections (structural purpose)
- Horizontal floor seam (wall meets ground perspective)
- Subtle rust bleeding from seams only
- Vignette (focus enhancement)

**Build Order**:
1. **Base metal plate layer** - Solid CONCRETE_GRAY with minimal noise texture
2. **Visible plate seams** - 2-3 vertical seams + 1 horizontal floor seam
   - Thick dark lines (SOOT_BLACK, 4-6px wide)
   - Slight shadow/depth (seams recessed into wall)
3. **Rivets at seam intersections** - 8-12 rivets where seams cross
   - Clear structural purpose (bolts holding plates together)
   - Positioned strategically at T-junctions and corners
4. **Subtle rust bleeding FROM seams** - Linear gradients from seam edges
   - RUST_DARK at 0.15 opacity (NOT 0.4 - was way too much)
   - 6-12px bleed outward from seams (weathering effect)
5. **Vignette** - Corner darkening for visual focus (keep from original plan)

**QA Gate Checklist**:
- [ ] **Wall Structure Test**: "Does this read as a metal wall made of bolted plates?" (structural clarity)
- [ ] **Seam Visibility**: Can you clearly see where the plates join? (2-3 vertical + 1 horizontal)
- [ ] **Rivet Purpose**: Do rivets make sense structurally? (positioned at seam intersections)
- [ ] **Perspective**: Does the horizontal floor seam establish "you're standing in a courtyard"?
- [ ] **Rust Subtlety**: Is rust weathering (from seams) NOT camo pattern? (0.15 opacity max)
- [ ] **Performance**: 60 FPS on iPhone SE
- [ ] **Accessibility**: Background doesn't interfere with button contrast

**Deliverable**:
- Commit: `feat(ui): add scrapyard background foundation for Phase 8.2c`
- Files: `scenes/hub/scrapyard.tscn` (updated), `assets/hub/backgrounds/` (textures)

**User Feedback Checkpoint**:
📸 "Does the background atmosphere match your vision? Any adjustments before we build buttons on top?"

**Rollback Strategy**:
- If user dislikes: Revert commit, adjust parameters (rust intensity, rivet count), re-commit
- Low risk: Background is isolated layer, no dependencies yet

---

### Session 2: Gate Frame + IconButton Component (3-4 hours) - REVISED

**CRITICAL CHANGE**: Gate button and gate frame are THE SAME THING - build together, not separately.

**Scope**:
- Gate frame visual (integrated into background wall structure)
- IconButton.gd base component (state machine: idle/pressed/disabled)
- Metal plate button aesthetic (4 corner rivets, depth effects)
- Gate-specific styling (hero button = the literal gate opening)
- Icon integration (gate SVG) + touch feedback

**Build Order**:
1. **Add gate frame to background** (Session 1 wall structure)
   - Two vertical "posts" on either side of center-top area (SOOT_BLACK ColorRects)
   - Horizontal cross-beam above gate area (structural support)
   - Rivets at frame corners (integrated with wall seams)
2. **IconButton.gd base class** (extends Control, reusable for all 3 buttons)
3. **Metal plate button visual** (StyleBoxFlat with borders, rivets, depth)
4. **State machine** (idle/pressed states)
   - Pressed state: 2px translate down, RUST_DARK background, border color invert
5. **Icon + label slots** (centered icon, bottom-aligned label)
6. **Gate button specialization** - Larger size (120x120pt), positioned in gate frame
7. **Integrate gate SVG icon** from Phase 8.2b
8. **Test in context** (gate button within gate frame on wall structure)

**QA Gate Checklist**:
- [ ] **Gate Integration**: "Does the gate button look like it's IN the wall frame?" (spatial coherence)
- [ ] **Frame Structure**: Gate frame reads as structural support? (posts + cross-beam obvious)
- [ ] **Button Physicality**: Does pressing feel like activating a physical gate mechanism?
- [ ] **Tactile Feedback**: Instant 2px drop + color swap (satisfying press)
- [ ] **Icon Clarity**: Gate icon legible at 120x120pt
- [ ] **Component Reusability**: Base IconButton works for roster/settings too (80x80pt test)
- [ ] **Performance**: No frame drops on button press
- [ ] **Accessibility**: Icon contrast ≥ 3:1 against button background

**Deliverable**:
- Commit: `feat(ui): add gate frame and IconButton component for Phase 8.2c`
- Files:
  - `scripts/ui/components/IconButton.gd` (base component)
  - `scenes/ui/components/icon_button.tscn` (component scene)
  - `scenes/hub/scrapyard.tscn` (updated with gate frame visual)

**User Feedback Checkpoint**:
📸 "Does the gate button feel like a physical gate in the wall? Does the frame provide enough context? Is the button tactile/premium feeling?"

**Rollback Strategy**:
- If user wants changes: Easy to tweak parameters (rivet size, press depth, icon padding)
- Medium risk: If state machine feels wrong, may need 30-60min refactor

---

### Session 3: Layout + Integration (2.5-3 hours)

**Scope**:
- Implement approved scalable layout (Hybrid+ with Spatial Zones)
- Position 3 buttons (Start Run 120x120pt, Roster/Settings 80x80pt)
- Integrate final icon SVGs (gate, roster, tools from Phase 8.2b)
- Spatial composition testing (hierarchy clear?)
- Responsive scaling (iPhone SE to Pro Max)
- Wire up button signals (navigation placeholder)

**Build Order**:
1. Update `scenes/hub/scrapyard.tscn` with background (from Session 1)
2. Instantiate 3 IconButton nodes (from Session 2)
3. Position buttons per approved layout:
   - Start Run: Center-top (120x120pt)
   - Character Roster: Lower-left flank (80x80pt)
   - Settings: Lower-right flank (80x80pt)
4. Assign final SVG icons:
   - `assets/icons/hub/icon_start_run_final.svg`
   - `assets/icons/hub/icon_roster_final.svg`
   - `assets/icons/hub/icon_settings_final.svg`
5. Set button labels ("START RUN", "ROSTER", "SETTINGS")
6. Connect button signals to placeholder navigation (print statements OK)
7. Test responsive scaling (safe area margins, different screen sizes)

**QA Gate Checklist**:
- [ ] **Hierarchy Test**: "Is Start Run obviously the primary action?" (10-second test)
- [ ] **Spatial Flow**: "Does layout feel organized, not cluttered?"
- [ ] **Thumb Ergonomics**: All buttons reachable one-handed on 6.7" device?
- [ ] **Icon Legibility**: All 3 icons recognizable at current sizes?
- [ ] **Responsive Scaling**: Layout adapts to 4.7" and 6.7" without overlap
- [ ] **Navigation Test**: Buttons correctly trigger signals (placeholder OK for now)

**Deliverable**:
- Commit: `feat(ui): integrate icon buttons into scrapyard hub layout`
- Files: `scenes/hub/scrapyard.tscn` (complete layout)

**User Feedback Checkpoint**:
📸 "Does the spatial layout feel right? Is Start Run clearly the hero? Any spacing adjustments?"

**Rollback Strategy**:
- If layout feels off: Easy to adjust positions (no code changes, just coordinates)
- Low risk: Pure positioning, buttons already work from Session 2

---

### Session 4: Environmental Details + Polish (2-3 hours)

**Scope**:
- Environmental storytelling (welding marks, support beam)
- Easter eggs (1-2 hidden details: survivor tally marks, lucky rivet)
- Button press SFX (metallic clang audio)
- Final polish (shadows, lighting refinement, micro-animations)
- 10-Second Impression Test (fresh eyes validation)
- Performance profiling (ensure 60 FPS on iPhone SE)

**Build Order**:
1. Add support beam sprite/ColorRect (above gate, diagonal brace visual)
2. Welding marks texture (RUST_ORANGE glow near beam joints)
3. Easter egg #1: Survivor tally marks (scratched in lower-left corner plate)
4. Easter egg #2: "Lucky" rivet (one rivet slightly bent in lower-right) - OPTIONAL
5. Button press SFX (import `metallic_clang.wav`, wire to IconButton pressed signal)
6. Shadow refinement (ambient occlusion under buttons for depth)
7. Final device QA pass (all devices, all buttons, all interactions)
8. 10-Second Impression Test with external observer (if available) or user validation

**QA Gate Checklist**:
- [ ] **Storytelling**: "Do environmental details add immersion without distraction?"
- [ ] **Easter Eggs**: "Are they discoverable but not obvious?" (1-2 only, subtle)
- [ ] **Audio Feedback**: SFX enhances tactile feel (not annoying on 10th press)
- [ ] **Performance**: Still 60 FPS with all details added (profile on iPhone SE)
- [ ] **10-Second Test**: External observer gets "fortified scrapyard" vibe immediately
- [ ] **Accessibility**: Details don't reduce button contrast or legibility

**Deliverable**:
- Commit: `feat(ui): complete Phase 8.2c hub with environmental storytelling`
- Files: `scenes/hub/scrapyard.tscn` (complete), `assets/hub/decorations/` (detail sprites), `audio/hub/sfx/` (button sounds)

**User Feedback Checkpoint**:
📸 "Final validation: Does this pass the 10-Second Impression Test? Any last tweaks before Phase 8.3?"

**Rollback Strategy**:
- If details feel wrong: Easy to disable layers (support beam, welding marks are separate nodes)
- Very low risk: Polish layer, core functionality complete from Session 3

---

## Success Criteria

### Qualitative Metrics (User Feedback)

**"Fortified" Feeling**:
- Show hub to 3 unfamiliar users
- Ask: "What kind of place is this?"
- **SUCCESS**: 2/3 say "bunker, shelter, safe place, fort"

**"Scrapyard" Authenticity**:
- Ask: "What materials is this made from?"
- **SUCCESS**: 2/3 mention "metal, salvaged parts, welded, repurposed"

**"Sanctuary" Atmosphere**:
- Ask: "Does this feel safe or dangerous?"
- **SUCCESS**: 3/3 say "safe, protected" with caveat "but dangerous outside"

**Button Physicality**:
- Ask: "Do the buttons feel like part of the environment or floating UI?"
- **SUCCESS**: 2/3 say "part of environment, mounted to wall, physical"

**$10 Quality Bar**:
- Ask: "Would you pay $10 for a game with this visual quality?"
- **SUCCESS**: 2/3 say "yes, looks premium" or "maybe, close"

### Quantitative Metrics (Technical)

**Performance** (Device Testing):
- iPhone SE (2020): ≥ 55 FPS average on hub (93% of 60 FPS target)
- iPhone 12+: Locked 60 FPS
- Battery drain: < 5% per 10 minutes idle on hub

**Touch Accuracy** (Interaction Testing):
- 95% of button taps register correctly (no mis-taps)
- No accidental Quit taps during 20-tap test session
- Buttons respond within 50ms of touch

**Visual Contrast** (WCAG Compliance):
- Button labels: ≥ 4.5:1 contrast ratio (DIRTY_WHITE on SOOT_BLACK)
- Icons: ≥ 3.0:1 contrast ratio (large elements exempt from 4.5:1)
- All text readable in bright sunlight (outdoor mobile test)

**Memory Footprint**:
- Hub scene RAM: < 15MB total
- Texture VRAM: < 10MB
- Scene load time: < 500ms on iPhone SE

### Definition of "Complete"

**✅ Phase 8.2c COMPLETE When**:
- [ ] Background shows fortified scrap wall (metal plates, rivets, rust, vignette)
- [ ] IconButton component works (normal/pressed states, rivets, 2px depth)
- [ ] All 3 buttons positioned spatially (gate center-top 120pt, roster/settings flanking 80pt)
- [ ] Icons integrated (gate, silhouettes, tools SVGs)
- [ ] Buttons feel diegetic (physical objects on wall, not floating UI)
- [ ] Environmental details add atmosphere (welding marks, 1-2 easter eggs)
- [ ] Button press SFX enhances tactile feedback
- [ ] Performance ≥ 55 FPS on iPhone SE
- [ ] User approves: "This feels like fortified scrapyard sanctuary"
- [ ] User approves: "This looks $10 premium"
- [ ] 10-Second Impression Test passes (3/5 criteria minimum)

**🎯 Stretch Goals** (Optional):
- [ ] Support beam detail adds structural storytelling
- [ ] Ambient audio (wind, generator hum) reinforces atmosphere
- [ ] 10-Second Test passes 5/5 criteria (outstanding quality)

---

## Asset Requirements

### Icons (✅ Ready from Phase 8.2b)

- ✅ `assets/icons/hub/icon_start_run_final.svg` (chain-link gate, rust colors)
- ✅ `assets/icons/hub/icon_roster_final.svg` (survivor silhouettes)
- ✅ `assets/icons/hub/icon_settings_final.svg` (crossed wrench + screwdriver)

### Background Textures (🔧 To Create in Session 1)

- 🔧 `assets/hub/backgrounds/rust_overlay.png` (512x512 tileable, RUST_DARK base, 40% opacity)
- 🔧 `assets/hub/backgrounds/rivet_sprite.png` (32x32, CONCRETE_GRAY + RUST_ORANGE highlight)
- 🔧 `assets/hub/backgrounds/metal_support_beam.png` (120x2048 vertical, SOOT_BLACK with sheen) - OPTIONAL
- 🔧 `assets/hub/backgrounds/noise_base.tres` (NoiseTexture2D resource for procedural metal texture)

### Detail Textures (📋 To Create in Session 4)

- 📋 `assets/hub/decorations/welding_marks.png` (256x256 tileable, SOOT_BLACK burn + RUST_ORANGE glow)
- 📋 `assets/hub/decorations/tally_marks.png` (128x128, scratched count, CONCRETE_GRAY)
- 📋 `assets/hub/decorations/lucky_rivet.png` (32x32, bent rivet variant) - OPTIONAL

### Audio Assets (🔊 To Add in Session 4)

- 🔊 `audio/hub/sfx/button_clang_01.wav` (metallic impact, 0.1-0.2s)
- 🔊 `audio/hub/sfx/button_clang_02.wav` (pitch variation +5%)
- 🔊 `audio/hub/sfx/button_clang_03.wav` (pitch variation -5%)

**Asset Creation Methods**:
- **Background base**: Godot NoiseTexture2D shader (procedural, fast, performant)
- **Detail overlays**: Gemini AI generation (rust, welding, rivets - consistent with icon style)
- **Easter eggs**: Manual GIMP/Photoshop (tally marks, subtle details require artistic control)

---

## Risk Management

### Known Risks

**RISK 1**: Background too busy, competes with buttons
**MITIGATION**: Desaturate background (85% saturation), A/B test clean vs detailed, Session 1 QA gate catches this early

**RISK 2**: IconButton component state machine feels wrong
**MITIGATION**: Test in isolation (Session 2), easy to refactor (30-60min), user feedback checkpoint before integration

**RISK 3**: Spatial layout doesn't scale well to future buttons
**MITIGATION**: Approved layout system (Hybrid+ with Zones) designed for 3-10 buttons, clear scalability path documented

**RISK 4**: Performance issues on iPhone SE (2020)
**MITIGATION**: LOD tiers ready (disable textures on low-end), profile early (Session 1), texture budget enforced (< 512KB background)

**RISK 5**: "Doesn't feel $10 premium"
**MITIGATION**: Iterative feedback loops (4 checkpoints), reference Hades/Darkest Dungeon quality bar, polish session (Session 4) for final refinement

### Rollback Strategy

**Git Safety Net**:
```bash
# Each session is a separate commit
# If Session 3 fails, rollback to Session 2 (buttons still work)
git log --oneline  # Find commit hash
git revert <commit-hash>  # Safe revert (preserves history)

# OR hard reset if safe (no pushed commits yet)
git reset --hard HEAD~1  # Undo last commit, keep previous work
```

**Per-Session Rollback**:
- Session 1 fails → Revert background, start over (no dependencies)
- Session 2 fails → Revert button component, background still intact
- Session 3 fails → Revert layout, background + buttons still usable
- Session 4 fails → Revert polish, core hub still functional

**Safety Principle**: Each session is isolated, failure doesn't cascade. Iterative approach minimizes sunk cost.

---

## Next Steps

### Before Session 1

1. ✅ **Documentation Complete**: This design plan committed to repo
2. ✅ **NEXT_SESSION.md Updated**: With 4-session breakdown and current status
3. ✅ **User Approval**: Confirmed on layout system + iterative approach
4. 📋 **Create Todo List**: Track 4 sessions + QA gates

### Session 1 Start Checklist

- [ ] Read this design document (refresh context)
- [ ] Read NEXT_SESSION.md (confirm current phase)
- [ ] Verify icon assets exist (`assets/icons/hub/icon_*_final.svg`)
- [ ] Verify wasteland color palette accessible (`scripts/ui/theme/color_palette.gd`)
- [ ] Create Session 1 todo items (background foundation tasks)
- [ ] Begin implementation (multi-layer background)

---

## References

**Research Documents**:
- [Hub Storytelling Research](../hub-storytelling-research.md) - Hub as narrative center philosophy
- [Phase 8 Icon Button References](../research/phase-8-icon-button-references.md) - Industry pattern analysis (Brotato, Vampire Survivors, etc.)
- [Final Icons Summary](../../assets/icons/hub/FINAL_ICONS_SUMMARY.md) - Icon design decisions (Phase 8.2b)

**Code References**:
- [Color Palette](../../scripts/ui/theme/color_palette.gd) - Wasteland colors (Phase 8.1)
- [Current Hub Scene](../../scenes/hub/scrapyard.tscn) - Pre-transformation state
- [Screen Container](../../scripts/ui/components/screen_container.gd) - iOS safe area handling (Phase 6)

**Expert Panel Documents**:
- Expert Panel Design Document (inline in this plan) - Layout system + implementation approach recommendations

---

## Document Metadata

**Version**: 1.0
**Date**: 2025-11-23
**Status**: APPROVED - Ready for Implementation
**Author**: Expert Panel (Sr Visual Designer, Sr Mobile Game Designer, Sr Narrative Designer, Sr Technical Artist)
**Approved By**: User (2025-11-23)
**Next Review**: After Session 1 completion (user feedback checkpoint)

**Estimated Implementation Time**:
- Optimistic: 7.5 hours
- Realistic: 9.5 hours
- With Buffer: 13.5 hours (includes potential rework)

**Success Probability**: HIGH (iterative approach with 4 feedback loops reduces risk)

---

**END OF DESIGN PLAN**
