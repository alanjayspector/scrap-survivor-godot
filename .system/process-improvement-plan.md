# Process Improvement Plan - Quality Gates & Checkpoints

**Date**: 2025-11-23
**Trigger**: Phase 6 QA failure revealed systematic process violations
**Root Cause**: Rushing without reading specs, manual edits without validation, bulk commits without incremental testing
**Goal**: Implement mandatory checkpoints that prevent process violations

---

## Executive Summary

**Problem**: Claude consistently rushes implementation, skips spec reading, and commits bulk changes without incremental validation. This causes 99% QA failure rate vs one-shot success when following evidence-based approach.

**Solution**: Add mandatory checkpoints and automatic warnings to CLAUDE_RULES.md that enforce disciplined process at critical decision points.

**Success Metric**: Return to one-shot QA success rate by forcing spec reading, incremental testing, and proper tooling.

---

## Analysis of Failure Patterns

### Primary Violations (from Phase 6 post-mortem)

1. **❌ Didn't read spec** (most critical)
   - week16-implementation-plan.md lines 2934-2975 showed correct pattern
   - Chose to skip reading and guess instead
   - Root cause cascades into all other failures

2. **❌ Manual .tscn editing without Godot editor**
   - Violated CLAUDE_RULES.md:101-234
   - Missed layout mode constraints
   - Created architectural violations

3. **❌ Bulk commits without incremental QA**
   - Committed 3 scenes at once
   - No device testing between scenes
   - Failures propagated to all scenes

4. **❌ Time pressure optimization**
   - User says "quality over speed" but Claude rushes anyway
   - Perceived time constraints trigger shortcuts
   - Evidence shows rushing creates 5x more work

5. **❌ Ignored own rules**
   - CLAUDE_RULES.md exists from previous failures
   - Lists exact violations Claude just committed
   - Rules documented but not internalized

---

## Proposed Solutions

### Solution 1: Pre-Implementation Spec Checkpoint (MANDATORY)

**Location**: Add to CLAUDE_RULES.md after line 45 (Evidence-Based Engineering Checklist)

**Content**:
```markdown
## Pre-Implementation Spec Checkpoint (MANDATORY)

**Before writing ANY code, Claude MUST:**

### Step 1: Read Specification
- [ ] Identify relevant spec section (file:lines)
- [ ] Read entire section (no skimming)
- [ ] Quote 2-3 key requirements from spec
- [ ] Identify pattern/example from spec

**Output to user:**
"📋 **SPEC CHECKPOINT**
Read: [file:lines]
Key requirements:
1. [quote from spec]
2. [quote from spec]
3. [quote from spec]

Pattern identified: [describe or diagram]

Does this match your understanding? (WAIT for 'yes')"

**If spec doesn't exist:** Document that fact, ask user for requirements.
**If Claude skips this step:** User should immediately stop and redirect.

### Step 2: Scope Checkpoint
- [ ] Breaking work into smallest testable increment?
- [ ] One scene/file at a time (not bulk)?
- [ ] QA validation after this piece?
- [ ] Commit this piece before next piece?

**If answer is "no" to any → TOO BIG, break it down further**

### Step 3: Method Checkpoint
- [ ] Using correct tools? (Godot editor for .tscn, NOT manual edit)
- [ ] Following established pattern from spec?
- [ ] Will run validators before commit?

**If ANY checkbox unchecked → STOP and discuss with user**
```

**Enforcement**: User will reject any implementation that doesn't show spec checkpoint output.

---

### Solution 2: Scene Modification Warning (AUTOMATIC)

**Location**: Add to CLAUDE_RULES.md Scene Creation Rules (after line 234)

**Content**:
```markdown
## Scene Modification Protocol (AUTOMATIC WARNING)

**BEFORE using Edit/Write tools on .tscn files, Claude MUST output:**

"⚠️ **SCENE MODIFICATION DETECTED**

About to modify: [filename]
Method: [Godot editor / Manual edit]

Checklist:
□ Read spec for this scene's hierarchy? [yes/no + cite spec section]
□ Using Godot editor (NOT manual edit)? [yes/no]
□ Applying to ONE scene only (incremental)? [yes/no]
□ Will test this scene before modifying next? [yes/no]

If ANY checkbox is unchecked, this violates scene modification protocol.

Proceed? (Requires user 'yes')"

**Manual .tscn editing is ONLY allowed for:**
- Minor text/property changes (1-2 lines)
- Following an explicit example from spec
- Emergency hotfixes (with user approval)

**All structural changes (adding/removing nodes, changing hierarchy) MUST use Godot editor.**
```

**Trigger**: Any use of Edit/Write on files matching `*.tscn`

---

### Solution 3: Multi-Scene Commit Warning (AUTOMATIC)

**Location**: Add to CLAUDE_RULES.md Git Commit section (after line 608)

**Content**:
```markdown
## Multi-Scene Commit Warning (AUTOMATIC)

**BEFORE committing changes to multiple scene files, Claude MUST output:**

"⚠️ **BULK COMMIT DETECTED**

About to commit changes to [N] scene files:
- [list scene files]

This violates incremental validation protocol.

**Risk**: If one scene has issues, ALL scenes are affected.
**Recommended**: Commit one scene at a time with device QA validation between.

**Incremental Process:**
1. Commit scene 1 → Device QA → Fix if needed
2. Commit scene 2 → Device QA → Fix if needed
3. Commit scene 3 → Device QA → Fix if needed

Proceed with bulk commit anyway? (Requires user 'yes' + justification)"

**Exceptions** (allowed bulk commits):
- Renaming operations across multiple files
- Global search/replace that's been tested
- User explicitly requests bulk commit
```

**Trigger**: git add includes >1 file matching `scenes/**/*.tscn`

---

### Solution 4: Phase Breakdown Strategy (PLANNING)

**Location**: Add to CLAUDE_RULES.md Session & Week Plan Management Protocol (after line 1106)

**Content**:
```markdown
## Phase Breakdown for One-Shot Success

**Problem**: Large phases (>1.5h) encourage rushing and bulk commits.
**Solution**: Break phases into sub-phases with QA gates.

### Phase Size Guidelines

**Optimal phase size**: 0.25-0.5 hours
- Small enough to one-shot
- Large enough to be meaningful
- Includes built-in QA gate

**Example - WRONG (too big):**
```
Phase 6: Safe Area Implementation (1.5h)
- Create component
- Apply to 3 scenes
- Test on device
```
**Result**: Rushed, bulk commit, 2/3 scenes broken

**Example - RIGHT (incremental):**
```
Phase 6.1: Create ScreenContainer component (0.5h)
→ Unit test component in isolation
→ QA Gate: Component works correctly

Phase 6.2: Apply to character_creation.tscn (0.25h)
→ Use Godot editor, follow spec pattern
→ QA Gate: Device test this scene (GO/NO-GO)

Phase 6.3: Apply to character_roster.tscn (0.25h)
→ Same pattern as 6.2
→ QA Gate: Device test this scene (GO/NO-GO)

Phase 6.4: Apply to scrapyard.tscn (0.25h)
→ Same pattern as 6.2
→ QA Gate: Device test this scene (GO/NO-GO)
```
**Result**: Each piece tested before next, failures caught early

### QA Gate Rules

**After each sub-phase:**
1. Commit the change
2. Deploy to device (if mobile feature)
3. Run QA checklist for this piece
4. **GO**: Continue to next sub-phase
5. **NO-GO**: Fix this piece before moving forward

**Benefits:**
- Failures isolated to single piece
- User can stop after first failure
- No bulk rollbacks needed
- Forces incremental validation (Claude's weakness)

### Planning Template

When creating week plans, use this template:

```markdown
## Phase [N]: [Feature Name]

**Total Estimated Time**: [X]h

**Breakdown:**
- Phase [N].1: [First increment] ([time]h)
  - QA Gate: [what to validate]
- Phase [N].2: [Second increment] ([time]h)
  - QA Gate: [what to validate]
- Phase [N].3: [Third increment] ([time]h)
  - QA Gate: [what to validate]

**Each sub-phase includes:**
- Spec reading checkpoint
- Implementation
- Local testing
- Commit
- Device QA (GO/NO-GO gate)
```
```

**Application**: Use this for all future week plans starting Week 17+

---

### Solution 5: Thinking Transparency (BEHAVIORAL)

**Location**: Add to CLAUDE_RULES.md Tone and Style section (after line 13)

**Content**:
```markdown
## Thinking Transparency at Decision Points

**At critical decision points, Claude MUST output thinking before acting:**

**Example - Scene Modification:**
```
I'm about to edit character_roster.tscn to add ScreenContainer.

Let me verify I understand the hierarchy from the spec first:
[reads spec, quotes pattern]

Spec shows: ScreenContainer → VBoxContainer → children
Current roster structure: [analyze current structure]

Plan: Use Godot editor to add VBoxContainer wrapper, then move existing children inside.

Proceeding with Godot editor (not manual edit).
```

**Example - Time Pressure Detection:**
```
I'm thinking "need to apply this to all 3 scenes quickly to hit the 1.5h estimate."

🚨 TIME PRESSURE DETECTED 🚨

This is the moment I usually rush and break things.

User priority: "Quality over speed"
Evidence: 99% QA failure when rushing vs one-shot when methodical

Corrective action: Break into 3 sub-phases, one scene at a time with QA gates.
```

**Benefits:**
- User sees decision points as they happen
- User can intervene before mistakes are made
- Builds trust through transparency
- Forces Claude to catch own bad habits
```

**Trigger**: Claude should proactively output thinking when:
- About to modify scene files
- About to commit multiple files
- Feeling time pressure
- About to skip a checklist step

---

### Solution 6: Time Pressure Awareness (BEHAVIORAL)

**Location**: Add to CLAUDE_RULES.md Enforcement Mechanism (after line 540)

**Content**:
```markdown
## Time Pressure Detection & Response

**Symptoms of harmful time pressure:**
- Thinking "need to do this quickly"
- Thinking "just do all X at once to save time"
- Skipping spec reading "because I already know"
- Manual editing "because Godot editor is slower"
- Bulk commits "to avoid multiple commit messages"

**When Claude detects these thoughts:**

1. **STOP immediately**
2. **Output the thought:**
   "🚨 TIME PRESSURE DETECTED: [describe the thought]"
3. **Review user priority:**
   User has stated: "I want to build a strong foundation and I'd rather take the time to do it right than to do it fast."
4. **Check the data:**
   - Evidence-based approach: One-shot success
   - Rushing approach: 99% QA failure rate
5. **Corrective action:**
   "Slowing down to follow proper process: [describe what will do instead]"

**Remember**: Rushing doesn't save time. It creates 5x more work through failed QA passes, debugging, and rework.

**User will always prefer:**
- 1 hour to do it right once
- Over 5 hours to do it wrong 3 times and fix it twice
```

**Application**: Claude should actively monitor for time pressure thoughts and self-correct.

---

## Implementation Checklist (For Process Improvement Chat)

This checklist is for the **dedicated process improvement chat session**:

```
Phase 1: Update CLAUDE_RULES.md

1. [ ] Add "Pre-Implementation Spec Checkpoint" section
   - [ ] Insert after line 45 (Evidence-Based Engineering Checklist)
   - [ ] Include all 3 checkpoints (Spec, Scope, Method)
   - [ ] Include output template for spec checkpoint

2. [ ] Add "Scene Modification Protocol" section
   - [ ] Insert after line 234 (Scene File Creation Rules)
   - [ ] Include automatic warning template
   - [ ] List exceptions for manual editing

3. [ ] Add "Multi-Scene Commit Warning" section
   - [ ] Insert after line 608 (Git commit section)
   - [ ] Include automatic warning template
   - [ ] List allowed exceptions

4. [ ] Add "Phase Breakdown for One-Shot Success" section
   - [ ] Insert after line 1106 (Session & Week Plan Management)
   - [ ] Include wrong vs right examples
   - [ ] Include QA gate rules
   - [ ] Include planning template

5. [ ] Add "Thinking Transparency at Decision Points" section
   - [ ] Insert after line 13 (Tone and Style)
   - [ ] Include example outputs
   - [ ] List trigger conditions

6. [ ] Add "Time Pressure Detection & Response" section
   - [ ] Insert after line 540 (Enforcement Mechanism)
   - [ ] Include symptoms list
   - [ ] Include response protocol

Phase 2: Create Example Week Plan with Sub-Phases

7. [ ] Create example showing Phase 6 breakdown
   - [ ] Show WRONG approach (single big phase)
   - [ ] Show RIGHT approach (4 sub-phases with QA gates)
   - [ ] Include in docs/examples/ folder

8. [ ] Document phase breakdown guidelines
   - [ ] Optimal size: 0.25-0.5h per sub-phase
   - [ ] Each sub-phase has QA gate
   - [ ] Template for future use

Phase 3: Test & Validate

9. [ ] Review updated CLAUDE_RULES.md for consistency
   - [ ] Check section numbering
   - [ ] Check cross-references
   - [ ] Check markdown formatting

10. [ ] Create test scenarios
    - [ ] "Claude is about to edit .tscn file" → Should trigger warning
    - [ ] "Claude is about to commit 3 scenes" → Should trigger warning
    - [ ] "Claude feels time pressure" → Should output detection

11. [ ] Commit changes
    - [ ] Stage CLAUDE_RULES.md
    - [ ] Commit message: "docs: add mandatory quality gates and checkpoints to prevent process violations"
    - [ ] Update NEXT_SESSION.md to reference new protocols

Phase 4: Document for Future Use

12. [ ] Add reference to process-improvement-plan.md in NEXT_SESSION.md
    - [ ] Link to this plan
    - [ ] Note completion status
    - [ ] Mark as "Process foundation for future phases"

13. [ ] Create quick reference card
    - [ ] One-page summary of all checkpoints
    - [ ] When each checkpoint triggers
    - [ ] What output is expected
    - [ ] Save as docs/CHECKPOINTS_QUICK_REFERENCE.md
```

---

## Success Criteria

**Process improvements are successful when:**

1. ✅ **Spec reading is mandatory** - Cannot proceed without showing spec checkpoint output
2. ✅ **Scene modifications warn automatically** - Every .tscn edit triggers protocol check
3. ✅ **Bulk commits warn automatically** - Multi-scene commits require justification
4. ✅ **Phases are broken down** - Future week plans use sub-phase pattern
5. ✅ **Thinking is transparent** - User can see decision points as they happen
6. ✅ **Time pressure is detected** - Claude catches and corrects rushing behavior

**Validation:**
- Next Phase 6 fix session follows new protocols
- Future phases use sub-phase breakdown
- QA failure rate returns to near-zero (one-shot success)

---

## Context for Process Improvement Chat

**What happened:**
- Phase 6 failed QA with critical architectural violations
- Root cause: Skipped reading spec, manual .tscn edits, bulk commits
- Expert audit identified 7 issues (5 CRITICAL)
- Analysis showed 99% QA failure when rushing vs one-shot when methodical

**What this plan solves:**
- Adds mandatory checkpoints before code changes
- Forces spec reading (cannot skip)
- Warns on risky operations (scene edits, bulk commits)
- Breaks large phases into testable increments
- Makes thinking visible so user can intervene

**Why separate chat:**
- Process improvement is meta-work (improving how we work)
- Feature work should use the new protocols (not develop them)
- Clean separation keeps focus clear

---

## Quick Start Prompt (For Process Improvement Chat)

```
Process improvement session - implement mandatory quality gates.

CONTEXT:
1. Read .system/process-improvement-plan.md (this file)
2. Review Phase 6 failure analysis in .system/NEXT_SESSION.md
3. Understand: Rushing causes 99% QA failure, need forcing functions

TASKS:
1. Follow Implementation Checklist above (Phases 1-4)
2. Update .system/CLAUDE_RULES.md with all 6 new sections
3. Create example week plan showing sub-phase breakdown
4. Create quick reference card for checkpoints
5. Commit changes
6. Report completion

GOAL: Next Claude session has enforceable protocols that prevent rushing.

Estimated time: 1-2 hours
```

---

**Last Updated**: 2025-11-23
**Status**: Plan ready for dedicated process improvement chat
**Next Action**: User creates new chat, provides this plan as context
**Expected Outcome**: Updated CLAUDE_RULES.md with mandatory quality gates
