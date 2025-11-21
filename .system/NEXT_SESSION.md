# Next Session: Apply Theme to All Screens + Icon Assets

**Last Updated**: 2025-11-20 22:00
**Current Branch**: `main` (after merge from `feature/theme-system`)
**Next Task**: Apply theme to remaining screens + Source icon assets

---

## Theme System Phase 1 (COMPLETED)

### What Was Built

**Branch**: `feature/theme-system` (merged to main)
**Commits**: `72ae23b`, `21f4c24`

**New Files Created**:
```
themes/
├── game_theme.tres              # Main theme resource
└── styles/
    ├── button_primary.tres      # Purple filled button
    ├── button_primary_pressed.tres
    ├── button_secondary.tres    # Outlined button
    ├── button_secondary_pressed.tres
    ├── button_danger.tres       # Red filled button
    ├── button_danger_pressed.tres
    ├── button_ghost.tres        # Transparent button
    ├── button_ghost_pressed.tres
    ├── panel_card.tres          # Card background
    ├── panel_elevated.tres      # Elevated panel with shadow
    ├── tab_selected.tres        # Selected tab style
    └── tab_unselected.tres      # Unselected tab style

scripts/ui/theme/
└── theme_helper.gd              # Programmatic styling utilities

scripts/ui/components/
└── ui_icon.gd                   # iOS-safe icon system (text fallbacks)
```

**Key Changes**:
- All emojis replaced with colored ASCII text (iOS-safe)
- Theme applied to CharacterDetailsPanel
- Buttons styled (close button = secondary, collapsible headers = ghost)
- TabContainer has styled selected/unselected states

### iOS Emoji Issue - Root Cause

Godot only supports **bitmap (PNG) emoji fonts**. iOS system fonts use COLR/SVG formats which Godot cannot render. Solution: Use TextureRect icons or text fallbacks.

---

## Icon Research Findings

### Icons Needed (~21 total)

**Stats (11)**:
- Health, Damage, Armor, Speed, Crit Chance, Attack Speed, Range, Regen, Lifesteal, Dodge, Luck

**Currency (5)**:
- Scrap, Nanites, Components, XP, Gold

**UI Actions (5)**:
- Expand, Collapse, Close, Settings, Back, Delete, Info

### Best Free Resources (CC0 Licensed)

| Source | Pack | Details | Link |
|--------|------|---------|------|
| **Kenney** | Game Icons | 105 assets, CC0, vector | https://kenney.nl/assets/game-icons |
| **Kenney** | UI Pack RPG Expansion | 85 assets, CC0, RPG | https://kenney.nl/assets/ui-pack-rpg-expansion |
| **OpenGameArt** | CC0 Resources | Hearts, swords, shields | https://opengameart.org/content/cc0-resources |
| **itch.io** | Soulbit Free 16x16 | Sword, shield, potion | Free on itch.io |

### Recommended Approach

**Option A: Kenney Game Icons** (Recommended)
- Clean, readable at small sizes
- Works with color tinting (UIIcon system supports this)
- CC0 = no attribution required

**Option B: Custom Wasteland Icons**
- Take clean icons, apply grunge/rust treatment
- Match game's post-apocalyptic theme

### AI Prompt for Icon Research

Use this prompt with another AI for deeper research:

```
I'm developing a mobile roguelike survivor game called "Scrap Survivor" in Godot 4.5.1.
The game has a POST-APOCALYPTIC WASTELAND theme - rusty metal, scavenged tech, irradiated wastelands.

I need ~20 UI icons for stat displays (Health, Damage, Armor, Speed, etc.) and UI actions.
Icons displayed at 20-24px on mobile, need to be readable at small sizes.

Color palette: Dark purples (#282747), danger red (#CC3737), toxic green (#76FF76), warning yellow (#EAC43D)

Questions:
1. What free asset packs fit this theme? Specific names and URLs.
2. Visual motifs for each stat in wasteland theme? (e.g., Health = radiation symbol? blood bag?)
3. Pixel art (16x16/32x32) vs vector for 20-24px mobile display?
4. Tools for adding wasteland "grunge" effects to clean icons?
5. Style references from games/media with good wasteland UI?
```

---

## Next Session Tasks

### 1. Source Icon Assets
- [ ] Download Kenney Game Icons pack
- [ ] Identify icons for each stat/action
- [ ] Process icons (resize to 24x24, export as PNG)
- [ ] Place in `themes/icons/` folder
- [ ] Update UIIcon system to load textures

### 2. Apply Theme to Remaining Screens
- [ ] `character_roster.tscn` - Apply game_theme.tres
- [ ] `character_creation.tscn` - Style buttons and inputs
- [ ] `character_card.tscn` - Card styling
- [ ] `wave_complete_screen.tscn` - Buttons and panels
- [ ] `scrapyard.tscn` (hub) - All buttons
- [ ] `hud.tscn` - Combat UI styling

### 3. Continue with Independent Phases (Week16)
After theme is applied everywhere:
- [ ] Haptic feedback system
- [ ] ButtonAnimation component
- [ ] ScreenContainer for safe areas

---

## Files Reference

**Theme System**:
- `themes/game_theme.tres` - Main theme
- `scripts/ui/theme/theme_helper.gd` - Programmatic helpers
- `scripts/ui/components/ui_icon.gd` - Icon system

**Existing Infrastructure**:
- `scripts/ui/theme/ui_constants.gd` - Measurements
- `scripts/ui/theme/color_palette.gd` - Colors

**Screens to Update**:
- `scenes/ui/character_roster.tscn`
- `scenes/ui/character_creation.tscn`
- `scenes/ui/character_card.tscn`
- `scenes/ui/wave_complete_screen.tscn`
- `scenes/hub/scrapyard.tscn`
- `scenes/ui/hud.tscn`

---

## Success Criteria (Theme System Phase 2)

1. All UI screens use `game_theme.tres`
2. All buttons styled appropriately (primary/secondary/danger/ghost)
3. Icon textures load and display correctly
4. Consistent look across all screens
5. Tests still passing (647/671)

---

**Session Date**: 2025-11-20
**Commits on feature/theme-system**: `72ae23b`, `21f4c24`
