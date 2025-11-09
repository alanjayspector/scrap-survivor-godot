<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Topic: React Native Platform-Specific Code Patterns for Web API Abstraction

Query:
Research React Native industry best practices for abstracting browser-specific APIs in a cross-platform monorepo (React Native + React Web). I need evidence-based patterns for:

1. STORAGE ABSTRACTION
   - localStorage (web) → AsyncStorage (React Native)
   - Industry standard patterns from major libraries
   - Error handling and migration strategies
2. EVENT SYSTEM ABSTRACTION
   - window.dispatchEvent/CustomEvent (web) → EventEmitter (React Native)
   - Pub/sub patterns used by React Navigation, Expo, etc.
3. NETWORK DETECTION ABSTRACTION
   - navigator.onLine (web) → NetInfo (React Native)
   - Observable state patterns for connection monitoring
4. PLATFORM-SPECIFIC FILE RESOLUTION
   - .native.ts pattern (how React Navigation, Expo SDK use it)
   - Metro bundler's platform resolution
   - TypeScript configuration for platform-specific types

For each pattern, provide:

- Official React Native documentation links
- Real-world examples from major libraries (React Navigation, Expo, React Native Paper)
- Common pitfalls and how to avoid them
- Testing strategies for platform-specific code

Focus on 2024-2025 best practices for Expo SDK 54+ and React Native 0.81+.

Response Format I Need:
Please structure the response as:

# Platform Abstraction Patterns for React Native

## 1. Storage Abstraction

**Official Pattern:** [citation]
**Industry Examples:** [library names with links]
**Implementation Pattern:** [code structure]
**Common Pitfalls:** [list]
**Testing Approach:** [strategy]

## 2. Event System Abstraction

[same structure]

## 3. Network Detection Abstraction

[same structure]

## 4. Platform-Specific File Resolution

[same structure]

## Summary: Recommended Approach

[synthesized best practice]

Now I have comprehensive information about React Native platform abstraction patterns. Let me generate a detailed response covering storage, event systems, network detection, and platform-specific file resolution with evidence-based patterns.

# Platform Abstraction Patterns for React Native

React Native cross-platform development requires robust abstraction patterns to handle differences between web and native platforms. For Expo SDK 54+ and React Native 0.81+, here are the industry-proven approaches for abstracting platform-specific APIs.

## 1. Storage Abstraction

### Official Pattern

React Native documentation explicitly recommends using an abstraction layer on top of AsyncStorage rather than using it directly. The official guidance states: "It is recommended that you use an abstraction on top of AsyncStorage instead of AsyncStorage directly for anything more than light usage since it operates globally."[^1][^2]

**Industry Examples**

**react-native-storage** (sunnylqm/react-native-storage): This widely-adopted library provides a unified wrapper that works with both AsyncStorage (React Native) and localStorage (web):[^3]

```typescript
import Storage from 'react-native-storage';
import AsyncStorage from '@react-native-async-storage/async-storage';

const storage = new Storage({
  size: 1000,
  storageBackend: AsyncStorage, // for web: window.localStorage
  defaultExpires: 1000 * 3600 * 24,
  enableCache: true,
});
```

**Redux Persist Pattern**: Major libraries like Redux Persist use platform-specific storage engines with a unified API, automatically selecting the appropriate backend based on platform.[^4][^5]

**Implementation Pattern**

The recommended approach uses platform-specific file extensions with TypeScript:

```typescript
// storage.native.ts
import AsyncStorage from '@react-native-async-storage/async-storage';

export const storage = {
  async getItem(key: string): Promise<string | null> {
    try {
      return await AsyncStorage.getItem(key);
    } catch (error) {
      console.error('Error reading from AsyncStorage:', error);
      return null;
    }
  },

  async setItem(key: string, value: string): Promise<void> {
    try {
      await AsyncStorage.setItem(key, value);
    } catch (error) {
      console.error('Error writing to AsyncStorage:', error);
    }
  },

  async removeItem(key: string): Promise<void> {
    await AsyncStorage.removeItem(key);
  },
};

// storage.web.ts
export const storage = {
  async getItem(key: string): Promise<string | null> {
    try {
      return localStorage.getItem(key);
    } catch (error) {
      console.error('Error reading from localStorage:', error);
      return null;
    }
  },

  async setItem(key: string, value: string): Promise<void> {
    try {
      localStorage.setItem(key, value);
    } catch (error) {
      console.error('Error writing to localStorage:', error);
    }
  },

  async removeItem(key: string): Promise<void> {
    localStorage.removeItem(key);
  },
};

// Import without extension
import { storage } from './storage';
```

**Common Pitfalls**

1. **AsyncStorage limits**: Android has a default 6MB limit that requires Java configuration to extend[^5]
2. **Data migration issues**: When migrating from localStorage to AsyncStorage, users lose data unless explicit migration is implemented[^6][^7]
3. **Type mismatches**: AsyncStorage returns `string | null` while some implementations expect `boolean | undefined`[^8]
4. **Security concerns**: AsyncStorage is unencrypted; use `expo-secure-store` for sensitive data like tokens[^9][^10]

**Testing Approach**

Create separate test configurations for each platform using Jest's platform-specific mocking:

```typescript
// __mocks__/@react-native-async-storage/async-storage.js
export default {
  setItem: jest.fn(() => Promise.resolve()),
  getItem: jest.fn(() => Promise.resolve(null)),
  removeItem: jest.fn(() => Promise.resolve()),
};

// storage.test.ts
describe('Storage', () => {
  it('should handle storage on native', async () => {
    const mockStorage = require('@react-native-async-storage/async-storage');
    await storage.setItem('key', 'value');
    expect(mockStorage.setItem).toHaveBeenCalledWith('key', 'value');
  });
});
```

## 2. Event System Abstraction

### Official Pattern

React Native's event system differs fundamentally between platforms. Web uses `window.dispatchEvent` with `CustomEvent`, while React Native uses EventEmitter patterns. React Navigation implements its own event system that abstracts these differences.[^11][^12][^13][^14]

**Industry Examples**

**React Navigation Events**: React Navigation provides a unified event API that works across all platforms:[^15][^13]

```typescript
React.useEffect(() => {
  const unsubscribe = navigation.addListener('focus', (e) => {
    // Screen came into focus
  });
  return unsubscribe;
}, [navigation]);
```

**EventTarget-based Pattern**: For web compatibility, create a custom EventEmitter that uses `EventTarget` on web and a custom implementation on native:[^12]

```typescript
// events.web.ts
class EventEmitter extends EventTarget {
  emit(eventName: string, data: any) {
    const event = new CustomEvent(eventName, { detail: data });
    return this.dispatchEvent(event);
  }

  on(eventName: string, handler: (data: any) => void) {
    const wrappedHandler = (event: CustomEvent) => handler(event.detail);
    this.addEventListener(eventName, wrappedHandler as EventListener);
    return () => this.removeEventListener(eventName, wrappedHandler as EventListener);
  }
}

// events.native.ts
import { EventEmitter as RNEventEmitter } from 'react-native';

class EventEmitter {
  private emitter = new RNEventEmitter();

  emit(eventName: string, data: any) {
    this.emitter.emit(eventName, data);
  }

  on(eventName: string, handler: (data: any) => void) {
    const subscription = this.emitter.addListener(eventName, handler);
    return () => subscription.remove();
  }
}

export const eventBus = new EventEmitter();
```

**Implementation Pattern**

**Expo Router and React Navigation Pattern**: Use a global event manager with consistent API:[^16]

```typescript
// Import platform-specific implementation
import { eventBus } from './events';

// Usage remains identical across platforms
function MyComponent() {
  useEffect(() => {
    const unsubscribe = eventBus.on('dataUpdate', (data) => {
      console.log('Received:', data);
    });
    return unsubscribe;
  }, []);

  const handleAction = () => {
    eventBus.emit('dataUpdate', { value: 42 });
  };
}
```

**Common Pitfalls**

1. **Memory leaks**: Always unsubscribe listeners in cleanup functions[^17]
2. **Type safety**: Event names and payloads should be strongly typed using TypeScript discriminated unions[^18]
3. **Cross-screen events**: React Navigation events are scoped to screens; use a global EventEmitter for app-wide events[^13]
4. **Web performance**: On web, avoid creating too many DOM elements for EventTarget-based implementations[^12]

**Testing Approach**

Mock the event system with Jest:

```typescript
// __mocks__/events.ts
export const eventBus = {
  emit: jest.fn(),
  on: jest.fn(() => jest.fn()), // Returns unsubscribe function
};

// component.test.tsx
import { eventBus } from './events';

it('should emit event on action', () => {
  const { getByText } = render(<MyComponent />);
  fireEvent.press(getByText('Action'));
  expect(eventBus.emit).toHaveBeenCalledWith('dataUpdate', expect.any(Object));
});
```

## 3. Network Detection Abstraction

### Official Pattern

React Native uses `@react-native-community/netinfo` for network detection, which provides cross-platform support including web. The library handles `navigator.onLine` (web) internally and provides a consistent API.[^19][^20]

**Industry Examples**

**NetInfo with React Query**: TanStack Query's official documentation shows integration with NetInfo:[^8]

```typescript
import NetInfo from '@react-native-community/netinfo';
import { onlineManager } from '@tanstack/react-query';

// Setup online manager
onlineManager.setEventListener((setOnline) => {
  return NetInfo.addEventListener((state) => {
    setOnline(state.isConnected ?? false);
  });
});
```

**Expo and React Navigation**: Both use NetInfo as their standard network detection library, providing hooks for reactive state management.[^20][^21]

**Implementation Pattern**

Create a custom hook that abstracts platform differences:

```typescript
// useNetworkStatus.ts
import { useEffect, useState } from 'react';
import { Platform } from 'react-native';

export function useNetworkStatus() {
  const [isConnected, setIsConnected] = useState<boolean | null>(true);

  useEffect(() => {
    if (Platform.OS === 'web') {
      // Web implementation
      const handleOnline = () => setIsConnected(true);
      const handleOffline = () => setIsConnected(false);

      window.addEventListener('online', handleOnline);
      window.addEventListener('offline', handleOffline);

      setIsConnected(navigator.onLine);

      return () => {
        window.removeEventListener('online', handleOnline);
        window.removeEventListener('offline', handleOffline);
      };
    } else {
      // Native implementation
      const NetInfo = require('@react-native-community/netinfo').default;

      const unsubscribe = NetInfo.addEventListener((state) => {
        setIsConnected(state.isConnected);
      });

      NetInfo.fetch().then((state) => {
        setIsConnected(state.isConnected);
      });

      return unsubscribe;
    }
  }, []);

  return { isConnected };
}
```

**Observable State Pattern**:[^19][^20]

```typescript
import NetInfo from '@react-native-community/netinfo';
import { useNetInfo } from '@react-native-community/netinfo';

function NetworkIndicator() {
  const netInfo = useNetInfo();

  return (
    <View>
      <Text>Type: {netInfo.type}</Text>
      <Text>Is Connected: {netInfo.isConnected?.toString()}</Text>
      <Text>Is Reachable: {netInfo.isInternetReachable?.toString()}</Text>
    </View>
  );
}
```

**Common Pitfalls**

1. **Null handling**: `isConnected` can be `null` for unknown networks; use nullish coalescing[^8]
2. **Web browser quirks**: Many valid networks report as "unknown" on web browsers[^20][^19]
3. **Reachability testing**: Configure custom endpoints for better reachability detection[^20]
4. **Initial state**: Always fetch initial state explicitly; don't rely on default values[^20]

**Testing Approach**

Mock NetInfo for platform-specific tests:

```typescript
// __mocks__/@react-native-community/netinfo.ts
export default {
  fetch: jest.fn(() => Promise.resolve({ isConnected: true })),
  addEventListener: jest.fn(() => jest.fn()),
  useNetInfo: jest.fn(() => ({ isConnected: true, type: 'wifi' })),
};

// useNetworkStatus.test.ts
import NetInfo from '@react-native-community/netinfo';

it('should handle network changes', async () => {
  const mockListener = jest.fn();
  (NetInfo.addEventListener as jest.Mock).mockImplementation((callback) => {
    mockListener.current = callback;
    return () => {};
  });

  const { result } = renderHook(() => useNetworkStatus());

  act(() => {
    mockListener.current({ isConnected: false });
  });

  expect(result.current.isConnected).toBe(false);
});
```

## 4. Platform-Specific File Resolution

### Official Pattern

React Native's Metro bundler supports platform-specific extensions including `.ios.`, `.android.`, `.native.`, and `.web.`. The official documentation states: "React Native will detect when a file has a `.ios.` or `.android.` extension and load the relevant platform file when required from other components".[^2][^22]

**Industry Examples**

**Expo Router**: Expo Router fully supports platform-specific extensions within the `app` directory with the requirement that a non-platform version also exists:[^23][^16]

```
app/
  _layout.tsx          // Used on iOS/Android
  _layout.web.tsx      // Used on web
  index.tsx            // All platforms
  about.tsx            // iOS/Android
  about.web.tsx        // Web
```

**React Navigation**: Uses platform-specific modules for components requiring different implementations:[^21]

```typescript
// TabBar.tsx (default)
// TabBar.native.tsx (iOS/Android)
// TabBar.web.tsx (Web)

import TabBar from './TabBar'; // Auto-resolves
```

**Implementation Pattern**

**Metro Bundler Resolution**: Metro resolves platform-specific files in this order (for Android with `sourceExts: ['js', 'jsx', 'ts', 'tsx']`):[^22]

1. `Module.android.js`
2. `Module.native.js` (if `preferNativePlatform: true`)
3. `Module.js`
4. `Module.android.jsx`
5. `Module.native.jsx`
6. `Module.jsx`
7. (continues for `.ts` and `.tsx`)

**TypeScript Configuration**: Use `moduleSuffixes` for type-safe platform-specific imports:[^24][^25][^26][^27]

```json
// tsconfig.json (base)
{
  "compilerOptions": {
    "moduleResolution": "node",
    "resolveJsonModule": true
  }
}

// tsconfig.web.json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "moduleSuffixes": [".web", ""]
  }
}

// tsconfig.native.json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "moduleSuffixes": [".native", ""]
  }
}
```

**Package.json scripts**:[^27]

```json
{
  "scripts": {
    "lint:ts": "concurrently \"npm:lint:ts:*\"",
    "lint:ts:web": "tsc -p tsconfig.web.json --noEmit",
    "lint:ts:native": "tsc -p tsconfig.native.json --noEmit"
  }
}
```

**Platform Module for Dynamic Loading**:[^28][^2]

```typescript
import { Platform } from 'react-native';

// Option 1: Platform.select
const Component = Platform.select({
  native: () => require('./Component.native'),
  web: () => require('./Component.web'),
  default: () => require('./Component'),
})();

// Option 2: Conditional require
let Storage;
if (Platform.OS === 'web') {
  Storage = require('./storage.web').default;
} else {
  Storage = require('./storage.native').default;
}
```

**Common Pitfalls**

1. **TypeScript confusion**: Without proper `moduleSuffixes`, TypeScript only validates one platform variant[^25][^24][^27]
2. **Missing base file**: In Expo Router's `app` directory, platform-specific routes require a base file to exist[^16]
3. **Web bundler configuration**: Configure web bundlers to ignore `.native.js` files to avoid bloating bundles[^2]
4. **Build cache issues**: Metro cache must be cleared when adding new platform-specific files[^29][^30]

**Testing Approach**

**Platform-specific Jest configuration**:[^31][^32][^33]

```javascript
// jest.config.js
module.exports = {
  preset: 'react-native',
  setupFiles: ['./jest.setup.js'],
};

// jest.setup.js - Mock Platform.OS for specific tests
beforeEach(() => {
  jest.resetModules();
});

// In test file
describe('Storage on iOS', () => {
  beforeEach(() => {
    jest.doMock('react-native/Libraries/Utilities/Platform', () => ({
      OS: 'ios',
      select: (obj) => obj.ios || obj.native || obj.default,
    }));
  });

  it('should use native storage', () => {
    const { storage } = require('./storage');
    // Test iOS-specific behavior
  });
});

describe('Storage on Web', () => {
  beforeEach(() => {
    jest.doMock('react-native/Libraries/Utilities/Platform', () => ({
      OS: 'web',
      select: (obj) => obj.web || obj.default,
    }));
  });

  it('should use web storage', () => {
    const { storage } = require('./storage');
    // Test web-specific behavior
  });
});
```

**Mock Platform.Version**:[^32]

```typescript
// Mocking Platform.Version (which is a getter)
const Platform = jest.requireActual('react-native').Platform;
Object.defineProperty(Platform, 'Version', {
  get: () => 13,
});
```

## Summary: Recommended Approach

For Expo SDK 54+ and React Native 0.81+ projects targeting both native and web platforms, follow these evidence-based best practices:

**1. File Organization Strategy**

Use platform-specific file extensions (`.native.ts`, `.web.ts`) for modules that require fundamentally different implementations, and use the `Platform` module for minor variations within shared files.[^22][^2][^16]

**2. TypeScript Configuration**

Implement separate `tsconfig.json` files with `moduleSuffixes` for each platform and run type-checking in parallel to ensure full type safety across all platforms.[^26][^25][^27]

**3. Storage Pattern**

Abstract storage behind a unified API using platform-specific files, leveraging `@react-native-async-storage/async-storage` for native and `localStorage` for web. Use `expo-secure-store` for sensitive data on native platforms.[^10][^3][^9]

**4. Event System**

Create a unified event bus that uses `EventTarget`/`CustomEvent` on web and React Native's `EventEmitter` on native, or leverage React Navigation's built-in event system for navigation-related events.[^15][^13][^12]

**5. Network Detection**

Use `@react-native-community/netinfo` which provides built-in web support via `navigator.onLine`, wrapping it in a custom hook for observable state management.[^19][^20]

**6. Testing Strategy**

Separate test runs for each platform using Jest with platform-specific mocks, and leverage `jest.resetModules()` to dynamically switch Platform.OS between test suites.[^34][^33][^31][^32]

**7. Build Configuration**

Configure Metro's `resolver.sourceExts` and TypeScript's `moduleSuffixes` consistently, and ensure web bundlers exclude `.native.*` files to optimize bundle sizes.[^35][^2][^22]

This approach aligns with patterns used by major libraries (React Navigation, Expo Router, React Native Paper) and provides maintainable, type-safe cross-platform code that scales from small projects to enterprise applications.[^36][^37][^38][^21][^16]
<span style="display:none">[^100][^101][^102][^103][^104][^105][^106][^107][^108][^39][^40][^41][^42][^43][^44][^45][^46][^47][^48][^49][^50][^51][^52][^53][^54][^55][^56][^57][^58][^59][^60][^61][^62][^63][^64][^65][^66][^67][^68][^69][^70][^71][^72][^73][^74][^75][^76][^77][^78][^79][^80][^81][^82][^83][^84][^85][^86][^87][^88][^89][^90][^91][^92][^93][^94][^95][^96][^97][^98][^99]</span>

<div align="center">⁂</div>

[^1]: https://archive.reactnative.dev/docs/0.23/asyncstorage

[^2]: https://reactnative.dev/docs/platform-specific-code

[^3]: https://github.com/sunnylqm/react-native-storage

[^4]: https://stackoverflow.com/questions/37563224/why-the-react-native-docs-recommends-that-you-use-an-abstraction-on-top-of-async

[^5]: https://stackoverflow.com/questions/44376002/what-are-my-options-for-storing-data-when-using-react-native-ios-and-android

[^6]: https://github.com/mrousavy/react-native-mmkv/issues/52

[^7]: https://github.com/expo/expo/issues/20400

[^8]: https://github.com/TanStack/query/discussions/3590

[^9]: https://www.linkedin.com/posts/armanabasian_reactnative-expo-mobileappdevelopment-activity-7326156813177896960-isyx

[^10]: https://blog.devgenius.io/keeping-tokens-safe-the-best-storage-options-for-react-native-authentication-9bf23fe28483

[^11]: https://www.dhiwise.com/post/leveraging-react-event-emitter-for-component-communication

[^12]: https://dev.to/itswillt/using-eventtarget-and-customevent-to-build-a-web-native-event-emitter-16hc

[^13]: https://github.com/react-navigation/react-navigation/issues/1363

[^14]: https://reactnavigation.org/docs/navigation-events/

[^15]: https://reactnavigation.org/docs/stack-navigator/

[^16]: https://docs.expo.dev/router/advanced/platform-specific-modules/

[^17]: https://dev.to/soumyarian/useeventemitter-a-react-hook-to-emit-and-listen-to-custom-events-20dc

[^18]: https://stackoverflow.com/questions/45831911/is-there-any-eventemitter-in-browser-side-that-has-similar-logic-in-nodejs

[^19]: https://github.com/react-native-netinfo/react-native-netinfo

[^20]: https://viewlytics.ai/blog/react-native-netinfo-complete-guide

[^21]: https://reactnavigation.org/docs/web-support/

[^22]: https://metrobundler.dev/docs/resolution/

[^23]: https://github.com/expo/router/discussions/490

[^24]: https://stackoverflow.com/questions/44001050/platform-specific-import-component-in-react-native-with-typescript

[^25]: https://kylemcd.com/posts/typescript-modules-suffixes-with-react-native

[^26]: https://www.typescriptlang.org/tsconfig/moduleSuffixes.html

[^27]: https://www.lucasloisp.com/react-native-typescript-platforms/

[^28]: https://archive.reactnative.dev/docs/platform-specific-code

[^29]: https://github.com/expo/expo/discussions/21736

[^30]: https://www.reddit.com/r/reactnative/comments/1g7f7jd/metro_error_unable_to_resolve_module_how_to_fix/

[^31]: https://stackoverflow.com/questions/44926458/platform-specific-testing-using-jest-on-a-react-native-app

[^32]: https://dev.to/naturalclar/mocking-platform-version-with-jest-4o9e

[^33]: https://stackoverflow.com/questions/43161416/mocking-platform-detection-in-jest-and-react-native

[^34]: https://www.rootstrap.com/blog/how-to-test-react-native-apps

[^35]: https://docs.expo.dev/guides/customizing-metro/

[^36]: https://reactnativeexpert.com/blog/react-native-paper-for-native-look-and-feel/

[^37]: https://github.com/callstack/react-native-paper

[^38]: https://www.callstack.com/blog/react-native-paper-for-startups-and-enterprises

[^39]: https://stackoverflow.com/questions/55405202/react-native-creating-abstraction-layer-for-asyncstorage

[^40]: https://www.reactnativepro.com/tutorials/react-native-module-reolution-with-typescript-and-babel/

[^41]: https://www.c-sharpcorner.com/article/async-storage-in-react-native/

[^42]: https://github.com/ds300/react-native-typescript-transformer/issues/43

[^43]: https://lyzer.hashnode.dev/implementing-custom-event-emitters-in-javascript-project

[^44]: https://codingcops.com/react-native-asyncstorage/

[^45]: https://airbnb.io/react-native/releases/0.28/docs/platform-specific-code.html

[^46]: https://github.com/react-native-async-storage/async-storage/issues/401

[^47]: https://reactnative.dev/docs/next/the-new-architecture/native-modules-custom-events

[^48]: https://airbnb.io/react-native/releases/0.29/docs/asyncstorage.html

[^49]: https://www.reddit.com/r/reactnative/comments/18ddkx5/platformspecific_extensions_are_there_any_best/

[^50]: https://stackoverflow.com/questions/64876248/emitting-custom-event-in-react

[^51]: https://rxdb.info/articles/localstorage.html

[^52]: https://microsoft.github.io/rnx-kit/docs/type-safety

[^53]: https://www.youtube.com/watch?v=KBlbkjqxNbM

[^54]: https://www.techaheadcorp.com/blog/architecting-seamless-navigation-for-react-native-apps-patterns-libraries-best-practices/

[^55]: https://www.reddit.com/r/expo/comments/1ndpzg5/expo_sdk_54_changelog_and_upgrade_guide/

[^56]: https://stackoverflow.com/questions/47025020/how-to-use-redux-in-react-native-to-dispatch-netinfo-connectivy-change-action

[^57]: https://expo.dev/changelog/sdk-54

[^58]: https://airbnb.io/react-native/releases/0.28/docs/netinfo.html

[^59]: https://stackoverflow.com/questions/79766758/sdk-54-the-expo-modules-autolinking-package-has-been-found-but-it-seems-to

[^60]: https://dev.to/lucy1/advanced-navigation-patterns-in-react-native-apps-4pm4

[^61]: https://dev.to/ajmal_hasan/detecting-internet-connectivity-in-react-native-using-netinfo-15ig

[^62]: https://shift.infinite.red/expo-sdk-54-better-faster-simpler-bf3c2a35269e

[^63]: https://reactnavigation.org

[^64]: https://archive.reactnative.dev/docs/0.38/netinfo

[^65]: https://blog.stackademic.com/demystifying-metro-builder-react-natives-bundler-d218ae84b113

[^66]: https://testrigor.com/react-native-testing/

[^67]: https://jestjs.io/docs/tutorial-react-native

[^68]: https://github.com/evanw/esbuild/issues/2395

[^69]: https://reactnative.dev/docs/testing-overview

[^70]: https://blog.expo.dev/testing-universal-react-native-apps-with-jest-and-expo-113b4bf9cc44

[^71]: https://github.com/react-native-maps/react-native-maps/issues/4641

[^72]: https://github.com/facebook/jest/issues/1370

[^73]: https://stackoverflow.com/questions/76629674/unable-to-resolve-utilities-platform-error-with-metro-bundler

[^74]: https://reactnative.dev/docs/turbo-native-modules-introduction

[^75]: https://xbsoftware.com/blog/cordova-to-react-native-migration/

[^76]: https://metadesignsolutions.com/using-react-native-with-expo-pros-cons-and-best-practices/

[^77]: https://shivlab.com/blog/steps-migrate-to-react-native-enterprise-apps/

[^78]: https://stackoverflow.com/questions/36902611/is-there-a-simple-synchronous-storage-option-for-react-native

[^79]: https://www.youtube.com/watch?v=HQ_xzbq_BnQ

[^80]: https://curatepartners.com/blogs/skills-tools-platforms/transitioning-from-native-to-react-native-a-comprehensive-guide-for-efficient-cross-platform-development/

[^81]: https://www.youtube.com/watch?v=2OoiL3rBzLc

[^82]: https://www.hackerone.com/blog/ensuring-mobile-application-security-expo

[^83]: https://expo.dev/blog/migrating-to-react-native-with-expo

[^84]: https://dev.to/mzakzook/asyncstorage-localstorage-cookies-1oek

[^85]: https://www.reddit.com/r/expo/comments/1kkvt2s/looking_for_a_way_to_avoid_being_broken_all_the/

[^86]: https://www.callstack.com/blog/migration-to-react-native

[^87]: https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps

[^88]: https://stackoverflow.com/questions/38847210/how-to-migrate-a-multi-platform-app-in-react-native

[^89]: https://reactnative.dev/docs/asyncstorage

[^90]: https://stackoverflow.com/questions/78372557/best-practices-for-storing-keys-and-public-urls-in-expo-react-native-project-ho

[^91]: https://docs.expo.dev/router/reference/api-routes/

[^92]: https://ignitecookbook.com/docs/recipes/ExpoRouter/

[^93]: https://www.youtube.com/watch?v=b8hKskhFt04

[^94]: https://docs.expo.dev/router/advanced/native-intent/

[^95]: https://stackoverflow.com/questions/52501822/is-there-a-way-to-create-and-dispatch-trigger-custom-event-with-react-navigation

[^96]: https://docs.expo.dev/router/basics/core-concepts/

[^97]: https://www.thisdot.co/blog/setting-up-react-navigation-in-expo-web-a-practical-guide

[^98]: https://www.youtube.com/watch?v=S2uZe6AkZOM

[^99]: https://www.linkedin.com/posts/nishantmobile_react-native-081-whats-new-and-why-it-activity-7370767096559046656-iH2q

[^100]: https://www.linkedin.com/posts/ayomidedaniel_reactnative-exposdk-mobileperformance-activity-7372494439509819392-C5CZ

[^101]: https://www.metacto.com/blogs/expo-alternatives-and-competitors-the-definitive-guide-for-2024

[^102]: https://dev.to/dsitdikov/unit-testing-components-with-jest-in-react-native-setup-and-trouble-resolutions-31c9

[^103]: https://reactnative.dev/blog/2025/08/12/react-native-0.81

[^104]: https://www.reddit.com/r/expo/comments/1o7b7jf/best_crossplatform_dropdown_package_for_react/

[^105]: https://dianapps.com/blog/react-native-081/

[^106]: https://getstream.io/blog/crossplatform-messaging-app/

[^107]: https://blog.stackademic.com/whats-new-in-expo-54-and-why-you-should-switch-now-93566b661a82

[^108]: https://www.metacto.com/blogs/react-native-vs-the-world-top-alternatives-competitors-in-2024
