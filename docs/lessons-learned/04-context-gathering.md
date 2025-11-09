# Lesson 04: Context Gathering & Code Search

**Category:** 🟡 Important (Default Behavior)
**Last Updated:** 2025-10-19
**Sessions:** Sprint 13 (E2E Tests), Multiple prior sessions

---

## CRITICAL RULE: Use Simple Tools, Check Docs First

**Context:** Multiple sessions where AI assistants thrashed with complex search commands instead of reading documentation or using simple `find`.

**User Feedback:**

> "my dude why are you thrashing so hard i did a simple find src | grep Bank and found the overlay?"

> "stop making assumptions when we have source code and documentation"

**Lesson:** Use the simplest tool that works. Read documentation before searching. Don't invent complexity.

---

## The Three-Step Search Protocol

### Step 1: Check Documentation FIRST

**Before searching codebase, check if docs answer your question:**

```bash
# Check if feature is documented
ls docs/04-game-systems/
cat docs/core-architecture/DATA-MODEL.md

# Check if pattern is documented
cat docs/testing/playwright-guide.md
cat docs/development-guide/coding-standards.md
```

**Why:** Documentation is curated, accurate, and faster than code search.

### Step 2: Use Simple Search Tools

**Prefer simple commands over complex ones:**

```bash
# ✅ GOOD - Simple, fast, obvious
find src -name "*Bank*"
find tests -name "*.spec.ts"
ls src/components/ui/

# ❌ BAD - Complex, slow, thrashing
git log --all --full-history --source -- "*Bank*"
grep -r "Bank" . | grep -v node_modules | grep .tsx
```

**Why:** Simple commands are faster, clearer, and less error-prone.

### Step 3: Ask User if Still Unclear

**Only after Steps 1-2, ask user:**

```
"I checked docs/core-architecture/ and used 'find src -name *Bank*'
but didn't find the Banking UI. Where should I look?"
```

**NOT:**

```
"Where is the Banking UI?"  (didn't check first)
```

---

## Good Search Patterns

### Finding Files

**Use `find` for file search:**

```bash
# Find by name pattern
find src -name "*Service.ts"
find tests -name "*bank*.spec.ts"
find src/components -name "*Overlay.tsx"

# Find by type
find src -type f -name "*.tsx"
find tests -type f -name "*.spec.ts"

# Combine with ls for specific directory
ls src/components/ui/ | grep Bank
```

### Finding Code Content

**Use `grep` for content search:**

```bash
# Find specific string
grep -r "BankOverlay" src/
grep -r "data-testid" src/components/ui/

# Find test patterns
grep -r "describe(" tests/shop/
grep -r "test(" tests/banking/

# Find import statements
grep -r "import.*BankingService" src/
```

### Checking Test ID Naming

**Read the testIds file directly:**

```bash
# See all test ID conventions
cat src/testing/testIds.ts

# Find specific test ID
grep "bank" src/testing/testIds.ts
```

---

## Anti-Patterns (Don't Do These)

### Anti-Pattern 1: Git Log for File Search

**❌ WRONG:**

```bash
git log --all --full-history --source -- "*Bank*"
git log --grep="Banking"
```

**Why it's wrong:**

- Slow (searches entire git history)
- Returns commits, not current files
- Thrashing (user has to correct you)

**✅ RIGHT:**

```bash
find src -name "*Bank*"
```

**Result:** Instant, current files, exactly what you need.

### Anti-Pattern 2: Complex Grep Chains

**❌ WRONG:**

```bash
grep -r "Bank" . | grep -v node_modules | grep .tsx | grep -v test
```

**Why it's wrong:**

- Overcomplicated
- Fragile (breaks if file structure changes)
- Hard to read

**✅ RIGHT:**

```bash
find src/components -name "*Bank*.tsx"
# OR
grep -r "BankOverlay" src/components/
```

**Result:** Simple, clear, maintainable.

### Anti-Pattern 3: Searching Before Reading Docs

**❌ WRONG:**

```
1. grep -r "test(" tests/
2. Try to infer test pattern from results
3. Ask user about test structure
```

**Why it's wrong:**

- Docs already explain test patterns
- Wastes time reinventing documented knowledge

**✅ RIGHT:**

```
1. cat docs/testing/playwright-guide.md
2. See test pattern documented
3. Copy pattern exactly
```

**Result:** Faster, accurate, no user correction needed.

---

## Real-World Example: Banking E2E Tests

### What Happened (Sprint 13)

**Task:** Add E2E tests for Banking System

**What I Did Wrong:**

1. Started writing tests immediately
2. Used complex git/grep commands to find Banking UI
3. Didn't check if test IDs were required
4. Made assumptions about test structure

**User Feedback:**

> "my dude why are you thrashing so hard i did a simple find src | grep Bank"
> "our testing documentation should clearly state we use test ids"
> "you should be following the documentation we have the examples you see"

**What I Should Have Done:**

**Step 1: Read docs first**

```bash
cat docs/testing/playwright-guide.md
# Found: "Use data-testid for reliable selectors"
```

**Step 2: Check existing tests**

```bash
ls tests/shop/
cat tests/shop/shop-purchasing.spec.ts
# Found: Pattern uses TEST_IDS, test harness, fixtures
```

**Step 3: Find Banking UI**

```bash
find src -name "*Bank*"
# Result: src/components/ui/BankOverlay.tsx (instant)
```

**Step 4: Implement following pattern**

- Copy shop-purchasing.spec.ts structure
- Use TEST_IDS from testIds.ts
- No thrashing, no user correction needed

---

## Search Command Reference

### By Use Case

| I Need To...               | Use This Command                                            |
| -------------------------- | ----------------------------------------------------------- |
| Find a file by name        | `find src -name "*Pattern*"`                                |
| Find files in specific dir | `ls src/components/ui/` or `find src/components/ui -type f` |
| Find code containing X     | `grep -r "search term" src/`                                |
| Find test files            | `find tests -name "*.spec.ts"`                              |
| Find test patterns         | `grep -r "describe(" tests/feature/`                        |
| Check test ID conventions  | `cat src/testing/testIds.ts`                                |
| Find imports of service    | `grep -r "import.*ServiceName" src/`                        |
| List directory contents    | `ls path/to/dir/`                                           |

### By File Type

```bash
# TypeScript components
find src -name "*.tsx"

# TypeScript services
find src/services -name "*.ts"

# Test files
find tests -name "*.spec.ts"

# Storybook stories
find src -name "*.stories.tsx"

# Configuration files
ls *.config.ts
```

---

## Documentation-First Checklist

**Before searching code, ask yourself:**

- [ ] Is this explained in docs/? (Check README.md, relevant section)
- [ ] Is there a guide for this? (playwright-guide.md, coding-standards.md, etc.)
- [ ] Are there examples in docs/? (before-you-start-checklist.md has examples)
- [ ] Is there a session log about this? (Check recent session-handoffs/)

**Only search code if:**

- [ ] Docs don't cover it
- [ ] Looking for specific implementation details
- [ ] Need to copy existing pattern

---

## Efficient Context Gathering Protocol

**From docs/README.md "Efficient Context Gathering" section:**

### Step 1: Read Documentation

**Before searching code:**

```bash
# Start with README
cat docs/README.md

# Check relevant guides
cat docs/testing/playwright-guide.md
cat docs/development-guide/coding-standards.md

# Check data model (if working with data)
cat docs/core-architecture/DATA-MODEL.md
```

### Step 2: Check Similar Existing Code

**After understanding patterns from docs:**

```bash
# Find similar implementations
find tests/shop -name "*.spec.ts"
cat tests/shop/shop-purchasing.spec.ts

# Find service patterns
ls src/services/
cat src/services/BankingService.ts
```

### Step 3: Verify Naming Conventions

**Check project conventions:**

```bash
# Test IDs
cat src/testing/testIds.ts

# Commit messages
cat docs/development-guide/commit-guidelines.md

# TypeScript conventions
cat docs/development-guide/coding-standards.md
```

---

## Common Mistakes to Avoid

### Mistake 1: "I'll search the codebase to figure it out"

**Why it fails:** Codebase is large, documentation is curated

**Solution:** Read docs first, search code second

### Mistake 2: "I'll use advanced git commands"

**Why it fails:** Git searches history, not current state. Slow and confusing.

**Solution:** Use `find` and `grep` for current codebase

### Mistake 3: "I'll infer patterns from search results"

**Why it fails:** You might find outdated or wrong patterns

**Solution:** Read documentation for canonical patterns

### Mistake 4: "I'll ask the user where X is"

**Why it fails:** User wrote docs to answer this question

**Solution:** Check docs first, then ask if still unclear

---

## Tools Comparison

| Tool       | Good For                          | Bad For               | Speed      |
| ---------- | --------------------------------- | --------------------- | ---------- |
| `find`     | Finding files by name/pattern     | Finding code content  | ⚡ Instant |
| `grep`     | Finding code containing string    | Finding files by name | ⚡ Fast    |
| `ls`       | Listing directory contents        | Recursive search      | ⚡ Instant |
| `cat`      | Reading specific file             | Finding files         | ⚡ Instant |
| `git log`  | Understanding commit history      | Finding current files | 🐌 Slow    |
| `git grep` | Finding code in git-tracked files | Simple searches       | ⚡ Fast    |

**Rule of Thumb:**

- File search = `find`
- Content search = `grep`
- Read file = `cat`
- List directory = `ls`
- Git history = `git log` (rarely needed)

---

## Success Criteria

**You're searching effectively when:**

- ✅ You check docs before searching code
- ✅ You use simple commands (`find`, `grep`, `ls`, `cat`)
- ✅ You find what you need in 1-2 commands
- ✅ User doesn't comment on your search approach

**You're thrashing when:**

- ❌ User says "why are you thrashing so hard"
- ❌ You're using complex git commands
- ❌ You're chaining multiple greps together
- ❌ You're searching before reading docs
- ❌ You need 5+ commands to find something

---

## Quick Reference Card

**Before ANY code search:**

1. ✅ Read relevant docs (README.md, guides, DATA-MODEL.md)
2. ✅ Use simple tools (`find`, `grep`, `ls`, `cat`)
3. ✅ Check test IDs in testIds.ts
4. ✅ Ask user only if docs + search don't answer

**Golden Rule:**
**Simplest tool that works > Complex tool that might work**

---

## The Shop/Bank/Hub Feature Universal Pattern (NEW)

**Context:** Session 2025-10-19 Part 5, I reinvented patterns instead of copying Shop.

**CRITICAL:** All future hub features follow the Shop pattern.

**User Quote:**

> "in terms of implementation alot of future roadmap will be exactly like Shop and now Banking you cant ignore our code base and conventions"

### Hub Feature Pre-Implementation Checklist

**Before writing ANY hub feature code:**

```bash
# 1. Read ShopService.ts (ProtectedSupabaseClient pattern)
cat src/services/ShopService.ts
# Observe: All Supabase calls via protectedSupabase
# Observe: operationName for debugging
# Observe: Timeout configuration
# Observe: Error handling

# 2. Read ShopOverlay.tsx (async loading pattern)
cat src/components/ui/ShopOverlay.tsx
# Observe: useState for loading/error/data
# Observe: useEffect for fetching
# Observe: Loading state render
# Observe: Error state render
# Observe: Success state render

# 3. Read shop E2E tests (test structure)
cat tests/shop/shop-purchasing.spec.ts
# Observe: Test structure (beforeEach, afterEach)
# Observe: Helper usage (signInTestUser, navigateToShop)
# Observe: Test ID usage (not CSS selectors)
# Observe: Defensive assertions

# 4. Read shop test harness helpers (helper pattern)
grep -A 20 "showShopOverlay" src/utils/testHarness.ts
# Observe: How shop overlay is opened
# Observe: How shop state is mocked
```

### The Universal Hub Feature Pattern

**Service Layer (ALL services follow this):**

```typescript
// ALWAYS use ProtectedSupabaseClient (never direct supabase)
import { protectedSupabase } from './ProtectedSupabaseClient';

class FeatureService {
  static async getData(id: string) {
    return protectedSupabase.query(() => supabase.from('table').select('*').eq('id', id), {
      timeout: 6000,
      operationName: 'feature-get-data',
      optimistic: cachedData, // Optional
    });
  }
}
```

**Overlay Layer (ALL overlays handle async loading):**

```typescript
const FeatureOverlay = ({ onClose }) => {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState(null);

  useEffect(() => {
    FeatureService.getData()
      .then(setData)
      .catch((err) => setError(err.message))
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  return <FeatureUI data={data} onClose={onClose} />;
};
```

**E2E Tests (ALL tests follow shop pattern):**

```typescript
test.describe('Feature', () => {
  test.beforeEach(async ({ page }) => {
    await signInTestUser(page);
    await selectFirstCharacter(page);
  });

  test.afterEach(async ({ page }) => {
    await closeOverlay(page);
  });

  test('should do thing', async ({ page }) => {
    await navigateToFeature(page);
    await expect(page.getByTestId(TEST_IDS.ui.feature.overlay)).toBeVisible();
  });
});
```

### Future Hub Features Using This Pattern

**All of these will be IDENTICAL to Shop/Bank:**

- ✅ Shop (implemented)
- ✅ Bank (implemented)
- ✅ Workshop (implemented)
- ✅ Inventory (implemented)
- ⏳ Barracks (future)
- ⏳ Marketplace (future)
- ⏳ Guild Hall (future)

**Copy Shop. Don't invent.**

---

## Related Lessons

- [08-dry-principle.md](08-dry-principle.md) - **NEW:** Never reinvent existing patterns
- [03-user-preferences.md](03-user-preferences.md) - Read requests twice, no assumptions
- [02-testing-conventions.md](02-testing-conventions.md) - Read testing docs before writing tests

## Related Documentation

- [docs/README.md](/home/alan/projects/scrap-survivor/docs/README.md) - Efficient Context Gathering section
- [docs/development-guide/before-you-start-checklist.md](/home/alan/projects/scrap-survivor/docs/development-guide/before-you-start-checklist.md)
- [src/services/ProtectedSupabaseClient.ts](/home/alan/projects/scrap-survivor/src/services/ProtectedSupabaseClient.ts) - **THE** way to call Supabase

## Session References

- [session-log-2025-10-19-part5-recovery.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part5-recovery.md) - Recovery from DRY violations
- [session-log-2025-10-19-part2-e2e-tests.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part2-e2e-tests.md) - Banking E2E thrashing incident
- CONTINUATION_PROMPT.md (Sprint 13 E2E Test Failures section)
