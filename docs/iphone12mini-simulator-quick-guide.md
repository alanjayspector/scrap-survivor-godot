# iPhone 12 mini Simulator - Quick Start Guide

**Device**: iPhone 12 mini (5.4" display, smallest supported device)
**Purpose**: Week 16 Phase 3.5 - Validate typography on compact screen
**Time**: 10-15 minutes

---

## Why iPhone 12 mini?

After expert consultation, we decided to support **iPhone 12+ (iOS 15+)**:
- ✅ Industry standard (5-year device support)
- ✅ 88% market coverage
- ✅ Optimal quality vs effort balance

**iPhone 12 mini** is the **smallest device** in our support matrix (5.4" display), making it the perfect test for compact screen constraints.

---

## Quick Steps

### 1. Open Xcode and Launch Simulator

**Option A: Via Xcode Menu**
1. Open Xcode
2. Menu: **Window → Devices and Simulators** (or `Cmd+Shift+2`)
3. Click **"Simulators"** tab
4. Find **"iPhone 12 mini"** in the list (left side)
5. Right-click → **"Boot"**
6. Simulator window opens

**Option B: Via Xcode Top Bar**
1. Open Xcode
2. Top toolbar: Click the device dropdown (middle-ish)
3. Select **"iPhone 12 mini"** from list
4. Simulator boots automatically

**What you'll see**: iPhone 12 mini simulator window (smaller than your iPhone 15 Pro Max)

---

### 2. Check for iPhone 12 mini Simulator

**If you SEE "iPhone 12 mini"**:
- ✅ Great! Proceed to step 3

**If you DON'T see it**:
Download it (one-time setup):
1. Xcode → **Settings** (or `Cmd+,`)
2. Click **"Platforms"** tab
3. Find **iOS** section
4. Click **"+"** or **"Get"**
5. Download latest iOS runtime (~10-15 min)
6. After download, iPhone 12 mini appears in simulator list

---

### 3. Export Game from Godot

1. Open Godot project: `/Users/alan/Developer/scrap-survivor-godot/project.godot`
2. Menu: **Project → Export**
3. Look for **"iOS"** preset (should already exist from before)
4. If no iOS preset:
   - Click **"Add..."** → Select **"iOS"**
   - Set Bundle Identifier: `com.test.scrapsurvivor`
5. Click **"Export Project"** button
6. Save to: `builds/ios/scrap-survivor.xcodeproj` (or create `builds/ios/` folder first)
7. Wait for export (30 sec - 2 min)

---

### 4. Open in Xcode and Select iPhone 12 mini

1. Navigate to `builds/ios/` folder
2. Double-click **`scrap-survivor.xcodeproj`**
3. Xcode opens your game project
4. **Top toolbar**: Find device dropdown (shows current target)
5. Click dropdown → Select **"iPhone 12 mini"**
6. Dropdown should now show "iPhone 12 mini"

**Visual**:
```
[Stop ■] [Play ▶] | scrap-survivor > [iPhone 12 mini ▼] | My Mac
                                        ^
                                    Click here!
```

---

### 5. Build and Run

1. Click **▶️ Play button** (top-left) or press `Cmd+R`
2. Xcode builds game (1-3 minutes first time)
3. Watch progress: "Building..." at top
4. Game launches automatically in iPhone 12 mini simulator

**What you'll see**: Your game running in the iPhone 12 mini simulator window!

---

### 6. Navigate to Character Selection

1. In simulator: Click through menus (click = tap)
2. Main Menu → Character Selection
3. View character cards

**Compare to your iPhone 15 Pro Max**:
- iPhone 12 mini: 5.4" display (compact)
- iPhone 15 Pro Max: 6.7" display (large)
- Text should still be readable and prominent on smaller screen!

---

### 7. Validate Character Cards

**Check these items** (from validation guide):

✅ **All text readable on 5.4" display**
- Can you read stats without squinting?
- Character names clear?
- Description text legible?

✅ **No text wrapping or overflow**
- Does any text get cut off?
- Does any text wrap to multiple lines unexpectedly?

✅ **Stats remain prominent on compact screen**
- Are stats (16pt) still the primary focus?
- Visual hierarchy still clear: Name > Stats > Desc > Aura?

✅ **Cards don't feel cluttered**
- Does the smaller screen make cards feel cramped?
- Is there still breathing room?

✅ **Overall impression: "Feels good on compact device"**
- Would you be happy playing on iPhone 12 mini?
- Any layout issues or concerns?

---

### 8. Take Screenshots

**While simulator is active:**
1. Press `Cmd+S` (in simulator window)
2. Screenshot saves to **Desktop**
3. File name: `Simulator Screen Shot - iPhone 12 mini - 2025-11-22 at XX.XX.XX.png`

**Take screenshots of**:
- Character selection screen (full view)
- Individual character card (close-up)
- Any problem areas (if found)

---

### 9. Report Findings

**Answer these questions**:

1. **Text readable?** Yes / No / Concerns: ___
2. **Text overflow?** Yes (problem!) / No (good!)
3. **Stats prominent?** Yes / No / Less than iPhone 15 Pro Max?
4. **Cards cluttered?** Yes (problem!) / No (good!)
5. **Overall verdict**: PASS / FAIL / NEEDS_TWEAKING

**Expected result**: Should PASS! Typography should look good on both large (6.7") and compact (5.4") devices.

---

## Troubleshooting

### "iPhone 12 mini not in list"
→ Download iOS runtime (Xcode → Settings → Platforms → Get iOS)

### "Simulator won't boot"
→ Quit and reopen Xcode, try again

### "Build failed"
→ Clean build: `Cmd+Shift+K`, then build again: `Cmd+R`

### "Black screen in simulator"
→ Wait 10-20 seconds (loading), check Xcode console for errors

---

## After Testing

1. **Fill out validation report**: [week16-phase3.5-validation-report.md](week16-phase3.5-validation-report.md)
2. **Update iPhone 12 mini section** with your findings
3. **Let me know results**:
   - ✅ PASS: Typography works on both devices → Phase 3.5 complete!
   - ❌ FAIL: Issues found → We'll fix and retest

---

## Simulator Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Screenshot | `Cmd+S` |
| Home button | `Cmd+Shift+H` |
| Lock screen | `Cmd+L` |
| Rotate device | `Cmd+←` or `Cmd+→` |
| Quit simulator | `Cmd+Q` |

---

## What Success Looks Like

✅ iPhone 12 mini simulator running
✅ Your game launched in simulator
✅ Character selection screen visible
✅ All text readable (no overflow, no wrapping)
✅ Stats prominent (visual hierarchy clear)
✅ Screenshots taken
✅ Validation report filled out

**Then**: Phase 3.5 COMPLETE! 🎉

---

**Created**: 2025-11-22
**Device**: iPhone 12 mini (5.4", smallest supported)
**Purpose**: Validate compact screen typography (Week 16 Phase 3.5)
