# Critical Fixes Plan - iOS TestFlight Preparation

**Created**: 2025-01-11
**Status**: Ready for Implementation
**Estimated Time**: 2-3 hours

---

## 🔴 P0 - CRITICAL (Must Fix Before TestFlight)

### P0.1: Fix Physics Race Conditions in Projectile System

**Issue**: Modifying physics state during collision callbacks causes crashes on iOS.

**Location**: `scripts/entities/projectile.gd`

**Current Code** (Line 221, 261, 291):
```gdscript
func deactivate() -> void:
    collision_area.set_monitoring(false)  # ❌ Immediate change during physics callback
    # ...

func hit_enemy(...) -> void:
    # ...
    deactivate()  # ❌ Called during _on_body_entered signal

func _on_body_entered(body: Node2D) -> void:
    hit_enemy(...)  # ❌ Triggers deactivate() during physics flush
```

**Fix Required**:
```gdscript
func deactivate() -> void:
    # Defer physics state changes to next frame
    if collision_area:
        collision_area.set_deferred("monitoring", false)
        collision_area.set_deferred("monitorable", false)

    # Mark as inactive immediately (safe)
    is_active = false

    # Defer queue_free to avoid double-free
    call_deferred("queue_free")

func hit_enemy(...) -> void:
    # Pierce logic...

    if pierce_count <= 0 or was_killed:
        # Don't call deactivate() directly - defer it
        call_deferred("deactivate")
```

**Files to Modify**:
- `scripts/entities/projectile.gd` - Lines 221, 274-291

**Test**:
1. Play 5 waves, rapid fire weapons
2. Kill 50+ enemies quickly
3. Monitor console for physics errors
4. Should see ZERO "Function blocked during in/out signal" errors

---

### P0.2: Fix Physics Race Conditions in Drop System

**Issue**: Spawning drop pickups during collision modifies Area2D monitoring state.

**Location**: `scripts/systems/drop_system.gd`

**Current Code** (Line 193):
```gdscript
func spawn_drop_pickups(...) -> void:
    # ...
    pickup.set_monitoring(false)  # ❌ Immediate during physics callback
    drops_container.add_child(pickup)
```

**Fix Required**:
```gdscript
func spawn_drop_pickups(...) -> void:
    # ...

    # Defer monitoring state change
    pickup.set_deferred("monitoring", false)

    # Safe to add child immediately
    drops_container.add_child(pickup)

    # Position and setup are safe (not physics state)
    pickup.global_position = random_offset_position
    # ...
```

**Alternative Fix** (cleaner):
```gdscript
# In drop_pickup.gd:202
func setup(...) -> void:
    # Don't disable monitoring in setup - let _ready() handle it
    # Remove: collision_area.set_monitoring(false)

func _ready() -> void:
    # Monitoring already disabled in scene, so this is safe
    # Or use: call_deferred("_setup_collision")

func _setup_collision() -> void:
    collision_area.set_monitoring(false)
```

**Files to Modify**:
- `scripts/systems/drop_system.gd` - Line 193
- `scripts/entities/drop_pickup.gd` - Line 202

**Test**:
1. Kill 20+ enemies with drops
2. Collect drops during combat
3. Monitor console for "Can't change this state while flushing queries"
4. Should see ZERO errors

---

### P0.3: Wave Input Re-enable (Already Fixed)

**Status**: ✅ COMPLETED (commit pending)

**Files Modified**:
- `scenes/game/wasteland.gd` - Added `_on_wave_started()` handler

**Test**:
1. Complete Wave 1
2. Click "Next Wave"
3. Verify joystick works on Wave 2+

---

## 🟡 P1 - HIGH PRIORITY (App Store Rejection Risk)

### P1.1: Add CoreMotion Privacy Description

**Issue**: App accessing motion sensors without privacy declaration.

**Location**: iOS export configuration

**Fix Required**:

**Option A** - Disable Motion (if not needed):
1. Open Godot → Project → Export → iOS
2. Find "Required Device Capabilities"
3. Remove "accelerometer" and "gyroscope" if present

**Option B** - Add Privacy Declaration (if needed):
1. In Godot export settings, add Custom Info.plist entry:
   ```xml
   <key>NSMotionUsageDescription</key>
   <string>Scrap Survivor uses device motion for enhanced gameplay controls</string>
   ```

**Recommended**: Option A (disable) - game doesn't use device motion.

**Files to Modify**:
- `export_presets.cfg` (via Godot Editor)

**Test**:
1. Export to iOS
2. Check Xcode project `Info.plist`
3. Should NOT see CoreMotion permission errors in device logs

---

### P1.2: Fix Signal Double-Connection

**Issue**: Signals connected multiple times causing duplicate callbacks.

**Location**: `scripts/ui/character_selection.gd`

**Current Code** (Lines 204, 206):
```gdscript
func _connect_signals() -> void:
    create_button.pressed.connect(_on_create_character_pressed)  # ❌ May already be connected
    back_button.pressed.connect(_on_back_pressed)  # ❌ May already be connected
```

**Fix Required**:
```gdscript
func _connect_signals() -> void:
    # Only connect if not already connected
    if not create_button.is_connected("pressed", _on_create_character_pressed):
        create_button.pressed.connect(_on_create_character_pressed)

    if not back_button.is_connected("pressed", _on_back_pressed):
        back_button.pressed.connect(_on_back_pressed)
```

**Files to Modify**:
- `scripts/ui/character_selection.gd` - Lines 204-206

**Test**:
1. Navigate to character selection
2. Create character
3. Go back, return to selection screen
4. Console should show ZERO "Signal already connected" errors

---

### P1.3: Monitor UIScene Lifecycle Warning

**Issue**: iOS 13+ SceneDelegate architecture not adopted.

**Status**: 🔶 GODOT ENGINE ISSUE

**Action Required**:
1. File Godot bug: https://github.com/godotengine/godot/issues
2. Monitor for Godot 4.5.2+ release
3. Add to project notes: "Known Godot limitation - tracked upstream"

**Risk Assessment**:
- Low immediate risk (warning only)
- Medium future risk (may cause crashes in iOS 18+)
- App Review: May ask questions, respond with "Godot engine limitation, tracking fix"

**No code changes required** - engine-level issue.

---

## 🟢 P2 - MEDIUM PRIORITY (Code Quality)

### P2.1: Fix Unused Shader Variables

**Status**: 🔶 GODOT ENGINE ISSUE

**Action**: None (Metal compiler optimization handles it)

**Impact**: Negligible performance impact, engine-level issue

---

### P2.2: Add Crash Analytics

**Recommendation**: Add Sentry or Firebase Crashlytics before TestFlight.

**Location**: New integration

**Why**: Catch physics crashes in production that may not appear in dev.

**Implementation** (Optional):
1. Add Sentry GDNative plugin
2. Initialize in `game_logger.gd`
3. Wrap physics callbacks in try/catch logging

**Priority**: OPTIONAL but highly recommended for TestFlight beta.

---

## 📋 Implementation Checklist

### Session Setup
```bash
# Start fresh terminal session
cd /Users/alan/Developer/scrap-survivor-godot

# Ensure Godot is closed
pgrep -f Godot && echo "⚠️  Close Godot first!"

# Pull latest changes (if working in team)
git status
```

### Fix Order (Recommended)
1. ✅ **P0.1**: Fix projectile physics deferred calls (15 min)
2. ✅ **P0.2**: Fix drop system physics deferred calls (10 min)
3. ✅ **P0.3**: Verify wave input fix (already done)
4. ✅ **P1.1**: Disable CoreMotion or add privacy string (5 min)
5. ✅ **P1.2**: Fix signal double-connection (5 min)
6. ✅ **Run full test suite** (2 min)
7. ✅ **Commit all fixes** (2 min)
8. ✅ **Test on device** (15 min)

**Total Estimated Time**: ~1 hour

### Testing Protocol

**Automated Tests**:
```bash
python3 .system/validators/godot_test_runner.py
```

**Device Testing** (Critical):
1. Export to iOS device
2. Run for 10+ minutes
3. Complete 5+ waves
4. Collect 50+ drops
5. Monitor Xcode console for errors
6. Check memory usage (should be < 250MB)

**Success Criteria**:
- ✅ ZERO physics errors in console
- ✅ ZERO signal double-connection errors
- ✅ ZERO CoreMotion permission errors
- ✅ Wave transitions work smoothly
- ✅ Joystick functional on all waves
- ✅ No crashes during 10-minute session

---

## 🚀 Post-Fix: TestFlight Preparation

### Before Upload:
1. ✅ All P0 and P1 fixes merged
2. ✅ Full test suite passing
3. ✅ Device testing complete (10+ min session)
4. ✅ Memory profiling done (no leaks)
5. ✅ Build number incremented

### TestFlight Checklist:
```
[ ] Xcode Archive successful
[ ] No warnings in Archive
[ ] TestFlight beta info filled out
[ ] External testing enabled
[ ] Beta tester group created
[ ] Release notes written
[ ] Upload to App Store Connect
[ ] Processing complete (wait 15-30 min)
[ ] Invite testers
```

### Known Limitations to Document:
1. **UIScene lifecycle**: Godot engine limitation (tracked upstream)
2. **Shader warnings**: Godot engine cosmetic issue (no impact)

---

## 📞 Support Resources

### If Tests Fail:
1. Check `test_results.xml` for specific failures
2. Run individual test file: `godot --headless -s addons/gut/run_tests.gd -d tests/path/to/test.gd`
3. Review Godot logs: `~/Library/Application Support/Godot/app_userdata/Scrap Survivor/logs/`

### If Device Crashes:
1. Connect device to Mac
2. Open Xcode → Window → Devices and Simulators
3. Select device → View Device Logs
4. Find crash log, export as `.crash` file
5. Symbolicate with Xcode or share for analysis

### Pre-Commit Hook Blocked:
```bash
# If blocked by tests:
python3 .system/validators/godot_test_runner.py  # See which test failed

# If blocked by linting:
gdlint path/to/file.gd
gdformat path/to/file.gd

# NEVER use --no-verify (per requirements)
```

---

## 🎯 Success Metrics

**Definition of Done**:
- All P0 fixes implemented ✅
- All P1 fixes implemented ✅
- 449/473 tests passing (or more) ✅
- Zero console errors during 10-minute device session ✅
- Ready for TestFlight upload ✅

**Estimated Total Time**: 1-2 hours (including testing)

**Risk Level**: LOW (well-defined fixes, clear test criteria)

---

## 📝 Notes for Next Session

**Context to Provide**:
> "I need to fix critical iOS physics crashes and App Store rejection risks identified in runtime logs. The plan is in docs/CRITICAL-FIXES-PLAN.md. Start with P0.1 (projectile deferred physics calls)."

**Files You'll Need Open**:
1. `scripts/entities/projectile.gd`
2. `scripts/systems/drop_system.gd`
3. `scripts/entities/drop_pickup.gd`
4. `scripts/ui/character_selection.gd`
5. `scenes/game/wasteland.gd` (verify P0.3 fix)

**Commands You'll Run**:
```bash
# Code quality
gdlint scripts/entities/projectile.gd
gdformat scripts/entities/projectile.gd

# Testing
python3 .system/validators/godot_test_runner.py

# Commit
git add <files>
git commit -m "fix: resolve iOS physics crashes and App Store rejection risks"
```

Good luck! 🚀
