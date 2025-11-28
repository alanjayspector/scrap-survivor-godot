# Art Asset Pipeline

## Quick Reference

### Manual Processing (Single File)
```bash
# Process a background image
./scripts/tools/optimize-art-asset.sh art-docs/my-image.png background

# Process an icon
./scripts/tools/optimize-art-asset.sh art-docs/my-icon.png icon

# Process a sprite
./scripts/tools/optimize-art-asset.sh art-docs/my-sprite.png sprite
```

### Watch Mode (Auto-Process)
```bash
# First install fswatch (one-time)
brew install fswatch

# Start the watcher
./scripts/tools/optimize-art-asset.sh --watch
```

---

## QA Screenshots

### Processing Screenshots for Claude Review
```bash
# Process a single screenshot
./scripts/tools/process-qa-screenshot.sh qa/my-screenshot.png

# Process all screenshots in qa/
./scripts/tools/process-qa-screenshot.sh --batch

# Watch mode (auto-process new screenshots)
./scripts/tools/process-qa-screenshot.sh --watch
```

### Directory Structure
```
qa/
├── *.png              # Drop screenshots here
├── previews/          # Claude-safe preview files (auto-generated)
│   └── *-preview.jpg
└── archive/           # Timestamped originals (auto-moved)
    └── *_YYYYMMDD_HHMMSS.png
```

### Workflow
1. Take screenshot during QA testing
2. Drop it in `qa/` directory
3. Run `./scripts/tools/process-qa-screenshot.sh --batch`
4. Tell Claude to review `qa/previews/YOUR_FILE-preview.jpg`

---

### Input → Output

| Input Location | Output Location | Format |
|----------------|-----------------|--------|
| `art-docs/*.png` | `assets/ui/backgrounds/` | 2048x2048 JPEG 85% |
| `art-docs/*_icon.png` | `assets/ui/icons/` | 128x128 PNG |
| `art-docs/*_sprite.png` | `assets/sprites/` | Original size PNG |

### Auto-Detection (Watch Mode)

The watcher detects asset type from filename:
- `*_bg.png`, `*_background.png` → Background
- `*_icon.png` → Icon  
- `*_sprite.png` → Sprite
- Everything else → Background (default)

### What Happens

1. **Preview Created**: `{name}-preview.jpg` (1024px, for Claude review)
2. **Asset Processed**: Converted to game-ready format
3. **Original Moved**: Moved to `art-docs/processed/`

## Directory Structure

```
art-docs/
├── processed/           # Original files after processing
├── *-preview.jpg        # Preview files for Claude review
└── *.png               # Drop new images here

assets/
├── ui/backgrounds/     # 2048x2048 JPEG backgrounds
├── ui/icons/           # 128x128 PNG icons
└── sprites/            # Game sprites
```

## For Claude Sessions

When you drop a new image in `art-docs/`:

1. Run: `./scripts/tools/optimize-art-asset.sh art-docs/YOUR_FILE.png`
2. Tell Claude to review: `art-docs/YOUR_FILE-preview.jpg`
3. The game-ready version is already in `assets/`

## Mobile Optimization Targets

| Asset Type | Max Size | Format | Notes |
|------------|----------|--------|-------|
| Background | 2048x2048 | JPEG 85% | ~800KB-1.2MB |
| Icon | 128x128 | PNG | ~10-50KB |
| Sprite | Varies | PNG | Keep under 512x512 |
