# React Native Migration Plan

## Scrap Survivor: Full Migration from Capacitor+Phaser to React Native+Expo

**Status:** Approved
**Start Date:** TBD (Post-Sprint 17)
**Estimated Duration:** 21-24 weeks (5-6 months)
**Code Reuse:** 68% (services/state/types = 95%+)
**Risk Level:** Medium
**Decision:** Hard pivot to React Native (skip Phaser optimization)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Required Services & Accounts](#required-services--accounts)
3. [Development Environment](#development-environment)
4. [Phase 0: Setup & Foundation](#phase-0-setup--foundation)
5. [Phase 1: UI Foundation](#phase-1-ui-foundation)
6. [Phase 2: Hub UI Components](#phase-2-hub-ui-components)
7. [Phase 3: Game Engine Migration](#phase-3-game-engine-migration)
8. [Phase 4: Integration & Testing](#phase-4-integration--testing)
9. [Phase 5: Deployment](#phase-5-deployment)
10. [Timeline & Milestones](#timeline--milestones)
11. [Risk Mitigation](#risk-mitigation)
12. [Success Metrics](#success-metrics)

---

## Executive Summary

### Why We're Migrating

**From:** React + Capacitor + Phaser (WebView-based)
**To:** React Native + Expo (True native)

**Key Drivers:**

1. **OTA Updates:** Ship bug fixes in 30 seconds vs 1-2 days App Store review
2. **Native Performance:** 60 FPS guaranteed vs ~45 FPS WebView ceiling
3. **Better UX:** Players can feel the difference - native is smoother
4. **AI-Friendly:** Single TypeScript codebase (easier for Claude to help)
5. **Long-term Viability:** React Native is proven for production games

### What We're Keeping

**95%+ of business logic:**

- All 20 services (Supabase, Banking, Inventory, etc.)
- All Zustand stores (state management)
- All types & config files (weapons, items, enemies)
- All utilities

**This is not a rewrite - it's an architecture upgrade.**

### Architecture Comparison

**Current:**

```
Capacitor Shell
  └─> WebView
       └─> React + Phaser
            ├─> Services
            ├─> State
            └─> UI
```

**Target:**

```
React Native (Expo)
  ├─> packages/core/        # Shared (95% reusable!)
  │    ├─> services/
  │    ├─> store/
  │    ├─> types/
  │    └─> config/
  ├─> packages/native/      # New RN app
  │    ├─> screens/         # UI (70% logic reuse)
  │    └─> game/            # Game engine (40% logic reuse)
  └─> packages/web/         # Old app (reference, then deprecate)
```

---

## Required Services & Accounts

### Critical Services (Required Before Phase 0)

#### 1. Expo Account

**Purpose:** Build, deploy, and OTA updates
**Cost:**

- **Free Tier:** Development only (local builds)
- **Production Tier:** $99/month (EAS Build + Updates)
  - Unlimited OTA updates
  - Cloud builds (iOS + Android)
  - Team collaboration

**When to Sign Up:** **Before Phase 0 (Week 1)**
**URL:** https://expo.dev/signup
**Notes:** Start with free tier, upgrade to production when ready to deploy (Phase 5)

#### 2. Apple Developer Account

**Purpose:** iOS development & App Store deployment
**Cost:** $99/year (mandatory)
**When to Sign Up:** **Before Phase 3 (Week 9)** - Needed for iOS Simulator
**URL:** https://developer.apple.com/programs/
**Notes:** Requires Apple ID, takes 24-48 hours for approval

#### 3. Google Play Console

**Purpose:** Android deployment
**Cost:** $25 one-time fee
**When to Sign Up:** **Before Phase 5 (Week 20)** - Deployment only
**URL:** https://play.google.com/console/signup
**Notes:** Requires Google account, instant approval

### Recommended Services (Optional but Valuable)

#### 4. GitHub Copilot

**Purpose:** AI code completion (pairs with Claude)
**Cost:** $10/month (or $100/year)
**When to Sign Up:** **Before Phase 1** (Day 1)
**URL:** https://github.com/features/copilot
**Notes:** Dramatically speeds up React Native component conversion

#### 5. Sentry (Error Tracking)

**Purpose:** Production crash reporting
**Cost:** Free tier (10k events/month), $26/month for growth
**When to Sign Up:** **Before Phase 4** (Week 17)
**URL:** https://sentry.io/signup/
**Notes:** Critical for production debugging

#### 6. Amplitude / Mixpanel (Analytics)

**Purpose:** User behavior tracking, A/B testing
**Cost:** Free tier (10M events/month), then usage-based
**When to Sign Up:** **Before Phase 5** (Week 20)
**URL:** https://amplitude.com or https://mixpanel.com
**Notes:** Integrate during deployment phase

### Cost Summary

| Service                 | When Needed        | Cost        | Frequency | Annual Cost      |
| ----------------------- | ------------------ | ----------- | --------- | ---------------- |
| **Expo (Dev)**          | Week 1             | $0          | Free      | $0               |
| **Expo (Prod)**         | Week 20            | $99/month   | Monthly   | $1,188           |
| **Apple Developer**     | Week 9             | $99         | Yearly    | $99              |
| **Google Play**         | Week 20            | $25         | One-time  | $25 (first year) |
| **GitHub Copilot**      | Week 1 (optional)  | $10/month   | Monthly   | $120             |
| **Sentry**              | Week 17 (optional) | $0-26/month | Monthly   | $0-312           |
| **TOTAL (Minimum)**     | -                  | -           | -         | **$1,312/year**  |
| **TOTAL (Recommended)** | -                  | -           | -         | **$1,744/year**  |

**Pre-Launch (Development Only):**

- Months 1-5: **$10/month** (just Copilot, optional)
- Month 6 (Launch): Add Expo ($99) + Sentry ($26) = **$135/month**

---

## Development Environment

### MacBook Pro M4 Max Setup

**Hardware:**

- MacBook Pro 14" M4 Max
- 36GB+ RAM recommended
- 512GB+ SSD

**Required Software:**

- macOS Sonoma 14.0+ (latest)
- Xcode 15+ (for iOS development)
- Android Studio (for Android development)
- Node.js 20 LTS (via nvm)
- VS Code (editor)
- Docker Desktop (PostgreSQL)

**Full setup guide:** See [MACBOOK-SETUP.md](./MACBOOK-SETUP.md)
**Automation script:** See `scripts/setup-mac.sh`

### WSL Setup (Current Environment)

**For reference only - Mac will be primary going forward**

- Windows 11 + Ubuntu WSL
- Node.js 18+ (via nvm)
- VS Code (Windows) + Remote WSL extension

**Reference script:** See `scripts/setup-wsl.sh`

---

## Phase 0: Setup & Foundation

**Duration:** 1-2 weeks
**Goal:** Monorepo setup, core package extraction, RN app initialization

### Prerequisites

- [ ] Expo account created (free tier)
- [ ] MacBook Pro M4 Max received and set up
- [ ] Development environment installed (see MACBOOK-SETUP.md)
- [ ] Sprint 17 complete (clean baseline)

### Tasks

#### Week 1: Monorepo Structure

**1. Install Dependencies**

```bash
# Install Expo CLI globally
npm install -g expo-cli eas-cli

# Install workspace tooling
npm install -g pnpm  # Faster than npm for monorepos
```

**2. Create Monorepo Structure**

```bash
# At project root
mkdir -p packages/core packages/native

# Initialize workspace
cat > package.json <<EOF
{
  "name": "scrap-survivor-monorepo",
  "private": true,
  "workspaces": [
    "packages/core",
    "packages/web",
    "packages/native"
  ],
  "scripts": {
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint"
  }
}
EOF
```

**3. Extract Core Package**

```bash
# Move existing src/ to packages/web/
mv src packages/web/src
mv public packages/web/public
mv index.html packages/web/index.html

# Create core package
mkdir -p packages/core
cd packages/core

# Initialize package
cat > package.json <<EOF
{
  "name": "@scrap-survivor/core",
  "version": "1.0.0",
  "main": "index.ts",
  "dependencies": {
    "@supabase/supabase-js": "^2.58.0",
    "zustand": "^5.0.8",
    "immer": "^10.1.1"
  }
}
EOF

# Move shared code
mv ../web/src/services ./services
mv ../web/src/store ./store
mv ../web/src/types ./types
mv ../web/src/config ./config
mv ../web/src/utils ./utils

# Create index.ts barrel export
cat > index.ts <<EOF
// Services
export * from './services';

// State
export * from './store';

// Types
export * from './types';

// Config
export * from './config';

// Utils
export * from './utils';
EOF
```

**4. Update Web App Imports**

```typescript
// packages/web/src/components/ShopOverlay.tsx

// OLD
import { BankingService } from '@/services/BankingService';
import { useGameStore } from '@/store/gameStore';

// NEW
import { BankingService, useGameStore } from '@scrap-survivor/core';
```

**5. Initialize React Native App**

```bash
cd packages/native

# Create Expo app
npx create-expo-app@latest . --template blank-typescript

# Configure app.json
cat > app.json <<EOF
{
  "expo": {
    "name": "Scrap Survivor",
    "slug": "scrap-survivor",
    "version": "1.0.0",
    "orientation": "landscape",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#1a1a1a"
    },
    "platforms": ["ios", "android"],
    "ios": {
      "bundleIdentifier": "com.yourcompany.scrapsurvivor",
      "supportsTablet": true
    },
    "android": {
      "package": "com.yourcompany.scrapsurvivor",
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#1a1a1a"
      }
    }
  }
}
EOF

# Install core package
pnpm add @scrap-survivor/core
```

**6. Verify Core Package in RN**

```typescript
// packages/native/App.tsx
import { supabase, useGameStore } from '@scrap-survivor/core';
import { useEffect } from 'react';

export default function App() {
  const user = useGameStore((state) => state.user);

  useEffect(() => {
    // Test Supabase connection
    supabase.auth.getSession().then(({ data }) => {
      console.log('Session:', data);
    });
  }, []);

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>Scrap Survivor - React Native</Text>
      <Text>User: {user?.email || 'Not logged in'}</Text>
    </View>
  );
}
```

**7. Run Tests**

```bash
# Run existing tests against core package
cd packages/core
pnpm test

# Verify all tests still pass
```

### Deliverables

- [x] Monorepo with 3 packages (core, web, native)
- [x] Core package with 95% of business logic
- [x] RN app boots and imports core package
- [x] Supabase client works in RN
- [x] All existing tests passing

### Success Criteria

- `npx expo start` runs successfully
- Core package imports work in RN
- Supabase authentication works
- All 447+ tests passing

---

## Phase 1: UI Foundation

**Duration:** 2 weeks
**Goal:** Design system, navigation, core screens

### Tasks

#### Week 2: Design System

**1. Install UI Dependencies**

```bash
cd packages/native

pnpm add react-navigation @react-navigation/native @react-navigation/stack
pnpm add react-native-reanimated react-native-gesture-handler
pnpm add react-native-toast-message
pnpm add @react-native-async-storage/async-storage
pnpm add expo-font expo-linear-gradient
```

**2. Port Design Tokens**

```typescript
// packages/native/src/theme/designTokens.ts

import { Platform, StyleSheet } from 'react-native';

export const colors = {
  // Port from packages/core/config/designTokens.ts
  background: '#0a0a0a',
  surface: '#1a1a1a',
  primary: '#10b981',
  // ... rest of colors
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
};

export const typography = {
  h1: StyleSheet.create({
    text: {
      fontSize: 32,
      fontWeight: 'bold',
      color: colors.text.primary,
    },
  }),
  // ... rest of typography
};
```

**3. Create Base Components**

```typescript
// packages/native/src/components/base/Button.tsx

import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { colors, spacing } from '@/theme/designTokens';

interface ButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  loading?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  onPress,
  children,
  variant = 'primary',
  disabled = false,
  loading = false,
}) => {
  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      style={[
        styles.button,
        styles[variant],
        (disabled || loading) && styles.disabled
      ]}
    >
      {loading ? (
        <ActivityIndicator color={colors.text.primary} />
      ) : (
        <Text style={styles.text}>{children}</Text>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    padding: spacing.md,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primary: {
    backgroundColor: colors.primary,
  },
  secondary: {
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
  },
  danger: {
    backgroundColor: colors.danger,
  },
  disabled: {
    opacity: 0.5,
  },
  text: {
    color: colors.text.primary,
    fontSize: 16,
    fontWeight: '600',
  },
});
```

**Repeat for:**

- Card
- Modal
- Input
- Header

#### Week 3: Navigation & Core Screens

**4. Set Up Navigation**

```typescript
// packages/native/src/navigation/AppNavigator.tsx

import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { AuthScreen } from '@/screens/AuthScreen';
import { CharacterSelectScreen } from '@/screens/CharacterSelectScreen';
import { HubScreen } from '@/screens/HubScreen';
import { GameScreen } from '@/screens/GameScreen';

const Stack = createStackNavigator();

export const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Auth"
        screenOptions={{
          headerShown: false,
          gestureEnabled: false,
        }}
      >
        <Stack.Screen name="Auth" component={AuthScreen} />
        <Stack.Screen name="CharacterSelect" component={CharacterSelectScreen} />
        <Stack.Screen name="Hub" component={HubScreen} />
        <Stack.Screen name="Game" component={GameScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

**5. Migrate Auth Screen**

```typescript
// packages/native/src/screens/AuthScreen.tsx

import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { supabase } from '@scrap-survivor/core';
import { Button, Input, Card } from '@/components/base';
import { useNavigation } from '@react-navigation/native';

export const AuthScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const navigation = useNavigation();

  const handleLogin = async () => {
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });

    if (!error) {
      navigation.navigate('CharacterSelect');
    }

    setLoading(false);
  };

  return (
    <View style={styles.container}>
      <Card>
        <Input
          placeholder="Email"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
        />
        <Input
          placeholder="Password"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />
        <Button onPress={handleLogin} loading={loading}>
          Login
        </Button>
      </Card>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#0a0a0a',
  },
});
```

**6. Replace LocalStorage with AsyncStorage**

```typescript
// packages/core/services/LocalStorageService.ts

// Add platform detection
import AsyncStorage from '@react-native-async-storage/async-storage';

const isNative = typeof window === 'undefined';

export class LocalStorageService {
  async get(key: string): Promise<string | null> {
    if (isNative) {
      return await AsyncStorage.getItem(key);
    }
    return localStorage.getItem(key);
  }

  async set(key: string, value: string): Promise<void> {
    if (isNative) {
      await AsyncStorage.setItem(key, value);
    } else {
      localStorage.setItem(key, value);
    }
  }

  // ... rest of methods
}
```

### Deliverables

- [x] Design system with base components
- [x] Navigation structure (4 main screens)
- [x] Auth screen functional
- [x] AsyncStorage integration working

### Success Criteria

- Login flow works end-to-end
- Navigation between screens smooth
- Design matches existing app aesthetic
- All components reusable

---

## Phase 2: Hub UI Components

**Duration:** 4 weeks
**Goal:** Migrate all hub overlays and UI components

### Component Migration Pattern

**For each component, follow this pattern:**

1. **Copy from web app**
2. **Convert JSX:**
   - `<div>` → `<View>`
   - `<span>`, `<p>` → `<Text>`
   - `<button>` → `<TouchableOpacity>`
3. **Convert styles:**
   - `className` → `style={styles.x}`
   - CSS object → `StyleSheet.create()`
4. **Keep logic unchanged:**
   - `useState`, `useEffect`, `useMemo` - same
   - Service calls - same
   - Event handlers - `onClick` → `onPress`

### Week 4-5: Shop Overlay

**Example: ItemCard Component**

```typescript
// packages/web/src/components/ui/ItemCard.tsx (OLD)

export const ItemCard: React.FC<Props> = ({ item, onPurchase }) => {
  return (
    <div className="item-card">
      <span className="item-name">{item.name}</span>
      <button onClick={onPurchase}>Buy</button>
    </div>
  );
};
```

```typescript
// packages/native/src/components/ItemCard.tsx (NEW)

import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

export const ItemCard: React.FC<Props> = ({ item, onPurchase }) => {
  return (
    <View style={styles.card}>
      <Text style={styles.name}>{item.name}</Text>
      <TouchableOpacity onPress={onPurchase} style={styles.button}>
        <Text style={styles.buttonText}>Buy</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    padding: 16,
    backgroundColor: '#1a1a1a',
    borderRadius: 8,
  },
  name: {
    fontSize: 18,
    color: '#ffffff',
    fontWeight: 'bold',
  },
  button: {
    marginTop: 8,
    padding: 12,
    backgroundColor: '#10b981',
    borderRadius: 4,
  },
  buttonText: {
    color: '#ffffff',
    textAlign: 'center',
  },
});
```

**Components to migrate:**

- ItemCard
- ShopOverlay
- ShopFilters
- ShopTabs

**Estimated time:** 1 week

### Week 6: Workshop Overlay

**Components:**

- WorkshopOverlay
- CraftTab
- RepairTab
- FusionTab
- WorkshopActionButton

**Services reused (no changes):**

- WorkshopService
- RecyclerService
- InventoryService

**Estimated time:** 1 week

### Week 7: Bank & Inventory

**Bank components:**

- BankOverlay
- BankDepositTab
- BankWithdrawTab
- BankHistoryTab

**Inventory components:**

- InventoryScreen
- CharacterInspector
- EquippedWeaponsUI

**Services reused:**

- BankingService
- InventoryService

**Estimated time:** 1 week

### Week 8: Modals & Polish

**Modals:**

- ErrorModal (already has setReactModalOpen!)
- ConfirmationModal
- UpgradeModal
- DeathModal
- WaveCompleteModal

**Replace framer-motion:**

```typescript
// OLD
import { motion } from 'framer-motion';

<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
>
  {children}
</motion.div>

// NEW
import Animated, { FadeIn } from 'react-native-reanimated';

<Animated.View entering={FadeIn}>
  {children}
</Animated.View>
```

**Estimated time:** 1 week

### Deliverables

- [x] All 38 UI components migrated
- [x] All hub overlays functional
- [x] Navigation between overlays working
- [x] Animations smooth

### Success Criteria

- Can navigate: Auth → Character Select → Hub → Shop/Workshop/Bank
- All service integrations working
- UI matches web app aesthetic
- 60 FPS scrolling/animations

---

## Phase 3: Game Engine Migration

**Duration:** 8 weeks
**Goal:** Reimplement Wasteland gameplay in React Native

### Week 9-10: Game Engine Setup

**1. Install react-native-game-engine**

```bash
cd packages/native
pnpm add react-native-game-engine
```

**2. Create Game Architecture**

```
packages/native/src/game/
├── entities/
│   ├── Player.ts
│   ├── Enemy.ts
│   └── Projectile.ts
├── systems/
│   ├── InputSystem.ts
│   ├── PhysicsSystem.ts
│   ├── CollisionSystem.ts
│   ├── AISystem.ts
│   ├── WeaponSystem.ts
│   └── WaveSystem.ts
├── renderers/
│   ├── PlayerRenderer.tsx
│   ├── EnemyRenderer.tsx
│   └── ProjectileRenderer.tsx
└── GameScreen.tsx
```

**3. Port Game Constants**

```typescript
// packages/core/config/gameConstants.ts already exists!
// Just import it in RN:

import { PLAYER_SPEED, WEAPON_STATS } from '@scrap-survivor/core';
```

**4. Create Basic Game Screen**

```typescript
// packages/native/src/game/GameScreen.tsx

import { GameEngine } from 'react-native-game-engine';
import { InputSystem } from './systems/InputSystem';
import { PhysicsSystem } from './systems/PhysicsSystem';

export const GameScreen = () => {
  const [entities, setEntities] = useState({
    player: {
      position: [400, 300],
      velocity: [0, 0],
      health: 100,
      renderer: <PlayerRenderer />
    }
  });

  return (
    <GameEngine
      systems={[InputSystem, PhysicsSystem]}
      entities={entities}
      style={{ flex: 1, backgroundColor: '#0a0a0a' }}
    />
  );
};
```

### Week 11-12: Player & Input

**1. Implement Player Entity**

```typescript
// packages/native/src/game/entities/Player.ts

import { PLAYER_SPEED } from '@scrap-survivor/core';

export const createPlayer = (x: number, y: number) => ({
  type: 'player',
  position: [x, y],
  velocity: [0, 0],
  health: 100,
  maxHealth: 100,
  speed: PLAYER_SPEED,
  size: 32,
  renderer: <PlayerRenderer />
});
```

**2. Implement Input System (Virtual Joystick)**

```typescript
// packages/native/src/game/systems/InputSystem.ts

import { PanGestureHandler } from 'react-native-gesture-handler';

export const InputSystem = (entities, { touches }) => {
  const player = entities.player;

  // Virtual joystick input
  if (touches.length > 0) {
    const touch = touches[0];
    const dx = touch.delta.x;
    const dy = touch.delta.y;

    player.velocity[0] = dx * player.speed;
    player.velocity[1] = dy * player.speed;
  } else {
    // No input = stop moving
    player.velocity[0] = 0;
    player.velocity[1] = 0;
  }

  return entities;
};
```

**3. Implement Physics System**

```typescript
// packages/native/src/game/systems/PhysicsSystem.ts

export const PhysicsSystem = (entities, { time }) => {
  const { delta } = time;

  Object.values(entities).forEach((entity: any) => {
    if (entity.velocity) {
      // Update position
      entity.position[0] += entity.velocity[0] * delta;
      entity.position[1] += entity.velocity[1] * delta;

      // Boundary checking
      entity.position[0] = Math.max(0, Math.min(800, entity.position[0]));
      entity.position[1] = Math.max(0, Math.min(600, entity.position[1]));
    }
  });

  return entities;
};
```

**4. Create Player Renderer**

```typescript
// packages/native/src/game/renderers/PlayerRenderer.tsx

import { Image } from 'react-native';

export const PlayerRenderer: React.FC<{ position: [number, number] }> = ({ position }) => {
  return (
    <Image
      source={require('@/assets/player.png')}
      style={{
        position: 'absolute',
        left: position[0],
        top: position[1],
        width: 32,
        height: 32,
      }}
    />
  );
};
```

### Week 13-14: Combat & Enemies

**1. Port WeaponSystem Logic (40% reusable)**

```typescript
// packages/native/src/game/systems/WeaponSystem.ts

import { WEAPON_STATS } from '@scrap-survivor/core';

export const WeaponSystem = (entities, { time }) => {
  const player = entities.player;
  const weapon = player.weapon;

  if (!weapon) return entities;

  // Increment fire timer
  weapon.fireTimer += time.delta;

  // Check if can fire
  const weaponStats = WEAPON_STATS[weapon.type];
  if (weapon.fireTimer >= weaponStats.fireRate && weapon.autoFire) {
    // Spawn projectile
    const projectileId = `projectile_${Date.now()}`;
    entities[projectileId] = createProjectile(player.position, weapon.direction, weaponStats);

    weapon.fireTimer = 0;
  }

  return entities;
};
```

**2. Port EnemyAI Logic (50% reusable)**

```typescript
// packages/native/src/game/systems/AISystem.ts

import { DirectChaseStrategy, ZigZagStrategy } from '@scrap-survivor/core';

export const AISystem = (entities) => {
  const player = entities.player;

  Object.values(entities).forEach((entity: any) => {
    if (entity.type === 'enemy') {
      // Reuse AI strategy logic!
      const strategy = entity.aiStrategy;
      const movement = strategy.calculateMovement(entity, player);

      entity.velocity[0] = movement.x * entity.speed;
      entity.velocity[1] = movement.y * entity.speed;
    }
  });

  return entities;
};
```

**3. Implement Collision System**

```typescript
// packages/native/src/game/systems/CollisionSystem.ts

const checkCollision = (a: Entity, b: Entity): boolean => {
  const dx = a.position[0] - b.position[0];
  const dy = a.position[1] - b.position[1];
  const distance = Math.sqrt(dx * dx + dy * dy);

  return distance < (a.size + b.size) / 2;
};

export const CollisionSystem = (entities) => {
  const projectiles = Object.values(entities).filter((e: any) => e.type === 'projectile');
  const enemies = Object.values(entities).filter((e: any) => e.type === 'enemy');

  // Projectile-enemy collisions
  projectiles.forEach((projectile: any) => {
    enemies.forEach((enemy: any) => {
      if (checkCollision(projectile, enemy)) {
        enemy.health -= projectile.damage;
        projectile.active = false;

        if (enemy.health <= 0) {
          enemy.active = false;
          // Emit event for scrap drop, etc.
        }
      }
    });
  });

  // Remove inactive entities
  Object.keys(entities).forEach((key) => {
    if (entities[key].active === false) {
      delete entities[key];
    }
  });

  return entities;
};
```

### Week 15-16: Wave System & Integration

**1. Port WaveSystem Logic (60% reusable)**

```typescript
// packages/native/src/game/systems/WaveSystem.ts

import { WAVE_DEFINITIONS } from '@scrap-survivor/core';

export const WaveSystem = (entities, { time }) => {
  const waveManager = entities.waveManager;

  if (!waveManager) return entities;

  waveManager.timer += time.delta;

  // Check if wave complete
  const enemiesAlive = Object.values(entities).filter((e: any) => e.type === 'enemy').length;

  if (enemiesAlive === 0 && !waveManager.spawning) {
    // Wave complete!
    waveManager.currentWave++;
    waveManager.spawning = true;
  }

  // Spawn enemies
  if (waveManager.spawning) {
    const waveConfig = WAVE_DEFINITIONS[waveManager.currentWave];

    waveConfig.enemies.forEach((enemyConfig) => {
      const enemyId = `enemy_${Date.now()}_${Math.random()}`;
      entities[enemyId] = createEnemy(enemyConfig);
    });

    waveManager.spawning = false;
  }

  return entities;
};
```

**2. Integrate with React State**

```typescript
// packages/native/src/game/GameScreen.tsx

import { useRunStore } from '@scrap-survivor/core';

export const GameScreen = () => {
  const runStore = useRunStore();
  const [entities, setEntities] = useState(initialEntities);

  const handleGameEvent = (event: string, data: any) => {
    switch (event) {
      case 'wave-complete':
        runStore.incrementWave();
        break;
      case 'enemy-killed':
        runStore.addKill();
        runStore.addScrap(data.scrapEarned);
        break;
      case 'player-death':
        // Navigate to death modal
        navigation.navigate('DeathModal');
        break;
    }
  };

  return (
    <GameEngine
      systems={[InputSystem, PhysicsSystem, WeaponSystem, AISystem, CollisionSystem, WaveSystem]}
      entities={entities}
      onEvent={handleGameEvent}
    />
  );
};
```

### Deliverables

- [x] Player movement functional
- [x] Enemies spawn and chase player
- [x] Weapons fire projectiles
- [x] Collisions detected
- [x] Wave progression working
- [x] Game loop integrated with React state

### Success Criteria

- 60 FPS gameplay with 50 entities
- Smooth controls on device
- All game systems working
- Death/wave-complete events firing correctly

---

## Phase 4: Integration & Testing

**Duration:** 3 weeks
**Goal:** E2E integration, testing, performance optimization

### Week 17: Full Integration

**1. Connect Game to Services**

```typescript
// When run ends, save to Supabase
const handleRunEnd = async (results: RunResults) => {
  await characterService.updateCharacter(character.id, {
    currency: character.currency + results.scrapEarned,
    stats: {
      ...character.stats,
      totalKills: character.stats.totalKills + results.kills,
    },
  });

  await bankingService.deposit(results.scrapEarned, 'Run completion');
};
```

**2. Test Full Flow**

- Auth → Character Select → Hub → Shop (buy item) → Game → Death → Hub
- Verify scrap earned
- Verify currency deduction
- Verify character stats updated

### Week 18: Testing

**1. Unit Tests**

```typescript
// packages/core/__tests__/services/BankingService.test.ts
// These tests already exist! Just run them in RN environment

import { BankingService } from '@scrap-survivor/core';

describe('BankingService (React Native)', () => {
  it('should deposit scrap', async () => {
    const result = await bankingService.deposit(100, 'Test');
    expect(result.success).toBe(true);
  });
});
```

**2. Component Tests**

```typescript
// packages/native/__tests__/components/ItemCard.test.tsx

import { render, fireEvent } from '@testing-library/react-native';
import { ItemCard } from '@/components/ItemCard';

test('renders item and handles purchase', () => {
  const mockPurchase = jest.fn();
  const { getByText } = render(
    <ItemCard item={{ name: 'Pistol' }} onPurchase={mockPurchase} />
  );

  const buyButton = getByText('Buy');
  fireEvent.press(buyButton);

  expect(mockPurchase).toHaveBeenCalled();
});
```

**3. E2E Tests (Detox)**

```bash
# Install Detox
pnpm add -D detox jest-circus

# Configure
npx detox init

# Write E2E test
# packages/native/e2e/gameplay.e2e.ts

describe('Gameplay Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('should complete full gameplay loop', async () => {
    // Login
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();

    // Select character
    await element(by.id('character-1')).tap();

    // Enter game
    await element(by.id('enter-wasteland')).tap();

    // Play for 10 seconds
    await new Promise(resolve => setTimeout(resolve, 10000));

    // Die or complete wave
    await expect(element(by.id('death-modal'))).toBeVisible();
  });
});
```

### Week 19: Performance Optimization

**1. FPS Monitoring**

```typescript
// Add FPS counter
import { PerformanceMonitor } from 'react-native-performance';

<PerformanceMonitor>
  <GameEngine ... />
</PerformanceMonitor>
```

**2. Object Pooling**

```typescript
// packages/native/src/game/utils/ProjectilePool.ts

class ProjectilePool {
  private pool: Projectile[] = [];

  get(): Projectile {
    if (this.pool.length > 0) {
      return this.pool.pop()!;
    }
    return createProjectile();
  }

  release(projectile: Projectile) {
    projectile.active = false;
    this.pool.push(projectile);
  }
}
```

**3. Render Culling**

```typescript
// Only render entities on screen
const isOnScreen = (entity: Entity): boolean => {
  return (
    entity.position[0] > -50 &&
    entity.position[0] < 850 &&
    entity.position[1] > -50 &&
    entity.position[1] < 650
  );
};
```

### Deliverables

- [x] Full app flow tested (E2E)
- [x] Unit tests migrated and passing
- [x] 60 FPS with 150 entities
- [x] No memory leaks

### Success Criteria

- All tests passing (unit + integration + E2E)
- 60 FPS on iPhone 12 / Pixel 5
- Cold start < 3 seconds
- No crashes during 30-min session

---

## Phase 5: Deployment

**Duration:** 3 weeks
**Goal:** App Store + Play Store launch

### Week 20: Build Configuration

#### Prerequisites

- [ ] Apple Developer account active ($99/year)
- [ ] Google Play Console account active ($25 one-time)
- [ ] Expo production account active ($99/month)
- [ ] App assets ready (icon, splash, screenshots)

**1. Configure EAS Build**

```bash
# Initialize EAS
eas build:configure

# eas.json will be created:
{
  "build": {
    "production": {
      "ios": {
        "distribution": "store",
        "bundleIdentifier": "com.yourcompany.scrapsurvivor",
        "buildNumber": "1"
      },
      "android": {
        "distribution": "store",
        "package": "com.yourcompany.scrapsurvivor",
        "versionCode": 1
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id@example.com",
        "ascAppId": "123456789"
      },
      "android": {
        "serviceAccountKeyPath": "./google-play-key.json"
      }
    }
  }
}
```

**2. Generate App Icons**

```bash
# Use Expo asset generator
npx expo-optimize

# Or manually create:
# - iOS: 1024x1024 (App Store)
# - Android: 512x512 (Play Store)
```

**3. Create Screenshots**

- iPhone 14 Pro Max (6.7")
- iPhone 14 (6.1")
- iPad Pro 12.9"
- Android Phone
- Android Tablet

### Week 21: TestFlight & Beta

**1. Build for iOS**

```bash
# Build
eas build --platform ios --profile production

# Wait 15-20 minutes for cloud build

# Submit to TestFlight
eas submit --platform ios --latest
```

**2. Build for Android**

```bash
# Build
eas build --platform android --profile production

# Submit to Internal Testing
eas submit --platform android --latest --track internal
```

**3. Beta Testing**

- Invite 10-20 beta testers
- Collect feedback via TestFlight/Play Console
- Fix critical bugs
- Iterate

**4. Set Up OTA Updates**

```bash
# Push OTA update
eas update --branch production --message "Bug fixes"

# Users get update on next app launch (< 30 seconds!)
```

### Week 22: App Store Submission

**1. App Store Connect (iOS)**

- Upload metadata (title, description, keywords)
- Upload screenshots
- Set pricing (free)
- Set age rating
- Submit for review
- Wait 1-2 days for approval

**2. Google Play Console (Android)**

- Upload metadata
- Upload screenshots
- Set pricing (free)
- Set content rating
- Submit for review
- Usually approved within hours

**3. Launch!**

```bash
# Monitor analytics
eas logs --platform ios

# Monitor crashes
# (Sentry should be integrated by now)

# Push hotfix if needed
eas update --branch production --message "Critical bugfix"
```

### Deliverables

- [x] iOS app live on App Store
- [x] Android app live on Play Store
- [x] OTA update pipeline active
- [x] Analytics tracking users
- [x] Crash reporting working

### Success Criteria

- Apps approved by both stores
- OTA updates working (< 30 sec to deploy)
- Analytics showing user sessions
- Crash rate < 1%

---

## Timeline & Milestones

### Overall Timeline

| Phase                | Duration        | Weeks      | Cumulative     |
| -------------------- | --------------- | ---------- | -------------- |
| **0. Setup**         | 1-2 weeks       | Week 1-2   | Week 2         |
| **1. UI Foundation** | 2 weeks         | Week 2-3   | Week 4         |
| **2. Hub UI**        | 4 weeks         | Week 4-7   | Week 8         |
| **3. Game Engine**   | 8 weeks         | Week 8-15  | Week 16        |
| **4. Integration**   | 3 weeks         | Week 16-18 | Week 19        |
| **5. Deployment**    | 3 weeks         | Week 19-21 | Week 22        |
| **TOTAL**            | **21-22 weeks** | -          | **5-6 months** |

### Key Milestones

**Month 1 (Weeks 1-4):**

- ✅ Monorepo setup
- ✅ Core package extracted
- ✅ RN app booting
- ✅ Auth screen working
- ✅ Design system complete

**Month 2 (Weeks 5-8):**

- ✅ Shop overlay migrated
- ✅ Workshop overlay migrated
- ✅ Bank overlay migrated
- ✅ All modals migrated

**Month 3 (Weeks 9-12):**

- ✅ Player movement working
- ✅ Enemy AI functional
- ✅ Combat system operational
- ✅ Game loop integrated

**Month 4 (Weeks 13-16):**

- ✅ Wave system complete
- ✅ Full gameplay loop tested
- ✅ 60 FPS performance
- ✅ All integrations working

**Month 5 (Weeks 17-20):**

- ✅ All tests passing
- ✅ E2E tests complete
- ✅ TestFlight builds live
- ✅ Beta testing complete

**Month 6 (Week 21-22):**

- ✅ App Store approval
- ✅ Play Store approval
- ✅ Public launch
- ✅ OTA updates active

---

## Risk Mitigation

### Risk 1: React Native Game Engine Performance

**Risk:** react-native-game-engine can't maintain 60 FPS with 150 entities

**Mitigation:**

- POC in Phase 3 Week 9-10 (stress test immediately)
- If insufficient: Fallback to Expo GL + custom engine
- Object pooling + culling reduces entity count
- Target mid-tier devices (iPhone 12, not latest)

**Backup Plan:** Use Expo GL with custom render loop (more complex, but proven)

### Risk 2: OTA Update Limitations

**Risk:** Native code changes still require App Store review

**Mitigation:**

- Minimize native dependencies
- Keep all game logic in JavaScript
- Use EAS Update for 95%+ of changes
- Plan native updates carefully (batched releases)

### Risk 3: Supabase RN Compatibility

**Risk:** Supabase client has issues in React Native

**Mitigation:**

- Already tested in Phase 0 (Week 1)
- Supabase JS client is platform-agnostic
- Fallback: Use Supabase REST API directly

### Risk 4: AsyncStorage Data Loss

**Risk:** AsyncStorage is less reliable than localStorage

**Mitigation:**

- Implement retry logic in LocalStorageService
- Sync to Supabase frequently (SyncService)
- Use MMKV if AsyncStorage fails (faster, more reliable)

### Risk 5: Build Failures on EAS

**Risk:** Cloud builds fail, blocking deployment

**Mitigation:**

- Use local builds for development (free, faster)
- Only use EAS for production builds
- Set up CI/CD fallback (GitHub Actions + Fastlane)

---

## Success Metrics

### Technical Metrics

**Performance:**

- ✅ 60 FPS gameplay (target devices: iPhone 12, Pixel 5)
- ✅ < 3 sec cold start time
- ✅ < 100 MB app size (iOS + Android)
- ✅ < 30 sec OTA update deployment

**Reliability:**

- ✅ 95%+ test coverage (services layer)
- ✅ < 1% crash rate
- ✅ 99.9% uptime (Supabase backend)
- ✅ 0 memory leaks (30-min session)

**Velocity:**

- ✅ Bug fixes deployed in < 30 sec (OTA)
- ✅ New features shipped weekly
- ✅ AI code assist effective (single TypeScript codebase)

### User Metrics

**Retention:**

- ✅ Day 1 retention > 40%
- ✅ Day 7 retention > 20%
- ✅ Day 30 retention > 10%

**Engagement:**

- ✅ Average session length > 10 min
- ✅ Sessions per day > 2

**Monetization:**

- ✅ IAP conversion > 5%
- ✅ ARPU (Average Revenue Per User) > $1

---

## Appendix

### Code Reuse Breakdown (Detailed)

| Category            | Files | Lines  | Reuse %   | Effort          |
| ------------------- | ----- | ------ | --------- | --------------- |
| **Services**        | 20    | 12,794 | 95%       | 2 days          |
| **State (Zustand)** | 3     | 8,000  | 100%      | 0 days          |
| **Types**           | 8     | 25,000 | 100%      | 0 days          |
| **Config**          | 7     | 37,000 | 100%      | 0 days          |
| **Utils**           | 10    | 2,000  | 90%       | 0.5 days        |
| **UI Components**   | 38    | 15,053 | 70% logic | 3-4 weeks       |
| **Phaser Scenes**   | 10    | 5,000  | 30% logic | 8-10 weeks      |
| **Game Systems**    | 6     | 3,000  | 40% logic | 4-6 weeks       |
| **AI/Weapons**      | 6     | 2,000  | 50% logic | 2-3 weeks       |
| **Entities**        | 2     | 2,700  | 20%       | 1 week          |
| **TOTAL**           | ~140  | 46,688 | **68%**   | **18-26 weeks** |

### Tool & Service Links

**Development:**

- Expo: https://expo.dev
- React Native: https://reactnative.dev
- React Navigation: https://reactnavigation.org
- React Native Game Engine: https://github.com/bberak/react-native-game-engine

**Testing:**

- Detox: https://wix.github.io/Detox/
- React Native Testing Library: https://callstack.github.io/react-native-testing-library/

**Deployment:**

- EAS Build: https://docs.expo.dev/build/introduction/
- EAS Update: https://docs.expo.dev/eas-update/introduction/

**Analytics:**

- Sentry: https://sentry.io
- Amplitude: https://amplitude.com
- Mixpanel: https://mixpanel.com

**Accounts:**

- Apple Developer: https://developer.apple.com
- Google Play Console: https://play.google.com/console
- Expo: https://expo.dev/signup

---

**Document Version:** 1.0
**Last Updated:** 2025-11-01
**Next Review:** After Phase 0 completion
