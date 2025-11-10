# Godot 4.5 Asset Import Settings & Optimization Guide

**For Multi-Platform Survivor Game (Mac M4, iOS, Android, HTML5)**

---

## Table of Contents

1. [Quick Start Decision Trees](#quick-start-decision-trees)
2. [Texture Import Settings](#texture-import-settings)
3. [Sprite Sheet Optimization](#sprite-sheet-optimization)
4. [Platform-Specific Settings](#platform-specific-settings)
5. [Audio Import Settings](#audio-import-settings)
6. [Tilemap Optimization](#tilemap-optimization)
7. [Memory Budget Management](#memory-budget-management)
8. [Visual Quality vs Performance](#visual-quality-vs-performance)
9. [Import Pipeline Automation](#import-pipeline-automation)
10. [Common Mistakes & Fixes](#common-mistakes--fixes)
11. [Enforceable Patterns](#enforceable-patterns)

---

## Quick Start Decision Trees

### Texture Type Decision Tree

```
Is it a 2D sprite/pixel art?
â”œâ”€ YES â†’ Use LOSSLESS compression
â”‚        â”œâ”€ Enable Detect 3D? NO (disable it!)
â”‚        â”œâ”€ Mipmaps: NO
â”‚        â””â”€ Filter: NEAREST
â”‚
â””â”€ NO â†’ Is it a UI texture?
        â”œâ”€ YES â†’ LOSSLESS, no mipmaps
        â”‚
        â””â”€ NO â†’ Is it a particle texture?
                â”œâ”€ YES â†’ VRAM COMPRESSED
                â”‚        Mipmaps: YES
                â”‚
                â””â”€ NO â†’ Check platform target...
```

### Audio Format Decision Tree

```
What type of audio?
â”œâ”€ Short SFX (< 2 seconds, loops often)
â”‚  â””â”€ WAV with optional compression
â”‚
â”œâ”€ Music or long SFX (> 2 seconds)
â”‚  â””â”€ OGG Vorbis 96-128 kbps
â”‚
â””â”€ Voice/dialogue
   â””â”€ OGG Vorbis 128 kbps, 22 kHz (mono if acceptable)
```

---

## Texture Import Settings

### Compression Mode Selection

| Compression Type | Use Case | File Size Impact | Memory Impact | Quality | Best For |
|---|---|---|---|---|---|
| **Lossless** | 2D sprites, pixel art, UI | Larger | Lower VRAM | 100% visual | Pixel art, sprites, UI |
| **Lossy** | Photos, backgrounds | Medium | Medium VRAM | 90-95% | High-detail backgrounds |
| **VRAM Compressed (S3TC/DXT)** | Desktop 3D, performance-critical | Smallest | Lowest VRAM | 85-90% | Desktop/console targets |
| **VRAM Compressed (ETC2)** | Mobile targets | Smallest | Lowest VRAM | 80-85% | Android, iOS fallback |
| **VRAM Compressed (ASTC)** | Premium mobile devices | Smallest | Lowest VRAM | 95%+ | Modern iOS/Android |

**Critical for Pixel Art:** Always use **LOSSLESS** compression. VRAM compression applies lossy algorithms that cause color banding and blur in pixel art graphics.

### Recommended Import Settings by Texture Type

#### 2D Sprites (Pixel Art)

```
Compress > Mode: Lossless
Detect 3D: Disabled (CRITICAL - prevents unwanted re-compression)
Mipmaps > Generate: No
Filter: Nearest (set globally in project settings)
Repeat/Clamp: Clamp (prevents edge artifacts in atlases)
```

**File Size Estimation:** A 256Ã—256 PNG sprite with lossless compression â‰ˆ 80-150 KB on disk.

#### UI Textures

```
Compress > Mode: Lossless
Detect 3D: Disabled
Mipmaps > Generate: No
Filter: Nearest (for sharp UI)
Repeat/Clamp: Clamp
SVG Scale: (if vector) Set to 1.0 for pixel-perfect UI
```

#### Particle Textures

```
Compress > Mode: VRAM Compressed (or Lossless if < 512Ã—512)
Detect 3D: Disabled
Mipmaps > Generate: Yes
Filter: Linear (smooth blending for particles)
Repeat/Clamp: Repeat (particles need tiling)
```

#### Tilemap Atlases

```
Compress > Mode: Lossless (if tiles are pixel art)
Detect 3D: Disabled
Mipmaps > Generate: No
Filter: Nearest
Repeat/Clamp: Clamp
```

### Global Project Settings for Pixel Art

**Navigate:** Project > Project Settings > Rendering > Textures

```
Canvas Textures > Default Texture Filter: Nearest
Canvas Textures > Use Nearest Mipmaps: No
Textures > VRAM Compression > Import S3TC BPTC: Enabled
Textures > VRAM Compression > Import ETC2 ASTC: Enabled
```

This ensures all textures default to nearest-neighbor filtering without pixel distortion.

### Filter Modes Explained

- **Nearest:** Preserves crisp pixel boundaries. **Use for pixel art.**
- **Linear:** Smooths/blurs pixels. Use only for high-detail graphics.
- **Nearest with Mipmaps:** Downsamples with crisp edges when zooming out. Rarely needed in 2D.
- **Linear with Mipmaps:** Smooth downsampling for 3D-like AA effect. Performance cost.

**Important:** In 2D games with zoom/scaling, mipmaps add performance overhead. Use only if you observe aliasing/graininess when cameras zoom out.

### Size Limits & Power-of-2 Considerations

**Hardware Limits:**
- Desktop GPUs: Up to 8192Ã—8192 (older GPUs may limit to 4096Ã—4096)
- Mobile GPUs: Maximum 4096Ã—4096, strict limitation
- HTML5/WebGL: Maximum 4096Ã—4096, some browsers limit to 2048Ã—2048

**Recommended Sprite Sizes:**
- Single sprites: 64Ã—64 to 256Ã—256
- Large bosses: Up to 512Ã—512
- Avoid exceeding 1024Ã—1024 for individual textures

**Power-of-2:** Not strictly required for most use cases, but recommended for:
- Textures with repeat/wrap enabled
- Older mobile devices
- Memory alignment optimization

**Size Limit Import Option:**
```
Compress > Process > Size Limit: 0 (disabled by default)
Set to > 0 to auto-downscale oversized textures (e.g., set to 2048 for mobile)
```

### Repeat & Clamp Settings

| Setting | Behavior | Use Case |
|---|---|---|
| **Repeat** | UV wraps around (0.5 â†’ 1.5 repeats) | Particle systems, scrolling backgrounds |
| **Repeat Mirrored** | Ping-pongs texture (flips at edges) | Smoother repeating patterns |
| **Clamp** | Stretches edge pixels beyond 0-1 UV range | Sprites, UI, atlases (prevents sampling adjacent textures) |

**For atlases in spritesheets:** Always use **Clamp** to prevent texture bleeding when filtering is applied.

---

## Sprite Sheet Optimization

### Atlas Packing Strategies

#### Single Master Atlas vs. Multi-Atlas Approach

**Single Master Atlas:**
- âœ“ Minimum draw calls (all sprites in 1 batch)
- âœ— Forces loading entire atlas into VRAM
- âœ— Limits to max 4096Ã—4096 on mobile
- âœ— Inefficient for large asset sets

**Multi-Atlas (Recommended):**
- âœ“ Load atlases per level/scene
- âœ“ Reduce VRAM pressure
- âœ“ Better mobile memory management
- âœ— Slightly more draw calls

**Strategy:** Group textures used together (characters + enemies, UI, level-specific objects). Typical project: 4-8 atlases.

### Frame Trimming & Padding

**Trimming:** Remove transparent pixels around sprites.

```
Compress > Process > Trim Alpha Border From Region: Enabled
```

**Benefits:**
- Reduces texture atlas size by 10-40%
- Saves VRAM
- Requires offset adjustment in code (sprite position shifts)

**Padding:** Add 1-2 pixels between frames in atlas to prevent sampling artifacts.

**Example Spritesheet Layout:**
```
[2px padding] [Sprite 64Ã—64] [2px padding] [Sprite 64Ã—64] [2px padding]
```

Most texture atlas tools (TexturePacker, Aseprite) handle this automatically.

### Animation Frame Organization

**Consistent Frame Sizes:**
- All frames in an animation must have identical dimensions
- Use uniform grid: 64Ã—64, 128Ã—128, etc.
- Pad with transparent pixels if sprites vary in size

**Frame Layout Example:**
```
Spritesheet: 512Ã—512
Grid: 8Ã—8 frames of 64Ã—64
Organized by: Idle (row 1), Walk (row 2), Attack (row 3)
```

### Reducing Draw Calls with Atlases

**Draw Call Baseline:** Each unique texture = 1 draw call minimum (in 2D).

**For 100-300 entities:**
- Without atlases: ~100-300 draw calls (if each uses unique texture)
- With 4 shared atlases: ~4 draw calls (ideal batching)
- Realistic with multiple layers: 8-16 draw calls

**Optimization:** Share atlases across entity types. Character atlas, enemy atlas, object atlas.

### Frame Trimming Implementation

**Before:** 256Ã—256 sprite with 50% transparent space
**After:** Trimmed to 128Ã—128 equivalent, offset by 64px in code

```gdscript
# After trimming, adjust sprite offset:
sprite.offset = Vector2(64, 64)  # Compensate for trim
sprite.scale = Vector2(1, 1)     # Maintain visual size
```

---

## Platform-Specific Settings

### iOS Import Configuration

**Apple devices support ASTC and ETC2, prefer ASTC for quality:**

```
Compress > Mode: VRAM Compressed
iOS Texture Compression: ASTC (preferred)
Fallback: ETC2 (older devices)
```

**Project Settings:**
```
Rendering > Textures > VRAM Compression > Import ETC2 ASTC: Enabled
```

**Size Constraints:**
- Max texture: 4096Ã—4096
- Recommended: 2048Ã—2048 for sprites
- Target: 20-30 MB total texture VRAM budget per level

**M4 Mac Optimization:**
- Uses ASTC compression (desktop-class GPU)
- Can handle larger atlases (up to 4096Ã—4096)
- Apply same settings as iOS for consistency

### Android Import Configuration

**Android GPUs primarily support ETC2 and ASTC:**

```
Compress > Mode: VRAM Compressed
Android Texture Compression: ASTC (modern devices, API 23+)
Fallback: ETC2 (legacy support)
```

**Project Settings:**
```
Rendering > Textures > VRAM Compression > Import ETC2 ASTC: Enabled
```

**Targeting older Android (API 19+):** Use ETC2 exclusively.

**Size Constraints:**
- Max texture: 4096Ã—4096
- Recommended: 1024Ã—2048 for memory-constrained devices
- Target: 15-20 MB texture VRAM (budget for older devices)

### HTML5/WebGL Limitations

**WebGL 2.0 support (Godot 4.5 requirement):**
- Uncompressed textures only in most browsers
- VRAM compression formats NOT supported in WebGL
- Textures exported as PNG/WebP

**Critical Settings for HTML5:**
```
Compress > Mode: Lossless (must use, VRAM formats ignored)
Mipmaps > Generate: No (causes upload overhead)
Maximum Texture Size: 2048Ã—2048 (browser compatibility)
```

**File Size Impact:**
- Lossless PNG: 256Ã—256 sprite â‰ˆ 80-120 KB (uncompressed in VRAM)
- Web export adds .wasm overhead (â‰ˆ5-10 MB base)
- Asset download time critical for web games

**Workaround for size:** Pre-compress with WebP format, decode at runtime (complex).

### Desktop (Mac M4) Optimization

**Mac with M4 GPU capabilities:**
```
Compress > Mode: VRAM Compressed
Desktop Texture Format: S3TC/BPTC (preferred) or ASTC
```

**Project Settings:**
```
Rendering > Textures > VRAM Compression > Import S3TC BPTC: Enabled
```

**Advantages:**
- Supports up to 8192Ã—8192 textures
- Can use larger atlases
- Less aggressive compression needed

### Per-Platform Import Overrides

**Set in Import dock after selecting texture:**

1. Select texture in FileSystem
2. Open Import tab (next to Scene tab)
3. Scroll to **Platform Overrides** section
4. Enable checkboxes for each platform
5. Modify settings per platform
6. **Reimport** button applies changes

**Example Workflow:**
- Base settings: Lossless, Nearest filter
- iOS override: VRAM Compressed, ASTC
- Android override: VRAM Compressed, ETC2
- HTML5 override: Lossless (already default)
- Mac override: VRAM Compressed, S3TC (if using)

**Critical:** After changing platform overrides, delete `.godot/imported/` folder and reimport to rebuild all platform variants.

---

## Audio Import Settings

### Sample Rate Recommendations

| Sample Rate | Use Case | File Size | Quality | Recommendation |
|---|---|---|---|---|
| 8 kHz | 8-bit retro, phone audio | Tiny | Low | Avoid |
| 22 kHz | UI sounds, voice | Small | Good | Acceptable for mono SFX |
| 44 kHz | Standard CD quality | Medium | Excellent | Default choice |
| 48 kHz | Professional audio | Larger | Best | Overkill for games |

**Mobile Target:** Default to 44 kHz for music, 22 kHz for SFX acceptable.

### Compression Formats Comparison

| Format | Quality | File Size | CPU Load | Best For |
|---|---|---|---|---|
| **WAV (uncompressed)** | 100% | Largest | Lowest | Short SFX (< 2s) |
| **WAV (QOA compressed)** | 100% | Medium | Low | SFX, no artifacts needed |
| **OGG Vorbis 96 kbps** | 90% | Small | Medium | Music, acceptable quality |
| **OGG Vorbis 128 kbps** | 95% | Medium | Medium | Music/voice, recommended |
| **MP3 192 kbps** | 85% | Medium | Higher | Avoid (legacy) |

**Recommended for Multi-Platform:**
- **Music:** OGG Vorbis 128 kbps, stereo, 44 kHz
- **SFX:** WAV (QOA) or OGG 96 kbps, mono, 44 kHz
- **Voice:** OGG 128 kbps, mono, 44 kHz

### Import Settings by Audio Type

#### Music/Ambient

```
Format: OGG Vorbis
Bitrate: 128 kbps (or 96 kbps for budget)
Channels: Stereo
Sample Rate: 44 kHz
Loop Mode: Disabled (set in music player code)
BPM: Set if using future interactive music
```

#### SFX (Short, Looping)

```
Format: WAV (QOA compression recommended)
Alternative: OGG Vorbis 96 kbps
Sample Rate: 44 kHz
Channels: Mono (acceptable for SFX)
Loop Mode: Forward (if metadata present)
Force 8-Bit: No
```

#### Voice/Dialogue

```
Format: OGG Vorbis 128 kbps
Sample Rate: 44 kHz or 22 kHz (voice tolerates lower)
Channels: Mono
Loop Mode: Disabled
```

### Looping Settings

**WAV-Specific Options:**
```
Edit > Loop Mode:
  - Disabled: No looping
  - Forward: Standard loop (point A â†’ point B â†’ repeat)
  - Ping-Pong: Reverse loop (A â†’ B â†’ A â†’ B â†’ ...)
  - Backward: Reverse play
```

**OGG Vorbis/MP3:**
- Looping configured in code via `AudioStreamPlayer.stream_paused`
- Use `AudioStreamPlayer.bus` for mixing

### Streaming vs. Preloaded

**Preloaded (Default):**
- Entire file loaded into RAM on first play
- Zero latency at playback
- Use for: SFX, short music (< 30 seconds)

**Streaming:**
- File read from disk progressively
- Lower RAM usage
- Use for: Long music (> 60 seconds), narration

**Project Settings:**
```
Audio > Import > MP3 Audio Bitrate Detection: On
Audio > General > Default Bus Layout: (keep default)
```

**In Code:**
```gdscript
# Preloaded (recommended for SFX)
var sfx = preload("res://sounds/jump.wav")
audio_player.stream = sfx

# Streaming for large files
var music_path = "res://music/long_track.ogg"
audio_player.stream = AudioStreamOggVorbis.new()
audio_player.play()
```

### Memory vs. Quality Trade-off

**Memory Budget for Audio (per level):**
- SFX: 2-5 MB (5-10 simultaneous sounds)
- Music: 3-8 MB (1-2 tracks per level)
- Total: 10-15 MB for audio subsystem

**Quality vs. Size:**
- OGG 128 kbps stereo: Imperceptible quality loss for music
- OGG 96 kbps mono: Acceptable for SFX/voice
- WAV uncompressed: Only if < 2 seconds and SFX variety high

---

## Tilemap Optimization

### Tileset Atlas Organization

**Tilemap Best Practices:**

```
Tileset Atlas Size: 512Ã—512 to 1024Ã—1024
Tile Size: 32Ã—32 or 64Ã—64 (consistent)
Margin: 1 pixel between tiles (prevents sampling artifacts)
Total Tiles: 256-512 (depends on game variety)
```

**Organization Example:**
```
Terrain Section: Grass, dirt, water (rows 1-4)
Decoration: Trees, rocks, plants (rows 5-8)
Special: Collision tiles, animation markers (rows 9-10)
```

### Autotile Settings

**Godot 4.5 Autotiling (Physics-Based):**

```
TileSet > Create Terrain Set
â”œâ”€ Terrain 1: Grass (transitions)
â”œâ”€ Terrain 2: Water (transitions)
â””â”€ Terrain 3: Sand (transitions)

TileSet > Setup Peering Bits
â”œâ”€ Which adjacent tiles match this terrain?
â””â”€ Godot auto-selects visual tile
```

**Performance Impact:** Minimal. Autotile just selects which tile variant to display.

### Collision Layer Efficiency

**Layers in TileMap:**

```
Layer 0: Visual (all terrain sprites)
Layer 1: Collision (physics tiles marked)
Layer 2: Events (trigger zones)
Layer 3: Parallax Background (separate visual)
```

**Collision Best Practices:**
- Use simple rect/polygon colliders, not per-pixel
- Share collision shapes across similar tiles
- Group collision tiles into TileMapLayer nodes for LOD

### Baked vs. Runtime Shadows

**Baked Lighting (2D in Godot 4.5):**
- CanvasItem lights with static bake
- Pre-render at edit-time
- Zero runtime cost
- Best for: Indoor levels, fixed lighting

**Runtime Shadows:**
- Real-time PointLight2D/DirectionalLight2D
- Dynamic, responsive to movement
- Performance cost: ~5-15% per light
- Best for: Torches, day/night cycles, dynamic objects

**Recommendation:** Use baked lighting for static tilemaps, runtime only for player/interactive objects.

---

## Memory Budget Management

### Texture Memory Estimation

**Formula:** Width Ã— Height Ã— Bytes Per Pixel = VRAM Usage

| Compression | Bytes Per Pixel | Example 256Ã—256 | Example 1024Ã—1024 |
|---|---|---|---|
| Lossless PNG (in VRAM) | 4 | 256 KB | 4 MB |
| ETC2 VRAM Compressed | 0.5 | 32 KB | 512 KB |
| ASTC VRAM Compressed | 1 | 64 KB | 1 MB |

**For 100-300 entities:**
- Worst case (lossless): 300 Ã— 256 KB = 76 MB (impossible)
- Typical (8 shared atlases, 1024Ã—1024 each, ETC2): 4 MB
- Realistic (10 atlases, mixed sizes): 8-12 MB

**Target Memory Budgets:**
- Mobile total VRAM: 256-512 MB
- Texture budget per level: 20-30 MB (leaves room for code, audio, physics)
- Recommended texture cap: 15-20 MB per level (safe margin)

### Atlas Consolidation

**Step 1: Identify all unique textures used per level**
```gdscript
# Pseudo-code for auditing
var textures_used = {}
for entity in level_entities:
    var tex_path = entity.get_texture_path()
    if tex_path not in textures_used:
        textures_used[tex_path] = File.get_size(tex_path)
```

**Step 2: Group by usage frequency**
- Frequently used: Player, common enemies, core UI
- Occasional: Projectiles, one-off items
- Rare: Boss sprites, special events

**Step 3: Pack into atlases**
- Frequent-use atlas: Priority 1 (always loaded)
- Occasional atlas: Load on-demand
- Rare atlas: Stream or preload only when needed

### Lazy Loading Patterns

**Pattern 1: Scene-Based Loading**
```gdscript
func _ready():
    # Load assets only for current level
    var level_atlas = load("res://assets/level_01_atlas.tres")
    # Enemies load when spawned
    
func spawn_enemy(type: String):
    var enemy_scene = load("res://enemies/" + type + ".tscn")
    var instance = enemy_scene.instantiate()
    add_child(instance)
```

**Pattern 2: Threaded Resource Loading**
```gdscript
func load_resources_async(paths: Array[String]):
    for path in paths:
        ResourceLoader.load_threaded_request(path)
        await get_tree().process_frame
        var resource = ResourceLoader.load_threaded_get(path)
        # Use resource
```

**Pattern 3: Resource Preload Optimization**
- âœ“ Use `preload()` only for essential startup assets (< 1 MB total)
- âœ“ Use `load()` for level-specific, boss, and optional assets
- âœ“ Use `ResourceLoader.load_threaded_request()` for large files

### Resource Preloading

**What to Preload (Startup):**
- Core UI (menu buttons, fonts): 0.5 MB
- Player sprite/animations: 2-3 MB
- Essential SFX: 1-2 MB
- **Total preload target: 5-8 MB max**

**Project Settings:**
```
Application > Run > Main Scene: Select main menu/title

Autoload (preloaded on engine start):
â”œâ”€ AudioManager (lightweight script)
â”œâ”€ InputManager (lightweight script)
â””â”€ GameSettings (lightweight script)
```

**Avoid:**
- Preloading entire level atlases
- Preloading all enemy sprites
- Preloading all music

### Unloading Unused Assets

**Manual Unload:**
```gdscript
func clear_level():
    # Clear all entity sprites, triggering GC
    for entity in entities:
        entity.queue_free()
    
    # Force GC (Godot 4.5+)
    if OS.get_static_memory_usage() > MEMORY_THRESHOLD:
        get_tree().call_group("cleanup", "queue_free")
```

**Auto-Unload with ResourceCache:**
```gdscript
# Godot 4.3+ ResourceLoader caching
ResourceLoader.save_resource_in_cache(path, resource)
# Later...
var cached = ResourceLoader.get_cached_resource(path)
if cached and not is_visible_in_tree(cached):
    ResourceLoader.remove_resource_from_cache(path)
```

---

## Visual Quality vs. Performance

### Pixel Art Filter Settings

**Global Pixel Art Configuration:**

```
Project Settings > Rendering > Textures > Canvas Textures
â”œâ”€ Default Texture Filter: Nearest
â”œâ”€ Use Nearest Mipmaps: No

Per-Sprite Override (if needed):
â”œâ”€ Sprite2D > CanvasItem > Texture > Filter: Inherit/Nearest
```

**Result:** Crisp, blocky pixel art without blur at any zoom level.

### Upscaling Strategies

**Option 1: Integer Scaling (Recommended for pixel art)**
```
Project Settings > Window > Stretch > Mode: Viewport
Project Settings > Window > Stretch > Aspect: Keep Height (or Width)
Project Settings > Window > Stretch > Scale Mode: Integer
```

**Example:** 320Ã—180 game â†’ 1280Ã—720 screen = 4Ã— integer scale (perfect pixels).

**Option 2: Canvas Item Scaling**
```
Project Settings > Window > Stretch > Mode: Canvas Items
Project Settings > Window > Stretch > Scale: 2.0 (or desired factor)
```

- Smoother upscaling (allows fractional scales like 1.5Ã—)
- Each sprite scales individually
- Use if integer scaling doesn't fit target resolutions

### Viewport Scaling

**For Dynamic Resolution (Performance Mode):**
```gdscript
# Reduce internal resolution to boost FPS
get_viewport().set_canvas_transform(Transform2D.IDENTITY.scaled(Vector2(0.75, 0.75)))
```

**Performance Impact:**
- 0.5Ã— scale: 4Ã— FPS improvement, visible degradation
- 0.75Ã— scale: 2Ã— FPS improvement, acceptable quality
- 1.0Ã— scale: Baseline (no scaling)

### Shader Optimization

**Avoid in Shaders (2D context):**
- Expensive texture operations (5+ samples per fragment)
- Complex branching (if-statements in fragment shader)
- Loops over arrays

**Optimized Shader Example:**
```glsl
// GOOD - single texture sample
shader_type canvas_item;
void fragment() {
    COLOR = texture(TEXTURE, UV);
}

// AVOID - 25 samples (too expensive)
vec4 blur = vec4(0.0);
for(int i = -2; i <= 2; i++) {
    for(int j = -2; j <= 2; j++) {
        blur += texture(TEXTURE, UV + vec2(i,j) * 0.01);
    }
}
COLOR = blur / 25.0;
```

### LOD Strategies for 2D

**LOD (Level of Detail) Implementation:**

```gdscript
# Reduce sprite complexity based on screen distance
func update_sprite_lod():
    var distance = camera.global_position.distance_to(global_position)
    
    if distance < 100:
        sprite.frame = detailed_frame  # High-detail version
    elif distance < 300:
        sprite.frame = medium_frame     # Medium-detail
    else:
        sprite.frame = low_detail_frame # Simple version or hidden
```

**LOD for Particles:**
```gdscript
# Reduce particle count when off-screen or distant
if is_on_screen():
    particles.amount = 100
else:
    particles.amount = 10  # Minimal particles off-screen
```

---

## Import Pipeline Automation

### .import File Structure

**Location:** `.godot/imported/` folder (hidden by default)

**Example .import file (asset_name.png.import):**
```ini
[remap]
importer="texture"
type="CompressedTexture2D"
uid="uid://w65yd8ixqw7c"
path="res://.godot/imported/asset_name.png-abc123.ctex"

[deps]
source_file="res://assets/asset_name.png"
dest_files=["res://.godot/imported/asset_name.png-abc123.ctex"]

[params]
compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
process/ignore_svg_scale=true
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
```

**Key Fields:**
- `importer`: Type of asset (texture, scene, audio)
- `uid`: Unique identifier (don't modify)
- `path`: Compiled output path
- `[params]`: Import settings (EDIT THIS when changing defaults)

### Batch Import Settings

**Using Presets:**

1. Set import options on one texture
2. Click **Preset** button (top of Import tab)
3. Select **Save As Preset...** (give it a name like "PixelArt2D")
4. Apply to other textures: **Preset > (select saved preset)**

**Presets to Create:**
- `PixelArt2D`: Lossless, Nearest, no mipmaps, Detect3D disabled
- `Particle`: Lossless/VRAM compressed, Nearest, mipmaps enabled
- `UI`: Lossless, Nearest, no mipmaps
- `MobileOptimized`: VRAM compressed, size limit 2048

### Version Control of .import Files

**Recommended .gitignore:**
```
# Ignore compiled imports (regenerated on each pull)
.godot/imported/
.godot/imported/*

# Keep .import configuration files (version control)
!*.import

# Ignore platform-specific files
.godot/
```

**Workflow:**
1. Commit: `.png` file + `.png.import` configuration
2. Ignore: `.godot/imported/` compiled output
3. On pull: Godot auto-regenerates `.godot/imported/` from `.import` files
4. If re-imports don't apply, delete `.godot/` folder manually

**Issue:** Godot 4.5 occasionally re-imports unchanged assets when .import files sync via git. Workaround: Use script to skip detection if .import hash matches.

### CI/CD Asset Validation

**Pre-Export Checks:**

```gdscript
# Script: validate_assets.gd (run in CI pipeline)
extends Node

func _ready():
    check_texture_compression()
    check_audio_formats()
    check_max_sizes()

func check_texture_compression():
    var dir = DirAccess.open("res://assets/sprites")
    for file in dir.get_files():
        if file.ends_with(".png"):
            var import_path = file + ".import"
            var config = ConfigFile.new()
            config.load(import_path)
            var mode = config.get_value("params", "compress/mode")
            if mode != 0:  # 0 = Lossless
                push_error("ERROR: %s using VRAM compression instead of lossless!" % file)

func check_audio_formats():
    var audio_dir = DirAccess.open("res://audio")
    for file in audio_dir.get_files():
        if file.ends_with(".mp3"):
            push_error("ERROR: MP3 found (%s), use OGG instead!" % file)

func check_max_sizes():
    var img = Image.new()
    var files = DirAccess.open("res://assets").get_files()
    for file in files:
        img.load("res://assets/" + file)
        if img.get_width() > 4096 or img.get_height() > 4096:
            push_error("ERROR: Oversized texture (%s) - max 4096Ã—4096!" % file)

func _notification(NOTIFICATION_PROCESS):
    get_tree().quit()
```

**Run in CI:**
```bash
godot --headless --script validate_assets.gd
if [ $? -ne 0 ]; then exit 1; fi
```

---

## Common Mistakes & Fixes

### Mistake 1: Wrong Compression for Pixel Art

**Problem:** Pixel art appears blurry or color-shifted after import.

**Cause:** VRAM compression (ETC2, ASTC, S3TC) applied to pixel sprites.

**Fix:**
1. Select sprite texture â†’ Import tab
2. Set `Compress > Mode: Lossless`
3. Set `Detect 3D > Compress To: Disabled` (prevents unwanted re-compression)
4. Click **Reimport**

**Verification:** Open `.import` file, confirm `compress/mode=0`.

### Mistake 2: Oversized Textures

**Problem:** 1024Ã—1024 or larger single-sprite textures cause mobile memory spike.

**Solution:**
- Break large sprites into 256Ã—256 or 512Ã—512 pieces
- Use smaller atlases (max 1024Ã—1024 for mobile)
- Set size limit: `Compress > Process > Size Limit: 2048` (for auto-downscale)

### Mistake 3: Unnecessary Mipmaps

**Problem:** Enabling mipmaps increases memory and causes performance drops.

**When Mipmaps Are Needed (2D):**
- Camera zoom-out observed with aliasing/graininess
- Downsampling backgrounds at distance

**When NOT Needed:**
- Fixed resolution games
- Pixel art (mipmaps blur pixels)
- UI elements
- **99% of 2D games**

**Fix:** Set `Mipmaps > Generate: No` for all 2D sprites.

### Mistake 4: Missing Platform Overrides

**Problem:** iOS/Android export uses desktop compression settings, causing bloated APKs or color issues.

**Fix:**
1. Select texture â†’ Import tab
2. Scroll to **Platform Overrides**
3. Check boxes: iOS, Android, Web
4. Set iOS: VRAM Compressed, ASTC
5. Set Android: VRAM Compressed, ETC2
6. Set Web: Lossless (already default)
7. **Reimport**

### Mistake 5: Unoptimized Sprite Sheets

**Problem:** Inconsistent frame sizes, padding, or improper trimming.

**Verification Checklist:**
- [ ] All frames in animation same size
- [ ] 1-2 pixel padding between frames
- [ ] No large transparent areas (consider trimming)
- [ ] Atlas size power-of-2 (recommended) or 512Ã—512/1024Ã—1024
- [ ] Frames in logical groups (idle, walk, attack)

**Tool Recommendation:** Use Aseprite or TexturePacker for automatic optimization.

### Mistake 6: Preloading Too Much

**Problem:** Game startup takes 10+ seconds, initial load spike.

**Cause:** Preloading 50+ MB of assets unnecessarily.

**Fix:**
- Preload only: 5-8 MB (UI, player, core SFX)
- Load on-demand: Levels, bosses, optional content
- Use `load()` or `ResourceLoader.load_threaded_request()` instead of `preload()`

---

## Enforceable Patterns

### Detectable Import Misconfigurations

**Pattern 1: Pixel Art with VRAM Compression**

```gdscript
# Detector: Flag if sprite uses non-lossless compression
func check_sprite_compression(texture_path: String) -> bool:
    var import_file = texture_path + ".import"
    var config = ConfigFile.new()
    config.load(import_file)
    var compress_mode = config.get_value("params", "compress/mode")
    
    # Mode 0 = Lossless, 1 = Lossy, 2 = VRAM Compressed
    if compress_mode != 0:
        push_warning("Pixel art using non-lossless: " + texture_path)
        return false
    return true
```

**Pattern 2: 3D Detection Not Disabled on Sprites**

```gdscript
func check_detect_3d_disabled(texture_path: String) -> bool:
    var config = ConfigFile.new()
    config.load(texture_path + ".import")
    var detect_3d = config.get_value("params", "detect_3d/compress_to")
    
    # 1 = VRAM Compressed (bad), 0 = Disabled (good)
    if detect_3d != 0:
        push_warning("Detect 3D not disabled: " + texture_path)
        return false
    return true
```

### File Size Thresholds

**Enforce Asset Size Limits:**

| Asset Type | Max Size | Threshold |
|---|---|---|
| Sprite sheet | 2 MB | 2.5 MB (alert) |
| Tileset atlas | 1 MB | 1.5 MB (alert) |
| Music track | 8 MB | 10 MB (alert) |
| UI texture | 500 KB | 750 KB (alert) |

**Script to Enforce:**
```gdscript
func validate_asset_size(path: String, max_size_mb: float):
    var file = FileAccess.open(path, FileAccess.READ)
    var size_mb = float(file.get_length()) / (1024 * 1024)
    
    if size_mb > max_size_mb:
        push_error("%s exceeds limit: %.1f MB > %.1f MB" % [path, size_mb, max_size_mb])
        return false
    return true
```

### Format Requirements

**Enforceable Formats:**

| File Type | Required Format | Reason |
|---|---|---|
| Sprite/texture | PNG | Lossless, good compression |
| Music | OGG Vorbis | Streaming-friendly, mobile optimized |
| SFX | WAV or OGG | Low latency, crisp quality |
| Tileset | PNG | Must be lossless for pixel accuracy |

**Reject:** JPEG (lossy artifacts), BMP (uncompressed), MP3 (patent/licensing issues).

### Naming Conventions

**Establish Standard Naming:**

```
res://assets/sprites/
â”œâ”€â”€ characters_player_idle.png
â”œâ”€â”€ characters_player_walk.png
â”œâ”€â”€ characters_enemy_goblin.png
â”œâ”€â”€ ui_button_normal.png
â”œâ”€â”€ ui_button_hover.png

res://audio/
â”œâ”€â”€ sfx_jump_01.wav
â”œâ”€â”€ sfx_footstep_01.ogg
â”œâ”€â”€ music_level_01_main.ogg
â”œâ”€â”€ music_level_01_combat.ogg
```

**Pattern:** `[category]_[entity]_[variant].[format]`

### Validation Scripts

**Comprehensive Validation Suite:**

```gdscript
# validate_imports.gd - Run before export
extends Node

const VALIDATION_RULES = {
    "*.png": {
        "compress/mode": 0,              # Lossless
        "detect_3d/compress_to": 0,      # Disabled
        "mipmaps/generate": false,
        "filter": "nearest",
    },
    "*.ogg": {
        "format": "ogg_vorbis",
        "max_size_mb": 10,
    },
    "*.wav": {
        "max_size_mb": 5,
    }
}

func validate_all():
    var failed = 0
    for rule_pattern in VALIDATION_RULES:
        var files = find_files_matching(rule_pattern)
        for file in files:
            if not validate_file(file, VALIDATION_RULES[rule_pattern]):
                failed += 1
    
    if failed > 0:
        push_error("Validation failed: %d assets" % failed)
        return false
    push_notification("All assets validated!")
    return true

func validate_file(path: String, rules: Dictionary) -> bool:
    var config = ConfigFile.new()
    if not config.load(path + ".import"):
        push_error("Missing .import file: " + path)
        return false
    
    for rule_key in rules:
        var expected = rules[rule_key]
        var actual = config.get_value("params", rule_key)
        if actual != expected:
            push_error("%s: %s = %s (expected %s)" % [path, rule_key, actual, expected])
            return false
    
    return true

func find_files_matching(pattern: String) -> Array:
    var result = []
    # Implement recursive file search
    return result
```

---

## Platform Compatibility Matrix

| Setting | Desktop (Mac M4) | iOS | Android | HTML5 | Recommendation |
|---|---|---|---|---|---|
| **Compression** | S3TC/ASTC | ASTC | ETC2/ASTC | Lossless | Per-platform override |
| **Max Texture** | 8192Ã—8192 | 4096Ã—4096 | 4096Ã—4096 | 2048Ã—2048 | Lossless 1024Ã—1024 |
| **Filter** | Nearest (pixel art) | Nearest | Nearest | Nearest | Global nearest |
| **Mipmaps** | No (2D) | No (2D) | No (2D) | No | Avoid in 2D |
| **Audio Format** | WAV/OGG | OGG | OGG | OGG/WAV | OGG standard |
| **Sample Rate** | 44 kHz | 44 kHz | 44 kHz | 44 kHz | Standardize 44 kHz |
| **Draw Calls** | 10-50 | 5-10 | 5-10 | 8-16 | Use atlases |

---

## Quick Reference Import Settings Table

**Copy-Paste for Your Import Dialogs:**

### 2D Pixel Art Sprite

```
Compress > Mode: Lossless
Compress > Lossy Quality: N/A
Compress > HDR Compression: Disabled
Compress > Normal Map: Disabled
Detect 3D > Compress To: Disabled
Mipmaps > Generate: No
Filter: (inherit â†’ set globally to Nearest)
Repeat/Clamp: Clamp
```

### UI Texture

```
Compress > Mode: Lossless
Detect 3D > Compress To: Disabled
Mipmaps > Generate: No
Filter: Nearest
```

### Tilemap Atlas

```
Compress > Mode: Lossless
Detect 3D > Compress To: Disabled
Mipmaps > Generate: No
Filter: Nearest
Repeat/Clamp: Clamp
```

### Particle Texture

```
Compress > Mode: VRAM Compressed (or Lossless if < 512Ã—512)
Detect 3D > Compress To: Disabled
Mipmaps > Generate: Yes
Filter: Linear
Repeat/Clamp: Repeat
```

### Music (OGG)

```
Sample Rate: 44000 Hz
Channels: Stereo
Loop: (set in code, not import)
Bitrate: 128000 bps
```

### SFX (WAV/OGG)

```
Sample Rate: 44000 Hz
Channels: Mono
Loop Mode: Forward (if looping)
Bitrate: 96000 bps (OGG)
```

---

## Official Documentation References

- **Godot 4.5 Import Documentation:** `https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html`
- **Texture Compression Formats:** `https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d/index.html#vram-compression`
- **Exporting for iOS:** `https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html`
- **Exporting for Android:** `https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html`
- **Exporting for Web:** `https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html`
- **Audio Import:** `https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_audio.html`
- **Optimization (Batching):** `https://docs.godotengine.org/en/stable/tutorials/performance/batching/index.html`

---

**Document Version:** 1.0 (Godot 4.5.1)  
**Last Updated:** November 2025  
**Audience:** Developers new to Godot asset optimization  
**Target Complexity:** 100-300 on-screen entities, pixel art, multi-platform
