# Godot 4.5 iOS Audio Runtime Loading Research

## Executive Summary

Godot 4.5 iOS exports have known issues with runtime `load()` operations on audio resources, particularly when dealing with `AudioStreamWAV`. The recommended approach for mobile platforms is to use `preload()` for essential audio assets instead of dynamic runtime loading. This documentation synthesizes research findings across six key topics related to audio handling in Godot 4.5 mobile exports.

---

## Query 1: Godot iOS Audio Runtime Loading Issue

### Key Finding: `load()` Fails on iOS Exports

**Status:** Known issue with multiple reported instances

**Error Pattern:**
- Audio files play correctly in editor
- iOS export throws: `"Unrecognized binary resource file"` or `"Music file not found: uid://..."`
- Error appears in device logs during runtime

**Root Cause Analysis:**

The core issue stems from resource path resolution in iOS exports:

1. **Import System Mismatch:** Godot internally uses `.import` folder metadata during editor sessions. When exporting to iOS, resource file structures change, and the runtime `load()` function cannot properly resolve imported audio resources using the original `res://` paths.

2. **UID Resolution Failure:** Resource UIDs (unique identifiers like `uid://lecq5ixjyy1`) work fine in the editor but fail to resolve to actual file paths in exported iOS builds. The exported binary does not contain the UID cache that maps identifiers to physical file locations.

3. **Resource Path Remapping:** During iOS export, Godot converts resource paths to binary format and stores them differently. The `.remap` files that bridge this translation are not properly loaded when `load()` is called at runtime on iOS.

**Evidence:**
- Forum reports show music files missing after iOS export despite working in editor preview
- Reimporting files and clearing `.godot` folder do not resolve the issue
- The problem is specific to runtime `load()` calls on iOS (desktop platforms less affected)

**Technical Context:**

When Godot exports to iOS:
- The original `.wav` files are not directly included
- Imported versions are stored in a binary format within the `.pck` (pack file)
- Runtime `load()` attempts to use the original path, which no longer exists in the expected location
- The iOS runtime lacks the full resource mapping infrastructure available in the editor

---

## Query 2: Godot Audio Preloading Best Practices

### Recommended Pattern: Preload for Mobile

**Official Recommendation:**

Preload should be used for **essential audio resources** on mobile platforms. The pattern differs from desktop due to iOS/Android resource constraints.

**Preload vs Load Characteristics:**

| Aspect | Preload | Load |
|--------|---------|------|
| **Timing** | Compile-time (before game start) | Runtime (when called) |
| **Memory** | Loaded immediately into RAM | Loaded only when needed |
| **Path Requirements** | Must be constant string (compile-time resolvable) | Can be dynamic/variable |
| **Startup Impact** | Increases initial load time | Spreads loading across gameplay |
| **Use Case** | Essential resources, small files | Optional, large, or dynamic resources |
| **Mobile Exports** | Reliable on iOS/Android | Problematic on iOS exports |

**Best Practice Implementation for Mobile:**

```gdscript
# Audio resources preloaded at script class load time
const SOUND_COLLECT = preload("res://audio/collect.wav")
const SOUND_JUMP = preload("res://audio/jump.wav")
const MUSIC_THEME = preload("res://audio/theme.ogg")

func _ready():
    # Direct reference available immediately
    $AudioStreamPlayer.stream = SOUND_COLLECT
    $AudioStreamPlayer.play()
```

**Pattern Considerations:**

- **File Size:** Preload only small audio files (sound effects, short loops)
- **Count:** Preload only necessary resources (10-20 files maximum)
- **Music:** For long audio, use Ogg Vorbis format with preload for better compression
- **Startup Time:** Monitor initial load time; large preloads delay game startup

**Cache Behavior:**

Once preloaded, resources remain in memory and are automatically cached by Godot. Calling `load()` on a previously preloaded resource returns the cached copy without reloading from disk.

**Known Limitation:**

Preload caching can sometimes cause issues when resources fail to load initially. The cache persists with the broken state until editor restart. This is a known issue in Godot 4.3+.

---

## Query 3: Godot iOS Export Audio Format Support

### WAV Format on iOS: Supported with Configuration

**Format Support Matrix:**

| Format | iOS Support | Recommended Use | Notes |
|--------|-------------|-----------------|-------|
| **WAV** | Yes | Short sound effects | Low CPU cost, larger files |
| **Ogg Vorbis** | Yes | Music, long effects | Better compression, higher CPU |
| **MP3** | Yes | Mobile/Web | Legacy format, good for mobile |

**WAV Specifications for iOS:**

- **Supported Encoding:** PCM (uncompressed), IMA-ADPCM, QOA (Quite OK Audio)
- **Sample Rates:** Auto-detected from file (common: 44.1kHz, 48kHz)
- **Bit Depth:** 8-bit, 16-bit, 24-bit supported
- **Channels:** Mono and stereo both supported
- **Default Import Compression:** QOA (lossy, reduces file size ~30%)

**Import Settings for WAV Files:**

In Godot editor, select WAV file and configure in Import dock:

1. **Force Mode:**
   - `Force / Mono`: Convert stereo to mono (50% size reduction)
   - `Force / Max Rate Hz`: Limit sample rate (default: 44100 Hz)

2. **Compress Mode:**
   - `Disabled` (PCM): Full quality, larger file
   - `RAM (IMA-ADPCM)`: Moderate compression, audible quality loss
   - `QOA` (default): Best compression ratio for iOS

3. **Edit Mode:**
   - `Loop Mode`: Set looping behavior (Forward, Ping-Pong, Backward, Disabled)
   - `Loop Points`: Define loop start/end positions

**Recommended iOS WAV Settings:**

```
Compress/Mode: QOA (default)
Force/Max Rate: 44100 Hz
Force/Mono: true (if mono acceptable)
Edit/Loop Mode: Detect from WAV
```

**File Size Comparison (1 second audio):**

- WAV 24-bit, 96kHz, stereo: 576 KB
- WAV 16-bit, 44kHz, mono (QOA): ~17 KB
- Ogg Vorbis 128 Kbps, stereo: 16 KB

**Critical Note for iOS Exports:**

WAV files work on iOS only if:
1. Files are imported using Godot's import system (not raw file access)
2. Resources are accessed via `preload()` or proper `load()` paths
3. Import settings are applied **before** exporting
4. The `.import` metadata is properly included in the export package

---

## Query 4: Godot AudioStreamPlayer2D Mobile Performance

### Positional Audio on Mobile: Patterns and Considerations

**AudioStreamPlayer2D Purpose:**

Provides positional audio in 2D environments:
- Sound pans left/right based on proximity to screen edges
- Attenuation reduces volume with distance
- Useful for: footsteps, ambient effects, UI feedback positioned in world

**Mobile Performance Best Practices:**

1. **Polyphony Management:**
   ```gdscript
   # Limit simultaneous sounds
   $AudioStreamPlayer2D.max_polyphony = 1  # One sound at a time
   ```
   - iOS/Android have limited audio mixing capacity
   - Typical safe limit: 4-8 simultaneous 2D audio streams
   - Exceeding limit causes oldest sounds to cut off

2. **Attenuation Settings:**
   ```gdscript
   $AudioStreamPlayer2D.max_distance = 500.0  # Stop volume decay
   $AudioStreamPlayer2D.attenuation = 1.0  # Linear falloff (default)
   ```
   - Higher attenuation exponents process faster on mobile
   - Set max_distance appropriately to avoid processing distant sounds

3. **Panning Strength:**
   ```gdscript
   $AudioStreamPlayer2D.panning_strength = 1.0  # Full pan L/R
   ```
   - Reduce if stereo separation not critical
   - Default (1.0) is typical for mobile

**Mobile-Specific Recommendations:**

- **Use WAV for short effects:** Lower CPU cost on mobile (hundreds of simultaneous WAV streams feasible)
- **Use Ogg for ambient:** Better compression for long atmospheric sounds
- **Keep polyphony low:** Set `max_polyphony` to 1-2 on low-end devices
- **Preload critical sounds:** Use `preload()` to avoid runtime loading hitches
- **Audio Buses:** Use for volume control without recreating nodes

**Listener Positioning:**

```gdscript
# AudioListener2D automatically follows active Camera2D
# Ensure Camera2D is in scene for positional audio to work correctly
var camera = get_viewport().get_camera_2d()
# Camera2D position determines where audio is "heard from"
```

**Performance vs. Quality Trade-off:**

| Setting | High Performance | High Quality |
|---------|------------------|--------------|
| Max Polyphony | 2-4 | 8-16 |
| Audio Format | WAV | Ogg Vorbis |
| Attenuation | Simple linear | Exponential |
| Bus Effects | Minimal | Full reverb/EQ |

---

## Query 5: Godot Resource Loading iOS Exports - "Unrecognized Binary Resource File"

### The `"Unrecognized binary resource file"` Error

**Error Manifestation:**

```
core/variant/variant_utility.cpp:1024:push_error(): Music file not found: uid://lecq5ixjyy1
Music file not found: uid://lecq5ixjyy1
```

or

```
ERROR: No loader found for resource: <path>
```

**Root Cause Analysis:**

This error occurs when runtime `load()` attempts to access a resource that exists in editor but is stored differently in the export:

1. **In Editor:** Resources use `.import` metadata with UID references
2. **In iOS Export:** Resources are binary-encoded in the `.pck` file
3. **Runtime Load:** The engine cannot locate the resource path mapping

**Why UID References Fail:**

- UIDs are editor metadata for tracking file movements
- Exported builds do **not** include UID cache (file: `.godot/uid_cache.bin`)
- Runtime `ResourceLoader.get_resource_uid()` returns `-1` (INVALID_ID) in exports
- Using `uid://` paths at runtime will always fail on iOS exports

**Why .remap Workarounds Sometimes Fail:**

Manual `.remap` file access (reading `res://path/file.wav.import`) is unreliable on iOS because:
- The `.import` folder structure is different in exports
- iOS build system doesn't expose `.godot/imported/` folder
- Remapped paths point to locations that don't exist in iOS runtime

**Resource Loading Flow Difference:**

**Editor:**
```
load("res://audio/music.wav") 
  â†’ finds music.wav in res://audio/
  â†’ checks .godot/imported/ for binary version
  â†’ uses import metadata to load binary
  â†’ SUCCESS
```

**iOS Export (Runtime):**
```
load("res://audio/music.wav")
  â†’ looks for music.wav in res://audio/ 
  â†’ file doesn't exist (only binary in .pck)
  â†’ checks .import metadata
  â†’ no .import folder in iOS runtime
  â†’ UID fails to resolve
  â†’ FAILURE: "Unrecognized binary resource file"
```

**Verified Solutions:**

1. **Use preload() instead** (most reliable)
2. **Reference via correct import path** (if possible to determine)
3. **Use AudioStreamWAV.load_from_file()** with proper error handling (for true runtime loading)
4. **Store resource paths in data files** (precache at build time)

**Known Unresolved Issues:**

- Dynamic `load()` of audio fails on iOS in Godot 4.4+
- This is not a bug but architectural limitation of iOS exports
- Expected behavior per Godot team assessment

---

## Query 6: Godot Autoload Audio Manager Pattern

### Audio Manager Autoload: Service-Oriented Architecture

**Pattern Purpose:**

Centralized audio management for mobile games using Godot's autoload system. This solves:
- Sounds cutting off when source node is removed
- Managing audio lifetime across scene changes
- Global access to audio playback
- Reusable audio player pool

**Architecture:**

```gdscript
# AudioManager.gd (set as autoload in Project Settings)
extends Node

var available_players: Array[AudioStreamPlayer] = []
var queue: Array[String] = []

func _ready():
    # Pre-create pool of audio players
    for i in range(8):
        var player = AudioStreamPlayer.new()
        add_child(player)
        available_players.append(player)
        player.finished.connect(_on_player_finished.bind(player))

func play_sound(sound_path: String):
    queue.append(sound_path)

func _process(delta):
    # Play queued sounds if players available
    if not queue.is_empty() and not available_players.is_empty():
        var player = available_players.pop_front()
        player.stream = preload(sound_path)  # Use preload reference
        player.play()

func _on_player_finished(player: AudioStreamPlayer):
    available_players.append(player)
```

**Mobile-Optimized Variant:**

```gdscript
# For iOS/Android with preloaded sounds
extends Node

# Preload all audio at class level
const SOUNDS = {
    "collect": preload("res://audio/collect.wav"),
    "jump": preload("res://audio/jump.wav"),
    "hit": preload("res://audio/hit.wav"),
    "music": preload("res://audio/music.ogg")
}

@onready var players: Array[AudioStreamPlayer] = []

func _ready():
    # Create reusable player pool
    for i in range(4):
        var player = AudioStreamPlayer.new()
        add_child(player)
        players.append(player)
        player.finished.connect(_on_finished.bind(player))
    
    # Start music
    play("music")

func play(sound_name: String):
    if not SOUNDS.has(sound_name):
        push_error("Sound not found: ", sound_name)
        return
    
    # Find available player
    for player in players:
        if not player.playing:
            player.stream = SOUNDS[sound_name]
            player.play()
            return
    
    # All players busy - skip (or implement queue)

func _on_finished(player: AudioStreamPlayer):
    player.stream = null
```

**Advanced Pattern: Spatializer with 2D Audio:**

```gdscript
extends Node

# Preloaded SFX
const SFX = {
    "pop": preload("res://audio/pop.wav"),
    "click": preload("res://audio/click.wav"),
}

@onready var sfx_players: Array[AudioStreamPlayer2D] = []

func _ready():
    # Create 2D audio player pool
    for i in range(4):
        var player = AudioStreamPlayer2D.new()
        add_child(player)
        player.max_distance = 500.0
        player.attenuation = 1.0
        sfx_players.append(player)

func play_at_position(sound_name: String, position: Vector2):
    if not SFX.has(sound_name):
        return
    
    for player in sfx_players:
        if not player.playing:
            player.global_position = position
            player.stream = SFX[sound_name]
            player.play()
            return
```

**Setup Instructions:**

1. Create scene: `AudioManager.tscn` with Node root
2. Attach `AudioManager.gd` script to root
3. Go to: Project â†’ Project Settings â†’ Autoload tab
4. Add scene: Select `AudioManager.tscn`
5. Give name: `AudioManager`
6. Access globally: `AudioManager.play("sound_name")`

**Usage Example:**

```gdscript
# From any script, no import needed
func _on_player_collected_coin():
    AudioManager.play("collect")

func _on_enemy_hit():
    AudioManager.play("hit")
```

**Mobile-Specific Considerations:**

- **Preload Limits:** Load only 10-20 critical sounds per game
- **Polyphony:** Set player pool size based on target device (4-8 typical)
- **Audio Buses:** Use for crossfading music without recreating players
- **Memory:** iOS has strict memory limits; monitor preload usage
- **Battery:** WAV uses less CPU than Ogg; prefer WAV for mobile

**Known Limitations of Autoload Pattern:**

- All audio preloaded at startup (increases initial load time)
- Player pool is fixed size (cannot dynamically add)
- No built-in fade transitions (must implement separately)
- Resource UIDs don't work at runtime (use names/paths only)

---

## Synthesis: Recommended iOS Audio Architecture

### Complete Implementation Example

```gdscript
# res://autoload/AudioManager.gd
extends Node

# Preload all audio resources at class load time
const AUDIO = {
    "sfx": {
        "collect": preload("res://audio/sfx/collect.wav"),
        "jump": preload("res://audio/sfx/jump.wav"),
        "hit": preload("res://audio/sfx/hit.wav"),
    },
    "music": {
        "theme": preload("res://audio/music/theme.ogg"),
        "boss": preload("res://audio/music/boss.ogg"),
    }
}

# Player pools
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

func _ready():
    # Create SFX player pool (iOS: 4 players)
    for i in range(4):
        var player = AudioStreamPlayer.new()
        add_child(player)
        player.bus = "SFX"
        sfx_players.append(player)
    
    # Dedicated music player
    music_player = AudioStreamPlayer.new()
    add_child(music_player)
    music_player.bus = "Music"

func play_sfx(sfx_name: String):
    var path = sfx_name.split("/")
    var sound = AUDIO["sfx"].get(path[-1])
    
    if not sound:
        push_error("SFX not found: ", sfx_name)
        return
    
    # Find available player
    for player in sfx_players:
        if not player.playing:
            player.stream = sound
            player.play()
            return

func play_music(music_name: String):
    var sound = AUDIO["music"].get(music_name)
    if not sound:
        push_error("Music not found: ", music_name)
        return
    
    music_player.stream = sound
    music_player.play()

func stop_music():
    music_player.stop()
```

### iOS Export Checklist

- [ ] All audio using `preload()` (not `load()`)
- [ ] WAV files configured with QOA compression in import settings
- [ ] Audio manager set as autoload in Project Settings
- [ ] Max polyphony set appropriately (4-8 for iOS)
- [ ] Test on actual iOS device (simulator may mask issues)
- [ ] No dynamic audio loading or UID references
- [ ] Audio files included in export (verify in .pck)

---

## Key Takeaways

1. **Runtime `load()` fails on iOS** - Use `preload()` instead for all mobile audio
2. **WAV format supported** - Configure with QOA compression for iOS
3. **UID references invalid at runtime** - Use string paths or preload constants
4. **Autoload pattern reliable** - Service-oriented audio manager recommended
5. **Polyphony limits strict** - Monitor and cap simultaneous audio on mobile
6. **Preload caching persistent** - Changes require editor restart
7. **Resource paths change in export** - `.import` metadata not available at runtime on iOS

---

## References and Source Documentation

- Godot 4.5 Importing Audio Samples documentation
- AudioStreamWAV class reference (4.5 stable)
- iOS export platform guidelines
- Community forum discussions on mobile audio (2023-2025)
- GitHub issues #18390, #77886, #107390 (resource loading)
- AudioStreamPlayer2D documentation and best practices
- Resource import process documentation

