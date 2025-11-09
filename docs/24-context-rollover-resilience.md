# Lesson 24: Context Rollover Resilience

**Date:** 2025-10-20
**Context:** E2E banking test fixes session - Git commit rules forgotten after context rollover

## Problem

During long debugging sessions, Claude Code agents can experience context rollovers (when conversation history is summarized to free up context). After a rollover, mechanical rules like git commit message formatting can be forgotten, leading to hook failures.

**Evidence:**

- Session 2025-10-20: First git commit attempt failed with:
  ```
  ✖ body's lines must not be longer than 100 characters [body-max-line-length]
  ✖ subject must be lower-case [subject-case]
  ```
- This occurred after a long debugging session with context rollover
- Required second attempt to fix format

## Root Cause

**Mechanical rules** (git commit format, test conventions, file naming) are stored in documentation but not actively referenced post-rollover. After summarization:

- Agent retains task context (what bugs to fix)
- Agent loses procedural context (how to format commits)
- No automatic prompt to re-check documentation

## Solution: Post-Rollover Recovery Checklist

Added to CONTINUATION_PROMPT.md as a mandatory step when resuming work after any break or rollover.

### When to Use This Checklist

Use immediately after:

1. Context rollover (conversation summarization)
2. Starting a new session from continuation prompt
3. After any long gap in conversation (>30 minutes)
4. Before any git commit operation

### The Checklist

```markdown
## Post-Rollover Recovery Checklist

Before proceeding with work, verify:

- [ ] Re-read Critical Rules (CONTINUATION_PROMPT Steps 1-5)
- [ ] Review git commit protocol (Step 14)
- [ ] Check NotebookLM query requirements (Step 6: minimum 3-4 per session)
- [ ] Verify testing conventions (Step 8)
- [ ] Check last 3 commits for pattern: `git log --oneline -3`
```

### Git Commit Pre-Flight (Run Before EVERY Commit)

```bash
# 1. Check recent commit patterns
git log --oneline -3

# 2. Verify your commit message format:
# - Subject is lowercase (e.g., "fix:" not "Fix:")
# - Subject follows conventional commits (fix/feat/docs/test/refactor)
# - Body lines ≤100 characters
# - Includes emoji footer and co-author
# - Uses HEREDOC format: cat <<'EOF'

# 3. Example correct format:
git commit -m "$(cat <<'EOF'
fix(e2e): fix banking e2e tests with mock implementation

Fixed all 4 tests by implementing proper mocking and
reactive state management.

Changes:
- Fixed tier reading pattern
- Added getOrCreateAccount mock
- Button disabled when amount > maxDeposit

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Pattern: Evidence-Based Recovery

When resuming after rollover, don't rely on memory. Instead:

1. **Read Documentation First**

   ```bash
   # Check commit format from recent commits
   git log --oneline -5
   git show HEAD --format=fuller

   # Re-read relevant sections of CONTINUATION_PROMPT.md
   ```

2. **Query NotebookLM for Patterns**

   ```bash
   python scripts/run.py ask_question.py \
     --question "What is the required git commit message format?" \
     --notebook-url "https://notebooklm.google.com/notebook/..."
   ```

3. **Verify Before Executing**
   - Check message format against example
   - Run commitlint rules in head before committing

## Related Issues

**Why This Matters:**

- Commit hook failures waste time (failed commit + retry)
- Shows agent is not resilient to context changes
- Indicates missing systematic recovery protocol

**Other Mechanical Rules at Risk:**

- File naming conventions (kebab-case, .spec.ts suffix)
- Test organization (unit tests in **tests**, E2E in tests/)
- Import path patterns (@/ for absolute imports)
- NotebookLM query frequency (minimum 3-4 per session)

## Testing This Protocol

To verify this checklist prevents rollover issues:

1. **Simulate Rollover:**
   - Start new session with continuation prompt
   - Don't reference CONTINUATION_PROMPT.md initially
   - Attempt a git commit

2. **Expected Behavior:**
   - Agent should consult Post-Rollover Recovery Checklist BEFORE committing
   - Agent should run `git log --oneline -3` to check pattern
   - Commit should succeed on first attempt

3. **Failure Indicators:**
   - Commit hook rejection
   - Agent guessing at format instead of checking examples
   - Missing emoji footer or co-author

## Integration with CONTINUATION_PROMPT.md

This checklist is now Step 2 in CONTINUATION_PROMPT.md, immediately after "Read This Document." It must be completed before proceeding with any tasks.

**Location:** CONTINUATION_PROMPT.md, Step 2
**Enforcement:** Manual (agent self-check)
**Verification:** First git commit attempt in session should succeed

## Key Takeaway

**Mechanical rules should never be forgotten, regardless of context rollover.**

The solution is systematic documentation reference, not relying on memory. When in doubt:

1. Read the docs
2. Check recent examples
3. Query NotebookLM
4. Verify before executing

This protocol ensures consistency across sessions and resilience to context changes.
