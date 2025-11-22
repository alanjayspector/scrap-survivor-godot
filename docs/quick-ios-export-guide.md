# Quick iOS Export & Deployment Guide

**For**: Week 16 Phase 3.5 Manual QA Testing
**Target Devices**: iPhone 15 Pro Max (physical), iPhone 8 (simulator)

---

## Prerequisites

### Required Software
- ✅ Godot 4.x installed
- ✅ Xcode installed (latest version)
- ✅ iOS export templates installed in Godot
- ✅ Apple Developer account (for physical device)
- ✅ iPhone 15 Pro Max connected via USB (for physical testing)

### Verify Export Templates

```bash
# In Godot Editor:
# Editor → Manage Export Templates → iOS/Xcode
# Ensure templates match your Godot version
```

---

## Method 1: Export to iPhone 15 Pro Max (Physical Device)

### Step 1: Configure iOS Export Preset

1. Open Godot project: `/Users/alan/Developer/scrap-survivor-godot/project.godot`
2. Go to: **Project → Export**
3. Select or create: **iOS** export preset
4. Configure settings:
   - **Name**: "iOS Debug" or "iOS Device"
   - **Runnable**: ✅ Checked
   - **Export Path**: `builds/ios/scrap-survivor.ipa` (or custom path)
   - **Bundle Identifier**: `com.yourcompany.scrapsurvivor` (must match provisioning profile)
   - **Team ID**: Your Apple Developer Team ID
   - **Provisioning Profile**: Select your development profile
   - **Code Signing**: Automatic or Manual (depending on setup)

5. **Application Settings**:
   - **Display Name**: Scrap Survivor
   - **Supported Devices**: iPhone (portrait + landscape as needed)
   - **Target iOS Version**: 15.0+ (or minimum supported)

6. **Export Type**: Debug (for testing)

### Step 2: Export Project

1. In Export window, select **iOS** preset
2. Click **Export Project**
3. Choose export location (e.g., `builds/ios/`)
4. Wait for export to complete
5. Godot will create an Xcode project

### Step 3: Deploy via Xcode

1. Open exported Xcode project: `builds/ios/scrap-survivor.xcodeproj`
2. Connect iPhone 15 Pro Max via USB
3. In Xcode:
   - Select iPhone 15 Pro Max as target device (top toolbar)
   - Click **Run** (▶️ button) or press `Cmd+R`
4. Xcode will build and deploy to device
5. First run may require **"Trust this computer"** on iPhone
6. May need to **enable Developer Mode** on iPhone (Settings → Privacy & Security → Developer Mode)
7. Game will launch automatically on device

### Step 4: Navigate to Character Selection

1. Game launches on iPhone 15 Pro Max
2. Tap through: Main Menu → Character Selection
3. Begin validation checklist

---

## Method 2: Export to iPhone 8 Simulator

### Step 1: Launch iPhone 8 Simulator

**Option A: Via Xcode**
1. Open Xcode
2. Go to: **Window → Devices and Simulators**
3. Select **Simulators** tab
4. Find **iPhone 8** (iOS 16.x or latest)
   - If not available, click **+** to add iPhone 8 simulator
5. Right-click → **Boot** simulator
6. iPhone 8 simulator window opens

**Option B: Via Terminal**
```bash
# List available simulators
xcrun simctl list devices

# Boot iPhone 8 simulator (use device UDID from list)
xcrun simctl boot "iPhone 8"

# Open simulator app
open -a Simulator
```

### Step 2: Export to Simulator via Godot

1. In Godot: **Project → Export**
2. Select **iOS** preset
3. Configure for simulator:
   - **Architecture**: x86_64 or arm64 (depending on Mac)
   - **Export Type**: Debug
4. Click **Export Project**
5. Save as `.xcodeproj`

### Step 3: Deploy to Simulator via Xcode

1. Open exported Xcode project: `builds/ios/scrap-survivor.xcodeproj`
2. In Xcode top toolbar:
   - Select **iPhone 8 Simulator** as target
3. Click **Run** (▶️) or press `Cmd+R`
4. Xcode builds and launches in simulator
5. Game appears in iPhone 8 simulator

### Step 4: Navigate to Character Selection

1. Game launches in simulator
2. Click through: Main Menu → Character Selection
3. Begin validation checklist

---

## Method 3: Quick Deploy (Godot One-Click Remote Deploy)

**Note**: This method may not work for all setups, but it's fastest if available.

### For Physical Device (iPhone 15 Pro Max)

1. In Godot Editor, click **Remote Debug** button (phone icon)
2. Select **Deploy with Remote Debug**
3. Choose **iOS** platform
4. Select connected device from list
5. Godot builds and deploys automatically
6. Game launches on device

### For Simulator

1. Ensure simulator is already running
2. In Godot Editor, click **Remote Debug**
3. Select simulator from device list
4. Godot deploys to simulator

**Limitation**: This may require additional Godot-iOS export plugin setup.

---

## Troubleshooting

### Physical Device Issues

**"Developer Mode Required"**
- Go to iPhone: Settings → Privacy & Security → Developer Mode
- Enable Developer Mode
- Restart iPhone

**"Untrusted Developer"**
- Go to iPhone: Settings → General → VPN & Device Management
- Trust your developer certificate

**"Provisioning Profile Error"**
- Verify Team ID and Bundle Identifier match
- Check provisioning profile in Xcode
- Regenerate profile if needed

**Device Not Detected**
- Ensure USB cable is connected
- Unlock iPhone
- Trust this computer on iPhone
- Restart Xcode

### Simulator Issues

**Simulator Not Listed**
- Download additional simulators in Xcode: Xcode → Settings → Platforms
- Install iOS 16.x runtime

**Simulator Won't Boot**
- Restart Xcode
- Delete and recreate simulator
- Check macOS version compatibility

**Build Fails**
- Check architecture matches Mac (Apple Silicon = arm64, Intel = x86_64)
- Clean build folder in Xcode: Product → Clean Build Folder
- Verify export templates match Godot version

### Export Issues

**Export Templates Missing**
- Godot: Editor → Manage Export Templates
- Download templates for your Godot version
- Restart Godot

**Code Signing Errors**
- Use automatic signing in Xcode
- Verify Apple Developer account is active
- Check certificate expiration

---

## Alternative: Use Godot Remote for Quick Testing

If iOS export is complex, you can use **Godot Remote** app for quick testing:

1. Install **Godot Remote** from App Store (free)
2. Connect iPhone to same network as Mac
3. In Godot: Project → Export → Remote Debug
4. Launch Godot Remote on iPhone
5. Game streams from Godot to device

**Limitations**:
- Streaming performance may not reflect native performance
- Not suitable for final validation
- Good for quick iteration

---

## Recommended Testing Flow

### Quick Test (5 min)
1. Deploy to iPhone 8 simulator (fastest)
2. Quick visual check for major issues
3. If looks good → proceed to physical device

### Full Test (15-20 min)
1. Deploy to iPhone 15 Pro Max (physical device)
2. Full validation checklist
3. Take screenshots
4. Deploy to iPhone 8 simulator
5. Minimum screen size validation
6. Fill out validation report

---

## Taking Screenshots

### On Physical Device (iPhone 15 Pro Max)
- Press **Volume Up + Side Button** simultaneously
- Screenshots save to Photos app
- Transfer to Mac via AirDrop or USB

### On Simulator (iPhone 8)
- Press **Cmd+S** in simulator window
- Screenshot saves to Desktop (default)
- Or: Simulator menu → File → New Screen Shot

---

## After Testing

1. Fill out validation report: [docs/week16-phase3.5-validation-report.md](week16-phase3.5-validation-report.md)
2. Make GO/NO-GO decision
3. If GO: Proceed to Phase 4
4. If NO-GO: Document issues, return to Phase 2

---

**Quick Reference**:
- Validation Guide: [docs/week16-phase3.5-validation-guide.md](week16-phase3.5-validation-guide.md)
- Validation Report: [docs/week16-phase3.5-validation-report.md](week16-phase3.5-validation-report.md)
- Character Selection Scene: [scenes/ui/character_selection.tscn](../scenes/ui/character_selection.tscn)
- Character Selection Script: [scripts/ui/character_selection.gd](../scripts/ui/character_selection.gd)

---

**Created**: 2025-11-22
**Last Updated**: 2025-11-22
