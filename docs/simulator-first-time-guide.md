# iPhone 8 Simulator - First Time User Guide

**For**: Week 16 Phase 3.5 - Character Selection Testing
**Experience Level**: Beginner-friendly
**Estimated Time**: 10-15 minutes

---

## What is the iOS Simulator?

The iOS Simulator is a tool that comes with Xcode that lets you run iOS apps on your Mac **without needing a physical iPhone**. It looks and behaves like a real iPhone, but it runs on your computer.

**Think of it as**: A virtual iPhone running inside a window on your Mac.

---

## Step-by-Step Guide

### Step 1: Open Xcode

1. Press `Cmd + Space` to open Spotlight Search
2. Type **"Xcode"**
3. Press Enter to launch Xcode
4. Wait for Xcode to fully load (may take 10-20 seconds)

**What you'll see**: Xcode welcome window (or recent projects screen)

---

### Step 2: Open Devices and Simulators Window

**Method A: Via Menu**
1. In Xcode menu bar, click **Window**
2. Click **Devices and Simulators**
3. A new window opens

**Method B: Via Keyboard Shortcut**
- Press `Cmd + Shift + 2`

**What you'll see**: A window with two tabs at the top - "Devices" and "Simulators"

---

### Step 3: Select Simulators Tab

1. Click the **"Simulators"** tab (top of window)
2. You'll see a list of available simulators on the left side

**What you'll see**: List like:
- iPhone 15 Pro Max (iOS 17.x)
- iPhone 15 (iOS 17.x)
- iPhone 14 (iOS 17.x)
- iPhone 8 (iOS 16.x) ← **We want this one**
- iPad models
- Etc.

---

### Step 4: Find iPhone 8 Simulator

**Look for**: An entry that says **"iPhone 8"** followed by iOS version (e.g., "iOS 16.4")

**If you see iPhone 8 in the list**:
- ✅ Great! Proceed to Step 5

**If you DON'T see iPhone 8**:
- You need to download it (see "Troubleshooting" section below)
- Don't worry - it's free and takes ~5 minutes

---

### Step 5: Boot the iPhone 8 Simulator

1. **Find iPhone 8** in the list (left side)
2. **Right-click** on "iPhone 8"
3. Select **"Boot"** from context menu
4. Wait 10-30 seconds for simulator to start

**Alternative method**:
1. Click once on "iPhone 8" to select it
2. Look at bottom-left of window for a **▶️ Play button** or **Boot** button
3. Click it

**What you'll see**:
- A new window opens showing an iPhone 8 screen
- You'll see the iOS lock screen or home screen
- The simulator window title says "iPhone 8"

**Visual**: It looks like a real iPhone 8 inside a Mac window!

---

### Step 6: Unlock the Simulator (If Needed)

**If you see a lock screen**:
1. Click and drag upward from bottom of screen (simulates swipe up)
2. Simulator unlocks to home screen

**If you see home screen**:
- ✅ Already unlocked, proceed!

**What you'll see**: iOS home screen with app icons (Clock, Maps, Photos, etc.)

---

### Step 7: Keep Simulator Running

**IMPORTANT**: Leave the simulator window open!

You'll see:
- iPhone 8 simulator window (keep this open)
- Xcode window (can minimize, but don't close)

The simulator is now **ready** to receive your game!

---

### Step 8: Export Your Game to Simulator

Now we'll deploy your game from Godot to the running simulator.

#### 8A: Open Your Godot Project

1. Open Godot Engine
2. Open project: `/Users/alan/Developer/scrap-survivor-godot/project.godot`
3. Wait for project to load

#### 8B: Open Export Window

1. In Godot menu bar: **Project → Export**
2. Export window opens

**What you'll see**: List of export presets (if any exist)

#### 8C: Check for iOS Export Preset

**Look for**: An entry called "iOS" or "iOS Debug" in the preset list

**If iOS preset exists**:
- ✅ Click on it to select
- Proceed to Step 8D

**If NO iOS preset exists**:
- Click **"Add..."** button (top-right)
- Select **"iOS"** from dropdown
- A new "iOS" preset is created
- Click on it to select

#### 8D: Configure Export Settings (First Time Only)

**IMPORTANT**: For simulator testing, you need specific settings.

1. With "iOS" preset selected, look at right side panel
2. Find **"Application"** section
3. Set these values:
   - **Bundle Identifier**: `com.test.scrapsurvivor` (or any format like `com.yourname.gamename`)
   - **Name**: `Scrap Survivor`
4. Find **"Architectures"** section
5. **Check BOTH**:
   - ✅ arm64 (if on Apple Silicon Mac)
   - ✅ x86_64 (if on Intel Mac)

**Not sure which Mac you have?**
- Click Apple logo (top-left) → **About This Mac**
- If it says "Apple M1/M2/M3" → You have Apple Silicon
- If it says "Intel Core i5/i7/i9" → You have Intel

6. **Export Path** (optional): Click folder icon, choose location like `builds/ios/`

#### 8E: Export the Project

1. Click **"Export Project"** button (bottom of window)
2. Choose where to save (e.g., create a folder `builds/ios/`)
3. **Name it**: `scrap-survivor` (or any name)
4. Click **"Save"**
5. Godot will export - watch progress bar
6. Wait for "Export completed" or progress bar to finish (30 seconds - 2 minutes)

**What Godot creates**: An **Xcode project** (folder with `.xcodeproj` file)

---

### Step 9: Open Exported Project in Xcode

1. Navigate to where you exported (e.g., `builds/ios/`)
2. Find the file ending in **`.xcodeproj`** (e.g., `scrap-survivor.xcodeproj`)
3. **Double-click** it to open in Xcode

**What you'll see**: Xcode opens your game project

---

### Step 10: Select iPhone 8 Simulator as Target

In Xcode window:

1. Look at the **top toolbar** (below the menu bar)
2. You'll see a **destination dropdown** (looks like: "iPhone 15 Pro" or device name)
3. **Click** on this dropdown
4. A menu appears showing all available devices
5. **Find and click**: **"iPhone 8"** (with iOS version)

**Visual guide**:
```
[Stop] [Play] | scrap-survivor > [iPhone 15 Pro ▼]  |  My Mac
                                   ^
                                   Click here!
```

**After selecting**: Dropdown should now show **"iPhone 8"**

---

### Step 11: Build and Run on Simulator

1. Click the **▶️ Play button** (top-left of Xcode toolbar)
   - Or press `Cmd + R`
2. Xcode will build your game (watch progress at top: "Building...")
3. Wait 1-3 minutes for first build (subsequent builds are faster)
4. Build completes → Game automatically launches in simulator

**What you'll see**:
- iPhone 8 simulator window comes to front
- Your game launches automatically
- Main menu appears!

**If you see errors**: See "Troubleshooting" section below

---

### Step 12: Navigate to Character Selection

In the iPhone 8 simulator window:

1. **Click** on buttons using your mouse (simulates tapping)
2. Navigate: Main Menu → Character Selection
3. View character cards

**Controls**:
- **Click** = Tap
- **Click + Drag** = Swipe
- **Scroll on trackpad** = Scroll gesture

---

### Step 13: Validate Character Selection Screen

Use the validation checklist from [docs/week16-phase3.5-validation-guide.md](week16-phase3.5-validation-guide.md):

**Key things to check**:
- ✅ All text is readable (no tiny text on 4.7" screen)
- ✅ No text wrapping or overflow
- ✅ Stats (16pt) are still prominent
- ✅ Cards don't feel cluttered
- ✅ Visual hierarchy still clear

---

### Step 14: Take Screenshots

**To capture what you see**:

**Method A: Via Keyboard**
1. Make sure simulator window is active (click on it)
2. Press `Cmd + S`
3. Screenshot saves to your **Desktop** (default)

**Method B: Via Menu**
1. In simulator window, click menu: **File → New Screen Shot**
2. Screenshot saves to Desktop

**Screenshot location**: `~/Desktop/Simulator Screen Shot - iPhone 8 - 2025-11-22 at XX.XX.XX.png`

---

### Step 15: Fill Out Validation Report

1. Open [docs/week16-phase3.5-validation-report.md](week16-phase3.5-validation-report.md)
2. Fill in "iPhone 8 Simulator" section
3. Note any issues (text overflow, readability, layout)
4. Add screenshot paths

---

## Troubleshooting

### Issue: "iPhone 8 Not in Simulator List"

**Solution**: Download iPhone 8 simulator runtime

1. In Xcode: **Xcode menu → Settings** (or press `Cmd + ,`)
2. Click **"Platforms"** tab
3. Find **"iOS"** section
4. Click **"+"** button or **"Get"** next to older iOS versions
5. Select **iOS 16.x** (includes iPhone 8)
6. Click **"Download"** - wait 10-20 minutes
7. After download: Go back to Devices and Simulators window
8. iPhone 8 should now appear in list

### Issue: "Simulator Won't Boot"

**Solution 1: Restart Xcode**
1. Quit Xcode (`Cmd + Q`)
2. Reopen Xcode
3. Try booting simulator again

**Solution 2: Delete and Recreate Simulator**
1. In Devices and Simulators window
2. Right-click iPhone 8
3. Select **"Delete"**
4. Click **"+"** button (bottom-left)
5. Choose iPhone 8 from dropdown
6. Click **"Create"**

### Issue: "Export Templates Missing" (in Godot)

**Solution**: Download iOS export templates

1. In Godot: **Editor → Manage Export Templates**
2. Click **"Download and Install"**
3. Wait for download to complete
4. Restart Godot
5. Try exporting again

### Issue: "Build Failed" in Xcode

**Common causes**:

**Wrong Architecture**:
- Check if you selected correct architecture (arm64 for Apple Silicon, x86_64 for Intel)
- In Godot export settings, ensure correct architectures are enabled

**Code Signing Error**:
- For simulator, you usually don't need code signing
- In Xcode: Select project → **Signing & Capabilities** tab → Set to "Automatically manage signing"

**Clean Build**:
1. In Xcode: **Product → Clean Build Folder** (or `Cmd + Shift + K`)
2. Try building again (`Cmd + R`)

### Issue: "Simulator Shows Black Screen"

**Solution**:
1. Wait 10-20 seconds (game may be loading)
2. If still black: Check Xcode console (bottom panel) for errors
3. Try rebuilding: `Cmd + Shift + K` (clean), then `Cmd + R` (run)

---

## Quick Reference Card

### Simulator Controls

| Action | How To |
|--------|--------|
| Tap | Click with mouse |
| Swipe | Click + drag |
| Home button | `Cmd + Shift + H` |
| Lock screen | `Cmd + L` |
| Rotate device | `Cmd + ← or →` |
| Screenshot | `Cmd + S` |
| Quit simulator | `Cmd + Q` |

### Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build and Run | `Cmd + R` |
| Stop | `Cmd + .` |
| Clean Build | `Cmd + Shift + K` |
| Devices & Simulators | `Cmd + Shift + 2` |

---

## What Success Looks Like

**You should see**:
- ✅ iPhone 8 simulator window open
- ✅ Your game running inside it
- ✅ Character Selection screen visible
- ✅ Character cards displayed correctly
- ✅ All text readable (no overflow)
- ✅ Screenshot saved to Desktop

**Fill out**: iPhone 8 section in validation report ✅

---

## After Testing

Once you've tested on iPhone 8 simulator:

1. **Compare** to iPhone 15 Pro Max results
2. **Note differences** (if any)
3. **Make GO/NO-GO decision**:
   - **GO**: Character selection typography works on both devices → Proceed to Phase 4
   - **NO-GO**: Issues found → Return to Phase 2, fix, retest

4. Let me know your results!

---

## Need Help?

If you get stuck:
1. Take a screenshot of the error/issue
2. Let me know what step you're on
3. I'll help troubleshoot!

---

**Created**: 2025-11-22
**For**: First-time iOS simulator users
**Context**: Week 16 Phase 3.5 validation testing
