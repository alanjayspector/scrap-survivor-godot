# Commit Message Guidelines

**Last Updated:** 2025-11-02 (changed to sentence-case for readability)
**Status:** Active - Current commit format standard
**Owner:** Project Team

---

## 🎯 Conventional Commits Format

All commits MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

**Format:** `type(scope): subject`

```
type(scope): short description

Optional longer description explaining the change.
Can be multiple paragraphs.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## ✅ Commit Types

Use these types (enforced by commitlint):

- **`feat`** - New feature for the user
- **`fix`** - Bug fix for the user
- **`refactor`** - Code restructuring without behavior change
- **`perf`** - Performance improvement
- **`test`** - Adding/updating tests
- **`docs`** - Documentation changes
- **`style`** - Code style changes (formatting, no logic change)
- **`chore`** - Build process, dependencies, tooling
- **`build`** - Build system changes
- **`ci`** - CI/CD configuration changes
- **`revert`** - Reverting a previous commit
- **`quality`** - Quality infrastructure improvements (linting, testing, CI/CD automation)

---

## 📝 Scope Guidelines

The scope indicates what part of the codebase is affected:

**Common scopes:**

- `ui` - User interface components
- `game` - Game logic, Phaser scenes
- `auth` - Authentication system
- `inventory` - Inventory management
- `workshop` - Workshop feature
- `recycler` - Recycler feature
- `shop` - Shop feature
- `tier` - Tier system (free/premium/sub)
- `test` - Test infrastructure
- `e2e` - E2E tests specifically
- `deps` - Dependency updates
- `config` - Configuration files
- `quality` - Quality infrastructure (linting, testing, CI/CD)
- `eslint` - ESLint configuration and rules
- `commitlint` - Commit message linting rules

**Examples:**

- `feat(recycler): Add dismantle confirmation dialog`
- `fix(auth): Handle null user session`
- `refactor(inventory): Extract weapon card component`
- `test(e2e): Add workshop repair test`
- `docs(readme): Update installation instructions`
- `chore(deps): Upgrade playwright to 1.40`

---

## ✍️ Subject Line Rules

**MUST follow these rules (enforced by commitlint):**

1. **Subject case:** Flexible - title case or sentence case accepted
   - ✅ `feat(ui): Add recycler button` (sentence case)
   - ✅ `feat(ui): Add Recycler Button` (title case)
   - ✅ `fix(native): Handle React Native navigation edge case`
   - ✅ `quality: Update linting rules for development flexibility`
   - ❌ Avoid ALL CAPS (unless it's an acronym)
   - **Why:** Allows flexibility while maintaining professional commit style
   - **Note:** commitlint shows warning for non-standard formatting but won't block commits

2. **No period:** Don't end subject with a period
   - ✅ `fix(auth): Handle null session`
   - ❌ `fix(auth): Handle null session.`

3. **Imperative mood:** Use "Add" not "Added" or "Adds"
   - ✅ `feat: Add new feature`
   - ❌ `feat: Added new feature`
   - ❌ `feat: Adds new feature`

4. **Max length:** Keep subject under 100 characters
   - ✅ `feat(ui): Add recycler dismantle button to inventory weapon cards`
   - ❌ `feat(ui): Add recycler dismantle button to inventory weapon cards that allows players to...`

5. **Body line length:** Body lines must also be under 100 characters
   - Enforced by commitlint for multi-line commits
   - Break long lines into multiple shorter lines
   - ✅ Good:
     ```
     integrate notebooklm as primary documentation query mechanism for ai
     assistants, enabling query-based access to all project documentation
     with significant token savings and improved context gathering.
     ```
   - ❌ Bad:
     ```
     integrate notebooklm as primary documentation query mechanism for ai assistants, enabling query-based access to all project documentation with significant token savings and improved context gathering.
     ```

---

## 📋 Real Examples from This Project

### Feature Additions

```bash
git commit -m "feat: complete sprint 10 - recycler foundation & blueprint pipeline

Merges feature/sprint-10-blueprint-loop into stable.

Sprint 10 Highlights:
- Fixed critical recycler weapon lookup bug with WeaponInstanceIdService
- Achieved 100% E2E test pass rate (14/14 runnable tests)
- Comprehensive workshop repair system with blueprint costs
- Full blueprint pipeline integration across Shop/Recycler/Workshop
- Created manual verification guide for QA
- 279 unit tests passing, all Storybook stories rendering

All sprint goals completed. Ready for manual QA.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Bug Fixes

```bash
git commit -m "fix(recycler): require stable weapon instance ids

Implement WeaponInstanceIdService to ensure stable IDs across sessions.
Fixes issue where weapon lookup failed after page refresh.

- Add WeaponInstanceIdService with seed-based ID generation
- Update RecyclerCoordinator to use stable IDs
- Add comprehensive unit tests for ID stability
- Update E2E fixtures to use stable IDs

Fixes: Recycler failing to find weapons after session reload

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Test Updates

```bash
git commit -m "test(e2e): achieve 100% e2e test pass rate (14/14 passing)

Skip recycler and workshop E2E tests in favor of unit tests.
Add comprehensive manual verification guide for QA.

Changes:
- Skip recycler-flow.spec.ts with detailed rationale
- Skip workshop-repair.spec.ts with detailed rationale
- Create tests/MANUAL_VERIFICATION.md for QA guide
- Clean up debug logging from InventoryScreen
- Document test philosophy: E2E for flows, unit for logic

Result: 14/14 runnable E2E tests passing (100% pass rate)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Infrastructure/Tooling

```bash
git commit -m "chore(test): add e2e test infrastructure improvements

Add Phaser game instance to window for debugging and E2E test access.
Add seed script for recycler fixture generation.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Quality Infrastructure (New Type)

```bash
git commit -m "quality(eslint): Adjust commitlint rules for development flexibility

Quality infrastructure improvements:
- Added quality commit type for infrastructure work
- Relaxed subject-case to warning level (not error)
- Added body-max-line-length warning for readability
- Added comprehensive documentation of rule levels

This demonstrates engineering principle: when rules are too restrictive,
fix the rules rather than bypass them. Quality gates should enable development,
not create friction for legitimate work.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Documentation

```bash
git commit -m "docs(workflow): update development guide to reflect actual workflow

Remove outdated MCP tool references.
Document current git workflow with pre-commit hooks.

- Update tool-usage.md with real workflow (no MCP)
- Update commit-guidelines.md with real examples
- Add GitHub CLI examples for PR creation
- Document pre-commit hooks (commitlint, lint-staged)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## 🚫 Common Mistakes

### Mistake 1: Lowercase subject start

❌ **Wrong:**

```bash
git commit -m "feat(ui): add recycler button"
```

✅ **Correct:**

```bash
git commit -m "feat(ui): Add recycler button"
```

### Mistake 2: Using wrong type

❌ **Wrong:**

```bash
git commit -m "merge: sprint 10 to stable"  # "merge" is not a valid type!
```

✅ **Correct:**

```bash
git commit -m "feat: complete sprint 10 - recycler foundation"
```

### Mistake 3: Vague subject

❌ **Wrong:**

```bash
git commit -m "fix: bug"
git commit -m "chore: updates"
git commit -m "feat: changes"
```

✅ **Correct:**

```bash
git commit -m "fix(auth): Handle null user session"
git commit -m "chore(deps): Upgrade playwright to 1.40"
git commit -m "feat(recycler): Add dismantle confirmation dialog"
```

### Mistake 4: Past tense

❌ **Wrong:**

```bash
git commit -m "feat(ui): Added recycler button"
git commit -m "fix(auth): Fixed null session bug"
```

✅ **Correct:**

```bash
git commit -m "feat(ui): Add recycler button"
git commit -m "fix(auth): Fix null session bug"
```

---

## 📝 Using HEREDOC for Multi-Line Commits

When commits have multiple lines, use HEREDOC to ensure proper formatting:

```bash
git commit -m "$(cat <<'EOF'
feat(recycler): Add dismantle confirmation dialog

Add confirmation dialog before dismantling weapons.
Shows scrap/parts rewards preview.

- Add RecyclerConfirmDialog component
- Integrate with RecyclerService.previewDismantle
- Add E2E test for confirmation flow
- Update inventory screen to show dialog

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Why HEREDOC?**

- Preserves line breaks
- Handles special characters correctly
- Prevents shell interpretation issues
- Required for pre-commit hooks to work properly

---

## 🤖 Claude Code Signature

All commits should include the Claude Code signature at the end:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

This:

- Provides attribution for AI-assisted work
- Helps track AI contributions
- Maintains transparency

---

## ⚙️ Automated Validation

Your commits are automatically validated by **commitlint** via Husky pre-commit hooks.

**What gets checked:**

- ✅ Type is one of the allowed types
- ✅ Subject is sentence-case (capital first letter)
- ✅ Subject has no trailing period
- ✅ Subject is under 100 characters
- ✅ Message follows conventional format

**If commit fails:**

```bash
⧗   input: feat(ui): add recycler button
✖   subject must be sentence-case [subject-case]
✖   found 1 problems, 0 warnings
husky - commit-msg script failed (code 1)
```

**Fix and retry:**

```bash
git commit -m "feat(ui): Add recycler button"
```

---

## 🔗 Related Documents

- [tool-usage.md](tool-usage.md) - Development workflow guide
- [coding-standards.md](coding-standards.md) - TypeScript and React standards
- [Conventional Commits Spec](https://www.conventionalcommits.org/) - Official specification

---

## 📝 Quick Reference

**Template:**

```
type(scope): Short imperative description

Optional longer description.
Use multiple lines if needed.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Valid types:** `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`, `build`, `ci`, `revert`, `quality`

**Rules:**

- Flexible subject case (title case or sentence case accepted)
- No trailing period
- Imperative mood ("Add" not "Added")
- Under 100 characters
- Use HEREDOC for multi-line commits
- **New:** Quality infrastructure work should use `quality` type
- **New:** Subject formatting shows warning but doesn't block commit

---

**Last Updated:** 2025-11-02
**Repository:** scrap-survivor
**Validation:** commitlint + husky
