# Performance Diagnostic Testing Plan

**Created**: 2025-11-19 @ 00:45 PST
**Purpose**: Isolate root cause of performance regression through systematic testing
**Context**: Session 6 Extended - Performance issue persists even after reverting to e28f0ee

---

## 🎯 Testing Objective

Determine whether the performance issue is caused by:
1. **Code changes** between commits
2. **Build/export process** artifacts
3. **Environmental factors** (Godot editor cache, iOS build cache, etc.)

---

## 📊 Test Matrix

### Branch Setup

| Branch Name | Base Commit | Description | Code State |
|-------------|-------------|-------------|------------|
| `test/performance-diagnostic-7acc9e0` | 7acc9e0 (20:44) | Baseline test | Stats fix + typography |
| `feature/week16-mobile-ui` | 4635c4f (current) | Latest corrected revert | e28f0ee state (with 8021f01 fixes) |

### Commit Timeline Reference

```
20:44 - 7acc9e0  (fix: stats race condition + typography)
           ↓
20:46 - cf54e8c  (docs: updated recovery plan)
           ↓
21:10 - 8021f01  (fix: await stats + XP bar height)  ← KEY CHANGES
           ↓
21:34 - e28f0ee  (docs: session 3 results) ← USER'S LAST KNOWN-GOOD
           ↓
22:17 - 516363e  (Performance bug introduced)
```

---

## 🧪 Test Procedure

### Test #1: Baseline from 7acc9e0

**Branch**: `test/performance-diagnostic-7acc9e0` (current)

**Steps**:
1. ✅ **Verify branch state**
   ```bash
   git log --oneline -1
   # Should show: 7acc9e0 fix: resolve character details stats race condition
   ```

2. 🔨 **Clean export**
   - Open project in Godot 4.5.1
   - **IMPORTANT**: Close and reopen Godot (clear editor cache)
   - Project → Export → iOS
   - Export to fresh location: `builds/test-7acc9e0.ipa`

3. 📱 **Device testing** (iPhone 15 Pro Max)
   - Delete any existing app version
   - Install fresh IPA
   - Test sequence:
     - App launch time
     - Navigation to character creation
     - Keyboard typing responsiveness
     - Button tap responsiveness
     - Character roster → Details button
     - Stats display appearance

4. 📝 **Record results**
   - Performance: ⚡ Fast / ⚠️ Slow / 🚨 Unusable
   - Keyboard: Responsive / Laggy / Unusable
   - Stats display: ✅ Visible / ❌ Empty
   - Grey screen: Yes / No / Duration: ___s
   - Device log: Save to `qa/logs/2025-11-19/test-7acc9e0.log`

**Expected Result**:
- If user's memory is correct, this should have **better performance** than e28f0ee revert
- But it should have **empty stats** or **race condition issues** (fixed in 8021f01)

---

### Test #2: Apply 8021f01 Changes Incrementally

**Purpose**: Determine which specific change (if any) affects performance

**Branch**: `test/performance-diagnostic-7acc9e0` (modify in place)

#### Test 2a: Add XP bar height change only

**Change**:
```diff
// scenes/ui/hud.tscn
- custom_minimum_size = Vector2(300, 35)
+ custom_minimum_size = Vector2(300, 45)
(plus label offset adjustments)
```

**Export**: `builds/test-7acc9e0-xpbar.ipa`
**Record**: Performance impact of XP bar height change

#### Test 2b: Add debug logging only

**Change**:
```gdscript
// character_details_panel.gd:93
+ GameLogger.info("[CharacterDetailsPanel] Populating stats", {"stats_count": stats.size()})
```

**Export**: `builds/test-7acc9e0-logging.ipa`
**Record**: Performance impact of debug logging

#### Test 2c: Add await fix only

**Change**:
```gdscript
// character_roster.gd:202
- character_details_panel.show_character(character)
+ await character_details_panel.show_character(character)
```

**Export**: `builds/test-7acc9e0-await.ipa`
**Record**: Performance impact of await (this is the critical one!)

#### Test 2d: All changes together (e28f0ee state)

**Changes**: All of the above combined
**Export**: `builds/test-7acc9e0-complete.ipa`
**Record**: Should match current `feature/week16-mobile-ui` branch behavior

---

### Test #3: Compare with feature branch

**Branch**: `feature/week16-mobile-ui`

**Steps**:
1. Switch back to main feature branch
   ```bash
   git checkout feature/week16-mobile-ui
   ```

2. **Clean export**
   - Close and reopen Godot (clear editor cache)
   - Export to: `builds/test-current-HEAD.ipa`

3. **Device testing** - Same sequence as Test #1

4. **Compare results**
   - Should be identical to Test 2d (all changes)
   - If different → environmental issue, not code issue

---

## 📋 Results Template

### Test Results Table

| Test | Commit/Changes | Launch | Keyboard | Stats | Grey Screen | Overall |
|------|----------------|--------|----------|-------|-------------|---------|
| #1 Baseline | 7acc9e0 | ⚡/⚠️/🚨 | ⚡/⚠️/🚨 | ✅/❌ | Y/N (___s) | ⚡/⚠️/🚨 |
| #2a XP bar | +XP height | | | | | |
| #2b Logging | +Debug log | | | | | |
| #2c Await | +await fix | | | | | |
| #2d Complete | All changes | | | | | |
| #3 Current | 4635c4f | | | | | |

Legend:
- ⚡ = Fast/Instant (< 1s)
- ⚠️ = Slow but usable (1-3s)
- 🚨 = Unusable (> 3s or extreme lag)
- Y/N = Yes/No for grey screen
- ✅/❌ = Stats visible/empty

---

## 🔬 Hypothesis Testing

### Hypothesis 1: The `await` causes performance issues

**Test**: Compare Test #1 vs Test #2c

**If true**:
- Test #1 (7acc9e0 without await) = Fast ⚡
- Test #2c (7acc9e0 with await) = Slow 🚨
- **Conclusion**: `await` blocking UI thread, need different async approach

**If false**:
- Both tests perform similarly
- **Conclusion**: `await` is not the culprit

---

### Hypothesis 2: The issue is environmental (not in code)

**Test**: Compare Test #2d vs Test #3

**If true**:
- Test #2d (incremental changes) = Fast ⚡
- Test #3 (current HEAD) = Slow 🚨
- Different despite identical code
- **Conclusion**: Godot editor cache, build artifacts, or export settings causing issue

**If false**:
- Both tests perform identically
- **Conclusion**: Issue is deterministic and in code

---

### Hypothesis 3: Multiple changes compound the issue

**Test**: Compare individual tests #2a, #2b, #2c vs combined #2d

**If true**:
- Each individual change = Fast ⚡
- Combined changes = Slow 🚨
- **Conclusion**: Interaction between changes causes performance degradation

**If false**:
- One specific change causes slowdown, others don't
- **Conclusion**: Identify and isolate the problematic change

---

## 🚀 Next Steps Based on Results

### Scenario A: 7acc9e0 is fast, e28f0ee is slow
→ The changes in 8021f01 ARE the problem
→ Need to revert those changes and find alternative fixes
→ Focus on the `await` - it's the most likely culprit

### Scenario B: Both 7acc9e0 and e28f0ee are slow
→ The issue exists BEFORE e28f0ee (user's memory incorrect)
→ Need to go back further in history
→ Test commit b3d8bf5 or earlier

### Scenario C: All incremental tests are fast, only full e28f0ee is slow
→ Environmental/build issue, not code
→ Clear all Godot caches: `.godot/`, `builds/`, iOS DerivedData
→ Re-export from clean state

### Scenario D: All tests are fast (can't reproduce issue)
→ Issue was transient or already fixed
→ User should test current HEAD and confirm
→ If still slow on user's device → investigate user's environment

---

## 📁 File Locations

**Test Branch**: `test/performance-diagnostic-7acc9e0`
**Feature Branch**: `feature/week16-mobile-ui`
**Export Builds**: `builds/test-*.ipa`
**Device Logs**: `qa/logs/2025-11-19/test-*.log`
**Results**: Update this document or recovery plan with findings

---

## ⚠️ Important Notes

1. **Always close and reopen Godot** between exports to clear editor cache
2. **Always delete old app** before installing new IPA on device
3. **Save device logs** for every test (even if performance seems fine)
4. **Test each build thoroughly** - don't rush, we need accurate data
5. **Document EVERYTHING** - timestamps, exact symptoms, duration of issues

---

**Status**: ✅ Ready for testing
**Current Branch**: `test/performance-diagnostic-7acc9e0`
**Baseline Commit**: `7acc9e0`
**Tester**: User (Alan)
**Expected Duration**: 2-3 hours for complete test matrix
