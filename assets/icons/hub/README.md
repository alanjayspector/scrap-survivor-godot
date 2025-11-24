# Hub Button Icons - Phase 8.2b

**Created**: 2025-11-23
**Purpose**: Icon-based navigation buttons for scrapyard hub (replacing text-only buttons)
**Status**: 🔨 In design iteration - awaiting clarity testing

---

## 📁 Current Assets

### SVG Icons (Claude-created - Geometric/Simple)

1. **icon_start_run_gate.svg** - Scrapyard gate with chain-link pattern (departure metaphor)
2. **icon_roster_silhouettes.svg** - Three wasteland survivor silhouettes (roster literal)
3. **icon_settings_tools.svg** - Wrench + screwdriver crossed (settings/adjustment)

**Style**: Bold geometric shapes, simple silhouettes, black fills (will be tinted in Godot)
**Size**: 80x80px viewBox
**Format**: SVG (scalable vector)

### AI-Generated Icons (User-created via Gemini - Coming Soon)

- See `GEMINI_PROMPTS.md` for detailed image generation prompts
- Will be saved as `*_gemini.png` files
- Alternative concepts and visual explorations

---

## 🎯 Next Steps

### 1. Preview Icons in Godot
- Import SVG files (Godot will auto-convert to CompressedTexture2D)
- Create test scene to view icons at 80x80pt size
- Apply RUST_ORANGE tint to see wasteland aesthetic

### 2. Clarity Testing ("Grandmother Test")
- Show icons to 2-3 people unfamiliar with the project
- Ask: "What do you think this button does?"
- Record responses:
  - ✅ PASS: Correct answer or close enough
  - ❌ FAIL: Wildly wrong or "no idea"

### 3. Compare SVG vs AI-Generated
- Which is clearer at 80x80pt?
- Which feels more "wasteland"?
- Which has better instant recognition?

### 4. Select Winners
- Pick one version per button (SVG, Gemini, or hybrid)
- Prioritize: **Clarity > Aesthetic > Technical**

### 5. Iteration (if needed)
- If clarity test fails, iterate on failed icons
- Adjust shapes, simplify details, test again
- Don't proceed to implementation until icons PASS

---

## 🎨 Design Requirements Checklist

For each icon to be approved:

- [ ] Instantly recognizable OR quick to learn with text label
- [ ] Works at 80x80pt (mobile button size)
- [ ] Bold shapes with thick outlines (3-4px minimum)
- [ ] Wasteland aesthetic (rust, weathering, physical objects)
- [ ] High contrast (readable on dark backgrounds)
- [ ] Passes clarity test with 2+ people

---

## 📊 Icon Concept Rationale

### "Start Run" - Scrapyard Gate
- **Metaphor**: Literal departure from hub (exit through gate)
- **Clarity**: Gates universally mean "entrance/exit"
- **Storytelling**: Hub is home base, you leave through the gate for missions
- **Backup**: Knife + wrench (combat + survival tools)

### "Character Roster" - Three Silhouettes
- **Metaphor**: Literal representation of multiple people
- **Clarity**: Human shapes = people, three = roster/group
- **Storytelling**: Your survivor crew at the scrapyard
- **Backup**: Dog tags (military roster identification)

### "Settings" - Wrench + Screwdriver
- **Metaphor**: Tools = adjustments/configuration
- **Clarity**: Tools are semi-universal for "settings" (especially with label)
- **Storytelling**: Wasteland aesthetic (hand tools, repair, maintenance)
- **Backup**: Gear cog (universal but less thematic)

---

## 🔧 Technical Specs

**SVG Import to Godot**:
- Godot auto-imports SVG as CompressedTexture2D
- Place in `assets/icons/hub/`
- Godot will create `.import` file
- Use in TextureRect or TextureButton nodes

**Color Tinting in Godot**:
```gdscript
# Apply rust orange tint to icon
texture_rect.modulate = Color("#D4722B")  # RUST_ORANGE
```

**Button Structure (Preview for 8.2c)**:
```
IconButton (PanelContainer or TextureButton)
├── Background (metal plate with rivets)
├── Icon (TextureRect - 70% of button area)
└── Label (stencil font - 30% of button area)
```

---

## 📚 Research References

- See `docs/research/phase-8-icon-button-references.md`
- Games studied: Hades, Darkest Dungeon, Slay the Spire, Brotato
- Icon-to-label ratio: 70-80% icon, 20-30% label
- Clarity standard: "Grandmother test" (instant recognition)

---

**Next Phase**: Sub-Phase 8.2c - Icon Button Implementation (after clarity testing passes)
