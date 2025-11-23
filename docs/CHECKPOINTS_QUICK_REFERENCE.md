# Quality Checkpoints Quick Reference

**Purpose**: One-page summary of all mandatory checkpoints that prevent process violations.

**When to use**: Reference this before starting any implementation work.

---

## 🚦 Pre-Implementation Spec Checkpoint (MANDATORY)

**Trigger**: Before writing ANY code

**Required Output**:
```
📋 **SPEC CHECKPOINT**
Read: [file:lines]
Key requirements:
1. [quote from spec]
2. [quote from spec]
3. [quote from spec]

Pattern identified: [describe or diagram]

Does this match your understanding? (WAIT for 'yes')
```

**Three Checkpoints**:

### 1. Spec Checkpoint
- [ ] Identified relevant spec section (file:lines)
- [ ] Read entire section (no skimming)
- [ ] Quoted 2-3 key requirements
- [ ] Identified pattern/example

### 2. Scope Checkpoint
- [ ] Breaking work into smallest testable increment?
- [ ] One scene/file at a time (not bulk)?
- [ ] QA validation after this piece?
- [ ] Commit this piece before next piece?

### 3. Method Checkpoint
- [ ] Using correct tools? (Godot editor for .tscn)
- [ ] Following established pattern from spec?
- [ ] Will run validators before commit?

**Result**: If ANY checkbox unchecked → STOP and discuss with user

---

## ⚠️ Scene Modification Warning (AUTOMATIC)

**Trigger**: Before using Edit/Write on `.tscn` files

**Required Output**:
```
⚠️ **SCENE MODIFICATION DETECTED**

About to modify: [filename]
Method: [Godot editor / Manual edit]

Checklist:
□ Read spec for this scene's hierarchy? [yes/no + cite spec section]
□ Using Godot editor (NOT manual edit)? [yes/no]
□ Applying to ONE scene only (incremental)? [yes/no]
□ Will test this scene before modifying next? [yes/no]

If ANY checkbox is unchecked, this violates scene modification protocol.

Proceed? (Requires user 'yes')
```

**Manual .tscn editing ONLY allowed for**:
- Minor text/property changes (1-2 lines)
- Following an explicit example from spec
- Emergency hotfixes (with user approval)

**All structural changes MUST use Godot editor**

---

## 🚨 Multi-Scene Commit Warning (AUTOMATIC)

**Trigger**: Before committing changes to >1 scene file

**Required Output**:
```
⚠️ **BULK COMMIT DETECTED**

About to commit changes to [N] scene files:
- [list scene files]

This violates incremental validation protocol.

**Risk**: If one scene has issues, ALL scenes are affected.
**Recommended**: Commit one scene at a time with device QA validation between.

**Incremental Process:**
1. Commit scene 1 → Device QA → Fix if needed
2. Commit scene 2 → Device QA → Fix if needed
3. Commit scene 3 → Device QA → Fix if needed

Proceed with bulk commit anyway? (Requires user 'yes' + justification)
```

**Exceptions** (allowed):
- Renaming operations across multiple files
- Global search/replace that's been tested
- User explicitly requests bulk commit

---

## 💭 Thinking Transparency at Decision Points

**Trigger**: When making critical decisions

**Example - Scene Modification**:
```
I'm about to edit character_roster.tscn to add ScreenContainer.

Let me verify I understand the hierarchy from the spec first:
[reads spec, quotes pattern]

Spec shows: ScreenContainer → VBoxContainer → children
Current roster structure: [analyze current structure]

Plan: Use Godot editor to add VBoxContainer wrapper, then move existing children inside.

Proceeding with Godot editor (not manual edit).
```

**When to output thinking**:
- About to modify scene files
- About to commit multiple files
- Feeling time pressure
- About to skip a checklist step

---

## 🚨 Time Pressure Detection (AUTOMATIC)

**Symptoms** (watch for these thoughts):
- "Need to do this quickly"
- "Just do all X at once to save time"
- "I already know, skip spec reading"
- "Manual editing is faster"
- "Avoid multiple commit messages"

**When detected, output**:
```
🚨 TIME PRESSURE DETECTED: [describe the thought]

User priority: "Quality over speed"
Evidence: 99% QA failure when rushing vs one-shot when methodical

Corrective action: [describe proper process instead]
```

**Remember**:
- Rushing doesn't save time (creates 5x rework)
- User prefers: 1h to do it right once
- Over: 5h to do it wrong 3 times and fix twice

---

## 📊 Phase Breakdown Guidelines

**Problem**: Phases >1.5h encourage rushing and bulk commits

**Solution**: Break into sub-phases with QA gates

### Optimal Phase Size: 0.25-0.5 hours

**Example - WRONG**:
```
Phase 6: Safe Area Implementation (1.5h)
- Create component
- Apply to 3 scenes
- Test on device
```
Result: Rushed, bulk commit, failures

**Example - RIGHT**:
```
Phase 6.1: Create component (0.5h) → QA Gate
Phase 6.2: Apply to scene 1 (0.25h) → QA Gate: GO/NO-GO
Phase 6.3: Apply to scene 2 (0.25h) → QA Gate: GO/NO-GO
Phase 6.4: Apply to scene 3 (0.25h) → QA Gate: GO/NO-GO
```
Result: Incremental, isolated failures, one-shot success

### QA Gate Process
1. Commit the change
2. Deploy to device (if mobile)
3. Run QA checklist
4. **GO**: Continue to next sub-phase
5. **NO-GO**: Fix before proceeding

---

## 📋 Quick Checklist Card

Print this and keep visible:

```
BEFORE WRITING CODE:
□ Spec checkpoint (read, quote, pattern)
□ Scope checkpoint (incremental, QA gate)
□ Method checkpoint (tools, pattern, validators)

BEFORE .tscn EDIT:
□ Read spec for hierarchy
□ Using Godot editor (NOT manual)
□ ONE scene only
□ Test before next

BEFORE BULK COMMIT:
□ Do I REALLY need bulk commit?
□ Can I do one at a time with QA gates?
□ User approved bulk commit?

WHEN FEELING RUSHED:
□ STOP and output time pressure detection
□ Remember: rushing = 5x rework
□ Break into smaller sub-phases
□ Quality over speed

PLANNING PHASES:
□ Each sub-phase 0.25-0.5h
□ QA gate after each sub-phase
□ GO/NO-GO decision before next
□ Spec checkpoint before implementation
```

---

## 🎯 Success Criteria

**Process improvements working when**:
1. ✅ Cannot proceed without spec checkpoint output
2. ✅ Every .tscn edit triggers automatic warning
3. ✅ Bulk commits require justification
4. ✅ Thinking is visible at decision points
5. ✅ Time pressure is detected and corrected
6. ✅ Phases broken into testable increments

**Result**: QA failure rate returns to near-zero (one-shot success)

---

**Version**: 1.0
**Effective**: 2025-11-23
**Source**: `.system/CLAUDE_RULES.md` process quality gates
**See Also**:
- `.system/CLAUDE_RULES.md` (full protocol details)
- `docs/examples/phase-breakdown-example.md` (Phase 6 case study)
- `.system/process-improvement-plan.md` (original analysis)

**Quick Links**:
- [Pre-Implementation Spec Checkpoint](.system/CLAUDE_RULES.md#pre-implementation-spec-checkpoint-mandatory)
- [Scene Modification Protocol](.system/CLAUDE_RULES.md#scene-modification-protocol-automatic-warning)
- [Multi-Scene Commit Warning](.system/CLAUDE_RULES.md#multi-scene-commit-warning-automatic)
- [Thinking Transparency](.system/CLAUDE_RULES.md#thinking-transparency-at-decision-points)
- [Time Pressure Detection](.system/CLAUDE_RULES.md#time-pressure-detection--response)
- [Phase Breakdown Strategy](.system/CLAUDE_RULES.md#phase-breakdown-for-one-shot-success)
