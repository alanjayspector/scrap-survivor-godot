# Audio Automation Scripts

**Week 14 Phase 1.1** - Automated audio asset sourcing

## Quick Start (Recommended)

### Step 1: Download Kenney Audio Packs

Visit these URLs and download to `~/Downloads`:

1. [Impact Sounds](https://kenney.nl/assets/impact-sounds) → Click "Download" → Save `kenney_impact-sounds.zip`
2. [Digital Audio](https://kenney.nl/assets/digital-audio) → Click "Download" → Save `kenney_digital-audio.zip`
3. [Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds) → Click "Download" → Save `kenney_sci-fi-sounds.zip`
4. [UI Audio](https://kenney.nl/assets/ui-audio) → Click "Download" → Save `kenney_ui-audio.zip`

**Time**: ~2 minutes (4 clicks + 4 downloads)

### Step 2: Run Automation Script

```bash
cd /Users/alan/Developer/scrap-survivor-godot
bash .system/scripts/process-kenney-audio.sh
```

**What it does**:
1. ✅ Checks for all 4 ZIP files in ~/Downloads
2. 📦 Extracts all packs to temp directory
3. 🔍 Intelligently selects 24 sounds based on filename patterns
4. 📋 Copies and renames to correct locations
5. 🧹 Cleans up temp files
6. ✅ Verifies all assets present

**Time**: ~30 seconds

**Result**: All 24 audio files ready to use!

---

## Dry Run (Preview Mode)

Want to see what the script will do before running it?

```bash
bash .system/scripts/process-kenney-audio.sh --dry-run
```

Shows all source → destination mappings without copying files.

---

## Manual Verification

After running the script, verify assets:

```bash
bash .system/validators/check-audio-assets.sh
```

**Expected output**:
```
📊 SUMMARY:
  Total files required: 24
  Files found: 24 ✓
  Missing files: 0 ✓
  Size warnings: 0 ✓
  Total size: ~3-5 MB ✓
```

---

## Troubleshooting

### "Missing X audio packs"

Download missing packs from links above to `~/Downloads`.

### "No match for patterns"

Some sounds might not match heuristics. Manually replace:

```bash
cp ~/Downloads/impactSounds/Audio/impactMetal_002.wav \
   assets/audio/weapons/plasma_pistol.wav
```

### "File size too large"

Script shows warnings if files exceed targets. Optimize:

1. Open in Audacity/audio editor
2. Export as OGG (better compression)
3. Lower sample rate to 22050 Hz
4. Convert stereo → mono

---

## Scripts Overview

### `process-kenney-audio.sh` (Recommended)

**Purpose**: Process Kenney packs from ~/Downloads
**Usage**: `bash .system/scripts/process-kenney-audio.sh [--dry-run]`
**Prerequisites**: 4 ZIP files downloaded to ~/Downloads
**Time**: 30 seconds

### `source-audio-assets.sh` (Advanced)

**Purpose**: Attempt automated download + process (may not work due to Kenney.nl download flow)
**Usage**: `bash .system/scripts/source-audio-assets.sh [--dry-run]`
**Prerequisites**: None (attempts to download automatically)
**Time**: 2-3 minutes (with fallback to manual downloads)
**Note**: Falls back to manual download prompts if automated download fails

---

## Why Automate?

✅ **Reproducible** - Run script, get same results every time
✅ **Fast** - 30 seconds vs 30-60 minutes manual
✅ **Error-Free** - No typos, no missing files, no wrong names
✅ **Documented** - Script shows exactly what was selected
✅ **Version Controlled** - Script committed to git (not 10MB+ audio)
✅ **CI/CD Ready** - Can run in build pipelines

---

## Next Steps

After audio assets are sourced:

1. Open Godot project
2. Verify FileSystem dock shows audio files
3. Continue to Phase 1.2: Implement weapon firing sounds

See: `docs/migration/week14-implementation-plan.md`
