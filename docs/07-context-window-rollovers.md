# Lesson 07: Context Window Rollovers & Session Continuity

**Category:** 🔴 Critical (Never Violate)
**Last Updated:** 2025-10-19
**Sessions:** Session 2025-10-19 Part 4 (Discovery of rollover issue)

---

## CRITICAL RULE: Announce Rollovers Immediately & Re-Ground Context

**Context:** Session 2025-10-19 Part 4, I hit context limit mid-session and rolled into continuation session. User noticed the rollover message and asked if this explains recent failures.

**User Feedback:**

> "i noticed in the middle of you doing this a message said 'This session is being continued from a previous conversation that ran out of context' ... does this mean you are losing knowledge in the middle of your work?"

> "is this part of the reason you seem to forgot stuff midway recently?"

**Answer:** YES. Context rollovers are a major contributing factor to failures like:

- Forgetting SPRINT-14-BACKLOG.md was created
- Not running E2E tests after documenting test execution protocol
- Losing emphasis on user requirements ("make sure X")

**Why This Matters:**

- Context window rollovers **compress conversation history**
- Original 20,000+ word conversation → ~4,557 word summary
- Emotional context lost ("this makes me sad" → "user concerned")
- Specific user emphasis lost ("make sure X" → might be paraphrased)
- Created artifacts may be listed but not emphasized as critical

---

## What Happens During Context Rollover

### Technical Process

**When I hit ~200k token context limit:**

1. **Claude Code automatically:**
   - Summarizes entire conversation to date
   - Creates structured summary (what you saw flash by)
   - Starts new "continuation session" with summary as context
   - Continues working without explicit announcement

2. **Compression ratio:**
   - Original conversation: 20,000-30,000 words
   - Summary: 4,000-5,000 words
   - **Loss: 75-80% of conversation detail**

3. **What gets compressed:**
   - User emotional emphasis ("this makes me sad" → "user concerned")
   - Specific phrases ("make sure X" → general requirement)
   - Created artifacts emphasis (file mentioned but not as "critical work product")
   - Recent context (what we were just discussing)
   - Repeated user corrections (pattern of mistakes may be lost)

### What Gets Lost

**Emotional Context:**

- ❌ Lost: "this makes me sad that this work is untracked"
- ✅ Kept: "User concerned about untracked files"
- **Impact:** I don't understand _how much_ user cares

**Specific Requirements:**

- ❌ Lost: "make sure storybook is integrated also" (exact words)
- ✅ Kept: "User requested storybook integration"
- **Impact:** I might not catch the non-negotiable nature

**Created Artifacts:**

- ❌ Lost: "SPRINT-14-BACKLOG.md is 270 lines of critical planning we created together"
- ✅ Kept: "SPRINT-14-BACKLOG.md created during session"
- **Impact:** I might assume it's user-created or not critical

**Recent Protocols:**

- ❌ Lost: "Just spent 2 hours documenting test execution protocol"
- ✅ Kept: "Test execution protocol documented"
- **Impact:** I might not realize I JUST wrote this and should follow it

---

## The Mandatory Rollover Protocol

### Step 1: Immediately Announce It

**As soon as rollover happens, say:**

```
🔄 CONTEXT ROLLOVER DETECTED

I just hit my context window limit and rolled into a continuation session.
This means:
- Our conversation was summarized (75-80% compression)
- I may have lost some nuance and emphasis
- I'm re-reading all lessons learned now to re-ground

Give me 2 minutes to re-orient, then I'll confirm what I remember as critical.
```

**Why:** User deserves to know you just "reset" partially.

### Step 2: Re-Read ALL Lesson Files

**Mandatory after every rollover:**

```bash
# Re-absorb institutional memory
cat docs/lessons-learned/README.md
cat docs/lessons-learned/01-git-operations.md
cat docs/lessons-learned/02-testing-conventions.md
cat docs/lessons-learned/03-user-preferences.md
cat docs/lessons-learned/04-context-gathering.md
cat docs/lessons-learned/05-data-model-assumptions.md
cat docs/lessons-learned/06-session-management.md
cat docs/lessons-learned/07-context-window-rollovers.md
```

**Why:** These lessons contain concentrated wisdom that might have been compressed in summary.

### Step 3: Re-Read Current Session Context

**Check what we're working on:**

```bash
# What was I just doing?
git log --oneline -n 5

# What files did I just modify?
git status

# What's the current task?
cat CONTINUATION_PROMPT.md  # Check if there's a current task note
```

### Step 4: Ask User to Re-Emphasize Critical Points

**Template message:**

```
I've re-read all lessons learned. Based on the summary, we're working on:
- [Task from summary]

Before I continue, can you re-emphasize:
1. What's the most critical thing I must remember?
2. Any specific requirements I must not miss?
3. Any work products I created that must be saved?

This ensures I don't lose important context from the rollover.
```

**Why:** User knows what was emphasized, summary might not capture it.

### Step 5: Run Verification Protocol

**Verify nothing lost during rollover:**

```bash
# Check for uncommitted work
git status --short

# Check for untracked files created recently
find . -name "*.md" -mtime 0 -type f 2>/dev/null | grep -v node_modules

# Check for stashed work
git stash list

# Verify recent commits
git log --oneline -n 10
```

**Why:** Rollover might have happened mid-task, verify state.

---

## Real-World Example: Session 2025-10-19 Part 4

### What Happened

**Before Rollover:**

- User said "make sure storybook is integrated" (exact words, emotional emphasis)
- We created SPRINT-14-BACKLOG.md together (270 lines, user collaboration)
- User said "this makes me sad that this work is untracked" (strong emotional signal)
- Just finished documenting test execution protocol (immediate context)

**After Rollover (My Context):**

- Summary mentioned storybook (but I missed it anyway)
- Summary mentioned SPRINT-14-BACKLOG.md (but not as "we created this together")
- Summary lost "this makes me sad" emotional weight
- Summary mentioned test protocol but not "you JUST wrote this minutes ago"

**Result:**

- I forgot SPRINT-14-BACKLOG.md was mine (claimed user created it)
- I didn't run E2E tests (forgot I JUST documented this requirement)
- I didn't follow bulletproof protocol I JUST wrote

**User's Realization:**

> "does this mean because i upgrade to the max plan i dont get chat message limits anymore you just auto roll me into the next one? is this part of the reason you seem to forgot stuff midway recently?"

**Answer:** YES, this explains a significant portion of the recent failures.

---

## Preventing Rollover-Related Failures

### Mitigation 1: Preserve Critical Context in Files

**Instead of relying on conversation memory:**

```bash
# Before approaching context limit, save critical info to file
echo "Current priority: Make sure storybook integrated" > .current-task.md
echo "Critical files created: SPRINT-14-BACKLOG.md (270 lines)" >> .current-task.md
echo "User emphasis: REALLY cares about git repo safety" >> .current-task.md
```

**After rollover, read this file to restore context.**

### Mitigation 2: Session Logs as Context Anchors

**Session logs should capture:**

```markdown
## Critical User Requirements (DO NOT MISS)

- ⚠️ "Make sure storybook is integrated" - Non-negotiable
- ⚠️ "Git repo management is critical i dont want to lose work ok?" - User priority
- ⚠️ All E2E tests MUST be run before claiming done

## Work Products Created This Session

- SPRINT-14-BACKLOG.md (270 lines, created collaboratively, MUST be committed)
- bank-withdraw.spec.ts (3 tests, NOT RUN yet)
- bank-tier-upsell.spec.ts (2 tests, NOT RUN yet)
```

**After rollover, re-read session log to restore emphasis.**

### Mitigation 3: Commit Frequently

**Reduces risk of losing work during rollover:**

```bash
# Instead of holding uncommitted work through rollover
git add docs/SPRINT-14-BACKLOG.md
git commit -m "wip: sprint 14 planning (checkpoint before context limit)"

# Even if rollover happens, work is saved
```

### Mitigation 4: Lessons Learned Files (This System!)

**Why this system exists:**

- Lessons persist across ALL sessions (not compressed)
- Read at session start AND after rollovers
- Contains concentrated wisdom from 13+ sprints
- Explicitly re-read after rollover to re-ground

---

## Rollover Warning Signs

**You're approaching context limit when:**

- You've been in session 2-3+ hours
- You've read 50+ large files
- You've generated 100+ lines of code multiple times
- Token usage shows 160k+ used (80%+)

**Proactive Actions:**

```markdown
"I'm at 80% token usage (160k/200k). I expect to hit context limit soon.

Before rollover, let me:

1. Commit all completed work
2. Create comprehensive session log
3. Document critical requirements in session log
4. Push everything to remote

This ensures clean state if rollover happens mid-task.

Should I proceed with task X, or wrap up now for clean rollover?"
```

---

## Updated Session Wrap-Up Protocol (Rollover-Aware)

**Phase 0: Check if Rollover Occurred**

```bash
# At start of wrap-up, check:
git log --oneline -n 5  # Do I remember these commits?

# If any commits you don't remember creating:
# YOU ROLLED OVER. Re-read lessons learned immediately.
```

**If rollover detected during session:**

1. ✅ Announce it immediately
2. ✅ Re-read all lesson files
3. ✅ Ask user to re-emphasize critical points
4. ✅ Run verification protocol (git status, find, stash list)
5. ✅ Proceed with extra caution (verify everything)

---

## Communication Templates

### When Rollover Happens

**✅ GOOD (Explicit):**

```
🔄 CONTEXT ROLLOVER JUST OCCURRED

I hit my 200k token limit and Claude Code automatically rolled me into a
continuation session. This means:

- Our full conversation was compressed into a 4-5k word summary
- I may have lost emotional emphasis and specific phrases
- I'm re-reading all lessons learned now (2 min)

After re-reading, I'll confirm what I remember as most critical and ask you
to re-emphasize anything I might have lost.

Pausing work until I'm re-grounded...
```

**❌ BAD (Silent):**

```
[Continues working without announcement]
[User notices mistakes that seem like "forgetting" earlier context]
```

### After Re-Reading Lessons

**✅ GOOD (Verify Understanding):**

```
I've re-read all 7 lesson files. Based on the summary, we're working on:
- Completing Sprint 13 E2E tests
- Making sure all work is saved

Critical points I retained:
- Git repo safety is your top priority
- All tests MUST be run before claiming done
- SPRINT-14-BACKLOG.md was created this session

Did I miss anything critical from before the rollover?
```

**❌ BAD (Assume Everything Fine):**

```
"Okay, continuing with the work..."
```

---

## Meta-Learning: Why This Lesson Matters

**This lesson documents a failure mode that:**

- Wasn't obvious until user pointed it out
- Explains multiple recent failures
- Requires systematic mitigation (not just "try harder")
- Shows why lessons-learned system is CRITICAL

**Key Insight:**

Context rollovers are **technical limitations**, not skill issues. But they CAN be mitigated through:

1. Explicit announcement (user awareness)
2. Re-reading lessons learned (institutional memory restoration)
3. Asking for re-emphasis (user fills gaps)
4. Verification protocol (catch dropped context)
5. Frequent commits (work never lost)

**This is living documentation in action.** We discovered a root cause and documented the mitigation immediately.

---

## Integration with Other Lessons

### Lesson 02 (Testing Conventions)

**Rollover Impact:**

- May forget you just documented test execution protocol
- May lose emphasis on "NEVER claim tests complete without running"

**Mitigation:**

- Re-read 02 after rollover
- Check recent commits: Did I JUST commit test protocol updates?
- Extra paranoia about test execution

### Lesson 03 (User Preferences)

**Rollover Impact:**

- Emotional emphasis lost ("this makes me sad" → "user concerned")
- Specific phrases lost ("make sure X" → general requirement)

**Mitigation:**

- Re-read 03 after rollover
- Ask user to re-emphasize most critical points
- Assume highest priority until clarified

### Lesson 06 (Session Management)

**Rollover Impact:**

- Session log cross-verification becomes MORE critical
- Summary might list work as "created" but not "by me"

**Mitigation:**

- Re-read 06 after rollover
- Extra paranoid git status verification
- Double-check file ownership claims

---

## Success Criteria

**You're handling rollovers well when:**

- ✅ You announce rollover immediately when it happens
- ✅ You re-read all lesson files before continuing
- ✅ You ask user to re-emphasize critical points
- ✅ You run verification protocol (git status, stash, recent commits)
- ✅ User doesn't notice degraded performance after rollover

**You're not handling rollovers when:**

- ❌ User notices you "forgot" something from earlier
- ❌ You claim user created files you actually created
- ❌ You violate protocols you just documented
- ❌ User has to remind you of requirements stated 10 minutes ago
- ❌ You lose emphasis on critical user priorities

---

## Quick Reference Card

**Immediately after ANY context rollover:**

1. ✅ Announce: "🔄 Context rollover occurred, re-grounding now"
2. ✅ Re-read: All 7 lesson files in docs/lessons-learned/
3. ✅ Verify: git status, git log -n 10, find recent files
4. ✅ Ask: "What's most critical to remember from before rollover?"
5. ✅ Proceed: With extra caution and verification

**Never:**

- ❌ Continue silently after rollover
- ❌ Assume summary captured everything
- ❌ Trust your memory of pre-rollover context
- ❌ Skip lessons-learned re-read

---

## Related Lessons

- [02-testing-conventions.md](02-testing-conventions.md) - May forget just-documented protocols
- [03-user-preferences.md](03-user-preferences.md) - Emotional emphasis lost
- [06-session-management.md](06-session-management.md) - Session log cross-verification MORE critical

## Related Documentation

- [CONTINUATION_PROMPT.md](/home/alan/projects/scrap-survivor/CONTINUATION_PROMPT.md) - Pre-flight checklist (read after rollover)

## Session References

- Session 2025-10-19 Part 4 - Discovery of rollover as root cause of failures
