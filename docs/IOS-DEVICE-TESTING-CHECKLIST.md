# iOS Device Testing Checklist - Critical Fixes Validation

**Date**: 2025-01-11
**Fixes**: P0.1, P0.2, P0.3, P1.2
**Commits**: `51ca2ee`, `57eb52e`

---

## 🔧 Pre-Test Setup

### 1. Clean Installation
- [ ] Delete existing app from iPhone (long-press → Remove App → Delete App)
- [ ] Clear any crash logs: Settings → Privacy & Security → Analytics & Improvements
- [ ] Ensure iPhone has at least 1GB free storage

### 2. Xcode Console Setup
- [ ] Connect iPhone to Mac via USB
- [ ] Open Xcode → Window → Devices and Simulators
- [ ] Select your iPhone
- [ ] Click "Open Console" button
- [ ] Filter by your app name (type "Scrap" in search box)
- [ ] Clear console log (CMD+K)

### 3. Deploy Fresh Build
- [ ] In Godot: Project → Export → iOS → Export Project
- [ ] Open exported Xcode project
- [ ] Build and Run to iPhone (CMD+R)
- [ ] Wait for app to launch on device

---

## 🎮 Gameplay Testing (10 Minutes Minimum)

### Wave 1-2: Basic Functionality
**Duration**: 3-5 minutes

- [ ] **Character Selection Works**
  - Select character type
  - Click "Create" button
  - NO "Signal already connected" errors in console ✅

- [ ] **Wave 1 Gameplay**
  - Use virtual joystick to move
  - Kill at least 10 enemies
  - Collect at least 5 drops (scrap/components)
  - Fire weapon continuously (rapid fire test)

- [ ] **Wave 1 → Wave 2 Transition**
  - Complete Wave 1
  - Click "Next Wave" button
  - **CRITICAL**: Virtual joystick still works on Wave 2 ✅
  - Player can move immediately

### Wave 2-5: Physics Stress Test
**Duration**: 5-7 minutes

- [ ] **High-Intensity Combat** (Each Wave)
  - Kill 20+ enemies per wave
  - Rapid fire weapons constantly
  - Collect 10+ drops per wave
  - Move around while fighting

- [ ] **Wave Transitions** (Repeat 3x)
  - Complete wave
  - "Next Wave" button works
  - Joystick persists across transitions
  - No input lag

### Extreme Stress Test (Optional but Recommended)
**Duration**: 5+ minutes

- [ ] Play until Wave 5+
- [ ] Kill 50+ enemies in a single wave
- [ ] Collect 30+ drops without pausing
- [ ] Use multiple weapon types if available

---

## 🚨 Critical Error Monitoring

### Physics Errors (MUST BE ZERO)
Monitor Xcode console for these errors:

#### ❌ P0.1 Projectile Errors (Should NOT appear):
```
Function blocked during in/out signal
Can't change monitoring state during flush
queue_free blocked during physics callback
```

#### ❌ P0.2 Drop System Errors (Should NOT appear):
```
Can't change this state while flushing queries
Area2D monitoring state change blocked
```

#### ❌ P1.2 Signal Errors (Should NOT appear):
```
Signal 'pressed' is already connected
Attempting to connect already-connected signal
```

### ✅ Success Indicators (Should appear):
```
[DropPickup] Collision configured: layer=8, mask=1
[Projectile] Pierce count exceeded, deactivating
Wave X started
Player movement/input re-enabled
```

---

## 📊 Performance Monitoring

### Memory Usage
- [ ] Open Xcode → Debug Navigator → Memory (while app running)
- [ ] **Baseline** (main menu): Record value: ___________ MB
- [ ] **Wave 1**: Record value: ___________ MB
- [ ] **Wave 3**: Record value: ___________ MB
- [ ] **Wave 5**: Record value: ___________ MB
- [ ] **Target**: Should stay under 250 MB
- [ ] **Memory Growth**: Should NOT increase >50MB per wave

### Frame Rate
- [ ] Xcode → Debug Navigator → FPS
- [ ] **Target**: 60 FPS (or 30 FPS consistently)
- [ ] **Wave 1-2**: No frame drops during combat
- [ ] **Wave 3-5**: Occasional drops OK, but not sustained

### Crash Detection
- [ ] App does NOT crash during 10-minute session ✅
- [ ] No unexpected app exits
- [ ] No freeze/hang requiring force quit

---

## ✅ Success Criteria Summary

### PASS Requirements (All Must Be True):
1. ✅ **ZERO** "Function blocked during in/out signal" errors
2. ✅ **ZERO** "Can't change this state while flushing queries" errors
3. ✅ **ZERO** "Signal already connected" errors
4. ✅ Virtual joystick works on Wave 2+ (P0.3 fix verified)
5. ✅ No crashes during 10-minute session
6. ✅ Memory usage < 250 MB
7. ✅ Drops can be collected during combat
8. ✅ Projectiles hit enemies without errors

### FAIL Triggers (Any One = Need More Fixes):
- ❌ ANY physics-related console errors
- ❌ App crashes during gameplay
- ❌ Virtual joystick stops working after wave transition
- ❌ Memory usage > 300 MB or continuously growing
- ❌ Sustained FPS < 20 for more than 10 seconds

---

## 📝 Test Results Log

**Tester**: ____________________
**Date**: ____________________
**Build Version**: ____________________
**iPhone Model**: ____________________
**iOS Version**: ____________________

### Console Errors Encountered:
```
(Paste any errors here, or write "NONE")




```

### Performance Measurements:
- Max Memory Usage: ___________ MB
- Lowest FPS Observed: ___________ FPS
- Total Session Duration: ___________ minutes
- Waves Completed: ___________
- Total Enemies Killed: ___________
- Total Drops Collected: ___________

### Issues Found:
- [ ] NONE - All tests passed ✅
- [ ] Physics errors (describe):
- [ ] Crashes (when):
- [ ] Performance issues (where):
- [ ] Input issues (describe):
- [ ] Other:

---

## 🐛 If Tests Fail

### 1. Collect Crash Logs
- Xcode → Window → Devices and Simulators
- Select iPhone → View Device Logs
- Find latest crash → Right-click → Export
- Save as `crash_YYYY-MM-DD.crash`

### 2. Console Log Export
- In Xcode console, right-click → Save Console Output
- Save as `console_log_YYYY-MM-DD.txt`

### 3. Report Back
Provide:
- Which test step failed
- Full error message from console
- What you were doing when it failed
- Crash log (if app crashed)
- Console log export

### 4. Rollback Steps (If Needed)
```bash
# Revert to previous commit
git log --oneline  # Find commit before fixes
git checkout <commit-hash>

# Rebuild and test
```

---

## ✅ After Successful Test

### 1. Document Results
- [ ] Fill out "Test Results Log" section above
- [ ] Take screenshot of Xcode console showing ZERO errors
- [ ] Record final memory usage

### 2. Mark Ready for TestFlight
- [ ] All pass criteria met
- [ ] No critical errors in 10-minute session
- [ ] Performance acceptable (FPS, memory)
- [ ] Ready to proceed with TestFlight upload

### 3. Optional: Extended Soak Test
- [ ] Play for 30+ minutes
- [ ] Complete 10+ waves
- [ ] Monitor for memory leaks (memory should plateau, not grow linearly)

---

## 📞 Quick Reference

**What's Fixed**:
- P0.1: Projectile physics crashes → Deferred calls
- P0.2: Drop spawn crashes → Deferred collision setup
- P0.3: Wave joystick persistence → Input re-enable
- P1.2: Signal double-connection → Connection guards

**What to Watch For**:
1. Console errors (should be ZERO)
2. Crashes (should be ZERO)
3. Joystick after wave transition (should WORK)
4. Memory usage (should be < 250 MB)

**Expected Outcome**:
Smooth gameplay, zero physics errors, game runs for 10+ minutes without issues.

---

**Good luck with testing! 🚀**

If all tests pass, you're ready for TestFlight deployment.
