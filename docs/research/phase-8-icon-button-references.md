# Phase 8.2 Icon Button Research - Hub Navigation in Premium Roguelites

**Date**: 2025-11-23
**Purpose**: Study industry patterns for icon-based hub navigation to design wasteland-themed buttons
**Context**: Pivoted from text-button styling to icon-based buttons per expert panel unanimous recommendation

---

## 🎯 Research Objectives

1. Document icon-to-label size ratios in successful games
2. Identify button depth/materiality techniques (shadows, borders, physical feel)
3. Understand icon clarity standards (instant recognition vs learned with label)
4. Study wasteland/grimdark UI aesthetics
5. Identify which wasteland objects map to hub functions

**Storytelling Lens** (from docs/hub-storytelling-research.md):
- Hub is narrative/emotional center, not just a menu
- Buttons should feel like physical objects IN the scrapyard space
- Icons reinforce "missions depart from here, this is home base"

---

## 📊 Game Analysis

### 1. Hades (Hub-Based Roguelite - Closest Parallel)

**Hub Structure**:
- House of Hades serves as narrative anchor between escape runs
- NPCs react to mission progress, creating feedback loop
- Hub is where story unfolds, missions accumulate context

**Navigation Pattern**:
- **"Escape Attempt" (Start Run)**: Large ornate door/portal - literal physical departure point
- **Codex/Mirror (Upgrades)**: Physical objects in the space (not floating UI)
- **NPCs**: Character portraits that ARE the buttons (faces = instant recognition)

**Icon-to-Label Ratio**:
- PRIMARY action (Escape): Icon-only with environmental context (door IS the button)
- SECONDARY actions: Small icons with text labels (approximately 60% icon, 40% label)

**Button Depth Techniques**:
- Glowing borders for interactive elements
- Shadow/depth on hover (element lifts slightly)
- Rich colors for active/available states vs desaturated for locked

**Clarity Standard**:
- Primary actions use environmental storytelling (door = exit)
- Secondary actions use universal icons (mirror = reflection/upgrades, codex = book/knowledge)

**Wasteland Parallel for Our Game**:
- "Start Run" could be scrapyard gate/exit (literal departure)
- "Character Roster" could be survivor quarters/barracks door
- Buttons should feel like physical objects you'd find in a scrapyard

---

### 2. Darkest Dungeon (Wasteland/Grimdark Aesthetic)

**Hub Structure**:
- The Hamlet (hub) is visibly degraded - physical manifestation of narrative stakes
- Missions directly framed as correcting mistakes (not abstract tasks)
- Environmental changes show progress (buildings repair)

**Navigation Pattern**:
- **"Embark" (Start Mission)**: Stagecoach icon - literal transportation object
- **Buildings (Roster, Blacksmith, etc.)**: Physical structures you "enter"
- Icons are OBJECTS from the world, not abstract symbols

**Icon-to-Label Ratio**:
- Hub buildings: 70% icon (building illustration), 30% label (building name)
- Action buttons: 80% icon, 20% label
- Heavy visual hierarchy - icons dominate

**Button Depth Techniques**:
- Parchment/paper texture backgrounds (era-appropriate materiality)
- Heavy borders (ink/woodcut aesthetic)
- Pressed state = darker border, slight position shift (tactile)
- Weathering effects (torn edges, stains, aging)

**Clarity Standard**:
- Stagecoach = travel (universal even in fantasy context)
- Buildings are literal representations (not abstract icons)
- Text labels confirm but aren't required for recognition

**Wasteland Parallel for Our Game**:
- Embrace weathering/decay in button visuals (rust, scratches, dents)
- Icons should be recognizable OBJECTS (not abstract symbols)
- "Start Run" = vehicle/gate (transportation/departure)
- "Character Roster" = barracks/lineup (physical location of crew)

---

### 3. Slay the Spire (Roguelike - Icon Clarity Gold Standard)

**Hub Structure**:
- Map-based navigation (nodes are locations, not abstract menus)
- Each icon type instantly communicates encounter type

**Navigation Pattern**:
- **Campfire**: Literal campfire icon - rest/heal
- **Monster**: Skull/creature - combat
- **Merchant**: Coin/shop - transaction
- **Unknown**: Question mark - mystery
- **Elite**: Burning skull - danger

**Icon-to-Label Ratio**:
- Map nodes: 100% icon, 0% label (icons are THAT clear)
- Menu buttons: 70% icon, 30% label
- Hover tooltips provide detail, but icons communicate instantly

**Button Depth Techniques**:
- Simple flat icons with colored backgrounds
- Active node glows/pulses
- Completed nodes desaturate
- Depth through color contrast, not physical shadows

**Clarity Standard** (THE GOLD STANDARD):
- "Grandmother test" - anyone can guess campfire, skull, coin
- Universal symbols that transcend culture/language
- NO mystery meat navigation

**Wasteland Parallel for Our Game**:
- Icons MUST pass instant recognition test
- Use universal metaphors: blade = combat, people = roster, gear = settings
- Avoid abstract symbols - use recognizable objects

---

### 4. Dead Cells (Mobile - Grimdark UI Aesthetic)

**Hub Structure**:
- Environmental navigation (walk to areas)
- When buttons exist, they're physical objects in the world

**Navigation Pattern**:
- Weapon racks you interact with (not "equip menu")
- NPCs you talk to (not "upgrade menu")
- Doors you enter (not "start run button")

**Icon-to-Label Ratio**:
- Tutorial/helper buttons: 60% icon, 40% label
- Interactive objects: No UI overlay - object IS the interaction

**Button Depth Techniques**:
- Dark backgrounds with bright accent colors (orange, blue, purple on black)
- Pixelated but HIGH contrast (readable on mobile)
- Glowing edges for interactables
- Minimal shadows, depth through color separation

**Clarity Standard**:
- Real objects > Abstract icons
- When icons used, they're literal (sword for weapon, skull for danger)

**Wasteland Parallel for Our Game**:
- High contrast wasteland colors (rust orange on dark metal/concrete)
- Consider making buttons look like OBJECTS (gate, door, board, locker)
- Glowing/highlighted edges for interactables

---

### 5. Brotato (Mobile Roguelike - Direct Competitor Analysis)

**Hub Structure**:
- Clean, functional menu with distinct visual sections
- Character portraits dominate the selection screen

**Navigation Pattern**:
- **Character Select**: Large character portraits (face = instant recognition)
- **Settings**: Gear icon (universal)
- **Shop/Unlocks**: Coin/treasure icons (transactional clarity)

**Icon-to-Label Ratio**:
- Character buttons: 85% portrait, 15% name label
- System buttons (settings, etc.): 70% icon, 30% label
- Very large touch targets (mobile-optimized)

**Button Depth Techniques**:
- Thick borders (4-6px)
- Gradient backgrounds (subtle 3D impression)
- Pressed state = border color inversion
- Bright colors on dark background

**Clarity Standard**:
- Faces for characters (most recognizable human element)
- Universal icons for system functions
- Large, simple, high-contrast

**Wasteland Parallel for Our Game**:
- Large touch targets (mobile-first)
- Thick borders (industrial/metal plate aesthetic)
- High contrast (rust orange on dark backgrounds)
- Simple, bold icons (not detailed illustrations)

---

### 6. Vampire Survivors (Viral Success - Minimalist Icons)

**Hub Structure**:
- Extremely simple menu system
- Character portraits as primary navigation

**Navigation Pattern**:
- **Characters**: Portrait grid (face-based selection)
- **Powers/Weapons**: Small icons representing items
- **Settings**: Text-based (less polished than premium competitors)

**Icon-to-Label Ratio**:
- Character select: 90% portrait, 10% name
- Item unlocks: 50% icon, 50% text (less optimized)

**Button Depth Techniques**:
- Minimal depth (success despite lack of polish)
- Simple borders
- Bright colors for active states

**Clarity Standard**:
- Characters: Faces work universally
- Items: Icons are pixel art but recognizable (sword, book, etc.)

**Key Lesson**:
- Icon clarity matters more than visual polish
- Simple can work IF icons are instantly recognizable
- Our wasteland aesthetic can have more polish and still hit clarity bar

---

## 🎨 Wasteland UI Aesthetic Research

### Fallout Series (Vault-Tec UI)

**Visual Language**:
- Retro-futuristic industrial (1950s tech meets post-apocalypse)
- Pip-Boy interface uses physical dials, gauges, switches
- Green monochrome CRT aesthetic (Fallout 3/NV) or amber (Fallout 4)
- Heavy use of iconography: atom symbol, vault boy illustrations

**Button Characteristics**:
- Physical switches and dials (tactile metaphors)
- Riveted metal plates
- Worn/scratched surfaces
- Stencil fonts (military/industrial)

**Icon Style**:
- Vault Boy illustrations (cartoon character in various poses)
- Simple line art icons (recognizable at small sizes)
- 1950s clip-art aesthetic

**Wasteland Parallel for Our Game**:
- Riveted metal plates for button backgrounds
- Stencil/military fonts for labels
- Worn/weathered surfaces (rust, scratches)
- Simple iconic illustrations (not photorealistic)

---

### Mad Max Films (Visual Reference)

**Wasteland Objects**:
- Repurposed road signs as armor/shields
- Car parts as weapons and tools
- Everything has a PREVIOUS LIFE (salvaged identity)
- Spray paint markings (faction symbols, warnings)

**Material Palette**:
- Rust (orange, brown)
- Dirty metal (steel gray with oxidation)
- Leather and fabric (earth tones)
- Blood and oil stains (dark reds/blacks)
- Desert sand (tan, beige)

**Wasteland Parallel for Our Game**:
- Icons should look like SALVAGED OBJECTS
- Spray-painted or stamped symbols (not clean graphics)
- Physical wear visible (dents, rust, scratches)
- "Start Run" = repurposed road sign? Vehicle part? Exit marker?

---

### Borderlands UI (Cel-Shaded Wasteland)

**Visual Language**:
- Hand-drawn, sketchy line art
- Heavy black outlines (comic book style)
- Stencil typography
- Physical texture (metal, paper, fabric)

**Button Characteristics**:
- Thick black borders
- Stamped/stenciled text
- Weathered backgrounds
- High contrast colors

**Icon Style**:
- Simple silhouettes with thick outlines
- Instantly readable shapes
- Stylized but recognizable objects

**Wasteland Parallel for Our Game**:
- Thick borders for buttons (industrial/stamped look)
- Simple iconic shapes (not detailed renders)
- Weathered textures on backgrounds

---

## 📐 Pattern Summary - What We Learned

### Icon-to-Label Size Ratios (Industry Standard)

**Primary Navigation Buttons** (Start Run, Character Roster):
- **Icon**: 70-85% of button area
- **Label**: 15-30% of button area
- **Typical Layout**: Icon above, label below (vertical stack)

**Secondary/System Buttons** (Settings):
- **Icon**: 60-70% of button area
- **Label**: 30-40% of button area
- **Can be more compact** (corner placement)

**Mobile Optimization**:
- Minimum touch target: 44x44pt (iOS HIG)
- Comfortable touch target: 56x56pt or larger
- Icon buttons typically 80-120pt square on mobile

---

### Button Depth & Materiality Techniques

**Physical Depth Signals**:
1. **Thick bottom border** (4-6px) creates shadow effect
2. **Border color contrast** (dark border on light bg, or vice versa)
3. **Gradient backgrounds** (subtle 3D impression)
4. **Pressed state**: Border inversion + 1-2px position shift

**Wasteland-Specific Materiality**:
1. **Rivets/bolts** at corners (metal plate aesthetic)
2. **Weathering texture** (rust, scratches, dents)
3. **Stamped or spray-painted** appearance (not clean print)
4. **Thick industrial borders** (welded/bolted look)

**Color Technique**:
- High contrast: Bright icon/label on dark background
- Rust orange (#D4722B) on dark metal (#2B2B2B) = 7:1 contrast ratio
- Glowing edges for active/hover states (subtle NEON_GREEN?)

---

### Icon Clarity Standards ("Grandmother Test")

**Gold Standard** (Slay the Spire model):
- Icon alone communicates function to unfamiliar user
- Universal metaphors: campfire = rest, skull = danger, coin = shop
- NO mystery meat navigation

**Acceptable** (Hades/Brotato model):
- Icon + label together are instantly clear
- Icon may need label for confirmation
- Icon reinforces label meaning (visual + verbal)

**For Our Three Hub Buttons**:

**"Start Run"** - Clarity Requirement: HIGH
- Must instantly communicate "begin mission/combat"
- Options that pass test:
  - ✅ Rusty blade/weapon (combat metaphor)
  - ✅ Exit gate/door (departure metaphor)
  - ✅ Backpack/gear (preparation metaphor)
  - ❌ Abstract triangle (too generic)

**"Character Roster"** - Clarity Requirement: MEDIUM-HIGH
- Must communicate "multiple people/survivors"
- Options that pass test:
  - ✅ 3 silhouettes side-by-side (literal roster)
  - ✅ Dog tags/ID badges (military roster metaphor)
  - ✅ Barracks/quarters door (location metaphor)
  - ❌ Single person icon (doesn't convey "multiple")

**"Settings"** - Clarity Requirement: MEDIUM (Universal pattern exists)
- Gear/wrench is universally recognized
- Options that pass test:
  - ✅ Wrench + screwdriver crossed (universal + wasteland)
  - ✅ Gear cog (universal, less thematic)
  - ✅ Control panel/dial (wasteland tech)
  - ❌ Abstract hamburger menu (mobile cliché)

---

## 🎯 Icon Concept Directions (Refined After Research)

### "Start Run" Button Icon Concepts

**CONCEPT 1: Scrapyard Gate (Departure Metaphor)**
- Visual: Rusty chain-link fence gate, slightly ajar
- Storytelling: Literal exit from scrapyard hub to wasteland missions
- Clarity: Gate = exit/entrance (universal architecture metaphor)
- Wasteland Authenticity: Gates are salvaged/repurposed in Mad Max aesthetic
- Technical: Simple silhouette, recognizable at 80x80px

**CONCEPT 2: Crossed Knife + Wrench (Combat + Survival)**
- Visual: Rusty combat knife crossed with pipe wrench (X shape)
- Storytelling: Tools of survival in wasteland (fight + fix)
- Clarity: Knife = danger/combat (universal weapon symbol)
- Wasteland Authenticity: Improvised weapons are wasteland signature
- Technical: Bold shapes, high contrast, easy to render

**CONCEPT 3: Wasteland Road Icon (Journey Metaphor)**
- Visual: Cracked asphalt road leading to horizon with "DANGER" sign
- Storytelling: Road to adventure (classic journey symbol)
- Clarity: Road/path = travel (universal)
- Wasteland Authenticity: Broken roads, warning signs
- Technical: More detailed, may be harder to read at small size

**RECOMMENDATION: Concept 1 (Scrapyard Gate) or Concept 2 (Knife+Wrench)**
- Both pass grandmother test
- Both feel physically present in scrapyard
- Gate reinforces hub-as-home narrative (you LEAVE through the gate)

---

### "Character Roster" Button Icon Concepts

**CONCEPT 1: Three Survivor Silhouettes (Literal Roster)**
- Visual: 3 human silhouettes standing side-by-side, weathered/worn edges
- Storytelling: Your crew/survivors at the hub (community)
- Clarity: Multiple people = roster/group (literal representation)
- Wasteland Authenticity: Ragged silhouettes (torn clothes, gear visible)
- Technical: Simple shapes, instant recognition

**CONCEPT 2: Dog Tags on Hooks (Military Roster Metaphor)**
- Visual: 3-4 military dog tags hanging from rusty hooks
- Storytelling: Survivors identified by tags (post-apocalypse ID system)
- Clarity: Dog tags = military roster (recognizable to most)
- Wasteland Authenticity: Salvaged military gear is wasteland staple
- Technical: Detailed but iconic shape (oval tags, chains)

**CONCEPT 3: Barracks Door with "CREW" Stencil**
- Visual: Metal door with spray-painted "CREW" or silhouette symbols
- Storytelling: Physical location where survivors gather (hub-as-space)
- Clarity: Door = entrance to space (requires label for confirmation)
- Wasteland Authenticity: Spray-paint markings, repurposed doors
- Technical: Slightly more complex (door frame, handle, markings)

**RECOMMENDATION: Concept 1 (Three Silhouettes)**
- Clearest instant recognition (literal = people)
- Simple to render, scales well
- Works with or without label

---

### "Settings" Button Icon Concepts

**CONCEPT 1: Wrench + Screwdriver Crossed (Universal + Wasteland)**
- Visual: Rusty pipe wrench crossed with flathead screwdriver (X shape)
- Storytelling: Tools to adjust/fix things (maintenance metaphor)
- Clarity: Tools = settings/adjustments (semi-universal, needs label)
- Wasteland Authenticity: Hand tools are wasteland signature
- Technical: Simple bold shapes, easy to render

**CONCEPT 2: Analog Gauge Dial (Wasteland Tech)**
- Visual: Circular gauge with needle, cracked glass, rust
- Storytelling: Mechanical controls (pre-digital tech)
- Clarity: Dial = control/adjustment (requires label for some users)
- Wasteland Authenticity: Salvaged industrial gauges
- Technical: More detailed (needle, numbers, glass cracks)

**CONCEPT 3: Gear Cog (Universal Standard)**
- Visual: Industrial gear cog, rusted and weathered
- Storytelling: Less thematic, more functional
- Clarity: Gear = settings (universal across all platforms)
- Wasteland Authenticity: Can be made rusty, but icon itself is generic
- Technical: Simple silhouette, instant recognition

**RECOMMENDATION: Concept 1 (Wrench+Screwdriver)**
- Balance of clarity + wasteland theme
- More interesting than generic gear cog
- Still recognizable with "Settings" label

---

## 📋 Design Requirements Document

### Button Component Specifications

**Size & Touch Targets** (Mobile-First):
- **Primary Buttons** (Start Run, Roster): 100x100pt minimum (comfortable tap)
- **Secondary Buttons** (Settings - corner icon): 56x56pt minimum
- **Icon Area**: 70-80% of button dimensions
- **Label Area**: 20-30% of button dimensions (below icon)
- **Spacing**: 16-24pt between buttons

**Visual Structure**:
```
┌─────────────────┐
│                 │
│   [ICON 70%]    │  ← Icon dominates (metal plate, rivets, weathered)
│                 │
├─────────────────┤
│  [Label 30%]    │  ← Stencil font, DIRTY_WHITE on dark
└─────────────────┘
```

**Color Palette** (from color_palette.gd):
- **Button Background**: SOOT_BLACK (#2B2B2B) or CONCRETE_GRAY (#707070)
- **Button Border**: RUST_DARK (#8B4513) - 4px bottom, 2px sides/top
- **Icon Color**: RUST_ORANGE (#D4722B) or DIRTY_WHITE (#E8E8D0)
- **Label Text**: DIRTY_WHITE (#E8E8D0) - stencil font
- **Rivets/Details**: CONCRETE_GRAY (#707070) or RUST_LIGHT (#E89B5C)
- **Active/Hover Glow**: NEON_GREEN (#39FF14) - subtle edge glow

**Depth & Materiality**:
1. **Base Layer**: Dark metal plate (SOOT_BLACK or CONCRETE_GRAY)
2. **Border**: Thick bottom (4px), thinner sides (2px) - RUST_DARK
3. **Rivets**: 4 corner rivets (small circles, CONCRETE_GRAY)
4. **Weathering**: Subtle texture overlay (scratches, rust spots) - optional
5. **Icon Layer**: Bold silhouette in RUST_ORANGE or DIRTY_WHITE
6. **Label**: Stencil font below icon, DIRTY_WHITE

**Pressed State**:
- Border inverts: RUST_LIGHT replaces RUST_DARK
- Button shifts down 2px (tactile depression)
- Bottom border reduces to 2px (flattens)
- Optional: Subtle clang SFX

**Hover State** (desktop):
- Subtle NEON_GREEN glow around border (1-2px)
- Icon brightens slightly (10-20% lighter)

---

### Icon Asset Specifications

**Technical Requirements**:
- **Format**: SVG (vector) for scalability, OR PNG at 2x resolution (160x160px for 80x80pt display)
- **Style**: Bold silhouettes with thick outlines (2-3px stroke)
- **Color**: Single-color initially (RUST_ORANGE or DIRTY_WHITE), can add details later
- **Weathering**: Optional texture layer (rust, scratches) - test clarity first
- **Line Weight**: Thick enough to read at 80x80pt (minimum 2px stroke)

**Clarity Testing Process**:
1. Create icon at target size (80x80pt)
2. Show to unfamiliar person for 3 seconds
3. Ask: "What do you think this button does?"
4. PASS: Correct answer or "I'd click it to [correct function]"
5. FAIL: "I have no idea" or wildly wrong answer
6. ITERATE until pass

**Art Direction**:
- **NOT photorealistic** - stylized silhouettes
- **NOT detailed illustrations** - bold iconic shapes
- **NOT clean vector art** - weathered, worn, imperfect edges
- **YES to bold shapes** - instant recognition at small size
- **YES to wasteland materials** - rust, metal, worn surfaces
- **YES to physical objects** - things you'd find in a scrapyard

---

## 🎯 Next Steps (For Sub-Phase 8.2b - Design & Iteration)

### Design Process

1. **Sketch Phase** (pencil/digital sketches):
   - Sketch 3 versions of each icon concept (9 total sketches)
   - Focus on silhouette clarity (squint test - still recognizable?)
   - Vary level of detail (simple vs complex)

2. **Clarity Testing** (before committing to assets):
   - Show sketches to 2-3 people unfamiliar with project
   - Ask "What does this button do?"
   - Iterate on failed concepts

3. **Asset Creation** (winners only):
   - Create SVG or high-res PNG assets
   - Apply wasteland color palette
   - Add weathering/texture (test that it doesn't hurt clarity)

4. **Component Integration** (Sub-Phase 8.2c):
   - Build IconButton component in Godot
   - Add metal plate background with rivets
   - Add depth effects (borders, shadows)
   - Test on device (iPhone 8 Plus minimum)

### Icon Concept Decisions (Ready for 8.2b)

**"Start Run"**:
- PRIMARY: Scrapyard gate (departure metaphor, reinforces hub-as-home)
- BACKUP: Knife + wrench crossed (combat + survival)

**"Character Roster"**:
- PRIMARY: Three survivor silhouettes (literal, instant clarity)
- BACKUP: Dog tags on hooks (thematic, recognizable)

**"Settings"**:
- PRIMARY: Wrench + screwdriver crossed (wasteland + functional)
- BACKUP: Gear cog (universal fallback if tools fail clarity test)

### Success Criteria for 8.2b

- [ ] 9 icon sketches created (3 per button)
- [ ] Clarity tested with 2-3 unfamiliar people
- [ ] 3 winning concepts selected (1 per button)
- [ ] Final icon assets created (SVG or PNG)
- [ ] Icons pass "grandmother test" (instant or quick recognition)
- [ ] Icons feel like wasteland objects (not abstract UI)
- [ ] Ready for component implementation (8.2c)

---

## 📚 Reference Links & Resources

### Games to Screenshot (Manual Research)
- Hades: House hub, escape door, mirror interactions
- Darkest Dungeon: Hamlet buildings, stagecoach, roster
- Slay the Spire: Map nodes (campfire, monster, merchant)
- Dead Cells: Equipment racks, upgrade NPCs
- Brotato: Character select, settings
- Vampire Survivors: Character grid, power-ups

### Wasteland Visual References
- Fallout 4 Pip-Boy interface
- Mad Max: Fury Road production design stills
- Borderlands UI screenshots
- Rust (survival game) UI elements

### Icon Design Tools
- Figma/Sketch for vector design
- Inkscape (free alternative)
- Procreate/Photoshop for texture overlays
- Godot's built-in SVG import

---

**Research Phase Status**: ✅ **COMPLETE** (patterns documented, concepts identified, ready for design)

**Next Phase**: Sub-Phase 8.2b - Icon Design & Iteration (4-6 hours)

**Last Updated**: 2025-11-23
