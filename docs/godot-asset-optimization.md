# Godot 4.5.1 Asset Import Settings & Optimization Guide
## Comprehensive Documentation for Multi-Platform Survivor-like Games

**Target**: Mac M4, iOS, Android, HTML5 | **Scale**: 100-300+ entities @ 60 FPS | **Style**: Pixel Art

---

## Table of Contents

1. [Texture Import Settings](#texture-import-settings)
2. [Sprite Sheet Optimization](#sprite-sheet-optimization)
3. [Platform-Specific Settings](#platform-specific-settings)
4. [Audio Import Settings](#audio-import-settings)
5. [Tilemap Optimization](#tilemap-optimization)
6. [Memory Budget Management](#memory-budget-management)
7. [Visual Quality vs Performance](#visual-quality-vs-performance)
8. [Import Pipeline Automation](#import-pipeline-automation)
9. [Common Import Mistakes](#common-import-mistakes)
10. [Enforceable Patterns & Validation](#enforceable-patterns--validation)

---

## Texture Import Settings

### Quick Decision Tree

```
Does your texture need VRAM compression?
â”œâ”€ YES: Is it for 3D?
â”‚  â”œâ”€ YES: Use VRAM Compressed (DXT1/S3TC or BPTC for high quality)
â”‚  â””â”€ NO: Use Lossless for 2D sprites (VRAM compression causes artifacts in pixel art)
â””â”€ NO: Use Lossless compression (PNG/WebP) for disk space, unrestricted GPU access
```

### Compress Mode Settings

**For 2D Pixel Art Sprites (Recommended)**:
- **Mode**: Lossless
- **Reasoning**: Pixel art quality degrades with VRAM compression algorithms. PVRTC and ETC2 show visible artifacts on sharp sprite edges and alpha channels.
- **VRAM Usage**: Uncompressed on GPU (e.g., 1024Ã—1024 RGBA = 4 MB VRAM)
- **File Size**: Reduced via WebP/PNG compression

**For 3D Assets & Performance Critical**:
- **Mode**: VRAM Compressed
- **Format**: See platform-specific section
- **VRAM Usage**: 1:4 to 1:6 compression ratio
- **Warning**: Basis Universal not supported in HTML5 exports (Godot 4.5 issue)

**Avoid for 2D Games**:
- **Basis Universal**: Lower file size but quality suffers for pixel art
- **High Quality VRAM Compression**: Slower compression, not worth overhead for sprites

### Mipmaps Settings

**For 2D Pixel Art**:
- **Mipmaps**: Disabled
- **Reasoning**: Pixel art downsampling causes blur and quality loss. 2D games don't benefit from mipmaps since sprites are drawn at their intended size.

**When Mipmaps ARE Needed**:
- Textures scaled down dramatically (distant 3D objects)
- Dynamic resolution scaling on mobile
- Parallax backgrounds with extreme zoom

**Power-of-2 Requirement**:
- Mobile GPUs: Mipmaps ONLY work on PoT textures (512, 1024, 2048, 4096)
- Desktop: Non-PoT supported, but performance hit without mipmaps when scaling

### Filter Mode Settings

**For Pixel Art (Essential)**:
- **Filter**: Nearest Neighbor
- **Method**: 
  - Globally: Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter = "Nearest"
  - Per-Node: Inspector > CanvasItem > Texture > Filter = "Nearest"
- **Why**: Preserves crisp pixel edges when scaling; prevents blur at odd zoom levels

**Alternative Method** (Sprite2D):
```
Right-click Texture â†’ Import Tab â†’ Preset: "2D Pixel"
Then: Reimport
```

### Repeat/Clamp Settings

**Sprite Textures**:
- **Repeat**: Disabled
- **Clamp**: Enabled (default)
- **Reasoning**: Prevents edge artifacts when sprites are adjacent in atlases

**Tiled/Seamless Backgrounds**:
- **Repeat**: Enabled (X/Y as needed)
- **Filter**: Nearest (for pixel art)

### Size Limits & Power-of-2 Considerations

| Platform | Max Texture Size | Practical Limit | Notes |
|----------|------------------|-----------------|-------|
| **Mac M4** | 16384Ã—16384 | 4096Ã—4096 | Metal backend, good headroom |
| **iOS** | 4096Ã—4096 | 2048Ã—2048 | A8+ supports ASTC; older devices limited |
| **Android** | 4096Ã—4096 | 2048Ã—2048 | Varies by GPU; budget conservatively |
| **HTML5** | 4096Ã—4096 | 2048Ã—2048 | WebGL constraint; PoT recommended |

**Memory Calculation**:
- Uncompressed RGBA: Width Ã— Height Ã— 4 bytes
- Example: 2048Ã—2048 = 16 MB VRAM
- Example: 1024Ã—1024 = 4 MB VRAM

**Power-of-2 Guidance**:
- Use PoT dimensions for all textures when possible
- Non-PoT breaks mipmaps; HTML5 may fail silently
- If using non-PoT, disable Repeat and Mipmaps

---

## Sprite Sheet Optimization

### Atlas Packing Strategies

**Consolidation Approach**:
- Combine all character sprites into single 2048Ã—2048 atlas
- Combine all enemy sprites into separate 2048Ã—2048 atlas
- Group UI elements into dedicated atlases
- Benefit: Reduces draw calls; one batch per atlas type

**Organization Pattern**:
```
Character_Atlas (2048Ã—2048)
â”œâ”€â”€ Player_Idle (4 frames, 64Ã—64 each)
â”œâ”€â”€ Player_Run (8 frames, 64Ã—64 each)
â”œâ”€â”€ Player_Attack (6 frames, 64Ã—64 each)
â””â”€â”€ Player_Death (4 frames, 64Ã—64 each)

Enemy_Atlas (2048Ã—2048)
â”œâ”€â”€ Zombie (6 frames)
â”œâ”€â”€ Skeleton (6 frames)
â””â”€â”€ Bat (8 frames)
```

### Texture Atlas Tools

**Recommended**:
- **TexturePacker** (Premium): Industry standard; supports Godot format
  - Install: Asset Lib â†’ Search "texturepacker" â†’ Get plugin
  - Export format: "Godot SpriteSheet"
  - Auto-regenerate on reimport
  
- **Free Alternatives**:
  - **Aseprite**: Built-in atlas export
  - **Krita**: Sprite sheet generation
  - **Python Scripts**: ImageMagick-based automation

### Frame Trimming

**Impact**:
- Removes transparent borders around sprites
- Reduces atlas size by 20-40%
- Requires margin adjustment in animation code

**Implementation**:
- TexturePacker: Enable "Trim" option
- Manual: Crop in Aseprite, align in Atlas

**Margin/Padding**:
- Recommendation: 2-pixel padding between sprites
- Prevents bleeding when using linear filtering
- TexturePacker: "Shape Padding" = 2

### Reducing Draw Calls with Atlases

**Current Performance**:
- Without atlases: 300+ entities = 300+ draw calls
- With atlases: 300+ entities = 2-5 draw calls

**How Atlases Reduce Draw Calls**:
1. All sprites using same atlas = batched into single call
2. Godot batches 2D nodes with same material automatically
3. One atlas per entity type = predictable batching

**Optimization Trick**:
- Assign material to parent node
- All children inherit material
- Automatic batching via material sharing

### Animation Frame Optimization

**Storage Method**:
- Store frames in atlas, not separate files
- Use AnimationPlayer with SpriteFrames resource
- SpriteFrames references atlas regions

**Setup Example**:
```
SpriteFrames (res://player_frames.tres)
â”œâ”€â”€ Default Animation
â”‚   â”œâ”€â”€ Frame 0: AtlasTexture (region: 0,0,64,64)
â”‚   â”œâ”€â”€ Frame 1: AtlasTexture (region: 64,0,64,64)
â”‚   â””â”€â”€ ... (rest of frames)
â””â”€â”€ Run Animation
    â”œâ”€â”€ Frame 0: AtlasTexture (region: 0,64,64,64)
    â””â”€â”€ ...
```

**Memory Savings**: 8 separate 64Ã—64 PNGs â†’ Single 512Ã—512 atlas (-75% overhead)

---

## Platform-Specific Settings

### iOS Texture Compression

**Modern Devices (A12+, 2018+)**:
- **Format**: ASTC 6Ã—6 or 8Ã—8
- **Compression Ratio**: 1:6 (excellent quality)
- **Enable in Project Settings**:
  ```
  Rendering > Textures > VRAM Compression > ASTC = ON
  Rendering > Textures > VRAM Compression > PVRTC = OFF (optional)
  ```

**Legacy Devices (A8-A11)**:
- **Format**: PVRTC 4bpp
- **Compression Ratio**: 1:4 (lower quality)
- **Enable**: VRAM Compression > PVRTC = ON
- **Warning**: PVRTC has poor quality on sprites with alpha transparency

**Optimal Mixed Strategy**:
- Enable both ASTC and PVRTC
- Export includes both; device selects at runtime
- No manual per-device export needed

**Rendering API**: Always use **GLES3**
- GLES3 supports both ETC2 and ASTC
- GLES2 limited to ETC1 (very poor compression)

### Android Texture Compression

**Modern Devices (2016+)**:
- **Format**: ETC2 (supported on 100% of Play Store devices)
- **Compression Ratio**: 1:4
- **Enable**:
  ```
  Rendering > Textures > VRAM Compression > ETC2 = ON
  ```

**Alternative (Better Quality)**:
- **Format**: ASTC 6Ã—6
- **Device Support**: ~85% of modern Android devices
- **Enable**: VRAM Compression > ASTC = ON

**Budget Conservative Approach**:
- Use **Basis Universal** for automatic transcoding
- Warning: Slower to compress; not worth for this project

**Project Export Settings**:
```
Android > Rendering > VRAM Compression = ETC2
OR
Android > Rendering > VRAM Compression = ASTC (if targeting recent devices)
```

### HTML5 Limitations (WebGL Constraints)

**Critical Restrictions**:
1. **Power-of-2 Textures Only**: Non-PoT textures fail silently or render as white
   - Always resize to: 512, 1024, 2048, 4096
   - Pad with transparency if needed

2. **No Basis Universal**: Web export breaks with Basis Universal (Godot 4.5 bug)
   - Solution: Use Lossless compression for HTML5 exports
   - Set per-platform override

3. **VRAM Compression Not Supported**: WebGL doesn't support S3TC, ETC2, ASTC
   - Ignore VRAM compression settings for HTML5
   - Engine automatically sends uncompressed

4. **Maximum Texture Size**: 4096Ã—4096 (often 2048Ã—2048 in browsers)
   - Keep textures under 2048Ã—2048 for safety
   - Split larger atlases across multiple files

**Recommended HTML5 Settings**:
- Compression Mode: **Lossless**
- Size: Max 2048Ã—2048
- Format: PNG (universal support)
- Mipmaps: Disabled

### Desktop vs Mobile Trade-Offs

| Aspect | Mac/Linux/Windows | Mobile |
|--------|------------------|--------|
| **Compression** | VRAM optional; performance headroom | VRAM compression critical |
| **Texture Size** | 4096Ã—4096 feasible | 2048Ã—2048 recommended |
| **VRAM Budget** | 256+ MB typical | 64-128 MB limited |
| **Filter** | Nearest OK; linear cheaper | Nearest recommended |
| **Atlasing** | Less critical | Critical for draw calls |

**Decision**: If targeting mobile, optimize for mobile limits; desktop will run better.

### Per-Platform Import Overrides

**Setup**:
1. Select texture in FileSystem
2. Import tab â†’ Presets dropdown
3. Select "2D Pixel"
4. Modify settings
5. Click "Override" for specific platform
6. Reimport

**Example Configuration**:
- **Default**: Lossless, 2048Ã—2048, Nearest
- **iOS Override**: ETC2/ASTC, 2048Ã—2048
- **Android Override**: ETC2, 2048Ã—2048
- **HTML5 Override**: Lossless, 1024Ã—1024

---

## Audio Import Settings

### Sample Rate Recommendations

| Audio Type | Recommended Rate | Max Rate | Notes |
|------------|-----------------|----------|-------|
| **SFX** | 22 kHz | 44 kHz | Below 11 kHz beyond human hearing for most effects |
| **Voice/Dialogue** | 22 kHz | 44 kHz | Human voice range; 22 kHz sufficient |
| **Music** | 48 kHz | 48 kHz | No benefit above 48 kHz; streaming common |
| **Ambient** | 22 kHz | 44 kHz | Background; lower rate acceptable |

**Mobile Constraint**: Use Force > Max Rate = 44100 Hz for most audio

### Compression Formats Decision

**Ogg Vorbis (Recommended for Mobile)**:
- **Compression**: Lossy, variable bitrate
- **Quality**: High quality at 96-128 kbps
- **File Size**: Small (50-70% reduction from WAV)
- **CPU Cost**: Low during playback
- **Best For**: SFX, short clips

**WAV (Desktop/Editor Only)**:
- **Compression**: Uncompressed
- **Quality**: Perfect fidelity
- **File Size**: Large (1 MB per second)
- **CPU Cost**: Minimal decoding
- **Storage**: Don't ship as-is; convert to Ogg for export

**MP3 (Avoid)**:
- **Issue**: Patent complications in some regions
- **Use Only If**: Legacy compatibility required
- **Performance**: Similar to Ogg Vorbis

### Looping Settings

**Music (Streaming)**:
- **Mode**: Forward
- **Loop**: Enabled
- **Start Point**: Set in import to skip intro
- **End Point**: Set to avoid silence

**SFX (One-Shot)**:
- **Loop**: Disabled
- **Play once, fire-and-forget

**Ambient Loops**:
- **Mode**: Forward
- **Seamless Edit**: Ensure no clicking at loop point

### Streaming vs Preloaded

**Preload (Memory-Heavy)**:
- Load entire file into RAM on startup
- Use for: SFX, UI sounds, short clips
- Latency: Zero
- RAM Cost: Full file size

**Streaming (Bandwidth-Heavy)**:
- Load from disk during playback
- Use for: Music, long dialogue
- Latency: ~1-2 second buffering
- RAM Cost: Streaming buffer only (~64 KB)

**Strategy for 100-300 Entities**:
- Preload: SFX pool (limit to 20 unique sounds)
- Stream: Background music
- Mixed: Important narratives preload, ambient stream

### Memory vs Quality Trade-Offs

**For Survivors Game (Estimate)**:
- 20 unique SFX Ã— 200 KB avg = 4 MB
- 3 music tracks Ã— 3 MB avg = 9 MB (streamed, not counted)
- Total RAM impact: ~4 MB + streaming buffer

**Optimization Targets**:
- SFX: Mono, 22 kHz, Ogg Vorbis 96 kbps
- Music: Stereo, 48 kHz, Ogg Vorbis 128 kbps
- Voice: Mono, 22 kHz, Ogg Vorbis 96 kbps

---

## Tilemap Optimization

### Tileset Atlas Organization

**Performance-Critical Layout**:
- Single texture atlas per tileset type
- Keep all tiles in one 2048Ã—2048 atlas if possible
- Minimize texture switches during rendering

**Recommended Arrangement**:
```
Tileset_Terrain (2048Ã—2048)
â”œâ”€â”€ Grass variants (4 rotations)
â”œâ”€â”€ Stone variants (4 rotations)
â”œâ”€â”€ Water (animated or static)
â””â”€â”€ Collision tiles (visually distinct)
```

**Avoid**:
- Separate texture per tile type (massive draw call overhead)
- Misaligned UV coordinates (causes bleeding artifacts)

### Autotile Settings (Terrains)

**Setup**:
1. TileSet editor: Select terrain
2. Setup peering bits (8-directional)
3. Assign texture variants
4. TileMap layer: Select terrain paint mode

**Performance Impact**:
- Autotile generation: CPU cost at tile-place time
- Rendering: No performance difference vs manual

**Optimization**: Pre-bake terrain connections offline if updating at runtime is slow

### Collision Layer Efficiency

**Best Practice**:
- One physics layer per TileSet
- Polygon shapes over rectangles where possible (tighter bounds)
- Disable collision for visual-only tiles
- Use manual collision layers only if dynamic updates needed

**Large Tilemap (700Ã—700 tiles)**:
- Chunking recommended to reduce memory/CPU
- Split into 100Ã—100 tile chunks
- Load/unload nearby chunks based on camera position
- Reduces draw calls and physics queries

### Baked vs Runtime Shadows

**Baked Shadows** (Recommended for Pixel Art):
- Pre-compute in editor
- Store as separate shadow texture layer
- Rendering: Single layer = single draw call
- Quality: Pixel-perfect, no computation needed

**Runtime Shadows**:
- Calculated per frame
- CPU overhead per entity
- 100-300 entities: Expensive
- Avoid for this project

**Pixel Art Approach**: Skip realistic shadows; use hand-drawn silhouettes in atlas

---

## Memory Budget Management

### Texture Memory Estimation

**Calculation Formula**:
```
VRAM Usage = (Width Ã— Height Ã— Bytes Per Pixel) / Compression Ratio
```

**Examples** (Assuming RGBA, no compression):
- 1024Ã—1024 RGBA: 4 MB VRAM
- 2048Ã—2048 RGBA: 16 MB VRAM
- 512Ã—512 RGBA: 1 MB VRAM

**With Compression** (ETC2, 1:4 ratio):
- 2048Ã—2048 ETC2: 4 MB VRAM (vs 16 MB uncompressed)

**For 100-300 Entities**:
- Estimate: 5-10 unique character sprites
- Estimate: 10-20 unique enemy sprites
- Estimate: 5 UI atlas textures
- Total: ~200-300 MB uncompressed equivalent
- With compression + atlasing: ~50-80 MB actual VRAM usage

### Atlas Consolidation

**Strategy**:
1. Group by entity type (player, enemies, items, UI)
2. Size per type: 2048Ã—2048 atlases
3. Rationale: Matches mobile GPU limits; improves batching

**File Structure**:
```
res://assets/textures/
â”œâ”€â”€ characters_atlas.png (2048Ã—2048)
â”œâ”€â”€ enemies_atlas.png (2048Ã—2048)
â”œâ”€â”€ ui_atlas.png (1024Ã—1024)
â”œâ”€â”€ items_atlas.png (1024Ã—1024)
â””â”€â”€ particles_atlas.png (512Ã—512)
```

### Lazy Loading Patterns

**Implementation** (GDScript):
```gdscript
var character_texture: Texture2D = null

func _ready():
    # Don't load yet
    pass

func _on_character_enters_viewport():
    if character_texture == null:
        character_texture = load("res://assets/characters_atlas.tres")
    # Use character_texture
```

**Benefits**:
- Startup time: Reduced
- Initial memory: Lower
- Gameplay memory: Same total, but distributed

### Resource Preloading

**Essential** (Load at Startup):
- Player sprite atlas
- Common enemy types (first 2-3)
- UI atlas
- Critical SFX (5-10 sounds max)

**Optional** (Load On-Demand):
- Rare enemy sprites
- Localized audio (dialogue)
- Dynamic content

### Unloading Unused Assets

**Pattern**:
```gdscript
func _on_level_end():
    # Unload enemy-specific resources
    get_tree().call_group("enemies", "queue_free")
    
    # Clear unused textures from memory
    if ResourceLoader.has_cached("res://enemies_atlas.tres"):
        var resource = load("res://enemies_atlas.tres")
        resource.unreference()  # Or use call_deferred
```

**Timing**: Unload between levels; don't unload mid-gameplay

---

## Visual Quality vs Performance

### Pixel Art Filter Settings (No Blur)

**Global Setting** (Recommended):
```
Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter
Set to: Nearest
```

**Per-Sprite Override** (if needed):
- Select Sprite2D node
- Inspector: CanvasItem > Texture > Filter = "Nearest"

**Verify**:
- Editor: Sprite should appear crisp, not blurry
- Export: Test on mobile device to confirm

### Upscaling Strategies

**Native Resolution**: 320Ã—180 or 640Ã—360
- Allows integer scaling on common resolutions
- Example: 320Ã—180 â†’ 1280Ã—720 (4Ã— integer scale) = perfect pixel alignment

**Viewport Scaling vs Canvas Scaling**:
- **Viewport Mode** (Crisp pixels):
  ```
  Project Settings > Display > Window
  Stretch Mode = "viewport"
  Stretch Scale = 2 or 4 (integer only)
  ```
- **Canvas Item Mode** (Flexible):
  ```
  Stretch Mode = "canvas_items"
  Stretch Scale = whatever needed
  ```

**Recommendation**: Use Viewport mode with integer scaling for pixel-perfect results

### Viewport Scaling

**Setup**:
```
Project > Project Settings > Display > Window
â”œâ”€â”€ Width: 640
â”œâ”€â”€ Height: 360
â”œâ”€â”€ Stretch Mode: Viewport
â””â”€â”€ Stretch Scale: 2
```

**Result**: 640Ã—360 game rendered at 1280Ã—720 (2Ã— integer scale = crisp)

### Shader Optimization

**For Pixel Art**, Use Minimal Shaders:
- Avoid expensive normal maps
- Skip parallax mapping
- Use simple color overlays instead of complex effects

**Example Simple Shader** (Minimal Overhead):
```glsl
shader_type canvas_item;

uniform sampler2D texture : hint_default_white;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
    COLOR = texture(texture, UV) * tint;
}
```

**Avoid**:
- Multiple texture lookups per fragment
- Complex math (sin/cos) per pixel
- Screen-space effects without proper LOD

### LOD Strategies for 2D

**2D-Specific LOD**:
- Distant sprites: Use lower-resolution versions
- Far entities: Render as simple colored rectangles
- Off-screen: Skip rendering entirely

**Implementation**:
```gdscript
func _ready():
    var distance = global_position.distance_to(player_position)
    if distance > 500:
        # Use low-res sprite
        sprite.texture = low_res_texture
    else:
        sprite.texture = full_res_texture
```

**Savings**: 30-50% fewer pixel fills for distant entities

---

## Import Pipeline Automation

### .import File Structure

**Location**: `.godot/imported/` folder (hidden)

**File Format** (INI-like):
```ini
[remap]
importer="texture"
type="CompressedTexture2D"
uid="uid://e1h2m3k4n5o6p7q8r9s0"
path="res://.godot/imported/sprite_texture.png-abc123hash.ctex"

[deps]
source_file="res://assets/sprite_texture.png"
dest_files=["res://.godot/imported/sprite_texture.png-abc123hash.ctex"]

[params]
compress/mode=0
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
process/fix_alpha_border=true
process/premult_alpha=true
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
process/screen_size_limit=0
svg/scale=1.0
editor_scale=1.0
```

**Key Settings**:
- `compress/mode`: 0=Lossless, 1=Lossy, 2=VRAM Compressed, 3=Basis Universal
- `mipmaps/generate`: true/false
- `process/fix_alpha_border`: true for atlases

### Batch Import Settings

**Command Line** (CI/CD):
```bash
godot --headless --convert-textures --path ./project
```

**Script** (Automate):
```gdscript
# Import settings updater
extends Node

func update_all_texture_imports():
    var texture_files = find_all_textures("res://assets/")
    
    for texture_path in texture_files:
        var import_path = texture_path + ".import"
        var config = ConfigFile.new()
        config.load(import_path)
        
        # Update settings
        config.set_value("params", "compress/mode", 0)  # Lossless
        config.set_value("params", "compress/lossy_quality", 0.7)
        config.set_value("params", "process/fix_alpha_border", true)
        
        config.save(import_path)
    
    # Reimport all
    EditorFileSystem.get_singleton().scan()
```

### Version Control of .import Files

**Recommendation**: **DO COMMIT** .import files

**Reasons**:
- Contains customized compression settings
- Ensures consistent imports across team
- Prevents unexpected settings changes
- Enables CI/CD validation

**Setup .gitignore**:
```
# Ignore compiled imports folder, keep .import metadata files
.godot/imported/
# But track individual .import files for custom settings
!res/**/*.import
```

### CI/CD Asset Validation

**Pre-Export Checks**:
```gdscript
# validate_assets.gd
extends Node

func validate_all_imports():
    var errors = []
    var textures = find_all_textures("res://assets/")
    
    for tex_path in textures:
        var import_path = tex_path + ".import"
        var config = ConfigFile.new()
        config.load(import_path)
        
        # Check compression mode
        var compress_mode = config.get_value("params", "compress/mode", -1)
        if compress_mode == -1:
            errors.append("Invalid compress/mode for: " + tex_path)
        
        # Check texture size
        var texture = load(tex_path) as Texture2D
        if texture.get_size().x > 2048 or texture.get_size().y > 2048:
            errors.append("Texture exceeds 2048Ã—2048: " + tex_path)
    
    if errors.size() > 0:
        push_error("Validation failed:\n" + "\n".join(errors))
        return false
    
    return true
```

### Preset System Usage

**Create Custom Preset**:
1. Import a texture
2. Adjust settings to desired state
3. Click Preset dropdown
4. Select "New Preset"
5. Name: "Pixel_Art_Sprite_2D"
6. Click "Set as Default for Texture"

**Result**: All future PNG imports use this preset automatically

**Preset Sharing**:
```
Presets stored in: res://.godot_export_templates_dir/export_presets.cfg
Share via git for team consistency
```

---

## Common Import Mistakes

### Wrong Compression for Pixel Art

**Mistake**:
```
Using VRAM Compression (S3TC/ETC2) on pixel art sprites
```

**Result**:
- Visible block artifacts (8Ã—8 pixel blocks)
- Color banding on solid-color areas
- Alpha transparency edges blurred

**Solution**: Use Lossless compression for all 2D pixel art

### Oversized Textures

**Mistake**:
- Importing 4096Ã—4096 character sprite (one character)
- Expecting 300 copies = feasible on mobile

**Reality**:
- 4096Ã—4096 RGBA = 64 MB VRAM (single texture)
- Total: 64 MB Ã— 300 = 19.2 GB (impossible)

**Solution**: 
- Max sprite size: 512Ã—512 or 256Ã—256
- Use atlases to group sprites
- Pack 30+ sprites into single 2048Ã—2048 atlas

### Unnecessary Mipmaps

**Mistake**:
```gdscript
Using mipmaps=true on all sprites
```

**Impact**:
- 33% increase in VRAM (adds 0.33Ã— original size for mipchain)
- File size increase
- No visual benefit for fixed-size 2D sprites

**Solution**:
- Mipmaps: OFF for 2D sprites
- Mipmaps: ON only for 3D or downsampled backgrounds

### Missing Platform Overrides

**Mistake**:
- Single import setting for all platforms
- Desktop optimal settings exported to iOS
- Result: iOS runs out of VRAM

**Solution**:
- Override per platform
- iOS: 2048Ã—2048 max, ETC2 compression
- Android: 2048Ã—2048 max, ETC2 compression
- HTML5: PoT sizes only, no VRAM compression

### Unoptimized Sprite Sheets

**Mistake**:
```
Sprite 1: res://player.png (256Ã—256)
Sprite 2: res://enemy.png (256Ã—256)
Sprite 3: res://item.png (256Ã—256)
... (50 separate files)
```

**Result**: 50 draw calls (minimum)

**Solution**:
```
res://characters_atlas.png (2048Ã—2048)
Contains: All player sprites, all enemy sprites
Result: 1-2 draw calls for all entities
```

---

## Enforceable Patterns & Validation

### Detectable Import Misconfigurations

**Automated Checker** (GDScript):
```gdscript
# validate_imports.gd - Run on project startup
extends Node

const TEXTURE_EXTENSIONS = [".png", ".jpg", ".webp"]
const MAX_TEXTURE_SIZE = 2048
const VALID_COMPRESS_MODES = [0, 1]  # Lossless, Lossy only for 2D

func _ready():
    validate_project_imports()

func validate_project_imports() -> bool:
    var all_valid = true
    var texture_files = find_textures_recursive("res://assets/")
    
    for tex_file in texture_files:
        var import_file = tex_file + ".import"
        if not ResourceLoader.exists(import_file):
            printerr("Missing .import file: ", import_file)
            all_valid = false
            continue
        
        var config = ConfigFile.new()
        if config.load(import_file) != OK:
            printerr("Failed to load: ", import_file)
            all_valid = false
            continue
        
        # Check compression mode
        var compress = config.get_value("params", "compress/mode", -1)
        if compress not in VALID_COMPRESS_MODES:
            printerr("Invalid compression mode for %s: %d" % [tex_file, compress])
            all_valid = false
        
        # Check texture size
        var texture = load(tex_file) as Texture2D
        if texture:
            var size = texture.get_size()
            if size.x > MAX_TEXTURE_SIZE or size.y > MAX_TEXTURE_SIZE:
                printerr("Texture exceeds size limit: %s (%dx%d)" % [tex_file, size.x, size.y])
                all_valid = false
        
        # Check mipmaps (should be false for 2D)
        var mipmaps = config.get_value("params", "mipmaps/generate", false)
        if mipmaps and ".png" in tex_file:
            push_warning("Mipmaps enabled on 2D sprite: ", tex_file)
    
    return all_valid

func find_textures_recursive(path: String) -> PackedStringArray:
    var files = PackedStringArray()
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.begins_with("."):
                file_name = dir.get_next()
                continue
            
            var full_path = path.path_join(file_name)
            
            if dir.current_is_dir():
                files.append_array(find_textures_recursive(full_path))
            elif file_name.get_extension().to_lower() in TEXTURE_EXTENSIONS:
                files.append(full_path)
            
            file_name = dir.get_next()
    
    return files
```

### File Size Thresholds

**Recommended Limits**:
- Individual texture: â‰¤ 5 MB
- Total assets folder: â‰¤ 200 MB (uncompressed)
- Exported HTML5: â‰¤ 50 MB
- APK (Android): â‰¤ 150 MB

**Monitoring**:
```bash
# Check asset sizes
du -sh res/assets/
ls -lh res/assets/textures/*.import
```

### Format Requirements

**Texture Files**:
- **2D Sprites**: PNG (lossless)
- **3D Textures**: PNG or TGA
- **Avoid**: JPEG (lossy) for pixel art

**Audio Files**:
- **SFX**: OGG Vorbis (compressed)
- **Music**: OGG Vorbis (streamed)
- **Source**: WAV (keep separate, convert on export)

**Scene/Script Files**:
- **Scenes**: .tscn (Godot text format)
- **Scripts**: .gd (GDScript)
- **Resources**: .tres (Godot resource format)

### Naming Conventions

**Textures**:
```
res://assets/textures/characters/player_idle_atlas.png
res://assets/textures/enemies/zombie_atlas.png
res://assets/textures/ui/hud_atlas.png
res://assets/textures/particles/effects_atlas.png
```

**Audio**:
```
res://assets/audio/sfx/footstep.ogg
res://assets/audio/sfx/attack_slash.ogg
res://assets/audio/music/level_1_loop.ogg
res://assets/audio/voice/dialogue_intro.ogg
```

**Pattern**: `type/category/name_descriptor.extension`

### Validation Scripts

**On-Save Hook** (Editor Plugin):
```gdscript
# addons/asset_validator/plugin.gd
extends EditorPlugin

func _ready():
    connect("scene_saved", Callable(self, "_on_scene_saved"))

func _on_scene_saved(scene_path: String):
    if should_validate(scene_path):
        var result = run_validation(scene_path)
        if not result:
            push_error("Validation failed for: ", scene_path)

func should_validate(path: String) -> bool:
    return path.begins_with("res://assets/")

func run_validation(path: String) -> bool:
    # Implement validation logic
    return true
```

---

## Quick Reference Import Settings Table

| Asset Type | Compression | Mipmaps | Filter | Max Size | Platform Notes |
|------------|-------------|---------|--------|----------|----------------|
| **Character Sprite** | Lossless | No | Nearest | 512Ã—512 | All platforms |
| **Enemy Sprite** | Lossless | No | Nearest | 512Ã—512 | All platforms |
| **UI Asset** | Lossless | No | Nearest | 1024Ã—1024 | All platforms |
| **Particle Texture** | Lossless | No | Nearest | 256Ã—256 | All platforms |
| **Tileset** | Lossless | No | Nearest | 2048Ã—2048 | Power-of-2 for HTML5 |
| **SFX** | OGG Vorbis | N/A | N/A | N/A | Mono, 22 kHz |
| **Music** | OGG Vorbis | N/A | N/A | N/A | Stereo, 48 kHz, Stream |

---

## Platform Compatibility Matrix

| Feature | Mac M4 | iOS | Android | HTML5 |
|---------|--------|-----|---------|-------|
| **Max Texture Size** | 16k | 4k | 4k | 4k |
| **Practical Size** | 4k | 2k | 2k | 2k |
| **VRAM Budget** | 512 MB | 128 MB | 128 MB | 64 MB |
| **Compression** | Any | ASTC/PVRTC | ETC2/ASTC | None (WebGL) |
| **Power-of-2 Required** | No | No (GLES3) | No (GLES3) | Yes |
| **Mipmaps** | Optional | Optional | Optional | Not recommended |
| **Max Entities** | 500+ | 100-150 | 75-100 | 50-75 |

---

## Official Godot References

- [Importing Images â€“ Godot 4.x](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)
- [Importing Audio â€“ Godot 4.x](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_audio_samples.html)
- [The Import Process â€“ Godot 4.x](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html)
- [2D Rendering Limitations â€“ Godot 4.x](https://docs.godotengine.org/en/stable/tutorials/rendering/2d_rendering_limitations.html)

---

## Implementation Checklist

- [ ] Set global texture filter to Nearest (Project Settings)
- [ ] Enable per-platform VRAM compression overrides
- [ ] Create texture atlases (max 2048Ã—2048 per atlas)
- [ ] Validate all textures â‰¤ 2048Ã—2048
- [ ] Disable mipmaps on all 2D sprites
- [ ] Convert audio to OGG Vorbis (22 kHz SFX, 48 kHz music)
- [ ] Set up lazy loading for non-critical assets
- [ ] Implement batch validation script
- [ ] Document custom import presets
- [ ] Test on iOS/Android devices (not emulators)
- [ ] Monitor VRAM usage with Godot profiler
- [ ] Profile draw calls per scene type
- [ ] Set up CI/CD asset validation

---

**Last Updated**: November 2025 | **Godot Version**: 4.5.1
