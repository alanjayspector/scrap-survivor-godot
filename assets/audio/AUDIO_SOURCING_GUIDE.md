# Audio Asset Sourcing Guide - Week 14 Phase 1.1

**Created**: 2025-11-15
**Purpose**: Source high-quality, royalty-free audio for Scrap Survivor
**License**: CC0 (Public Domain) - No attribution required

---

## 🚀 Automated Method (RECOMMENDED)

**Save time!** Use our automation script instead of manual sourcing:

### Quick Start (2 minutes total):

1. **Download 4 ZIP files** to `~/Downloads` from Kenney.nl:
   - [Impact Sounds](https://kenney.nl/assets/impact-sounds) → `kenney_impact-sounds.zip`
   - [Digital Audio](https://kenney.nl/assets/digital-audio) → `kenney_digital-audio.zip`
   - [Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds) → `kenney_sci-fi-sounds.zip`
   - [UI Audio](https://kenney.nl/assets/ui-audio) → `kenney_ui-audio.zip`

2. **Run automation script**:
   ```bash
   bash .system/scripts/process-kenney-audio.sh
   ```

3. **Done!** All 24 files extracted, selected, and organized automatically.

**See**: [.system/scripts/README.md](../../.system/scripts/README.md) for details.

---

## 📖 Manual Method (Original Instructions)

If you prefer manual control or the automation script doesn't work, follow these steps:

## Quick Links

**Primary Source**: [Kenney Audio Packs](https://kenney.nl/assets?q=audio)
**License**: CC0 1.0 Universal (Public Domain)

### Recommended Packs:

1. **[Impact Sounds](https://kenney.nl/assets/impact-sounds)** (512 sounds)
   - Enemy damage/death sounds
   - Weapon impact sounds
   - Download: Direct ZIP

2. **[Digital Audio](https://kenney.nl/assets/digital-audio)** (400 sounds)
   - Weapon firing sounds (lasers, plasma, electronic)
   - UI beeps and clicks
   - Download: Direct ZIP

3. **[Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds)** (200 sounds)
   - Weapon sounds (energy weapons, explosions)
   - Ambient sci-fi effects
   - Download: Direct ZIP

4. **[UI Audio](https://kenney.nl/assets/ui-audio)** (200 sounds)
   - Button clicks
   - Selection sounds
   - Error/locked sounds
   - Download: Direct ZIP

---

## Required Audio Files (31 total)

### Weapons (10 files) - `assets/audio/weapons/`

| File Name | Source Pack | Suggested Sound | Notes |
|-----------|-------------|-----------------|-------|
| `plasma_pistol.wav` | Digital Audio / Sci-Fi Sounds | Electric zap, short laser blast | High pitch, quick |
| `rusty_blade.wav` | Impact Sounds | Metal swing/slash | Metallic clang |
| `shock_rifle.wav` | Sci-Fi Sounds | Electric crackle | Continuous electric buzz |
| `steel_sword.wav` | Impact Sounds | Sharp metal slash | Clean, sharp |
| `shotgun.wav` | Impact Sounds | Deep boom with reverb | Heavy, bassy |
| `sniper_rifle.wav` | Impact Sounds | Sharp crack | High-pitched snap |
| `flamethrower.wav` | Sci-Fi Sounds | Continuous whoosh/roar | Loopable, fire sound |
| `laser_rifle.wav` | Sci-Fi Sounds | Sustained beam hum | Medium pitch laser |
| `minigun.wav` | Impact Sounds | Rapid mechanical rattle | Fast repetition |
| `rocket_launcher.wav` | Impact Sounds | Explosion with bass | Deep explosion |

### Enemies (8 files) - `assets/audio/enemies/`

| File Name | Source Pack | Suggested Sound | Notes |
|-----------|-------------|-----------------|-------|
| `spawn_1.wav` | Sci-Fi Sounds | Mechanical whir/teleport | Spawn effect 1 |
| `spawn_2.wav` | Sci-Fi Sounds | Organic growl/materialize | Spawn effect 2 |
| `spawn_3.wav` | Digital Audio | Electronic ping | Spawn effect 3 |
| `damage_1.wav` | Impact Sounds | Light impact/hit | Damage variation 1 |
| `damage_2.wav` | Impact Sounds | Metal clang | Damage variation 2 |
| `death_1.wav` | Impact Sounds | Explosion/collapse | Death variation 1 |
| `death_2.wav` | Sci-Fi Sounds | Power down sound | Death variation 2 |
| `death_3.wav` | Impact Sounds | Metallic crash | Death variation 3 |

### Ambient (3 files) - `assets/audio/ambient/`

| File Name | Source Pack | Suggested Sound | Notes |
|-----------|-------------|-----------------|-------|
| `wave_start.wav` | Digital Audio / Sci-Fi Sounds | Dramatic sting/alarm | 2-3 seconds, attention-grabbing |
| `wave_complete.wav` | Digital Audio / UI Audio | Victory fanfare/power-up | 3-4 seconds, triumphant |
| `low_hp_warning.wav` | Digital Audio | Heartbeat or alarm beep | Loopable, 1-2 seconds |

### UI (3 files) - `assets/audio/ui/`

| File Name | Source Pack | Suggested Sound | Notes |
|-----------|-------------|-----------------|-------|
| `button_click.wav` | UI Audio | Soft beep or tap | Short, subtle |
| `character_select.wav` | UI Audio | Confirm chime/power-up | Positive, clear |
| `error.wav` | UI Audio | Negative buzz/denied | Short, clear denial |

---

## Step-by-Step Instructions

### 1. Download Audio Packs

```bash
# Navigate to downloads folder
cd ~/Downloads

# Download from Kenney.nl (manually via browser):
# 1. Visit: https://kenney.nl/assets/impact-sounds
# 2. Click "Download" button
# 3. Repeat for: Digital Audio, Sci-Fi Sounds, UI Audio
```

### 2. Extract Archives

```bash
# Extract all ZIP files
unzip "Impact Sounds.zip" -d impact-sounds
unzip "Digital Audio.zip" -d digital-audio
unzip "Sci-Fi Sounds.zip" -d sci-fi-sounds
unzip "UI Audio.zip" -d ui-audio
```

### 3. Browse and Select Sounds

Open each extracted folder and listen to sounds. Use the table above as a guide, but feel free to choose sounds that fit the game's aesthetic.

**Pro Tips**:
- Preview sounds before copying (use macOS QuickLook: Space bar)
- Choose .WAV or .OGG format (Godot supports both)
- Prefer shorter sounds (< 2 seconds) for weapons/impacts
- Ensure sounds are mono or stereo (not surround)

### 4. Copy to Project

```bash
# Navigate to project audio directory
cd /Users/alan/Developer/scrap-survivor-godot/assets/audio

# Copy selected sounds and rename according to table above
# Example:
cp ~/Downloads/impact-sounds/impactMetal_001.wav weapons/plasma_pistol.wav
cp ~/Downloads/digital-audio/laser1.wav weapons/laser_rifle.wav
# ... etc for all 31 files
```

### 5. Verify Installation

```bash
# Check all directories have files
ls -lh weapons/
ls -lh enemies/
ls -lh ambient/
ls -lh ui/

# Should see 10 weapon files, 8 enemy files, 3 ambient files, 3 UI files
```

### 6. Import to Godot

1. Open Godot project
2. Navigate to `res://assets/audio/` in FileSystem dock
3. Godot will automatically import .wav/.ogg files
4. Verify import settings:
   - **Compression**: Vorbis (smaller file size)
   - **Loop**: OFF (except `low_hp_warning.wav` - set to ON)
   - **Mono**: ON for weapons/impacts (smaller file size, works with AudioStreamPlayer2D)

---

## File Size Guidelines

**Target**: < 10 MB total (mobile optimization)

| Category | Files | Target Size Each | Total |
|----------|-------|------------------|-------|
| Weapons | 10 | < 200 KB | < 2 MB |
| Enemies | 8 | < 100 KB | < 800 KB |
| Ambient | 3 | < 500 KB | < 1.5 MB |
| UI | 3 | < 50 KB | < 150 KB |
| **TOTAL** | **24** | - | **< 5 MB** |

**If files are too large**:
- Use OGG format (better compression than WAV)
- Lower sample rate (22050 Hz is sufficient for game audio)
- Trim silence from start/end
- Use mono instead of stereo

---

## Quality Checklist

Before finalizing audio selection:

- [ ] All 31 files present and correctly named
- [ ] No silence/gaps at start of sounds (instant playback)
- [ ] Volume levels roughly consistent (no one sound too loud/quiet)
- [ ] No clicks/pops at start/end (clean loop points if looping)
- [ ] File sizes reasonable (< 10 MB total)
- [ ] Godot import settings verified (compression, loop, mono)
- [ ] Preview sounds in-game (test with weapon switcher)

---

## Troubleshooting

### "Sound cuts off too early"
- Check Godot import settings: Compression mode
- Try PCM format for critical sounds (larger but no latency)

### "Sound is too quiet/loud"
- Adjust in code (volume_db parameter in AudioStreamPlayer2D)
- Don't normalize files - handle in code for easy adjustment

### "Clicking/popping when sound starts"
- Trim silence from start of file
- Ensure clean waveform at 0-crossing points

### "File size too large"
- Use OGG compression (Godot import setting)
- Lower sample rate to 22050 Hz (adequate for game audio)
- Use mono instead of stereo

---

## Alternatives to Kenney

If Kenney packs don't have suitable sounds:

1. **[Freesound.org](https://freesound.org)**
   - Filter by: License = CC0
   - Search terms: "laser", "explosion", "metal hit", etc.
   - Download individual files

2. **[OpenGameArt.org](https://opengameart.org/art-search-advanced?keys=&field_art_type_tid%5B%5D=13)**
   - Filter by: License = CC0 or CC-BY 3.0
   - Category: Sound Effect

3. **Generate with AI** (experimental):
   - [AudioGen (Meta)](https://audiocraft.metademolab.com/audiogen.html)
   - [AudioLDM](https://audioldm.github.io/)
   - Note: Verify license/usage rights

---

## Next Steps

After audio files are sourced and organized:

1. ✅ Phase 1.1 complete
2. ➡️ Phase 1.2: Implement weapon firing sounds in weapon_service.gd
3. ➡️ Phase 1.3: Implement enemy audio in enemy.gd
4. ➡️ Phase 1.4: Implement ambient/UI audio
5. ➡️ Phase 1.5: Balance audio levels and test

---

**Questions?** Consult [docs/migration/week14-implementation-plan.md](../../docs/migration/week14-implementation-plan.md) for context.
