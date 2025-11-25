# The Scrapyard - Scene Art Bible
## Scrap Survivor | AI Art Generation Reference

**Document Purpose:** Complete visual reference for generating art assets for "The Scrapyard" - the central hub scene in Scrap Survivor. This is the first scene all players see after character selection and serves as the game's home base.

**Target AI Tools:** Gemini Imagen, Midjourney, DALL-E 3, Stable Diffusion
**Target Platform:** Mobile-first (iOS/Android via Capacitor)
**Genre Context:** Top-down roguelite auto-shooter (Brotato/Vampire Survivors style)

---

## 1. GAME CONTEXT

### What Is Scrap Survivor?
A mobile roguelite survival game where players are "Scrappers" - resourceful survivors in a post-apocalyptic wasteland who fight waves of mutants, raiders, and rogue machines while collecting scrap to build increasingly powerful gear.

### The Core Fantasy
**"Building something amazing out of literal junk."** Players don't find polished weapons - they bolt together contraptions from salvage. The upgrade you get isn't "+10% damage" - it's a circular saw blade visibly attached to your gun.

### Genre Comparisons
- **Gameplay:** Brotato, Vampire Survivors, Survivor.io
- **Visual Tone:** Borderlands meets Darkest Dungeon meets Mad Max
- **Setting Vibe:** More Ratchet & Clank colorful wasteland than Fallout grimdark

---

## 2. THE SCRAPYARD - OVERVIEW

### What Is The Scrapyard?
The Scrapyard is the player's **home base** - a fortified junkyard settlement that serves as the central hub between combat runs. It's where players:
- Buy/sell items at the Shop
- Upgrade stats at the Advancement Hall
- Store currency at the Bank (Premium)
- Access special vendors (Premium/Subscription)
- Prepare for their next run into the Wasteland

### Emotional Function
The Scrapyard should feel like a **safe haven** - warm, industrious, protected. After the chaos of combat, players return here to catch their breath, improve their build, and prepare for the next challenge. It should feel:
- **Safe:** Walls, guards, defenses visible
- **Busy:** Signs of life, activity, industry
- **Warm:** Golden-hour lighting, fire glow, lit windows
- **Hopeful:** Despite the apocalypse, people are surviving, building, thriving

### Visual Inspiration Sources
- **Mad Max: Fury Road** - Citadel/Gas Town (fortified settlements)
- **Borderlands series** - Sanctuary, Fyrestone (colorful wasteland towns)
- **Fallout 4** - Diamond City, player settlements (scrap architecture)
- **Darkest Dungeon** - Hamlet hub (illustrated 2D hub aesthetic)
- **AFK Arena** - Hub screens (mobile game polish level)

---

## 3. ART DIRECTION

### Style: "Illustrated Junkpunk"
The art style is **painterly/illustrated** with visible brushwork, NOT photorealistic. Think of it as a living graphic novel or concept art come to life.

**Core Visual Principles:**
- **Heavy outlines** on major shapes (buildings, vehicles, characters)
- **Painterly textures** - visible brushstrokes, not smooth gradients
- **Rich detail** - every surface tells a story of use, repair, modification
- **Warm color temperature** - sunset/golden hour as default lighting
- **Layered depth** - foreground, midground, background clearly defined
- **Environmental storytelling** - details suggest history and function

### What This Style Is NOT
- ❌ Photorealistic renders
- ❌ Clean vector art
- ❌ Pixel art / retro 8-bit
- ❌ Anime/manga style
- ❌ Grimdark desaturated (Fallout 3 style)

### What This Style IS
- ✅ Concept art quality illustrations
- ✅ Painterly with visible texture
- ✅ Colorful despite being "post-apocalyptic"
- ✅ Detail-rich without being cluttered
- ✅ Borderlands-adjacent but warmer/softer

---

## 4. COLOR PALETTE

### Primary Palette - Environment

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Rust Orange | #B85C38 | 184, 92, 56 | Rusted metal, warm accents |
| Corrugated Tan | #C4A77D | 196, 167, 125 | Metal siding, sand, canvas |
| Scrap Gray | #5C5C5C | 92, 92, 92 | Metal surfaces, shadows |
| Burnt Umber | #8B4513 | 139, 69, 19 | Wood, deep rust, dirt |
| Dusty Brown | #A0826D | 160, 130, 109 | Ground, paths, weathered surfaces |

### Secondary Palette - Atmosphere

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Sunset Orange | #E86A33 | 232, 106, 51 | Sky glow, dramatic lighting |
| Dusk Purple | #6B4C6B | 107, 76, 107 | Evening sky, deep shadows |
| Firelight Gold | #FFB347 | 255, 179, 71 | Warm light sources, glows |
| Window Yellow | #FFC857 | 255, 200, 87 | Lit windows, interior glow |

### Accent Palette - UI & Gameplay

| Color Name | Hex Code | RGB | Phaser Hex | Usage |
|------------|----------|-----|------------|-------|
| Primary Orange | #FF6600 | 255, 102, 0 | 0xff6600 | Buttons, highlights, selection |
| Terminal Green | #00FF00 | 0, 255, 0 | 0x00ff00 | CRT screens, tech elements |
| Safe Cyan | #00CED1 | 0, 206, 209 | 0x00ced1 | Player-friendly indicators |
| Alert Red | #DC143C | 220, 20, 60 | 0xdc143c | Warnings, danger |
| Premium Gold | #FFD700 | 255, 215, 0 | 0xffd700 | Premium features, currency |

### Background/Base Colors

| Color Name | Hex Code | Phaser Hex | Usage |
|------------|----------|------------|-------|
| Scene Background | #2C2C2C | 0x2c2c2c | Default game background |
| Dark Panel | #1A1A1A | 0x1a1a1a | UI panel backgrounds |
| Light Panel | #333333 | 0x333333 | Secondary panels |
| Border Stroke | #444444 | 0x444444 | Panel borders |

### Sky Gradient (Sunset Scene)
```
Top:    #2D1B4E (deep purple)
        ↓
Middle: #8B4B6B (dusty rose)
        ↓
        #E86A33 (sunset orange)
        ↓
Bottom: #FFB347 (golden glow at horizon)
```

---

## 5. SCRAPYARD LAYOUT & ARCHITECTURE

### Overall Composition
The Scrapyard should be presented as a **fortified settlement** viewed from a **3/4 overhead perspective** or **wide establishing shot**. Key elements:

1. **Perimeter Walls** - Made from:
   - Stacked crushed cars
   - Shipping containers
   - Corrugated metal sheets
   - Concrete barriers
   - Chain-link with scrap reinforcement

2. **Guard Towers** - At corners/gates:
   - Wooden/metal scaffolding
   - Mounted searchlights
   - Gun emplacements (turrets, artillery)
   - Lookout platforms
   - Warning flags/banners

3. **Central Plaza** - Open gathering space:
   - Packed dirt/gravel surface
   - Fire barrels for warmth/light
   - Circular or oval shape
   - Central meeting point

4. **Buildings/Locations** - Arranged around plaza:
   - Various sizes and styles
   - Each with distinct silhouette
   - Lit windows showing activity
   - Signs identifying function

5. **Atmosphere Details**:
   - Smoke rising from chimneys
   - Hanging lights (string lights, lanterns)
   - Cables and wires connecting buildings
   - Scrap piles between structures
   - Parked vehicles (trucks, motorcycles)

---

## 6. HUB LOCATIONS - DETAILED DESIGNS

Each location in the Scrapyard needs a distinct visual identity. They should be recognizable at a glance from their silhouette and color coding.

### 6.1 THE SCRAP HEAP (Shop)
**Tier:** Free
**Function:** Buy/sell items and weapons

**Visual Concept:**
- A converted **truck or large vehicle** serving as a mobile shop
- Retractable sides revealing merchandise display
- Hand-painted sign: "SCRAP TRUST & EXCHANGE" or "THE SCRAP HEAP"
- Awning/canopy for weather protection
- Items hanging from hooks, laid on tables
- Glowing neon "OPEN" sign (if active)
- Vendor character visible inside

**Key Elements:**
- Truck bed as display counter
- Weapon racks on sides
- Crates and barrels of goods
- Cash register or scale
- String lights for visibility
- Chalkboard with prices

**Color Accent:** Warm orange/gold (commerce)

---

### 6.2 ADVANCEMENT HALL (Upgrades)
**Tier:** Free
**Function:** Level up stats, apply permanent upgrades

**Visual Concept:**
- **Workshop/garage** building with large bay door
- Sparks flying from welding inside
- Blueprints and schematics visible on walls
- Workbenches with tools
- Character upgrade stations (like examination chairs)
- Progress meters and gauges

**Key Elements:**
- Overhead industrial lamp
- Tool pegboard
- Vise and anvil
- Sparking welding equipment
- "UPGRADES" sign in industrial font
- Open bay door revealing interior

**Color Accent:** Electric blue (improvement/progress)

---

### 6.3 THE BANK
**Tier:** Premium
**Function:** Store currency safely between runs

**Visual Concept:**
- **Reinforced bunker** or vault building
- Heavy metal door with wheel lock
- Porthole window with bars
- Security cameras (improvised)
- "BANK" sign in official/stern font
- More substantial/permanent construction

**Key Elements:**
- Thick riveted walls
- Multiple locks/bolts on door
- Guard posted outside (optional)
- Safe visible through window
- Currency counter/window
- Security lighting

**Color Accent:** Green (money/financial)
**Premium Indicator:** Subtle gold trim, padlock icon

---

### 6.4 BLACK MARKET
**Tier:** Premium  
**Function:** Buy rare/exotic items

**Visual Concept:**
- **Hidden/shadowy** location
- Behind a curtain, down an alley, under a tarp
- Dim lighting with strategic spotlights on goods
- Exotic merchandise (glowing items, strange tech)
- Suspicious vendor character
- "Invitation only" vibe

**Key Elements:**
- Concealed entrance
- Purple/red mood lighting
- Rare items with glow effects
- Hooded or masked vendor
- No official signage
- Lookout character nearby

**Color Accent:** Purple (rare/mysterious)
**Premium Indicator:** Subtle gold elements, lock icon until unlocked

---

### 6.5 BARRACKS (Minions)
**Tier:** Premium
**Function:** Manage companion minions

**Visual Concept:**
- **Military-style** quarters/kennels
- Bunks or pods for minion storage
- Training dummies and obstacle course
- Command console for deployment
- Minions visible resting or training

**Key Elements:**
- Reinforced cages/pods
- Feeding stations
- Training equipment
- Deployment roster board
- Minion health/status displays
- Military-style organization

**Color Accent:** Military green/khaki
**Premium Indicator:** Gold stars, rank insignia

---

### 6.6 QUANTUM STORAGE
**Tier:** Subscription
**Function:** Transfer items between characters

**Visual Concept:**
- **High-tech anomaly** in rustic setting
- Glowing portal or rift
- Floating items suspended in energy
- Sci-fi elements contrasting with junkpunk
- Dimensional distortion effects
- Tesla coils or energy collectors

**Key Elements:**
- Swirling portal/vortex
- Floating inventory items
- Energy containment ring
- Control panel
- Warning signs about dimensional instability
- Ethereal glow effect

**Color Accent:** Cyan/teal (quantum/tech)
**Subscription Indicator:** Animated glow, subscription badge

---

### 6.7 CULTIVATION CHAMBER (Idle System)
**Tier:** Subscription
**Function:** Passive stat gains over time

**Visual Concept:**
- **Greenhouse/growth chamber** hybrid
- Growing pods with characters inside
- Nutrient tubes and monitoring equipment
- Plants and organic growth mixed with tech
- Progress bars showing growth
- Peaceful, zen atmosphere

**Key Elements:**
- Glass/transparent walls
- Glowing growth pods
- Monitoring screens with stats
- Organic/plant decorations
- Bubbling nutrient tanks
- Soft ambient lighting

**Color Accent:** Growth green (natural)
**Subscription Indicator:** Animated growth effect

---

### 6.8 ATOMIC VENDOR (Weekly Special)
**Tier:** Subscription
**Function:** Exclusive rotating inventory

**Visual Concept:**
- **Heavily shielded** vendor booth
- Radiation warning symbols
- Lead-lined walls
- Hazmat-suited vendor
- Exotic glowing merchandise
- Timer showing rotation

**Key Elements:**
- Radiation symbols
- Lead/concrete shielding
- Geiger counter display
- Glowing rare items
- Hazmat suit on vendor
- "WEEKLY SPECIAL" indicator
- Countdown timer

**Color Accent:** Radioactive yellow-green
**Subscription Indicator:** Pulsing glow, weekly reset timer

---

### 6.9 WASTELAND GATE (Enter Combat)
**Tier:** Free
**Function:** Start combat run

**Visual Concept:**
- **Main entrance/exit** gate of the Scrapyard
- Large, imposing, reinforced
- Warning signs about danger beyond
- Guards stationed at post
- Button/lever to open
- View of wasteland beyond

**Key Elements:**
- Heavy gate doors (could be truck doors, shipping container)
- "DANGER: WASTELAND BEYOND" signage
- Skull warnings
- Guard posts
- Opening mechanism
- Glimpse of dangerous exterior

**Color Accent:** Alert red (danger/action)

---

## 7. INTERIOR SCENE GUIDELINES

For locations that have interior views (Bank, Workshop, etc.), use these guidelines:

### Architectural Style
- **Bunker/Quonset hut** aesthetic with arched ceilings
- Corrugated metal walls and roofing
- Exposed pipes and ductwork
- Industrial lighting (hanging lamps, bare bulbs)
- Concrete or dirt floors

### Standard Interior Elements
- Workbench with tools
- CRT monitor/terminal (green screen)
- Pegboard with hanging tools
- Shelving with supplies
- Heavy door (vault-style or industrial)
- Warm single light source
- Personal touches (posters, photos, decorations)

### Interior Lighting
- Single overhead lamp or lantern as key light
- Green CRT glow as accent
- Warm amber/orange tones
- Deep shadows for atmosphere
- Practical lights visible (not just ambient)

---

## 8. LIGHTING & ATMOSPHERE

### Default Time of Day: Golden Hour/Dusk
The Scrapyard's signature look is **late afternoon to early evening** - the "golden hour" transitioning to dusk. This provides:
- Warm, inviting atmosphere
- Dramatic long shadows
- Contrast between lit interiors and cooling exterior
- Beautiful sky gradients
- Cozy "end of day" feeling

### Light Sources
1. **Natural:** Setting sun casting orange/gold light
2. **Fire:** Burning barrels, torches, bonfires
3. **Electric:** String lights, neon signs, spotlights
4. **Interior:** Warm window glow from buildings

### Shadow Treatment
- Long, dramatic shadows from low sun angle
- Pools of warm light around fire sources
- Cool purple/blue in shadowed areas
- Rim lighting on silhouettes

### Weather/Atmosphere
- Default: Clear sky with some clouds
- Subtle dust particles in air
- Heat shimmer optional
- Smoke rising from chimneys
- No rain in default scene (save for variants)

---

## 9. SIGNAGE & TYPOGRAPHY

### Sign Style Guidelines
- **Hand-painted** appearance
- Slightly irregular letterforms
- Weathered and chipped paint
- Mounted on wood or metal backing
- Often illuminated by spotlights

### Font Characteristics
- **Bold, blocky** sans-serif for main text
- Industrial/military feel
- Slight imperfections (worn edges)
- Mix of painted and stenciled
- Some neon-style for special locations

### Example Sign Text
- "THE SCRAP HEAP" (Shop)
- "UPGRADES" (Advancement Hall)
- "BANK" (simple, official)
- "DANGER - KEEP OUT" (restricted areas)
- "OPEN" / "CLOSED" (neon style)
- "SCRAP TRUST & EXCHANGE" (on truck shop)

---

## 10. CHARACTER INTEGRATION

### NPC Placement
NPCs should be visible in the scene to show life and activity:
- Vendor at shop counter
- Guard at watch tower
- Mechanic working at garage
- Citizens walking paths
- Characters lounging/resting

### NPC Visual Style
- Same illustrated style as environment
- Distinct silhouettes
- Functional clothing (jumpsuits, armor pieces)
- Tools and gear visible
- Expressions readable at small size

### Player Character Indication
- Highlighted position for player
- Could be central plaza or specific "home" spot
- Clear path to each location
- Character should feel like they belong

---

## 11. UI INTEGRATION ZONES

When designing the scene, leave space for UI overlays:

### Top Area
- Player stats (health, currency)
- Wave/progress indicators
- Menu button

### Bottom Area
- Navigation buttons to locations
- Action buttons
- Tooltip area

### Side Margins
- Notification areas
- Premium/subscription indicators
- Quick access buttons

### Center
- Keep relatively uncluttered
- Main focal point of scene
- Interactive location hotspots

---

## 12. MOBILE OPTIMIZATION NOTES

### Resolution Targets
- **Design at:** 2048 x 1536 (iPad resolution)
- **Scale down** for phones
- **Aspect ratios:** Support 16:9 to 4:3

### Visual Clarity Requirements
- Locations must be tappable targets (~100px minimum)
- Text readable at small sizes
- High contrast between interactive and decorative elements
- Clear visual hierarchy

### Performance Considerations
- Static background (single image or few layers)
- Animated elements as separate overlays
- Avoid dense particle effects in hub
- Simple lighting (baked, not dynamic)

---

## 13. ANIMATION GUIDELINES (Future Reference)

### Ambient Animations
- Flickering fire light
- Smoke rising
- Flags/banners waving
- Searchlight rotation
- NPCs with idle animations

### Interactive Feedback
- Location highlights on hover/tap
- Door open animations
- Sign illumination
- Purchase/success effects

---

## 14. PROMPT TEMPLATES FOR AI GENERATION

### Main Scrapyard Overview
```
A fortified post-apocalyptic junkyard settlement at golden hour/dusk, 
illustrated painterly style inspired by Borderlands and Darkest Dungeon. 
Walls made of stacked crushed cars and shipping containers. Guard towers 
with searchlights at corners. Central dirt plaza with fire barrels. 
Multiple scrap metal buildings with lit windows around the plaza. 
Hand-painted signs. A truck converted into a shop with "SCRAP TRUST 
& EXCHANGE" sign. Dramatic orange and purple sunset sky. Warm, 
inviting safe-haven atmosphere despite post-apocalyptic setting. 
Heavy outlines, painterly textures, rich detail. --ar 16:9
```

### Interior Workshop/Bunker
```
Interior of a post-apocalyptic bunker workshop, illustrated painterly 
style. Arched corrugated metal ceiling. Workbench with tools hanging 
on pegboard. Old green CRT computer terminal glowing. Heavy vault door 
with porthole window. Single hanging lantern providing warm amber light. 
Gears and mechanical parts as decoration. Worn concrete floor. 
Borderlands-inspired art style with heavy outlines and painterly 
textures. Cozy, industrious atmosphere. --ar 16:9
```

### Shop/Vendor Location
```
A converted military truck serving as a trading post in a post-apocalyptic 
junkyard, illustrated painterly style. Side panels opened to reveal 
merchandise. Hand-painted "SCRAP HEAP" sign. Weapons hanging from hooks. 
Crates and barrels of goods. Awning providing shade. Neon "OPEN" sign. 
Vendor character visible inside. Warm lighting from string lights. 
Borderlands-inspired cel-shaded look with heavy outlines. --ar 3:4
```

### Bank/Vault Location
```
A reinforced bunker bank in a post-apocalyptic settlement, illustrated 
painterly style. Heavy riveted metal walls. Vault door with wheel lock 
and porthole window. Security lighting. "BANK" sign in official font. 
Green accent lighting. Safe visible through barred window. 
Impenetrable, secure feeling. Borderlands-inspired art style. --ar 3:4
```

---

## 15. ASSET CHECKLIST

### Priority 1 - Immediate Need
- [ ] Main Scrapyard overview (hero background)
- [ ] Shop/Scrap Heap exterior
- [ ] Advancement Hall exterior
- [ ] Wasteland Gate
- [ ] Basic NPC silhouettes

### Priority 2 - Core Features
- [ ] Bank exterior (Premium)
- [ ] Black Market exterior (Premium)
- [ ] Interior template (for detail views)
- [ ] UI button set
- [ ] Sign/typography set

### Priority 3 - Enhanced Features
- [ ] Barracks exterior (Premium)
- [ ] Quantum Storage (Subscription)
- [ ] Cultivation Chamber (Subscription)
- [ ] Atomic Vendor (Subscription)
- [ ] Weather/time variants

### Priority 4 - Polish
- [ ] NPC character set
- [ ] Animation frames
- [ ] Particle effects
- [ ] Transition screens

---

## 16. REFERENCE IMAGE NOTES

### Provided Concept Art Analysis

**Image: Bunker Interior (Diorama - d4a5c8)**
- ✅ Excellent: CRT terminal, vault door, tool pegboard, lantern lighting
- ✅ Style: Perfect painterly quality, warm tones
- 📝 Use for: Bank interior, Workshop interior template
- 🎨 Key colors: Rust brown, corrugated tan, green CRT glow

**Image: Bunker Interior (Cozy - qs819q)**
- ✅ Excellent: Lived-in feel, blueprints, armchair, single bulb
- ✅ Style: Warmer, more personal space feeling
- 📝 Use for: Advancement Hall interior, personal quarters
- 🎨 Key colors: Warm amber, muted browns, soft shadows

**Image: Scrapyard Overview (kitzyl) - HERO IMAGE**
- ✅ Excellent: Everything - this nails the vision
- ✅ Perfect: "SCRAP TRUST & EXCHANGE" truck, guard towers, fire barrels
- ✅ Perfect: Sunset lighting, fortified walls, multiple buildings
- 📝 Use for: Main hub background, establishing shot, marketing
- 🎨 Key colors: Sunset orange, dusk purple, window gold, rust everywhere

---

## 17. VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 2025 | Initial comprehensive Scrapyard scene bible |

---

*Document for: Scrap Survivor*
*Scene: The Scrapyard (Hub)*
*Status: Ready for AI art generation*
