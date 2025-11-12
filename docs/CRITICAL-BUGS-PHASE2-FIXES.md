# Critical Bugs - Week 12 Phase 2 Post-QA Fixes

**Created**: 2025-01-11
**Status**: Ready for Implementation
**Session**: Fresh token budget required
**Priority**: P0 (Gameplay Blockers)

---

## 🔍 Bug Analysis Summary

Based on manual QA testing on iOS device and runnable.log analysis, the following critical bugs were identified:

### Bugs Confirmed:
1. ✅ Wave countdown timer not counting down (displays "1:00" static)
2. ✅ Enemies stick to player and don't take damage from weapons
3. ✅ Player moved off-screen (position: 1046, -208)
4. ✅ Contact damage not working (enemies don't damage player)
5. ⚠️ UI text too small on device
6. ⚠️ Health bar not visible enough

---

## 🐛 Bug 1: Wave Timer Not Counting Down

### **Severity**: P0 - Critical (Gameplay Feature)

### **Evidence**:
- Log shows WaveManager emits `wave_started` signal (lines 155, 762, 1498, 2694, 4010)
- Log shows WaveManager emits `wave_completed` with `wave_time` stats
- **NO logs** showing HUD connecting to WaveManager signals
- HUD `_process()` never runs wave timer logic

### **Root Cause**:
HUD's `_ready()` tries to connect to WaveManager via `get_tree().get_first_node_in_group("wave_manager")`, but WaveManager is not added to the "wave_manager" group.

**File**: [scripts/systems/wave_manager.gd](../scripts/systems/wave_manager.gd#L22-L26)
```gdscript
func _ready() -> void:
    # Connect to drop collection signal to track collected drops (not generated)
    if DropSystem:
        DropSystem.drops_collected.connect(_on_drops_collected)
    # ❌ MISSING: add_to_group("wave_manager")
```

**File**: [scenes/ui/hud.gd](../scenes/ui/hud.gd#L56-L59)
```gdscript
# Connect to WaveManager signals for wave timer
var wave_manager = get_tree().get_first_node_in_group("wave_manager")
if wave_manager:  # ❌ This is null!
    wave_manager.wave_started.connect(_on_wave_started)
    wave_manager.wave_completed.connect(_on_wave_completed)
```

### **Fix**:

**Option A** (Recommended): Add WaveManager to group
```gdscript
# scripts/systems/wave_manager.gd line 23
func _ready() -> void:
    add_to_group("wave_manager")  # ✅ ADD THIS

    # Connect to drop collection signal to track collected drops (not generated)
    if DropSystem:
        DropSystem.drops_collected.connect(_on_drops_collected)
```

**Option B**: Connect signals in Wasteland scene
```gdscript
# scenes/game/wasteland.gd after wave_manager initialization
if hud and wave_manager:
    wave_manager.wave_started.connect(hud._on_wave_started)
    wave_manager.wave_completed.connect(hud._on_wave_completed)
```

### **Verification**:
1. Run game and check logs for `"HUD: Wave timer started"` message
2. Observe wave timer counting down from 1:00 → 0:59 → 0:58...
3. Watch timer turn yellow at 0:10, red at 0:05
4. Confirm timer shows "COMPLETE" in green at wave end

### **Files to Modify**:
- `scripts/systems/wave_manager.gd` (add to group in `_ready()`)

---

## 🐛 Bug 2: Enemies Stick to Player & Don't Take Damage

### **Severity**: P0 - Critical (Combat Broken)

### **Evidence**:
- User report: "enemies can get stuck to the player, they don't move off them"
- User report: "the player's weapon never fires upon them"
- Log analysis: Projectiles hit enemies at distance, but no hits when close

### **Root Cause (Hypothesis)**:
When enemies get very close to player (< 10px), TargetingService may be excluding them due to minimum range logic OR weapon auto-targeting skips enemies that are "too close".

**File**: [scripts/autoload/targeting_service.gd](../scripts/autoload/targeting_service.gd) (need to check)

### **Investigation Steps**:
1. Check TargetingService.get_nearest_enemy() for minimum distance filter
2. Check if weapon range has a minimum threshold
3. Add debug logs when enemy distance < 50px to player
4. Test with debug hotkeys to manually cycle weapons when enemy stuck

### **Potential Fixes**:

**Option A**: Remove minimum distance requirement
```gdscript
# targeting_service.gd
func get_nearest_enemy(player_pos: Vector2, max_range: float) -> Enemy:
    var nearest_enemy = null
    var nearest_distance = max_range

    for enemy in living_enemies.values():
        var distance = player_pos.distance_to(enemy.global_position)
        # ❌ REMOVE: if distance < MIN_DISTANCE: continue
        if distance <= max_range and distance < nearest_distance:
            nearest_enemy = enemy
            nearest_distance = distance

    return nearest_enemy
```

**Option B**: Add collision-based targeting fallback
```gdscript
# player.gd or wasteland.gd
# If no enemy in weapon range, check for collision with player Area2D
# Fire at colliding enemy even if outside "range"
```

### **Files to Investigate**:
- `scripts/autoload/targeting_service.gd` (get_nearest_enemy logic)
- `scripts/entities/player.gd` (weapon firing logic)
- `scenes/game/wasteland.gd` (weapon spawn logic)

---

## 🐛 Bug 3: Player Moved Off-Screen

### **Severity**: P0 - Critical (Player Lost)

### **Evidence**:
- User report: "the player moved out off the screen and I couldn't get him back"
- Log line -3: Final weapon fire position `(1046.635, -208.1773)`
- Negative Y (-208) = ~200 pixels ABOVE viewport top
- Positive X (1046) = ~200 pixels RIGHT of viewport edge (assuming 848px width)

### **Root Cause**:
No camera bounds or player position clamping. Player can move infinitely in any direction.

### **Fix**:

**Option A** (Recommended): Clamp player position in _physics_process
```gdscript
# scripts/entities/player.gd in _physics_process after move_and_slide()
func _physics_process(delta: float) -> void:
    # ... existing movement code ...
    move_and_slide()

    # Clamp player position to stay on-screen
    _clamp_to_viewport()

func _clamp_to_viewport() -> void:
    """Keep player within viewport bounds"""
    var viewport_size = get_viewport_rect().size
    var margin = 20.0  # Pixels from edge

    # Clamp X (horizontal)
    global_position.x = clamp(
        global_position.x,
        margin,
        viewport_size.x - margin
    )

    # Clamp Y (vertical)
    global_position.y = clamp(
        global_position.y,
        margin,
        viewport_size.y - margin
    )
```

**Option B**: Use Camera2D limit properties
```gdscript
# scenes/game/wasteland.gd or camera_controller.gd
func _ready() -> void:
    var camera = get_viewport().get_camera_2d()
    if camera:
        # Set camera limits based on level bounds
        camera.limit_left = 0
        camera.limit_top = 0
        camera.limit_right = 1920  # Adjust to level size
        camera.limit_bottom = 1080
```

**Option C**: Add invisible collision walls at screen edges
```gdscript
# Create StaticBody2D walls in wasteland.tscn at viewport edges
# Player collision will naturally prevent moving off-screen
```

### **Recommendation**: Option A (player position clamping)
- Simplest implementation
- Works on any device resolution
- No scene modifications needed
- Prevents player from ever getting lost

### **Files to Modify**:
- `scripts/entities/player.gd` (add `_clamp_to_viewport()` method)

---

## 🐛 Bug 4: Contact Damage Not Working

### **Severity**: P0 - Critical (Combat Feature Missing)

### **Evidence**:
- **ZERO** instances of `"Enemy dealt contact damage"` in entire log file
- Expected: Enemies should deal damage on collision with player
- Actual: Enemies touch player but no damage dealt

### **Root Cause**:
Enemy contact damage system exists in code but is not triggering.

**File**: [scripts/entities/enemy.gd](../scripts/entities/enemy.gd#L124-L135)
```gdscript
# Check for collision with player (contact damage)
if contact_damage_cooldown <= 0:
    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        if collider == player:
            # Deal contact damage to player
            player.take_damage(damage, global_position)
            contact_damage_cooldown = contact_damage_rate
            GameLogger.debug(
                "Enemy dealt contact damage", {"id": enemy_id, "damage": damage}
            )
            break  # Only deal damage once per cooldown period
```

### **Investigation**:
1. Check if `get_slide_collision_count()` returns > 0 when enemy touches player
2. Verify `collision.get_collider()` correctly identifies player
3. Add debug log to print collision count each frame
4. Check if player has correct collision layer/mask

### **Debug Logging**:
```gdscript
# Add to enemy.gd _physics_process temporarily
if player and player.is_alive():
    var distance = global_position.distance_to(player.global_position)
    if distance < 50:  # Very close to player
        print("[Enemy] Near player! Distance: ", distance, " Collisions: ", get_slide_collision_count())
```

### **Potential Fixes**:

**Option A**: Check collision layers
```gdscript
# Verify enemy collision setup in enemy.gd or enemy.tscn
# Enemy should be on layer 2 (enemies)
# Enemy should detect layer 1 (player)
collision_layer = 2  # Enemy layer
collision_mask = 1   # Detect player layer
```

**Option B**: Use Area2D for contact damage instead of slide collisions
```gdscript
# Add Area2D child to enemy for damage detection
# Connect body_entered signal
# More reliable than slide collision detection
```

**Option C**: Add collision shape debug
```gdscript
# Enable collision shape debug in project settings
# Visual confirmation that collision shapes are correct
```

### **Files to Investigate**:
- `scripts/entities/enemy.gd` (contact damage logic)
- `scenes/entities/enemy.tscn` (collision setup)
- `scripts/entities/player.gd` (collision layer/mask)
- `scenes/entities/player.tscn` (collision setup)

---

## ⚠️ Bug 5: UI Text Too Small (UX Issue)

### **Severity**: P1 - High (Usability)

### **Evidence**:
- User report: "the text is hard to read...too small for my weak human eyes"
- Current font sizes likely 12-16pt (default)
- Mobile devices need 18-24pt minimum for readability

### **Fix**:

**Phase 1**: Increase all HUD font sizes
```gdscript
# scenes/ui/hud.tscn
# Update all Label nodes with theme_override_font_sizes/font_size

# HP Bar label: 16pt → 20pt
# XP Bar label: 14pt → 18pt
# Wave label: 16pt → 22pt
# Wave timer: 24pt ✅ (already large)
# Currency labels: 14pt → 18pt
```

**Phase 2**: Create custom theme resource
```
# Create resources/themes/mobile_theme.tres
# Set default font sizes for all Control types
# Apply theme to HUD root node
```

### **Files to Modify**:
- `scenes/ui/hud.tscn` (all Label nodes)
- `scenes/ui/wave_complete_screen.tscn` (if exists)

---

## ⚠️ Bug 6: Health Bar Not Visible Enough

### **Severity**: P1 - High (UX)

### **Evidence**:
- User report: "i need a better visible health bar"
- Current: Likely small ProgressBar at top-left

### **Fixes**:

**Option A** (Quick): Make HP bar larger and more prominent
```gdscript
# scenes/ui/hud.tscn - HPBar node
offset_left = 20.0
offset_top = 20.0
offset_right = 320.0  # ← Increase from ~200
offset_bottom = 50.0  # ← Increase from ~30

# Increase bar height and width
# Add thicker border
```

**Option B**: Add HP number overlay
```gdscript
# Add Label showing "HP: 85/100" on top of bar
# Makes exact HP clear at a glance
```

**Option C**: Add low HP warning
```gdscript
# When HP < 30%, flash red border around screen
# Visual alert that player is in danger
```

**Option D**: All of the above
```gdscript
# Larger bar + HP text + low HP warning
# Best UX for mobile
```

### **Files to Modify**:
- `scenes/ui/hud.tscn` (HPBar size and style)
- `scenes/ui/hud.gd` (low HP warning logic)

---

## 📋 Implementation Order

### **Session 1: Critical Combat Fixes** (30-45 min)
1. ✅ Fix wave timer (add WaveManager to group) - 5 min
2. ✅ Fix player off-screen (add position clamping) - 10 min
3. ✅ Investigate contact damage (debug logs + fix) - 15-20 min
4. ✅ Investigate stuck enemies (targeting service) - 15-20 min

### **Session 2: UI/UX Polish** (20-30 min)
5. ✅ Increase all font sizes - 10 min
6. ✅ Make health bar more visible - 10 min
7. ✅ Add low HP warning - 10 min

---

## 🧪 Testing Checklist

After fixes, verify:

### Wave Timer:
- [ ] Timer counts down from 1:00 → 0:00
- [ ] Timer turns yellow at < 10s
- [ ] Timer turns red at < 5s
- [ ] Timer shows "COMPLETE" at wave end
- [ ] Log shows `"HUD: Wave timer started"` each wave

### Player Bounds:
- [ ] Player cannot move off top edge
- [ ] Player cannot move off bottom edge
- [ ] Player cannot move off left edge
- [ ] Player cannot move off right edge
- [ ] Player position never negative
- [ ] Player position never > viewport size

### Contact Damage:
- [ ] Log shows `"Enemy dealt contact damage"` when enemy touches player
- [ ] Player HP decreases when enemy collides
- [ ] Contact damage has 1s cooldown (not constant damage)
- [ ] Camera shakes on player damage

### Enemy Targeting:
- [ ] Weapons fire at enemies even when very close (< 50px)
- [ ] Stuck enemies take damage from projectiles
- [ ] No enemies permanently stuck to player

### UI Readability:
- [ ] All text readable on device at arm's length
- [ ] HP bar clearly shows current/max HP
- [ ] Low HP warning triggers at < 30% HP

---

## 🔧 Code Changes Summary

### Files to Modify:
1. `scripts/systems/wave_manager.gd` - Add to group
2. `scripts/entities/player.gd` - Add position clamping
3. `scripts/entities/enemy.gd` - Debug + fix contact damage
4. `scripts/autoload/targeting_service.gd` - Fix close-range targeting
5. `scenes/ui/hud.tscn` - Increase font sizes
6. `scenes/ui/hud.gd` - Add low HP warning

### Estimated Total Time:
- Investigation: 15-20 min
- Fixes: 30-40 min
- Testing: 15-20 min
- **Total**: 60-80 minutes

---

## 📝 Notes for Next Session

### Log Analysis Tools Used:
```bash
# Search for errors
grep -i "ERROR\|WARNING\|Invalid" runnable.log

# Search for wave timer
grep -i "wave_timer\|wave_started\|_process" runnable.log

# Search for contact damage
grep -i "contact damage\|enemy dealt" runnable.log

# Search for player damage
grep -i "player.*damage\|health.*changed" runnable.log
```

### Key Log Insights:
- WaveManager emits signals correctly ✅
- HUD never connects to WaveManager ❌
- Zero contact damage events ❌
- Player position went negative (off-screen) ❌
- Projectile damage working perfectly ✅
- Drop collection working perfectly ✅
- XP tracking working (post-Phase 2 fix) ✅
- Damage tracking working (post-Phase 2 fix) ✅

### Good News:
- Core gameplay loop works well
- Pickup magnet system working
- Drop collection smooth
- XP progression functional
- Weapon firing reliable
- Wave progression working

### Only Issues:
- HUD timer not connected
- Player can escape viewport
- Contact damage not triggering
- Close-range targeting issue
- UI scaling for mobile

**All issues are fixable in < 1 hour!** 🎯

---

## 🎮 Manual QA Feedback Summary

From user testing session:

### What Worked:
✅ Pickup magnets feel great
✅ Joystick works well overall
✅ Combat feels satisfying
✅ Weapon variety is fun
✅ Drop collection smooth

### What Broke:
❌ Wave timer static (doesn't count down)
❌ Enemies stick to player
❌ Player went off-screen
❌ Contact damage not working

### UX Improvements Needed:
⚠️ Text too small
⚠️ Health bar not prominent enough
⚠️ Need better visual feedback for low HP

---

**End of Plan**

**Next Steps**:
1. Start fresh session with full token budget
2. Follow implementation order above
3. Fix P0 bugs first (combat blockers)
4. Then polish UI/UX
5. Test thoroughly on device
6. Push fixes and update documentation
