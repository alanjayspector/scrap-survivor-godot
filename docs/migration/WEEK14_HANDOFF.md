# Week 14 Handoff Document - Phase 1.2 Ready to Start

**Date**: 2025-11-15
**Status**: Phase 1.0 & 1.1 Complete, Phase 1.2 Ready
**Next Session**: Implement weapon firing sounds with diagnostic logging

---

## What's Done ✅

### Phase 1.0: iOS Weapon Switcher (1 hour) ✅
- Debug UI for testing all 10 weapons on iOS
- Files: `scenes/ui/debug_weapon_switcher.{gd,tscn}`
- Updated: `scenes/game/wasteland.gd` with platform detection
- **Result**: Can test all weapons on iOS by tapping buttons

### Phase 1.1: Audio Infrastructure (1 hour) ✅
- Complete directory structure: `assets/audio/{weapons,enemies,ambient,ui}/`
- 6 documentation files (sourcing guide, manifest, READMEs)
- 3 automation scripts:
  - `.system/scripts/process-kenney-audio.sh` ⭐ (1-click sourcing)
  - `.system/validators/check-audio-assets.sh` (verification)
- **Result**: User can source 24 audio files in 2 minutes

**Audio Status**: Infrastructure ready, files NOT YET sourced (user doing this in parallel)

---

## What's Next ⏭️

### Phase 1.2: Weapon Firing Sounds (2 hours)

**Goal**: Implement weapon audio playback with comprehensive diagnostic logging

**Tasks**:
1. Add `play_weapon_sound()` to `weapon_service.gd`
2. Integrate audio into `player.gd` `_fire_weapon()` method
3. Add defensive checks (graceful fallback if audio missing)
4. Comprehensive diagnostic logging at all stages

**Key Requirements**:
- **Graceful degradation**: Game works with/without audio files
- **Diagnostic logging**: Log audio loading, playback, failures
- **AudioStreamPlayer2D**: Positional audio with attenuation
- **Auto-cleanup**: Audio players removed after playback
- **Pitch variation**: 0.95-1.05 to prevent repetition fatigue

---

## Files to Modify

### 1. `scripts/services/weapon_service.gd`

**Add**:
```gdscript
## Audio (Week 14 Phase 1.2)
var weapon_audio_streams: Dictionary = {}  # weapon_id -> audio path

func _ready() -> void:
    # Existing code...
    _load_weapon_audio()

func _load_weapon_audio() -> void:
    """Load weapon audio streams (Week 14 Phase 1.2)

    Gracefully handles missing audio files with diagnostic logging.
    """
    GameLogger.info("Loading weapon audio streams")

    weapon_audio_streams = {
        "plasma_pistol": "res://assets/audio/weapons/plasma_pistol.wav",
        "rusty_blade": "res://assets/audio/weapons/rusty_blade.wav",
        # ... all 10 weapons
    }

    # Verify audio files exist
    var loaded_count = 0
    for weapon_id in weapon_audio_streams.keys():
        var path = weapon_audio_streams[weapon_id]
        if ResourceLoader.exists(path):
            loaded_count += 1
        else:
            GameLogger.warning("Weapon audio not found", {
                "weapon_id": weapon_id,
                "path": path
            })

    GameLogger.info("Weapon audio loaded", {
        "total": weapon_audio_streams.size(),
        "found": loaded_count,
        "missing": weapon_audio_streams.size() - loaded_count
    })

func play_weapon_sound(weapon_id: String, position: Vector2) -> void:
    """Play weapon firing sound (Week 14 Phase 1.2)

    Creates positional audio with pitch variation and auto-cleanup.
    Gracefully handles missing audio files.
    """
    if not weapon_audio_streams.has(weapon_id):
        GameLogger.debug("No audio configured for weapon", {"weapon_id": weapon_id})
        return

    var audio_path = weapon_audio_streams[weapon_id]
    if not ResourceLoader.exists(audio_path):
        GameLogger.debug("Audio file not found", {
            "weapon_id": weapon_id,
            "path": audio_path
        })
        return

    # Load and play audio
    var stream = load(audio_path)
    if not stream:
        GameLogger.warning("Failed to load audio", {
            "weapon_id": weapon_id,
            "path": audio_path
        })
        return

    # Create AudioStreamPlayer2D for positional audio
    var audio_player = AudioStreamPlayer2D.new()
    audio_player.stream = stream
    audio_player.volume_db = -5.0  # Slightly quieter
    audio_player.pitch_scale = randf_range(0.95, 1.05)  # Variation
    audio_player.max_distance = 1500
    audio_player.attenuation = 1.5
    audio_player.global_position = position

    # Auto-cleanup
    audio_player.finished.connect(audio_player.queue_free)

    # Add to scene
    get_tree().root.add_child(audio_player)
    audio_player.play()

    GameLogger.debug("Weapon sound playing", {
        "weapon_id": weapon_id,
        "position": position,
        "pitch": audio_player.pitch_scale
    })
```

### 2. `scripts/entities/player.gd`

**Modify `_fire_weapon()` method**:
```gdscript
func _fire_weapon(direction: Vector2) -> void:
    """Fire the equipped weapon using WeaponService"""
    # ... existing code ...

    # Play weapon sound (Week 14 Phase 1.2)
    WeaponService.play_weapon_sound(equipped_weapon_id, global_position)

    # ... rest of firing logic ...
```

---

## Testing Checklist

After implementation:

- [ ] Game runs without audio files (silent, no errors)
- [ ] Log shows: "Audio file not found" warnings (expected if not sourced)
- [ ] Game runs WITH audio files (sound plays)
- [ ] Log shows: "Weapon sound playing" debug messages
- [ ] Pitch variation works (sounds slightly different each shot)
- [ ] Audio players auto-cleanup (no memory leaks)
- [ ] All 10 weapons have audio configured
- [ ] iOS weapon switcher works (test all weapons)

---

## Audio Sourcing (User Task)

User is running this while you implement:

```bash
# Download 4 ZIPs from Kenney.nl to ~/Downloads
# Then run:
bash .system/scripts/process-kenney-audio.sh
```

**Don't wait for audio files** - implement code with graceful fallback first.

---

## Reference Documents

- **Main Plan**: `docs/migration/week14-implementation-plan.md`
- **Audio Guide**: `assets/audio/AUDIO_SOURCING_GUIDE.md`
- **Automation**: `.system/scripts/README.md`
- **Claude Rules**: `.system/CLAUDE_RULES.md`

---

## Key Principles

1. **Diagnostic Logging**: Log everything (load, play, fail, cleanup)
2. **Graceful Degradation**: Work without audio (don't break game)
3. **Evidence-Based**: Test before claiming success
4. **Follow Rules**: Get approval for git commits

---

**Ready to start Phase 1.2!** 🚀
