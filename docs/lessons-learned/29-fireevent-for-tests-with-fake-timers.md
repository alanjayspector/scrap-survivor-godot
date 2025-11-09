# Lesson 29: fireEvent for Tests with Fake Timers

**Created:** 2025-10-22
**Session:** Sprint 16 - Error Handling (Phase 1-2)
**Category:** 🟡 Pattern - Testing
**Related:** Vitest, Testing Library, Component Testing

---

## The Problem

`userEvent.setup()` causes test timeouts when combined with `vi.useFakeTimers()` in Vitest.

### What Happened (Sprint 16, 2025-10-22):

**Task:** Test ErrorToast component with auto-dismiss functionality

**What I Did:**

```tsx
describe('ErrorToast', () => {
  let user: ReturnType<typeof userEvent.setup>;

  beforeEach(() => {
    user = userEvent.setup();
    vi.useFakeTimers(); // For auto-dismiss tests
  });

  it('should call onDismiss when clicked', async () => {
    render(<ErrorToast {...props} />);
    await user.click(dismissButton); // ❌ Test timeout in 5000ms!
  });
});
```

**Error:**

```
Error: Test timed out in 5000ms.
If this is a long-running test, pass a timeout value as the last argument
or configure it globally with "testTimeout".
```

**Why This Failed:**

- `userEvent` simulates realistic user interactions with delays
- `vi.useFakeTimers()` freezes time
- `userEvent` waits for delays that never complete
- Tests time out waiting for `userEvent` to finish

---

## The Pattern

**Use `fireEvent` instead of `userEvent` when testing with fake timers.**

### Correct Implementation:

```tsx
import { fireEvent } from '@testing-library/react';

describe('ErrorToast', () => {
  beforeEach(() => {
    vi.useFakeTimers(); // For auto-dismiss tests
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // ✅ CORRECT - fireEvent with fake timers
  it('should call onDismiss when clicked', () => {
    const onDismiss = vi.fn();
    render(<ErrorToast {...props} onDismiss={onDismiss} />);

    const dismissButton = screen.getByTestId('dismiss-button');
    fireEvent.click(dismissButton);

    expect(onDismiss).toHaveBeenCalledTimes(1);
  });

  // ✅ Auto-dismiss test works with fake timers
  it('should auto-dismiss after duration', () => {
    const onDismiss = vi.fn();
    render(<ErrorToast {...props} duration={3000} onDismiss={onDismiss} />);

    expect(onDismiss).not.toHaveBeenCalled();

    vi.advanceTimersByTime(3000); // Works with fireEvent

    expect(onDismiss).toHaveBeenCalledTimes(1);
  });

  // ✅ Keyboard navigation works
  it('should support keyboard navigation', () => {
    const onDismiss = vi.fn();
    render(<ErrorToast {...props} onDismiss={onDismiss} />);

    const dismissButton = screen.getByTestId('dismiss-button');

    fireEvent.keyDown(dismissButton, { key: 'Enter' });
    expect(onDismiss).toHaveBeenCalledTimes(1);
  });
});
```

---

## When to Use This Pattern

**Use `fireEvent` when:**

- ✅ Tests use `vi.useFakeTimers()` or `vi.setSystemTime()`
- ✅ Testing auto-dismiss, debounce, throttle functionality
- ✅ Testing setTimeout, setInterval, requestAnimationFrame
- ✅ Need precise timing control with `vi.advanceTimersByTime()`

**Use `userEvent` when:**

- ✅ Testing without fake timers
- ✅ Need realistic user interaction simulation (typing, hover, etc.)
- ✅ Testing complex multi-step interactions
- ✅ Integration tests without timing dependencies

---

## Trade-offs

### fireEvent

**Pros:**

- Works reliably with fake timers
- Synchronous (no await needed)
- Fast test execution
- Precise timing control

**Cons:**

- Less realistic (no delays, no event propagation)
- Doesn't simulate full user behavior
- Might miss timing-related bugs

### userEvent

**Pros:**

- More realistic user simulation
- Simulates delays, focus, hover
- Better integration test coverage

**Cons:**

- Breaks with fake timers
- Async (requires await)
- Slower test execution

---

## Complete Example

**From ErrorToast.test.tsx:**

```tsx
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ErrorToast } from './ErrorToast';
import { TEST_IDS } from '@/testing/testIds';

describe('ErrorToast', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  const defaultProps = {
    title: 'Test Error',
    message: 'Test message',
    severity: 'error' as const,
    onDismiss: vi.fn(),
  };

  describe('Interaction', () => {
    it('should call onDismiss when dismiss button is clicked', () => {
      const onDismiss = vi.fn();
      render(<ErrorToast {...defaultProps} onDismiss={onDismiss} />);

      const dismissButton = screen.getByTestId(TEST_IDS.ui.errorToast.dismissButton);
      fireEvent.click(dismissButton);

      expect(onDismiss).toHaveBeenCalledTimes(1);
    });

    it('should auto-dismiss after duration expires', () => {
      const onDismiss = vi.fn();
      render(<ErrorToast {...defaultProps} duration={3000} onDismiss={onDismiss} />);

      expect(onDismiss).not.toHaveBeenCalled();

      // Fast-forward time by 3000ms
      vi.advanceTimersByTime(3000);

      expect(onDismiss).toHaveBeenCalledTimes(1);
    });

    it('should clear timeout on unmount', () => {
      const onDismiss = vi.fn();
      const { unmount } = render(
        <ErrorToast {...defaultProps} duration={3000} onDismiss={onDismiss} />
      );

      // Unmount before duration expires
      unmount();

      // Fast-forward time
      vi.advanceTimersByTime(3000);

      // Should not call onDismiss after unmount
      expect(onDismiss).not.toHaveBeenCalled();
    });
  });

  describe('Accessibility', () => {
    it('should support keyboard navigation', () => {
      const onDismiss = vi.fn();
      render(<ErrorToast {...defaultProps} onDismiss={onDismiss} />);

      const dismissButton = screen.getByTestId(TEST_IDS.ui.errorToast.dismissButton);
      dismissButton.focus();

      // Press Enter
      fireEvent.keyDown(dismissButton, { key: 'Enter' });
      expect(onDismiss).toHaveBeenCalledTimes(1);

      // Reset
      onDismiss.mockClear();

      // Press Space
      fireEvent.keyDown(dismissButton, { key: ' ' });
      expect(onDismiss).toHaveBeenCalledTimes(1);
    });
  });
});
```

---

## Why userEvent Fails with Fake Timers

**Technical Explanation:**

1. `userEvent` uses real delays for realistic simulation:

   ```tsx
   await userEvent.click(button);
   // Internally: delay -> pointerDown -> delay -> pointerUp -> click
   ```

2. `vi.useFakeTimers()` freezes time:

   ```tsx
   vi.useFakeTimers();
   // Now setTimeout, setInterval don't progress without vi.advanceTimersByTime()
   ```

3. `userEvent` waits for delays that never complete:
   ```tsx
   await user.click(button); // Waits forever because time is frozen
   // Test timeout!
   ```

**Attempted Solutions that Didn't Work:**

```tsx
// ❌ userEvent with delay: null (still times out)
const user = userEvent.setup({ delay: null });

// ❌ advanceTimers in between (unpredictable)
await user.click(button);
vi.advanceTimersByTime(100); // How much? Unknown internal delays
```

**Working Solution:**

```tsx
// ✅ fireEvent (synchronous, no delays)
fireEvent.click(button); // Immediate, works with fake timers
```

---

## Key Principles

### 1. Choose Based on Test Requirements

```tsx
// Need fake timers for auto-dismiss? Use fireEvent
describe('Auto-dismiss', () => {
  beforeEach(() => vi.useFakeTimers());

  it('dismisses after 3s', () => {
    fireEvent.click(button); // ✅
    vi.advanceTimersByTime(3000);
  });
});

// No timing requirements? Use userEvent
describe('Form input', () => {
  it('types into input', async () => {
    const user = userEvent.setup();
    await user.type(input, 'hello'); // ✅ More realistic
  });
});
```

### 2. Clean Up Timers

```tsx
afterEach(() => {
  vi.restoreAllMocks();
  vi.useRealTimers(); // Always restore real timers
});
```

### 3. Test Coverage is Identical

```tsx
// Both test the same user interaction:
fireEvent.click(button); // Less realistic, works with timers
await user.click(button); // More realistic, breaks with timers

// Coverage is the same - onClick handler is called
// Choose based on test requirements, not coverage
```

---

## When You Might Need Both

**Some test files need both patterns:**

```tsx
describe('MyComponent', () => {
  describe('with fake timers (auto-dismiss)', () => {
    beforeEach(() => vi.useFakeTimers());
    afterEach(() => vi.useRealTimers());

    it('auto-dismisses', () => {
      render(<MyComponent />);
      fireEvent.click(button); // Use fireEvent
      vi.advanceTimersByTime(3000);
    });
  });

  describe('without fake timers (typing)', () => {
    it('handles typing', async () => {
      const user = userEvent.setup();
      render(<MyComponent />);
      await user.type(input, 'hello'); // Use userEvent
    });
  });
});
```

---

## Evidence

**Files:**

- `src/components/ui/ErrorToast.test.tsx` (23 tests, all use fireEvent)
- `src/components/ui/ErrorModal.test.tsx` (31 tests, all use fireEvent)

**Both files use `vi.useFakeTimers()` for auto-dismiss and cleanup tests.**

**Commit:** `d906c2a` - feat(ui): add error toast component with test-first approach

---

## Summary

**When testing components with timing logic:**

1. Use `vi.useFakeTimers()` for auto-dismiss, debounce, throttle
2. Use `fireEvent` instead of `userEvent` to avoid timeouts
3. Clean up with `vi.useRealTimers()` in `afterEach`
4. Use `vi.advanceTimersByTime()` to control time progression

**Trade-off: Less realistic but more reliable for timing-sensitive tests.**
