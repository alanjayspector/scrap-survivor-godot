# Lesson 28: Storybook Interactive Stories with React Hooks

**Created:** 2025-10-22
**Session:** Sprint 16 - Error Handling (Phase 1-2)
**Category:** 🟡 Pattern - Storybook Development
**Related:** Component Creation Checklist, ESLint Configuration

---

## The Problem

ESLint `rules-of-hooks` error when using React hooks directly in Storybook story render functions.

### What Happened (Sprint 16, 2025-10-22):

**Task:** Create interactive Storybook stories for ErrorModal component

**What I Did:**

```tsx
// ❌ WRONG - Violates rules-of-hooks
export const Interactive: Story = {
  render: () => {
    const [isOpen, setIsOpen] = useState(false); // Error!

    return (
      <div>
        <button onClick={() => setIsOpen(true)}>Show Modal</button>
        <ErrorModal isOpen={isOpen} onClose={() => setIsOpen(false)} />
      </div>
    );
  },
};
```

**ESLint Error:**

```
React Hook "useState" is called in function "render" that is neither a
React function component nor a custom React Hook function.
React component names must start with an uppercase letter.
React Hook names must start with the word "use"  react-hooks/rules-of-hooks
```

**Why This Failed:**

- React hooks can ONLY be called inside React components or custom hooks
- Story render functions are plain functions, not components
- Component names must start with uppercase letter
- ESLint pre-commit hook blocked the commit

---

## The Pattern

**Extract interactive logic into a separate component, then render it in the story.**

### Correct Implementation:

```tsx
// ✅ CORRECT - Extract to component
const InteractiveDemo = () => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div>
      <button onClick={() => setIsOpen(true)}>Show Modal</button>
      <ErrorModal isOpen={isOpen} onClose={() => setIsOpen(false)} />
    </div>
  );
};

export const Interactive: Story = {
  render: () => <InteractiveDemo />,
};
```

### Why This Works:

1. `InteractiveDemo` is a React component (starts with uppercase)
2. Hooks are called inside a component (rules-of-hooks satisfied)
3. Story render function just returns JSX (no hooks)
4. ESLint passes, interactive functionality works

---

## When to Use This Pattern

**Use this pattern when:**

- ✅ Storybook story needs `useState`, `useEffect`, or any React hook
- ✅ Story requires interactive state management
- ✅ Multiple stories share the same interactive logic
- ✅ Story needs to demonstrate user interactions (open/close, form input, etc.)

**Don't need this pattern when:**

- ❌ Story only uses static props (use `args` instead)
- ❌ Story doesn't need state management
- ❌ Component is purely presentational

---

## Complete Example

**From ErrorModal.stories.tsx:**

```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { ErrorModal } from './ErrorModal';
import { useState } from 'react';

const meta: Meta<typeof ErrorModal> = {
  title: 'UI/ErrorModal',
  component: ErrorModal,
  // ...
};

export default meta;
type Story = StoryObj<typeof ErrorModal>;

// Static story - uses args (no hooks needed)
export const Error: Story = {
  args: {
    isOpen: true,
    title: 'Connection Error',
    message: 'Unable to connect to the server.',
    severity: 'error',
    onClose: fn(),
  },
};

// Interactive story - needs hooks
const InteractiveDemo = () => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div>
      <button onClick={() => setIsOpen(true)}>Show Error Modal</button>

      <ErrorModal
        isOpen={isOpen}
        title="Sample Error"
        message="Click backdrop or press Escape to close."
        severity="error"
        onClose={() => setIsOpen(false)}
      />
    </div>
  );
};

export const Interactive: Story = {
  render: () => <InteractiveDemo />,
};

// Multiple modals with state management
const AllSeveritiesDemo = () => {
  const [openModal, setOpenModal] = useState<'error' | 'warning' | 'info' | null>('error');

  return (
    <div style={{ padding: '20px' }}>
      <div style={{ display: 'flex', gap: '16px' }}>
        <button onClick={() => setOpenModal('error')}>Show Error</button>
        <button onClick={() => setOpenModal('warning')}>Show Warning</button>
        <button onClick={() => setOpenModal('info')}>Show Info</button>
      </div>

      <ErrorModal
        isOpen={openModal === 'error'}
        title="Critical Error"
        message="Error severity modal."
        severity="error"
        onClose={() => setOpenModal(null)}
      />

      <ErrorModal
        isOpen={openModal === 'warning'}
        title="Warning Message"
        message="Warning severity modal."
        severity="warning"
        onClose={() => setOpenModal(null)}
      />

      <ErrorModal
        isOpen={openModal === 'info'}
        title="Information"
        message="Info severity modal."
        severity="info"
        onClose={() => setOpenModal(null)}
      />
    </div>
  );
};

export const AllSeverities: Story = {
  render: () => <AllSeveritiesDemo />,
};
```

---

## Key Principles

### 1. Component Naming Convention

```tsx
// ✅ Component name starts with uppercase
const InteractiveDemo = () => { ... };

// ❌ Function name starts with lowercase
const interactiveDemo = () => { ... };
```

### 2. Hooks Only in Components

```tsx
// ✅ Hook called inside component
const MyComponent = () => {
  const [state] = useState();
  return <div />;
};

// ❌ Hook called in render function
export const Story = {
  render: () => {
    const [state] = useState(); // Error!
  },
};
```

### 3. Keep Demo Components Focused

```tsx
// ✅ One component per story type
const InteractiveDemo = () => { ... };
const AllVariantsDemo = () => { ... };

// ❌ One giant component for all stories
const MegaDemo = ({ variant }) => { ... }; // Too complex
```

---

## ESLint Configuration

This pattern works with standard ESLint + React hooks plugin:

```json
{
  "plugins": ["react-hooks"],
  "rules": {
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn"
  }
}
```

No special configuration needed - just follow React component naming rules.

---

## Benefits

1. **ESLint Compliant**: Passes pre-commit hooks
2. **React Compliant**: Follows hooks rules
3. **Reusable**: Demo components can be extracted to shared stories
4. **Type-Safe**: TypeScript works correctly with component inference
5. **Maintainable**: Clear separation between story config and demo logic

---

## Related Patterns

- **Component Creation Checklist**: Step 4 - Create Storybook Stories
- **Static Stories**: Use `args` for presentational components
- **Custom Hooks**: Can be used inside demo components
- **Storybook Actions**: Use `fn()` from `@storybook/test` for callbacks

---

## Evidence

**Files:**

- `src/components/ui/ErrorModal.stories.tsx:121-154` (InteractiveDemo)
- `src/components/ui/ErrorModal.stories.tsx:159-243` (AllSeveritiesDemo)
- `src/components/ui/ErrorToast.stories.tsx` (similar pattern)

**Commit:** `7bc1d41` - feat(ui): add error modal component with test-first approach

---

## Summary

**When creating interactive Storybook stories:**

1. Extract interactive logic into a separate component (starts with uppercase)
2. Call hooks inside that component
3. Render the component in story's `render` function
4. Keep demo components focused and reusable

**This satisfies React hooks rules, passes ESLint, and maintains interactivity.**
