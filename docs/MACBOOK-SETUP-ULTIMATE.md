# MacBook Pro M4 Max – Ultimate React Native & AI-Enhanced Development Setup Guide

**Device:** MacBook Pro 14” M4 Max 2024
**macOS Version:** Sonoma 14.0+
**Prepared for:** React Native, Claude/AI, Modern JS/TS, and Fullstack Development
**Setup Duration:** ~3-4 hours
**Automation:** Use `scripts/setup-mac.sh` if migrating multiple tools

---

## Table of Contents

1. Initial macOS Setup
2. Homebrew + Package Management
3. Core Dev Tools
4. Xcode & iOS
5. Android Studio & Android
6. Node.js/NVM Details
7. VS Code Extensions (AI, RN, Productivity)
8. React Native & Debugging Stack
9. Productivity/Terminal Enhancements
10. Repository & Env Setup
11. M4 Hardware Optimization & Best Practices
12. Verification: Testing, Debugging, AI Integration
13. Troubleshooting & Reference

---

## 1. Initial macOS Setup

- Enable FileVault, firewall, privacy basics
- Disable auto-correct, auto-capitalize (System Settings → Keyboard)
- Trackpad/touch/keyboard tuned for dev
- Create `~/Developer/projects` for repos
- Set appearance: dark mode recommended

## 2. Homebrew + Package Management

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
brew update && brew upgrade
brew install git gh watchman ccache mas
```

_M4-specific:_

```bash
sudo chmod 2777 /opt/homebrew/var/run/watchman # Required for multi-user & fast builds
```

## 3. Core Dev Tools

- **Git** – `brew install git`
- **GitHub CLI** – `brew install gh`
- Configure with username/email, set VS Code as `$EDITOR`

## 4. Xcode & iOS

- Install from App Store (recommended)
- Run Xcode once to accept license
- Install Command Line tools:

```bash
xcode-select --install
sudo xcodebuild -license accept
```

- Download latest iOS simulator in Xcode
- Install CocoaPods:

```bash
sudo gem install cocoapods
pod setup
```

## 5. Android Studio & Android

- `brew install --cask android-studio`
- In Android Studio: install SDK, AVD for ARM64
- Set environment vars in `~/.zprofile`:

```bash
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zprofile
source ~/.zprofile
```

- Create emulator via UI or CLI (`system-images;android-34;google_apis;arm64-v8a`)
- Verify with `adb --version` and AVD launch

## 6. Node.js/NVM Details

- Install NVM:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zprofile
```

- Node.js 20+:

```bash
nvm install 20
nvm alias default 20
```

- Fast package manager:

```bash
npm install -g pnpm
pnpm setup
```

## 7. VS Code Extensions (AI, RN, Productivity)

- **VS Code:**

```bash
brew install --cask visual-studio-code
```

- Recommended extensions:
  - React Native Tools (Microsoft)
  - Expo Tools (Expo)
  - ESLint, Prettier
  - GitLens
  - Error Lens (inline errors)
  - Auto Rename Tag, Path Intellisense
  - Import Cost
  - Thunder Client (REST API testing)
  - Claude Dev (AI assist for code/completion/chat)
  - Claude Debugs for You (AI log/debugging)
  - Turbo Console Log (console log productivity)
  - In Your Face (alerts for missed warnings)
  - TypeScript Importer, Pretty TypeScript Errors

**AI/Claude Integration:**

- Install Claude Dev & Claude Debugs for You from marketplace
- Follow onboarding to connect Claude account/API key (if required)

## 8. React Native & Debugging Stack

**Main tools:**

- Watchman
- Flipper (comprehensive debugger)
  - Install via Homebrew: `brew install --cask flipper`
  - Add plugin: `npm install react-native-flipper`
  - Configure pods (iOS): pod install
  - Launch and connect to project
- Sentry (error/performance monitoring)
  - Setup: `npx @sentry/wizard@latest -i reactNative`
  - Verify crash/error tracking
- React Native DevTools profiler
  - Launch with `npx react-native start` then `j` for DevTools
- Log viewing:

```bash
react-native log-ios
react-native log-android
```

- Reactotron (for state inspection; Zustand/Redux support)
- TanStack Query DevTools (for hooks/query debugging)

## 9. Productivity/Terminal Enhancements

- **iTerm2**: Homebrew install, dark theme, Menlo font
- **Oh My Zsh**: Shell enhancement (`robbyrussell` or `powerlevel10k` theme)
- **Powerlevel10k**: Fast prompt, status display
- **Rectangle**: Window management shortcuts
- **Fig**: Autocomplete for CLI/terminal
- **Docker Desktop**: Run local services (e.g. Postgres)
- **Alfred (optional)**: Enhanced Spotlight/search

## 10. Repository & Env Setup

- Clone repo to `~/Developer/projects`
- Branch, run setup scripts
- Configure Supabase or other API/service credentials in `.env.local`

## 11. M4 Hardware Optimization & Best Practices

- Min RAM: 36GB for multitasking
- Enable Metal GPU acceleration (iOS Simulator)
- Use ccache for builds

```bash
brew install ccache
```

- Use parallel build flags where available
- Monitor Watchman permissions if multi-user setup

## 12. Verification: Testing, Debugging, AI Integration

Check:

- Node/npm/pnpm versions correct
- Xcode/iOS/Android simulator boot
- All emulators run
- Expo CLI and EAS CLI working
- VS Code loads all key extensions (React Native, Claude, Thunder Client, etc)
- Flipper connects and displays RN logs/network/DB
- Sentry initializes and displays events
- Claude can debug in VS Code and analyze logs
- API debugging works (Thunder Client)
- DevTools profiler launches and profiles app
- Production error tracking receives events

## 13. Troubleshooting & Reference

**Common issues:**

- Watchman permission fix:

```bash
sudo chmod 2777 /opt/homebrew/var/run/watchman
```

- Xcode license:

```bash
sudo xcodebuild -license accept
```

- Expo/Metro cache clear:

```bash
npx expo start --clear
```

- CocoaPods install via rbenv (if permissions issue):

```bash
brew install rbenv
rbenv install 3.2.2
rbenv global 3.2.2
gem install cocoapods
```

- Emulator troubleshooting (`ANDROID_HOME`, ARM64 images)
- Make sure all AI extensions in VS Code have valid API/credentials

---

## Quick Commands (Reference)

```bash
npx expo start
npx expo start --ios
npx expo start --android
npm test
npm run lint
pnpm install
react-native log-ios
react-native log-android
code ~/Developer/projects/project-name
```

---

## Checklists

- [x] macOS updated
- [x] Homebrew setup & updated
- [x] Git/GitHub CLI configured
- [x] Xcode/CLI tools/iOS Simulator ready
- [x] Android Studio/SDK/AVD ready
- [x] CocoaPods/rbenv
- [x] Android env vars set
- [x] NVM/Node/pnpm/expo installed
- [x] Watchman installed + permissions fixed
- [x] VS Code installed w/ all AI/RN extensions
- [x] iTerm2, Zsh, and window mgmt setup
- [x] Repo cloned, .env ready
- [x] All tests run
- [x] Flipper, Sentry, DevTools profiling verified
- [x] Claude AI debugging/log review works

---

**Version:** 2.0 (Generated Nov 2, 2025)
**Device:** MacBook Pro 14” M4 Max
**Contact:** For support, reach out via Slack team or codebase README
