# Godot 4.5.1 iOS Permissions Removal Guide

This guide walks you through disabling unused permissions for iOS builds in Godot 4.5.1.

---

## Overview of Permissions

Godot 4.5.1 handles permissions in two different places:

| Permission | Location | Method |
|-----------|----------|--------|
| Camera | Export Settings | Privacy settings (presence disables permission request) |
| Microphone | Export Settings | Privacy settings (presence disables permission request) |
| Photo Library | Export Settings | Privacy settings (presence disables permission request) |
| Motion Sensors (Gyroscope/Accelerometer) | Project Settings | Input device settings |

---

## Part 1: Disable Export Privacy Permissions

These permissions are automatically requested by Godot when you leave the usage description fields populated. **To disable them, simply leave the description fields empty**.

### Step 1: Open Export Settings

1. Go to **Project > Export** in the Godot editor
2. Select your **iOS** export preset (or create one if you don't have one)
   - If no iOS preset exists, click **Add Preset** and select **iOS**

### Step 2: Disable Camera Permission

In the Export preset panel:

1. Navigate to **Privacy** section in the left panel
2. Find **privacy/camera_usage_description** field
3. **Leave it empty** (delete any text if present)
4. Also clear **privacy/camera_usage_description_localized** if it has content

**Result:** The `NSCameraUsageDescription` key will not be added to Info.plist, and iOS will not request camera permissions.

### Step 3: Disable Microphone Permission

1. In the **Privacy** section, find **privacy/microphone_usage_description**
2. **Leave it empty** (remove all text)
3. Also clear **privacy/microphone_usage_description_localized**

**Result:** The `NSMicrophoneUsageDescription` key will not be added to Info.plist, and iOS will not request microphone permissions.

### Step 4: Disable Photo Library Permission

1. In the **Privacy** section, find **privacy/photolibrary_usage_description**
2. **Leave it empty** (remove all text)
3. Also clear **privacy/photolibrary_usage_description_localized**

**Result:** The `NSPhotoLibraryUsageDescription` key will not be added to Info.plist, and iOS will not request photo library permissions.

---

## Part 2: Disable Motion Sensors (Gyroscope/Accelerometer)

Motion sensors are controlled through **Project Settings**, not export settings. You need to disable the accelerometer/gyroscope input device.

### Step 5: Open Project Settings

1. Go to **Project > Project Settings** in the Godot editor
2. Enable the **Advanced** toggle (top right) to see all available settings
3. Search for `input_devices/sensors`

### Step 6: Disable Accelerometer

1. Find **input_devices/sensors/enable_accelerometer**
2. Set it to **OFF** (unchecked)

**Result:** Godot will not read accelerometer data on iOS.

### Step 7: Disable Gyroscope (if needed)

Note: Godot 4.5.1 uses the accelerometer for device motion. If you want to completely disable all motion input:

1. Search for `enable_gyroscope` in Project Settings
2. If it exists, set it to **OFF**

**Note:** In most Godot versions, gyroscope is bundled with accelerometer through the motion sensor API.

---

## Verification Checklist

After completing these steps, verify your configuration:

### In Export Settings (iOS preset):
- [ ] `privacy/camera_usage_description` is **empty**
- [ ] `privacy/camera_usage_description_localized` is **empty**
- [ ] `privacy/microphone_usage_description` is **empty**
- [ ] `privacy/microphone_usage_description_localized` is **empty**
- [ ] `privacy/photolibrary_usage_description` is **empty**
- [ ] `privacy/photolibrary_usage_description_localized` is **empty**

### In Project Settings:
- [ ] `input_devices/sensors/enable_accelerometer` is **OFF**

---

## Build and Test

1. Export your project to Xcode:
   - **Project > Export**
   - Select your iOS preset
   - Choose output folder
   - Click **Export Project**

2. Open the exported Xcode project:
   - Navigate to the exported folder
   - Open `YourProjectName.xcodeproj`

3. **Verify Info.plist** (optional, for advanced users):
   - In Xcode, open `YourProjectName-Info.plist`
   - Search for `NSCamera`, `NSMicrophone`, `NSPhotoLibrary`, `NSMotion`
   - These keys should **not** be present

4. Build and deploy to an iOS device to confirm permissions are not requested

---

## Troubleshooting

### Permissions Still Showing in iOS Settings

If the app still shows these permissions in iOS Settings > Privacy:

1. The Info.plist may have been cached
2. **Clean Build Folder** in Xcode: **Shift + Cmd + K**
3. Delete the Derived Data folder: `~/Library/Developer/Xcode/DerivedData`
4. Rebuild and redeploy

### Permission Prompt Still Appearing

If a permission prompt still appears when running the app:

1. Your code may be explicitly requesting permissions
2. Search your GDScript files for:
   - `OS.request_permission()` calls
   - `Input.get_accelerometer()` calls
   - Any camera/microphone API usage
3. Remove or conditionally disable these calls

### Gyroscope Still Active After Disabling

If motion sensors still provide data after disabling in Project Settings:

1. Check if your code explicitly uses:
   - `Input.get_gyroscope()`
   - `Input.get_accelerometer()`
2. Remove these calls or add conditional checks
3. Ensure you saved Project Settings (Ctrl+S or Cmd+S)

---

## Additional Resources

- Godot iOS Export Documentation: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html
- EditorExportPlatformIOS Reference: https://docs.godotengine.org/en/stable/classes/class_editorexportplatformios.html
- Input API Reference: https://docs.godotengine.org/en/stable/classes/class_input.html
