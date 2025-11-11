# iOS Privacy Permissions Fix Guide - P1.1

**Issue**: App Store requires privacy descriptions for all requested permissions
**Priority**: P1 - HIGH (App Store Rejection Risk)
**Time Required**: 10-15 minutes
**Status**: Required before TestFlight upload

---

## 🚨 Errors to Fix

Your app is requesting these 4 permissions without proper descriptions:

1. ❌ **NSCameraUsageDescription** - Camera access
2. ❌ **NSMicrophoneUsageDescription** - Microphone access
3. ❌ **NSPhotoLibraryUsageDescription** - Photo library access
4. ❌ **NSMotionUsageDescription** - Device motion (accelerometer/gyroscope)

**App Store Error Message:**
```
The value for NSCameraUsageDescription must be a non-empty string.
The value for NSMicrophoneUsageDescription must be a non-empty string.
The value for NSPhotoLibraryUsageDescription must be a non-empty string.
The value for NSMotionUsageDescription must be a non-empty string.
```

---

## ✅ Solution: Disable Unused Permissions

Since **Scrap Survivor** is a top-down shooter that doesn't use camera, microphone, photos, or device motion, we'll **remove these permissions entirely**.

---

## 📋 Step-by-Step Fix (Godot 4.x)

### Step 1: Open Export Settings

1. **Launch Godot Editor**
2. **Project** menu → **Export...**
3. You should see your **iOS** preset in the left sidebar
4. **Click on the iOS preset** to select it

**Screenshot reference**: Look for "Export Presets" window with iOS listed

---

### Step 2: Disable Camera Permission

**Location**: Export Settings → iOS Preset → Options tab

1. Scroll down to find **"Privacy"** or **"Capabilities"** section
2. Look for **"Camera"** or **"NSCameraUsageDescription"**
3. **Options:**
   - **If there's a checkbox**: Uncheck "Enable Camera"
   - **If there's a text field**: Leave it completely empty (delete any text)
   - **If there's a toggle**: Set to "Off" or "Disabled"

**What to look for:**
```
Privacy / Camera
  ☐ Enable Camera Access
  Description: [empty]
```

---

### Step 3: Disable Microphone Permission

1. In the same **Privacy** section
2. Find **"Microphone"** or **"NSMicrophoneUsageDescription"**
3. **Disable it** using the same method as camera:
   - Uncheck box, or
   - Leave description empty, or
   - Toggle to "Off"

**What to look for:**
```
Privacy / Microphone
  ☐ Enable Microphone Access
  Description: [empty]
```

---

### Step 4: Disable Photo Library Permission

1. Still in **Privacy** section
2. Find **"Photo Library"** or **"NSPhotoLibraryUsageDescription"**
3. **Disable it**:
   - Uncheck box, or
   - Leave description empty, or
   - Toggle to "Off"

**What to look for:**
```
Privacy / Photo Library
  ☐ Enable Photo Library Access
  Description: [empty]
```

---

### Step 5: Disable Motion Sensors (CoreMotion)

**This is tricky in Godot 4.x - try both methods:**

#### Method A: Required Device Capabilities

1. Scroll to **"Required Device Capabilities"** section
2. Look for these entries:
   - `accelerometer`
   - `gyroscope`
3. **Remove them** from the list:
   - Click the `-` button next to each, or
   - Delete them from the comma-separated list, or
   - Uncheck if they're checkboxes

**What to look for:**
```
Required Device Capabilities:
  armv7, arm64
  (DO NOT include: accelerometer, gyroscope)
```

#### Method B: Custom Info.plist (If Method A doesn't work)

1. Scroll to **"Custom Info.plist"** section
2. **If it's empty**: Leave it empty (best option)
3. **If it has content**: Make sure it does NOT include:
   ```xml
   <key>UIRequiredDeviceCapabilities</key>
   <array>
     <string>accelerometer</string>  <!-- REMOVE THIS -->
     <string>gyroscope</string>      <!-- REMOVE THIS -->
   </array>
   ```

---

### Step 6: Verify No Privacy Permissions Requested

**Check the "Permissions" or "Entitlements" section:**

Make sure NONE of these are enabled:
- ❌ Camera
- ❌ Microphone
- ❌ Photo Library
- ❌ Location Services (if present)
- ❌ Contacts (if present)
- ❌ Motion & Fitness (if present)

**Only enable permissions your game actually uses.**

---

### Step 7: Save and Re-Export

1. **Click "Save"** or **"Close"** (Godot auto-saves export presets)
2. **Export Project** again:
   - Click **"Export Project"** button
   - Choose **iOS** platform
   - Save to your iOS export folder
3. **Overwrite** the previous export

---

## 🔍 Verification Steps

### Verify in Xcode

1. **Open** the exported Xcode project
2. **Select** your app target in the left sidebar
3. **Click** the "Info" tab
4. **Check** "Custom iOS Target Properties"
5. **Verify** these keys are **NOT present**:
   - `NSCameraUsageDescription`
   - `NSMicrophoneUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSMotionUsageDescription`

**If they're present with empty values**: Delete the entire row for each

---

### Alternative: Manual Info.plist Edit (Advanced)

**Only do this if the Godot method doesn't work:**

1. **Navigate** to exported Xcode project
2. **Find** `Info.plist` file
3. **Right-click** → Open As → Source Code
4. **Remove** these blocks if present:

```xml
<!-- DELETE THESE ENTIRE BLOCKS -->
<key>NSCameraUsageDescription</key>
<string></string>

<key>NSMicrophoneUsageDescription</key>
<string></string>

<key>NSPhotoLibraryUsageDescription</key>
<string></string>

<key>NSMotionUsageDescription</key>
<string></string>

<!-- Also remove from capabilities if present -->
<key>UIRequiredDeviceCapabilities</key>
<array>
  <!-- Remove these lines: -->
  <string>accelerometer</string>
  <string>gyroscope</string>
</array>
```

5. **Save** the file
6. **Rebuild** in Xcode

---

## 🧪 Testing the Fix

### Before Building:

1. **Clean Build Folder** in Xcode: Product → Clean Build Folder (⇧⌘K)
2. **Delete derived data**: Xcode → Preferences → Locations → Derived Data → Delete

### Build and Test:

1. **Build** to iOS device (⌘R)
2. **Check Xcode console** for permission warnings
3. **Should NOT see**:
   ```
   The value for NSCameraUsageDescription must be a non-empty string.
   ```

### Archive Test (Final Validation):

1. **Product** → **Archive**
2. **Validate App** (don't upload yet)
3. **Check for errors** in validation results
4. **Should pass** without permission errors

---

## ⚠️ Troubleshooting

### Issue: Permissions Still Requested After Export

**Cause**: Godot 4.x includes iOS frameworks that auto-request permissions

**Fix**:
1. Check if you're using any plugins that require these permissions
2. Remove unused plugins from Project Settings → Plugins
3. Check `project.godot` for unused iOS features
4. Try exporting to a completely new folder

---

### Issue: Can't Find Privacy Settings in Godot

**Godot 4.0 - 4.2**:
- Privacy settings may be in **"Options"** section
- Look for **"Application"** → **"Permissions"**
- May need to expand sections with arrows `▸`

**Godot 4.3+**:
- Privacy settings reorganized
- Check **"Capabilities"** tab
- Look in **"Custom Info.plist"** section

---

### Issue: Custom Info.plist Keeps Adding Permissions

**Solution**: Edit the exported Xcode project's `Info.plist` directly after each export

**Automated Fix** (create a post-export script):

Create `scripts/post-export-ios.sh`:
```bash
#!/bin/bash
# Remove unwanted privacy keys from Info.plist

PLIST="$1/Info.plist"

/usr/libexec/PlistBuddy -c "Delete :NSCameraUsageDescription" "$PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Delete :NSMicrophoneUsageDescription" "$PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Delete :NSPhotoLibraryUsageDescription" "$PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Delete :NSMotionUsageDescription" "$PLIST" 2>/dev/null

echo "✅ Removed unwanted privacy permissions"
```

Make executable:
```bash
chmod +x scripts/post-export-ios.sh
```

Run after each export:
```bash
./scripts/post-export-ios.sh path/to/exported/ios/project
```

---

## 🎯 Alternative: Add Valid Descriptions (NOT Recommended)

**Only do this if you actually use these features:**

In Godot Export Settings → iOS → Custom Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>Scrap Survivor needs camera access to capture screenshots for sharing your victories</string>

<key>NSMicrophoneUsageDescription</key>
<string>Scrap Survivor needs microphone access for voice chat during multiplayer sessions</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Scrap Survivor needs photo library access to save game screenshots</string>

<key>NSMotionUsageDescription</key>
<string>Scrap Survivor uses device motion for tilt-to-move gameplay controls</string>
```

**⚠️ Warning**:
- Apple will reject if descriptions don't match actual usage
- Your app doesn't use any of these features
- Stick with disabling them completely

---

## ✅ Success Checklist

After completing this guide:

- [ ] Godot export settings saved
- [ ] Camera permission disabled/removed
- [ ] Microphone permission disabled/removed
- [ ] Photo Library permission disabled/removed
- [ ] Motion sensors disabled/removed
- [ ] Project re-exported to iOS
- [ ] Xcode `Info.plist` verified (no permission keys)
- [ ] Build succeeds without permission warnings
- [ ] Archive validation passes

---

## 📊 Before/After Comparison

### Before (❌ Rejected):
```xml
<!-- Info.plist contains: -->
<key>NSCameraUsageDescription</key>
<string></string>  <!-- Empty = Rejection -->

<key>NSMicrophoneUsageDescription</key>
<string></string>  <!-- Empty = Rejection -->

<key>NSPhotoLibraryUsageDescription</key>
<string></string>  <!-- Empty = Rejection -->

<key>NSMotionUsageDescription</key>
<string></string>  <!-- Empty = Rejection -->
```

### After (✅ Approved):
```xml
<!-- Info.plist contains: -->
<!-- NONE of the above keys -->
<!-- Only app-specific settings like bundle ID, version, etc. -->
```

---

## 🚀 Next Steps

After fixing privacy permissions:

1. **Rebuild** iOS export in Godot
2. **Open** in Xcode
3. **Archive** (Product → Archive)
4. **Validate** (should pass without errors)
5. **Upload to TestFlight** (Distribute App)
6. **Wait** for Apple processing (15-30 minutes)
7. **Invite** beta testers

---

## 📞 Common Questions

### Q: Will removing these permissions break my app?

**A**: No. Scrap Survivor doesn't use camera, mic, photos, or motion sensors.

### Q: What if Apple asks why I removed Motion?

**A**: "The game uses virtual joystick controls and doesn't require device motion sensors."

### Q: Can I add these later if needed?

**A**: Yes. Update export settings, add valid descriptions, and submit an update.

### Q: Why does Godot request these by default?

**A**: Godot includes iOS frameworks that may trigger permission requests. It's a known issue in Godot 4.x.

---

## 🐛 Still Having Issues?

If privacy errors persist after following this guide:

1. **Export to completely new folder**
2. **Delete all Xcode derived data**
3. **Check for Godot plugins** requesting permissions
4. **Manually edit Info.plist** in Xcode
5. **Use post-export script** to auto-remove keys

---

**Good luck!** After completing this guide, your app should pass App Store privacy validation. 🎉
