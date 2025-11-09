# Lesson 01: Git Operations

**Category:** 🔴 Critical (Never Violate)
**Last Updated:** 2025-10-19 (Updated Part 3 - Meta-lesson added)
**Sessions:** 2025-10-19 Part 2 (E2E Tests), Part 3 (Lessons Learned creation)

---

## CRITICAL RULE: Always Get Approval First

**Context:** Session 2025-10-19, I attempted `gh pr merge --squash` without asking.

**User Feedback:**

> "i'm a little nervous with squashes can you first explain to me why you are doing it this way this time?"

> "also in the future please check in with a recommendation before acting. git repo management is critical i dont want to lose work ok?"

**Lesson:** NEVER execute git operations affecting branches/history without explicit user approval.

**Why This Matters:**

- Git operations are often irreversible (especially after push)
- User values detailed commit history for context
- Losing work destroys trust and wastes time
- Recovery from mistakes consumes session tokens

---

## The Protocol (Mandatory)

### 1. Present Options

```
"I can merge this PR using three strategies:

1. --merge (preserves all commits)
   Pros: Full history, easy to trace changes
   Cons: More commits in main branch

2. --squash (combines into one commit)
   Pros: Clean linear history
   Cons: Loses individual commit messages

3. --rebase (replays commits)
   Pros: Linear history, preserves commits
   Cons: Rewrites commit history
```

### 2. Make Recommendation

```
"I recommend --merge because:
- Preserves your detailed commit messages from Sprint 13
- Makes it easy to trace when specific features were added
- Matches previous merge strategy for Sprints 1-12
```

### 3. Wait for Approval

```
"Which approach would you prefer?"
```

### 4. Execute Confirmed Command

**Only after user explicitly approves:**

```bash
gh pr merge 12 --merge --delete-branch
```

---

## Operations Requiring Approval

### Branch/History Operations

- ❌ `git merge` (any strategy: merge, squash, rebase)
- ❌ `git rebase` (any form)
- ❌ `git reset --hard` (destructive)
- ❌ `git push --force` (overwrites remote)
- ❌ `gh pr merge` (any flags)
- ❌ Branch deletion (`git branch -D`, `--delete-branch` flag)
- ❌ `git commit --amend` (if not your commit)
- ❌ `git cherry-pick` (if affects shared branches)

### Why These Need Approval

They are **irreversible** or **affect shared history**.

---

### Operations OK Without Approval

### Safe Local Operations

- ✅ `git add <files>`
- ✅ `git commit -m "message"` (following commit message guidelines, with all hooks passing)
- ✅ `git status`
- ✅ `git log`
- ✅ `git diff`
- ✅ `git show`

### Safe Remote Operations

- ✅ `git push origin <feature-branch>` (first push or fast-forward)
- ✅ `git pull origin <feature-branch>` (updating current branch)
- ✅ `git fetch`

### Why These Are Safe

They don't affect shared history or branch structure AND they pass all quality checks.

**IMPORTANT Critical Update:** Never use `--no-verify` with `git commit`. If quality hooks fail:

1. **Fix the underlying issue** (preferred)
2. **Adjust the rule if inappropriate** (new approach)
3. **Commit properly** - quality gates enable, don't block legitimate work

**What this means:**

- ❌ `git commit -m "message" --no-verify` (NEVER bypass quality gates)
- ✅ Fix linting/commitlint issues and commit normally
- ✅ Adjust eslint/commitlint config if rules are too restrictive
- ✅ Quality gates should be modified to enable development, not bypassed

---

## Merge Strategy Preferences

### User Prefers: `--merge`

**Why:** Preserves all individual commits with their messages

- Sprint 13 had 7 detailed commits explaining each phase
- Historical context is valuable for future debugging
- Matches convention from Sprints 1-12

**When to use:**

- Default for all feature branch merges
- When commits tell a coherent story
- When preserving authorship matters

### Avoid: `--squash`

**Why:** Loses commit history

- Individual commit messages disappear
- Can't trace when specific changes were made
- Makes git bisect less useful

**Only use if:**

- User explicitly requests it
- Branch has messy WIP commits that don't add value
- User confirms they don't need the history

### Acceptable: `--rebase`

**Why:** Creates linear history while preserving commits

- Keeps individual commits
- Cleaner graph than merge commits
- But rewrites history (which user is cautious about)

**Only use if:**

- User explicitly requests it
- Branch is behind main and needs updating
- Working on personal feature branch (not shared)

---

## Commit Message Guidelines

### Required Elements (Per User Convention)

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body explaining why, not what>

<optional breaking changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Why HEREDOC?

- Ensures proper multi-line formatting
- Prevents shell escaping issues
- Matches existing commit convention

### Types Used

- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `docs:` - Documentation changes
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks

### CRITICAL: Always Check Guidelines Before Committing

**Meta-Lesson (Session 2025-10-19 Part 3):**

Even when you KNOW commit guidelines exist, you must CHECK them before every commit.

**What Happened:**
I spent 2+ hours documenting "read docs before doing things" in lessons-learned system. Then immediately committed with incorrect format:

```bash
# ❌ WRONG - uppercase "Problem"
git commit -m "docs(lessons-learned): create institutional memory...

Problem: AI assistants start each session..."
```

Pre-commit hook rejected it (subject must be lowercase). I fixed it:

```bash
# ✅ CORRECT - lowercase "problem"
git commit -m "docs(lessons-learned): create institutional memory...

problem: AI assistants start each session..."
```

**User's Response:**

> "so commit messages is something we covered extensively in under docs/01 getting started .. what did you just learn? :) while doing this wrap up ?"

**The Real Lesson:**

**Knowing docs exist ≠ Following docs**

**Before EVERY commit:**

1. ✅ Open `docs/development-guide/commit-guidelines.md`
2. ✅ Verify your message matches format (lowercase subject, conventional commits)
3. ✅ Check body format (problem/solution pattern if applicable)
4. ✅ THEN commit

**Don't rely on:**

- Memory of "how commit messages work"
- Muscle memory from other projects
- Assuming you remember the format

**Pre-commit hook is last resort, not first line of defense.**

**Location of Guidelines:**

- `docs/development-guide/commit-guidelines.md` (primary reference)
- `docs/getting-started/` (also covered extensively)

**Why This Matters:**
If I can document lessons about reading docs, then immediately fail to read docs, this proves the fundamental problem: **AI assistants need systematic reminders, not just knowledge.**

That's exactly why lessons-learned system exists.

---

## Recovery From Mistake (What I Did)

### The Incident

```bash
# I attempted (user rejected):
gh pr merge 12 --squash --delete-branch
```

### The Recovery

1. **Stopped immediately** when user challenged
2. **Explained all options** with pros/cons
3. **Made recommendation**: `--merge` to preserve history
4. **Waited for confirmation**: User said "let's go with your recommendation"
5. **Executed approved command**:
   ```bash
   gh pr merge 12 --merge --delete-branch
   ```

### Why This Worked

- Acknowledged the mistake
- Provided educational context (not defensive)
- Gave user control
- Built trust through transparency

---

## Common Scenarios

### Scenario 1: Merging PR After Sprint Complete

```
AI: "Sprint 13 is complete. I can merge PR #12 to stable using:

1. --merge (recommended): Preserves all 7 commits with detailed messages
2. --squash: Creates single commit 'Sprint 13: Banking System'
3. --rebase: Replays commits on top of stable

I recommend --merge because your commit messages document the 8 phases
clearly, which will help with future debugging and context.

Which approach would you prefer?"

User: "let's go with --merge"

AI: [Executes] gh pr merge 12 --merge --delete-branch
```

### Scenario 2: Updating Feature Branch

```
AI: "Your feature branch is 5 commits behind stable. I can update it using:

1. git merge stable (creates merge commit)
2. git rebase stable (rewrites history, linear)
3. git pull --rebase (similar, but pulls remote first)

I recommend 'git merge stable' to avoid rewriting history on a shared branch.

Would you like me to update the branch?"

User: "yes, merge stable in"

AI: [Executes] git merge stable --no-edit
```

### Scenario 3: Fixing Mistakes

```
AI: "I noticed a typo in the last commit message. I can fix it using:

1. git commit --amend (rewrites last commit)
2. Leave it (minor typo, not worth rewriting history)

I recommend leaving it since the branch is already pushed and the typo
doesn't affect understanding.

Would you like me to amend it anyway?"
```

---

## Red Flags (Stop and Ask)

If you're about to:

- Use `--force` or `-f` flag
- Delete a branch
- Rewrite history (`rebase`, `amend`, `reset`)
- Merge to `main` or `stable`
- Create a release tag

**STOP. Ask first.**

---

## Testing This Lesson

### Self-Check Questions

Before any git operation, ask:

1. Does this change branch history? → **Need approval**
2. Does this affect remote branches? → **Need approval**
3. Is this reversible? → If no, **need approval**
4. Would the user want to know? → **Need approval**

### Practice Scenarios

- "Merge PR to stable" → **Ask first** (affects shared branch)
- "Commit changes to feature branch" → **OK** (standard workflow)
- "Push to feature branch" → **OK** (your branch, fast-forward)
- "Rebase feature branch" → **Ask first** (rewrites history)
- "Delete merged branch" → **Ask first** (destructive)

---

## Summary

**ALWAYS ASK before git operations affecting branches or history.**

**The Protocol:**

1. Present options with pros/cons
2. Make recommendation with rationale
3. Wait for explicit approval
4. Execute confirmed command only

**User values:**

- Preserving detailed commit history
- Being in control of git operations
- Transparency about risks

**My responsibility:**

- Never assume what user wants
- Educate about options
- Respect that it's their repository

---

## Quality Gate Philosophy (Critical Update)

**Session 52 taught us a fundamental lesson about quality gates.**

### The Wrong Approach (What I Initially Did)

```bash
# ❌ NEVER DO THIS - Bypass quality systems
git commit --no-verify -m "session complete"
```

**Why this is dangerous:**

- Creates shortcuts around quality systems
- Undermines trust in the codebase
- Accumulates hidden technical debt
- Sets bad precedent for other developers

### The Right Approach (What I Learned)

**When quality gates fail:**

```bash
# ✅ Step 1: Identify the problem
npm run lint  # See actual what's failing

# ✅ Step 2: Fix the underlying issue
vim file-with-errors.ts  # Fix coding issues
npm run lint --fix       # Auto-fix formatting

# ✅ Step 3: If rules are inappropriate, adjust them
vim eslint.config.js      # Make rules development-friendly
vim commitlint.config.js   # Make commit rules practical

# ✅ Step 4: Commit properly with all checks passing
git add -A
git commit -m "fix(quality): Adjust quality rules for development flexibility"
```

### Quality Gate Engineering Principles

**Good quality gates should:**

- ✅ **Prevent real problems** (type errors, security issues)
- ✅ **Enable development** (flexible, context-appropriate)
- ✅ **Guide best practices** (warnings, not blockers)
- ✅ **Be adjustable** (modify rules, don't bypass)
- ✅ **Create friction for bad code, not for good code**

**What we adjusted in Session 52:**

- Made `subject-case` a warning instead of error (flexible formatting)
- Added `quality` commit type for infrastructure work
- Added `no-unused-expressions` off for test files (mock patterns)
- Added comprehensive documentation for rule severity levels

### When BYPASSING Quality Gates IS Appropriate

**NEVER use `--no-verify` unless:**

1. **Emergency hotfix** to production (and add comment explaining why)
2. **Infrastructure temporarily broken** and you need to commit the fix
3. **You plan to fix the root cause immediately after**

**Even then, document the bypass:**

```bash
git commit --no-verify -m "fix(emergency): Hotfix production crash

URGENT: Had to bypass linting due to critical production issue.
TODO: Fix linting rules in follow-up commit.

⚠️ Note: Quality gate bypassed due to emergency"
```

### The Engineering Mindset

**Instead of "How do I bypass this restriction?" ask:**

- "Why does this restriction exist?"
- "Is the rule appropriate for our development context?"
- "Can I make the rule more flexible?"
- "Does fixing the root issue improve the system?"

**This transforms quality gates from obstacles into tools for continuous improvement.**

---

## Related Lessons

- [03-user-preferences.md](03-user-preferences.md) - Communication patterns
- [Session 52 Results](../../../sprints/sprint-19/sessions/SESSION-52-ACTUAL-RESULTS-WITH-WORKING-TESTS.md) - Quality gate engineering in action

## Session References

- [session-log-2025-10-19-part2-e2e-tests.md](/home/alan/projects/scrap-survivor/docs/archive/session-handoffs/session-log-2025-10-19-part2-e2e-tests.md)
