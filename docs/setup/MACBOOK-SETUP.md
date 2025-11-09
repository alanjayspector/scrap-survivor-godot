# MacBook Pro M4 Max Setup Guide

## Complete Development Environment for React Native + Scrap Survivor

**Target Hardware:** MacBook Pro 14" M4 Max
**macOS Version:** Sonoma 14.0+ (or latest)
**Setup Time:** 3-4 hours
**Automation:** See `scripts/setup-mac.sh` for one-command setup

---

## Table of Contents

1. [Initial macOS Setup](#initial-macOS-setup)
2. [Homebrew Installation](#homebrew-installation)
3. [Core Development Tools](#core-development-tools)
4. [Xcode & iOS Development](#xcode--ios-development)
5. [Android Studio & Android Development](#android-studio--android-development)
6. [Node.js & Package Managers](#nodejs--package-managers)
7. [VS Code & Extensions](#vs-code--extensions)
8. [React Native Specific Tools](#react-native-specific-tools)
9. [Productivity Tools](#productivity-tools)
10. [Repository Setup](#repository-setup)
11. [Verification & Testing](#verification--testing)

---

## Initial macOS Setup

### 1. First Boot

**After unboxing:**

1. Power on and follow setup wizard
2. Sign in with Apple ID
3. Enable FileVault (disk encryption)
4. Set up Touch ID / Face ID
5. **Skip** iCloud Drive sync (optional, can slow down setup)

### 2. System Preferences

**Settings → General:**

- Appearance: Dark (recommended for development)
- Show scroll bars: Always

**Settings → Desktop & Dock:**

- Size: Medium
- Automatically hide and show the Dock: Yes
- Show recent applications in Dock: No

**Settings → Trackpad:**

- Tap to click: On
- Tracking speed: Fast (adjust to preference)

**Settings → Keyboard:**

- Key repeat rate: Fast
- Delay until repeat: Short
- Text input → Disable "Correct spelling automatically"
- Text input → Disable "Capitalize words automatically"

**Settings → Security & Privacy:**

- FileVault: On
- Firewall: On

### 3. Terminal Setup

**Open Terminal.app** (pre-installed):

```bash
# Make sure you're in home directory
cd ~

# Create development directories
mkdir -p ~/Developer/projects
mkdir -p ~/Developer/tools
```

---

## Homebrew Installation

**Homebrew** is the package manager for macOS. It makes installing development tools effortless.

### Install Homebrew

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow the prompts, enter your password when asked

# Add Homebrew to PATH (for M-series Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify installation
brew --version
# Should output: Homebrew 4.x.x
```

### Update Homebrew

```bash
# Update Homebrew itself
brew update

# Upgrade any pre-installed packages
brew upgrade
```

---

## Core Development Tools

### Git (Version Control)

```bash
# Install Git
brew install git

# Verify installation
git --version
# Should output: git version 2.40+

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Enable helpful colors
git config --global color.ui auto

# Set default editor (VS Code)
git config --global core.editor "code --wait"
```

### GitHub CLI (Optional but Recommended)

```bash
# Install GitHub CLI
brew install gh

# Authenticate with GitHub
gh auth login

# Follow the prompts to authenticate via browser
```

---

## Xcode & iOS Development

### Install Xcode

**Two options:**

**Option A: App Store (Recommended)**

1. Open App Store
2. Search for "Xcode"
3. Click "Get" (it's free, but 15+ GB download)
4. Wait 30-60 minutes for download + installation
5. Open Xcode once to accept license agreement

**Option B: Command Line**

```bash
# Install Xcode via command line (slower, but unattended)
mas install 497799835  # Xcode's App Store ID

# Note: Requires 'mas' (Mac App Store CLI)
# Install mas first: brew install mas
```

### Install Xcode Command Line Tools

```bash
# Install CLI tools (C compiler, git, etc.)
xcode-select --install

# Click "Install" in the popup dialog

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# Accept license
sudo xcodebuild -license accept
```

### Install iOS Simulator

```bash
# Open Xcode
# Navigate to: Xcode → Settings → Platforms
# Download iOS 17.x Simulator (or latest)

# Or via command line:
xcodebuild -downloadPlatform iOS

# List available simulators
xcrun simctl list devices

# Create a simulator (if needed)
xcrun simctl create "iPhone 15" "iPhone 15"
```

### CocoaPods (Dependency Manager for iOS)

```bash
# Install CocoaPods
sudo gem install cocoapods

# Verify installation
pod --version
# Should output: 1.15.x

# Set up CocoaPods repo (one-time setup)
pod setup
```

---

## Android Studio & Android Development

### Install Android Studio

```bash
# Install via Homebrew Cask
brew install --cask android-studio

# Or download manually from: https://developer.android.com/studio
```

### Initial Android Studio Setup

**First launch:**

1. Open Android Studio
2. Click "Next" through the setup wizard
3. **Select "Custom" installation type**
4. **Install components:**
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)
   - Performance (Intel HAXM) ← Skip on M4 (ARM-based)

**SDK Manager:**

1. Open Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK
2. **SDK Platforms tab:**
   - Check Android 14.0 (API 34)
   - Check Android 13.0 (API 33)
3. **SDK Tools tab:**
   - Check Android SDK Build-Tools
   - Check Android Emulator
   - Check Android SDK Platform-Tools
   - Check Android SDK Tools (Obsolete) ← May be needed for some tools
4. Click "Apply" and wait for downloads

### Configure Environment Variables

```bash
# Add Android SDK to PATH
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zprofile
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zprofile
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zprofile
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.zprofile
echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.zprofile

# Apply changes
source ~/.zprofile

# Verify
echo $ANDROID_HOME
# Should output: /Users/your-username/Library/Android/sdk

# Verify adb (Android Debug Bridge)
adb --version
# Should output: Android Debug Bridge version 1.0.41
```

### Create Android Emulator

**Via Android Studio UI:**

1. Open Android Studio
2. Tools → Device Manager
3. Click "Create Device"
4. Select "Phone" → "Pixel 5"
5. Select system image: **Android 14.0 (API 34)** with **ARM64** (important for M4!)
6. Click "Next" → "Finish"

**Via Command Line:**

```bash
# List available system images
sdkmanager --list | grep system-images

# Install Android 14 ARM64 image (for M4 Mac)
sdkmanager "system-images;android-34;google_apis;arm64-v8a"

# Create AVD
avdmanager create avd -n Pixel_5_API_34 -k "system-images;android-34;google_apis;arm64-v8a" -d "pixel_5"

# List AVDs
avdmanager list avd

# Launch emulator
emulator -avd Pixel_5_API_34
```

---

## Node.js & Package Managers

### Install nvm (Node Version Manager)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Add to shell profile
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zprofile
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zprofile
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zprofile

# Apply changes
source ~/.zprofile

# Verify
nvm --version
# Should output: 0.39.7
```

### Install Node.js

```bash
# Install Node.js 20 LTS (recommended for React Native)
nvm install 20

# Set as default
nvm alias default 20

# Verify
node --version
# Should output: v20.x.x

npm --version
# Should output: 10.x.x
```

### Install pnpm (Fast Package Manager)

```bash
# Install pnpm globally
npm install -g pnpm

# Verify
pnpm --version
# Should output: 9.x.x

# Configure pnpm
pnpm setup

# Set pnpm store location (optional, for better performance)
pnpm config set store-dir ~/.pnpm-store
```

### Install Global Packages

```bash
# Expo CLI (for React Native development)
npm install -g expo-cli eas-cli

# Useful dev tools
npm install -g typescript ts-node
npm install -g prettier eslint
npm install -g npm-check-updates  # Update package.json dependencies
npm install -g serve  # Serve static files

# Verify
expo --version
eas --version
```

---

## VS Code & Extensions

### Install VS Code

```bash
# Install via Homebrew
brew install --cask visual-studio-code

# Or download from: https://code.visualstudio.com
```

### Essential Extensions

**Install via VS Code UI:**

1. Open VS Code
2. Click Extensions icon (⌘+Shift+X)
3. Search and install:

**React Native Development:**

- **React Native Tools** (Microsoft) - Debugging, IntelliSense
- **Expo Tools** (Expo) - Expo project support

**Code Quality:**

- **ESLint** (Microsoft) - Linting
- **Prettier** - Code formatter
- **Error Lens** (Alexander) - Inline error display

**Git:**

- **GitLens** (GitKraken) - Git superpowers

**Productivity:**

- **Auto Rename Tag** - Rename paired HTML/JSX tags
- **Bracket Pair Colorizer** - Colorize matching brackets
- **Path Intellisense** - Autocomplete file paths
- **Import Cost** - Show package sizes

**TypeScript:**

- **TypeScript Importer** - Auto-import TypeScript definitions
- **Pretty TypeScript Errors** - Better error messages

**Optional:**

- **GitHub Copilot** ($10/month) - AI code completion
- **Tabnine** (Free alternative to Copilot)

### Configure VS Code

**Settings (⌘+,):**

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.tabSize": 2,
  "editor.fontSize": 14,
  "editor.fontFamily": "Menlo, Monaco, 'Courier New', monospace",
  "workbench.colorTheme": "Default Dark+",
  "files.autoSave": "onFocusChange",
  "terminal.integrated.defaultProfile.osx": "zsh"
}
```

### Install `code` Command in PATH

```bash
# Open VS Code
# Press ⌘+Shift+P (Command Palette)
# Type "shell command"
# Select "Shell Command: Install 'code' command in PATH"

# Verify
code --version
# Should output: 1.x.x

# Now you can open projects via terminal:
code ~/Developer/projects/scrap-survivor
```

---

## React Native Specific Tools

### Watchman (File Watcher)

```bash
# Install Watchman (improves Metro bundler performance)
brew install watchman

# Verify
watchman --version
# Should output: 2023.x.x
```

### Flipper (React Native Debugger)

```bash
# Install Flipper
brew install --cask flipper

# Or download from: https://fbflipper.com

# Flipper plugins (install from Flipper UI):
# - React DevTools
# - Network Inspector
# - Databases (SQLite)
# - Preferences (AsyncStorage)
```

### Reactotron (Zustand State Inspector)

```bash
# Install Reactotron
brew install --cask reactotron

# Or download from: https://github.com/infinitered/reactotron

# Add to project:
# pnpm add -D reactotron-react-native
```

### React Native Debugger (Alternative to Flipper)

```bash
# Install React Native Debugger
brew install --cask react-native-debugger

# Launch via:
open "rndebugger://set-debugger-loc?host=localhost&port=8081"
```

---

## Productivity Tools

### iTerm2 (Better Terminal)

```bash
# Install iTerm2
brew install --cask iterm2

# Open iTerm2 → Preferences
# - Appearance → Theme: Dark
# - Profiles → Text → Font: 14pt Menlo
# - Profiles → Keys → Left Option key: Esc+
```

### Oh My Zsh (Shell Enhancement)

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set theme (in ~/.zshrc)
sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

# Enable plugins (in ~/.zshrc)
# Find: plugins=(git)
# Replace with: plugins=(git node npm macos vscode)

# Apply changes
source ~/.zshrc
```

### Powerlevel10k (Better Zsh Theme)

```bash
# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set theme in ~/.zshrc
sed -i '' 's/ZSH_THEME="agnoster"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Apply and configure
source ~/.zshrc
# Follow the configuration wizard
```

### Rectangle (Window Management)

```bash
# Install Rectangle (free window manager)
brew install --cask rectangle

# Launch Rectangle
open -a Rectangle

# Grant accessibility permissions when prompted

# Recommended shortcuts:
# ⌃⌥ + Left/Right Arrow: Left/right half
# ⌃⌥ + Enter: Maximize
# ⌃⌥ + C: Center window
```

### Fig (Terminal Autocomplete)

```bash
# Install Fig
brew install --cask fig

# Launch Fig
open -a Fig

# Follow setup wizard

# Fig adds autocomplete to:
# - Terminal commands
# - Git commands
# - npm/pnpm scripts
# - SSH hosts
```

### Docker Desktop (PostgreSQL, Services)

```bash
# Install Docker Desktop
brew install --cask docker

# Launch Docker
open -a Docker

# Wait for Docker to start (whale icon in menu bar)

# Verify
docker --version
# Should output: Docker version 25.x.x

# Run PostgreSQL (for local Supabase development)
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16
```

### Alfred (Spotlight Alternative) - Optional

```bash
# Install Alfred (Spotlight on steroids)
brew install --cask alfred

# Launch Alfred
open -a Alfred

# Set up hotkey: ⌘+Space (replace Spotlight)
# Alfred → Preferences → General → Alfred Hotkey
```

---

## Repository Setup

### Clone scrap-survivor Repository

```bash
# Navigate to projects directory
cd ~/Developer/projects

# Clone via SSH (recommended)
git clone git@github.com:your-username/scrap-survivor.git

# Or via HTTPS
git clone https://github.com/your-username/scrap-survivor.git

# Navigate into project
cd scrap-survivor

# Install dependencies
pnpm install

# Or if using npm
npm install
```

### Branch Setup

```bash
# Check current branch
git branch

# You should be on 'stable' or 'main'

# Create feature branch for migration
git checkout -b feature/react-native-migration

# Verify
git branch
# Should show: * feature/react-native-migration
```

### Supabase Environment Variables

```bash
# Copy .env.example to .env.local
cp .env.example .env.local

# Edit .env.local
code .env.local

# Add your Supabase credentials:
# VITE_SUPABASE_URL=your-supabase-url
# VITE_SUPABASE_ANON_KEY=your-anon-key
```

### Run Existing Web App

```bash
# Start dev server
npm run dev

# Should open http://localhost:5173
# Verify the existing app works before migration
```

---

## Verification & Testing

### Test All Tools

**1. Node.js & npm:**

```bash
node --version  # Should be v20.x.x
npm --version   # Should be 10.x.x
pnpm --version  # Should be 9.x.x
```

**2. Git:**

```bash
git --version  # Should be 2.40+
gh --version   # GitHub CLI (if installed)
```

**3. Xcode:**

```bash
xcode-select -p  # Should show Xcode path
xcrun simctl list devices  # Should list iOS simulators
```

**4. Android:**

```bash
echo $ANDROID_HOME  # Should show Android SDK path
adb --version       # Should show ADB version
avdmanager list avd # Should list Android emulators
```

**5. React Native:**

```bash
expo --version  # Should be 50+
eas --version   # Should be latest
watchman --version
```

**6. VS Code:**

```bash
code --version
```

### Test iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Boot a simulator
xcrun simctl boot "iPhone 15"

# Open Simulator app
open -a Simulator
```

### Test Android Emulator

```bash
# List AVDs
emulator -list-avds

# Launch emulator
emulator -avd Pixel_5_API_34 &

# Wait for emulator to boot (1-2 minutes)

# Verify with adb
adb devices
# Should show emulator device
```

### Test Expo App

```bash
# Create a test Expo project
cd ~/Developer/projects
npx create-expo-app@latest test-app --template blank-typescript

cd test-app

# Start Expo
npx expo start

# Press 'i' for iOS simulator
# Press 'a' for Android emulator

# Should see "Open up App.tsx to start working on your app!"
```

### Run scrap-survivor Tests

```bash
cd ~/Developer/projects/scrap-survivor

# Run all tests
npm test

# Should pass 447+ tests
```

---

## Troubleshooting

### Issue: Xcode CLI Tools Not Found

**Error:** `xcode-select: error: tool 'xcodebuild' requires Xcode`

**Solution:**

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcode-select --reset
```

### Issue: Android Emulator Won't Start

**Error:** `PANIC: Cannot find AVD system path`

**Solution:**

```bash
# Check ANDROID_HOME
echo $ANDROID_HOME

# If empty, re-add to ~/.zprofile:
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zprofile
source ~/.zprofile

# Re-create AVD
avdmanager delete avd -n Pixel_5_API_34
avdmanager create avd -n Pixel_5_API_34 -k "system-images;android-34;google_apis;arm64-v8a" -d "pixel_5"
```

### Issue: Metro Bundler Port Conflict

**Error:** `Error: listen EADDRINUSE: address already in use :::8081`

**Solution:**

```bash
# Find process using port 8081
lsof -i :8081

# Kill the process
kill -9 <PID>

# Or use a different port
npx expo start --port 8082
```

### Issue: CocoaPods Installation Fails

**Error:** `You don't have write permissions for the /Library/Ruby/Gems/2.6.0 directory`

**Solution:**

```bash
# Use rbenv for Ruby version management
brew install rbenv

# Install latest Ruby
rbenv install 3.2.2
rbenv global 3.2.2

# Add to ~/.zprofile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zprofile
source ~/.zprofile

# Verify
ruby --version

# Install CocoaPods
gem install cocoapods
```

### Issue: Watchman Stuck

**Error:** `Watchman: watchman--no-pretty get-sockname returned with exit code=1`

**Solution:**

```bash
# Stop watchman
watchman shutdown-server

# Clear cache
watchman watch-del-all

# Restart Metro with cache clear
npx expo start --clear
```

---

## Checklist

Before starting React Native migration, ensure:

- [x] macOS updated to latest (Sonoma 14.0+)
- [x] Homebrew installed and updated
- [x] Git configured with user name and email
- [x] Xcode installed (15+ GB)
- [x] Xcode CLI tools installed
- [x] iOS Simulator downloaded
- [x] CocoaPods installed
- [x] Android Studio installed
- [x] Android SDK installed (API 33, 34)
- [x] Android emulator created (ARM64 for M4)
- [x] ANDROID_HOME environment variable set
- [x] nvm installed
- [x] Node.js 20 LTS installed
- [x] pnpm installed
- [x] Expo CLI installed
- [x] EAS CLI installed
- [x] Watchman installed
- [x] VS Code installed
- [x] VS Code extensions installed
- [x] iTerm2 installed (optional)
- [x] Oh My Zsh installed (optional)
- [x] Rectangle installed (optional)
- [x] Docker Desktop installed
- [x] scrap-survivor repo cloned
- [x] Project dependencies installed
- [x] Tests passing (447+)
- [x] iOS Simulator boots successfully
- [x] Android Emulator boots successfully
- [x] Expo test app runs on both platforms

**Once all checked, you're ready to start Phase 0 of the React Native migration!**

---

## Quick Reference

### Common Commands

```bash
# Start Expo dev server
npx expo start

# Start iOS simulator
npx expo start --ios

# Start Android emulator
npx expo start --android

# Clear cache
npx expo start --clear

# Run tests
npm test

# Lint code
npm run lint

# Format code
npx prettier --write .

# Update dependencies
npx npm-check-updates -u
npm install

# Check bundle size
npx expo-cli customize:web
```

### Keyboard Shortcuts (VS Code)

| Command          | Shortcut  |
| ---------------- | --------- |
| Command Palette  | ⌘+Shift+P |
| Quick Open       | ⌘+P       |
| Find in Files    | ⌘+Shift+F |
| Toggle Terminal  | ⌃+`       |
| Format Document  | ⌥+Shift+F |
| Go to Definition | F12       |
| Rename Symbol    | F2        |
| Multi-cursor     | ⌥+Click   |

---

**Document Version:** 1.0
**Last Updated:** 2025-11-01
**For:** MacBook Pro 14" M4 Max Setup
