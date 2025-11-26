# Phase 10: Barracks Background Replacement
## Implementation Plan

**Created**: 2025-11-26
**Expert Panel**: Approved
**Estimated Effort**: 1-2 hours
**Dependencies**: Option C asset at 2048×2048 resolution

---

## 1. OBJECTIVE

Replace the current barracks roster background (building exterior with 45% overlay) with Option C (dark gradient with industrial edge framing) to make character cards "the stars" of the screen.

### Success Criteria

- [ ] Character cards visually "pop" against dark background
- [ ] Industrial junkpunk theme maintained via edge framing
- [ ] No visual competition between background and cards
- [ ] Device QA passes on iPhone
- [ ] File size ≤1MB for the new background

---

## 2. ASSET GENERATION

### Prompt for Banana Nano (2048×2048)

```
Illustrated junkpunk style, abstract dark background gradient, 
industrial grunge aesthetic, subtle metal and rust textures fading 
into darkness, muted earth tones, hand-painted brushstroke style, 
vignette effect darker at edges, atmospheric and moody, 
minimalist background for UI overlay, no objects no text,
pipes and cables visible at edges, teal oxidation on rust,
dark center for content overlay, 2048x2048 square format
```

### Asset Requirements

| Property | Value |
|----------|-------|
| Resolution | 2048×2048 |
| Format | PNG (preferred) or WebP |
| Color profile | sRGB |
| Max file size | 1MB |
| Filename | `barracks_interior.png` |
| Location | `assets/ui/backgrounds/` |

---

## 3. IMPLEMENTATION STEPS

### Phase 10.1: Asset Integration (0.25h)

**Steps**:
1. Receive generated asset from Alan
2. Validate resolution (2048×2048) and file size (≤1MB)
3. Copy to `assets/ui/backgrounds/barracks_interior.png`
4. Verify Godot imports it correctly (check `.import` file created)

**QA Gate**: Asset appears correctly in Godot editor

---

### Phase 10.2: Scene Modification (0.5h)

**File**: `scenes/ui/barracks.tscn`

**Current Structure**:
```
CharacterRoster (Control)
├── Background (TextureRect) → barracks_background.png
├── GradientOverlay (ColorRect) → 45% black
├── ScreenContainer (MarginContainer)
│   └── VBoxContainer
│       ├── HeaderContainer
│       ├── CharacterListContainer
│       └── ButtonsContainer
└── AudioStreamPlayer
```

**Target Structure**:
```
CharacterRoster (Control)
├── Background (TextureRect) → barracks_interior.png (NEW)
├── ScreenContainer (MarginContainer)
│   └── ... (unchanged)
└── AudioStreamPlayer
```

**Changes Required**:
1. Update `Background` TextureRect to use `barracks_interior.png`
2. Remove or disable `GradientOverlay` ColorRect (Option C has built-in darkness)
3. Verify stretch_mode is correct for new aspect ratio

**Technical Notes**:
- Option C is square (2048×2048), current background may be 16:9
- Use `stretch_mode = 6` (STRETCH_KEEP_ASPECT_COVERED) to handle cropping
- Center the texture so dark center aligns with card area

**QA Gate**: Scene opens in Godot editor without errors

---

### Phase 10.3: Visual Verification (0.25h)

**Desktop Checks**:
- [ ] Background loads correctly
- [ ] Cards are visually prominent
- [ ] No harsh edges or cropping issues
- [ ] Edge framing visible on sides
- [ ] Dark center behind card grid

**Code Review**:
- [ ] No hardcoded references to old background
- [ ] GradientOverlay removed or set visible=false

**QA Gate**: Visual inspection passes in Godot editor

---

### Phase 10.4: Device QA (0.5h)

**Deploy to iPhone**:
```bash
# Build and deploy
# (follow existing iOS deployment workflow)
```

**Device Checklist**:
- [ ] Background visible on device
- [ ] Character cards "pop" against background
- [ ] Safe areas respected
- [ ] No performance issues
- [ ] Scrolling smooth
- [ ] All existing functionality works

**QA Gate**: Device testing passes

---

### Phase 10.5: Cleanup & Commit (0.25h)

**Optional Cleanup**:
- Consider removing `barracks_background.png` from `assets/ui/backgrounds/`
- Or keep for potential future use (character creation screen)

**Commit**:
```
feat(barracks): replace background with Option C dark gradient

- Replace building exterior with recessive UI background
- Remove GradientOverlay (darkness built into new asset)
- Character cards now visually "pop" as intended

Expert panel approved: Marvel Snap principle applied
```

---

## 4. ROLLBACK PLAN

If issues discovered:
1. Revert scene to use `barracks_background.png`
2. Re-enable `GradientOverlay`
3. Document issues in NEXT_SESSION.md
4. Investigate in next session

---

## 5. RELATED DOCUMENTATION

- [Art Asset Usage Guide](./art-asset-usage-guide.md) - Full asset catalog
- [Scrapyard Scene Art Bible](/mnt/project/Scrapyard_Scene_Art_Bible.md) - Style guide
- [Phase 9 Survivor Selection](./phase-9-survivor-selection.md) - Previous phase

---

## 6. FUTURE CONSIDERATIONS

### Week 17+ Polish Work

Based on expert panel analysis, these items are queued:
1. Hub building tiles (use building exteriors as navigation tiles)
2. Start Run screen with wasteland-gate background
3. Character creation with cultivation-chamber background
4. Button/sign sprite sheet integration

### Barracks Exterior Repurposing

The `barracks-exterior.png` asset should be repurposed, not deleted:
- **Option A**: Character creation screen background
- **Option B**: Hub building tile when that feature is implemented
- **Option C**: Promotional/marketing material

---

**Document Version**: 1.0
**Status**: Ready for Implementation (pending asset generation)
