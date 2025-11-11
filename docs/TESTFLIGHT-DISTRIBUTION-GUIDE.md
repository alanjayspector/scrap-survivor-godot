# TestFlight Distribution Guide

**Goal:** Share your iOS game with friends/testers via Apple's TestFlight
**Prerequisites:** Apple Developer Account ($99/year)

---

## Step 1: Create App in App Store Connect

1. Go to [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with your Apple ID
3. Click **"My Apps"** → **"+"** → **"New App"**
4. Fill in:
   - **Platform:** iOS
   - **Name:** Scrap Survivor (or your chosen name)
   - **Primary Language:** English
   - **Bundle ID:** Select `com.alanjayspector.scrapsurvivor` (from dropdown)
   - **SKU:** `scrap-survivor-001` (any unique identifier)
   - **User Access:** Full Access
5. Click **"Create"**

---

## Step 2: Archive Your App in Xcode

1. **Connect your iPhone** (required even for TestFlight)
2. In Xcode, select device dropdown: **"Any iOS Device (arm64)"**
3. Go to **Product → Scheme → Edit Scheme**
   - Set **Build Configuration** to **"Release"** (not Debug)
   - Click **Close**
4. Go to **Product → Archive**
   - Wait 2-5 minutes for build to complete
5. Xcode Organizer window opens automatically
   - Shows your archive with app icon and version

---

## Step 3: Upload to App Store Connect

1. In Xcode Organizer (from Step 2):
   - Select your archive
   - Click **"Distribute App"** button
2. Choose **"TestFlight & App Store"** → **Next**
3. Choose **"Upload"** → **Next**
4. **Distribution Options:**
   - ✓ Upload your app's symbols (for crash reports)
   - ✓ Manage Version and Build Number (let Xcode increment)
   - Click **Next**
5. **Automatic Signing:** Click **"Automatically manage signing"** → **Next**
6. Review summary → Click **"Upload"**
7. Wait 5-10 minutes for upload to complete
8. Click **"Done"**

---

## Step 4: Processing & Compliance

1. You'll receive email: **"The uploaded build is now processing"**
2. Wait 10-30 minutes for Apple to process your build
3. You'll receive email: **"Your build has completed processing"**

4. **Export Compliance:**
   - Go back to [App Store Connect](https://appstoreconnect.apple.com)
   - Navigate to **My Apps → Scrap Survivor → TestFlight tab**
   - Click on your build (will have yellow warning)
   - Answer compliance questions:
     - **"Is your app designed to use cryptography?"** → **No** (unless you added encryption)
   - Click **"Start Internal Testing"** (if prompted)

---

## Step 5: Add External Testers

### Option A: Create a Test Group

1. In **TestFlight tab** → **"External Groups"** section
2. Click **"+"** to create new group
3. Name it: **"Friends Beta Test"**
4. Add build by clicking **"+"** next to "Builds"
5. Select your build → **"Next"**
6. Fill out **"What to Test"** field:
   ```
   Testing weapon visual identity and mobile gameplay:
   - Test all 8 weapons (press 1-8 to switch)
   - Provide feedback on weapon distinctiveness
   - Report any bugs or performance issues
   ```
7. Click **"Submit for Review"**
   - **First time only:** Apple reviews (1-2 days)
   - Future builds: Instant availability

### Option B: Add Individual Testers

1. In **TestFlight tab** → **"Testers"** section → **"+"**
2. Enter friend's email: `friend@example.com`
3. Add to group: **"Friends Beta Test"**
4. They receive email with TestFlight invite link

---

## Step 6: Testers Install TestFlight

**Your friends need to:**

1. Install **TestFlight** app from App Store (free)
2. Open invite email on iPhone
3. Tap **"View in TestFlight"** button
4. In TestFlight app: Tap **"Accept"** → **"Install"**
5. Launch **"Scrap Survivor"** from TestFlight

---

## Tester Feedback

**Testers can:**
- Submit feedback via TestFlight app (screenshots, comments)
- You see feedback in App Store Connect → TestFlight → Feedback

**View crash reports:**
- App Store Connect → TestFlight → Builds → Select build → Crash Reports

---

## Updating Your Build (For Bug Fixes)

1. Make code changes in Godot
2. Export updated iOS project (overwrites Desktop files)
3. Open in Xcode
4. **Increment build number:**
   - Select project → Target → General
   - **Build:** Change to next number (e.g., `1` → `2`)
5. **Product → Archive** (repeat Step 2-3)
6. Upload to same App Store Connect entry
7. In TestFlight → Select new build for your test group
8. Testers auto-receive update notification

---

## Quick Reference Commands

**Check Team ID:**
```bash
# Found at developer.apple.com/account → Membership
```

**Increment build in Xcode CLI:**
```bash
/usr/bin/xcodebuild -project "Scrap Survivor.xcodeproj" -showBuildSettings | grep MARKETING_VERSION
```

---

## Troubleshooting

**"No accounts in Xcode"**
- Xcode → Settings → Accounts → Add Apple ID

**"Failed to create provisioning profile"**
- Check Bundle ID matches App Store Connect
- Verify Team ID is correct
- Try: Xcode → Preferences → Accounts → Download Manual Profiles

**"Build not appearing in TestFlight"**
- Wait 30 minutes for processing
- Check email for processing errors
- Verify build shows in App Store Connect → Activity tab

**"Tester can't install"**
- Verify tester is added to group
- Check they accepted invite email
- Ensure build is available to their group

---

## TestFlight Limits

- **Internal testers:** 100 max (your Apple Developer team)
- **External testers:** 10,000 max
- **Build lifetime:** 90 days (then expires, upload new build)
- **Review time:** First external build only (~24-48 hours)

---

## Next Steps After Testing

Once you have feedback:
1. Prioritize: Sound design > Additional visual polish
2. Implement changes
3. Re-export, re-archive, re-upload
4. Iterate based on tester feedback

**Goal:** Achieve 8/10+ weapon distinctiveness before moving to Week 12 Phase 2
