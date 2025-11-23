# Claude Code Rules & Blocking Protocol

**Version**: 1.0
**Effective**: 2025-01-10
**Enforcement**: MANDATORY - Violations stop work immediately

## BLOCKING PROTOCOL (Active)

### High-Risk Actions Requiring User Approval

Before executing these actions, I MUST:
1. Announce: "**APPROVAL REQUIRED**: [action description]"
2. Show completed evidence checklist
3. Show exact command to be executed
4. **WAIT for user "yes" before proceeding**

**High-Risk Actions:**
- ✓ Any `git commit` (even if validation passes)
- ✓ Any `git push`
- ✓ Modifying validator files in `.system/validators/`
- ✓ Changing quality gate expectations or test assertions
- ✓ Using flags: `--no-verify`, `--force`, `--amend`, `--skip-ci`
- ✓ Modifying pre-commit hooks or validation configuration

## NEVER Rules (Zero Tolerance)

**NEVER do these under any circumstances:**

1. ❌ **NEVER use `--no-verify`** on git commits
2. ❌ **NEVER bypass quality gates** (validators, linters, formatters, tests)
3. ❌ **NEVER modify validators without evidence** (docs, line numbers, examples)
4. ❌ **NEVER assume validation is wrong** - investigate first, prove with evidence
5. ❌ **NEVER take shortcuts when frustrated** - stop and investigate systematically

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

**Trigger**: Claude should proactively output thinking when:
- About to modify scene files
- About to commit multiple files
- Feeling time pressure
- About to skip a checklist step

## Evidence-Based Engineering Checklist

Before modifying validators or bypassing any gate:

```
□ Have I read the validation code? [file:line reference]
□ Have I found 3+ correct examples? [list examples]
□ Can I cite documentation/SDK proving correctness? [citations]
□ Have I asked user if unclear? [yes/no]
```

**If ANY checkbox is unchecked → STOP and ask user**

## Pre-Implementation Spec Checkpoint (MANDATORY)

**Before writing ANY code, Claude MUST:**

### Step 1: Read Specification
- [ ] Identify relevant spec section (file:lines)
- [ ] Read entire section (no skimming)
- [ ] Quote 2-3 key requirements from spec
- [ ] Identify pattern/example from spec

**Output to user:**
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

## Commit Message Format

**Validation**: `.git/hooks/commit-msg:7`

**Valid format**: `<type>: <description 1-100 chars>`

**Valid types**:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style (formatting, no logic change)
- `refactor` - Code restructuring (no behavior change)
- `perf` - Performance improvement
- `test` - Test additions/changes
- `chore` - Build, tooling, dependencies
- `build` - Build system changes
- `ci` - CI/CD changes
- `revert` - Revert previous commit

**Optional scope**: `<type>(scope): <description>`

**Examples:**
- ✅ `feat: add enemy spawning`
- ✅ `fix: correct drop_system zero-amount bug`
- ✅ `docs: update migration timeline`
- ❌ `debug: add logging` (invalid type)
- ❌ `feat:add enemy` (missing space)
- ❌ `add enemy spawning` (missing type)

**Multi-line commits allowed after first line**

## Investigation Protocol (Before Attempting Fixes)

### When validation fails:

**After 2 failed attempts → STOP and investigate:**

1. Read validation configuration:
   - Commits: `.git/hooks/commit-msg`
   - Linting: `.gdlintrc`
   - Formatting: `.editorconfig`
   - Tests: Look at failing test file
   - Validators: Read the `.system/validators/[name].py` file

2. Find correct examples:
   - Commits: `git log --oneline -10`
   - Code: Search codebase for working examples
   - Validators: Read referenced documentation

3. Match pattern exactly before retrying

4. If still unclear → **ASK USER**

## Component Integration & Scene Validation Protocol

**CRITICAL**: Scene files and component integration require special validation.

### Scene File Creation Rules

**NEVER manually edit .tscn files without validation.**

1. ✅ **ALWAYS create scenes via Godot editor** (File → New Scene)
2. ❌ **NEVER hand-edit .tscn files** without opening in editor after
3. ✅ **IF manual edit required** → Open in Godot editor immediately to validate

### Scene File Validation Checklist

Before committing any .tscn file:
```
□ Scene opens in Godot editor without errors
□ All child nodes have parent="..." specification (check .tscn file)
□ Scene instantiates successfully (automated validator checks this)
□ Scene hierarchy displays correctly in editor
□ No orphan nodes (all children specify parent)
```

**If scene won't load**: Check that all child nodes specify `parent="..."` attribute

**Example - Correct scene structure**:
```
[node name="Root" type="PanelContainer"]

[node name="Child" type="HBoxContainer" parent="."]

[node name="GrandChild" type="Label" parent="Child"]
```

**Example - WRONG (missing parent)**:
```
[node name="Root" type="PanelContainer"]

[node name="Child" type="HBoxContainer"]  # ❌ Missing parent="."
```

### Component Integration Protocol

**Creating a component ≠ Using a component**

When refactoring to use reusable components:

**Integration Checklist**:
```
□ Component scene created via Godot editor
□ Component script implemented
□ Component preloaded in parent script (const SCENE = preload(...))
□ Parent code instantiates component (SCENE.instantiate())
□ Parent code calls component.setup() or initialization
□ Parent code connects component signals
□ Integration tested (instantiation succeeds, no null errors)
□ Manual QA validation on device
□ Old manual UI code REMOVED (if refactor)
```

### Before Marking Work "COMPLETE"

- ❌ **NOT ENOUGH**: Component files exist
- ❌ **NOT ENOUGH**: Tests pass
- ✅ **REQUIRED**: Component actually used in parent code
- ✅ **REQUIRED**: Integration manually validated on device
- ✅ **REQUIRED**: Old code removed (if claiming refactor)

### Red Flags

- 🚩 Component scene exists but no `preload()` references in codebase
- 🚩 Parent still has old manual UI generation code
- 🚩 "80 lines → 14 lines" refactor claim but file still has 80 lines
- 🚩 Plan says "refactored to use Component" but Grep shows no references

### Verification Commands

**Before claiming "refactored to use component":**

```bash
# Check component is actually used
grep "COMPONENT_SCENE" scripts/path/to/parent.gd
# Should show: preload() and instantiate() calls

# Check old code is removed
wc -l scripts/path/to/parent.gd
# Line count should match "after" claim, not "before"

# Check function was actually refactored
grep -A 20 "func _create_item" scripts/path/to/parent.gd
# Function should be ≤20 lines if using component
```

**If old manual UI code still present** → Refactor NOT complete

### Scene Instantiation Testing

**When creating PackedScene components**, verify instantiation:

```gdscript
# Test that scene loads
const SCENE = preload("res://path/to/component.tscn")

func test_instantiation():
    var instance = SCENE.instantiate()
    assert(instance != null, "Scene instantiation failed - check parent nodes")
    assert(instance.has_method("setup"), "Component missing setup method")
```

**If instantiate() returns null** → Scene file corrupted, check parent specifications

### Automated Validators

The following validators enforce these rules:

- **scene_structure_validator.py** - Validates .tscn parent specifications (BLOCKING)
- **scene_instantiation_validator.py** - Tests scenes can instantiate (BLOCKING)
- **component_usage_validator.py** - Verifies components are used (BLOCKING if preloaded but unused)
- **refactor_verification_validator.py** - Validates refactor claims (BLOCKING on refactor commits)

**These run automatically in pre-commit hooks.**

### Scene Modification Protocol (AUTOMATIC WARNING)

**BEFORE using Edit/Write tools on .tscn files, Claude MUST output:**

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

**Manual .tscn editing is ONLY allowed for:**
- Minor text/property changes (1-2 lines)
- Following an explicit example from spec
- Emergency hotfixes (with user approval)

**All structural changes (adding/removing nodes, changing hierarchy) MUST use Godot editor.**

---

## Files to Read Before Certain Actions

| Action | Required Reading |
|--------|-----------------|
| Git commit | `.git/hooks/commit-msg` |
| Modifying validator | The validator file + docs it references |
| Fixing test failure | The test file + implementation file |
| Changing quality gate | Configuration files + ask user |
| Creating .tscn scene | ALWAYS use Godot editor (not manual) |
| Refactoring to components | Component Integration Protocol above |

## Running Tests and Validators

**IMPORTANT**: NEVER try to find `godot` command in PATH. Always use the validator scripts.

### Test Runner

**Run automated tests:**
```bash
python3 .system/validators/godot_test_runner.py
```

This script:
- Handles Godot executable location automatically
- Runs all 520 GUT tests in headless mode
- Creates class cache for custom classes
- Outputs JUnit XML results to `test_results.xml`

### Available Validators

All validators are in `.system/validators/` directory:

**Python Validators:**
- `godot_test_runner.py` - Run automated tests (520 tests)
- `test_method_validator.py` - Validate test method calls against service APIs
- `test_naming_validator.py` - Check test naming conventions
- `test_patterns_validator.py` - Check for test quality issues (non-blocking)
- `test_quality_validator.py` - Check assertion quality (non-blocking)
- `integration_test_checker.py` - Verify integration tests exist
- `godot_antipatterns_validator.py` - Check for Godot anti-patterns (non-blocking)
- `godot_performance_validator.py` - Check for performance issues (non-blocking)
- `godot_config_validator.py` - Validate Godot project configuration
- `scene_node_path_validator.py` - Validate scene node paths
- `data_model_consistency_validator.py` - Check data model usage (non-blocking)
- `service_architecture_validator.py` - Validate service architecture
- Other validators: `native_class_checker.py`, `resource_validator.py`, etc.

**Shell Script Validators:**
- `check-imports.sh` - Validate asset import settings (non-blocking)
- `check-patterns.sh` - Validate GDScript patterns (non-blocking)
- `check-audio-assets.sh` - Check audio asset configuration

**Non-Blocking vs Blocking:**
- **Blocking**: Tests, test method validator, config validator - MUST pass for commit
- **Non-blocking**: Test patterns, antipatterns, performance - warnings only, good to fix but won't block commit

## Mobile-Native Development Standards

**Effective**: 2025-11-22 (Week 16 learnings)

### Definition of "Mobile-Native"

**Mobile-native DOES NOT mean:**
- ❌ Gaming UI patterns (two-tap confirmations, button state machines)
- ❌ Hybrid workarounds (desktop + mobile mixed)
- ❌ "Works on mobile" (just responsive to screen size)

**Mobile-native MEANS:**
- ✅ **iOS HIG compliance** - Follow Apple Human Interface Guidelines exactly
- ✅ **Platform patterns** - Use ModalFactory.show_confirmation(), not button states
- ✅ **Native controls** - Use ALERT, SHEET, FULLSCREEN modals
- ✅ **Cite guidelines** - Reference specific HIG sections when claiming compliance

### Before Claiming "iOS HIG Compliant"

**Evidence Checklist:**
```
□ Can cite specific iOS HIG guideline(s)? [URL or section]
□ Uses platform-native patterns? (modals, not button state machines)
□ Tested on actual iOS device? (not just simulator/desktop)
□ Uses ModalFactory or approved mobile components?
```

**If ANY checkbox unchecked → NOT iOS HIG compliant**

### Mobile Pattern Examples

**✅ CORRECT - iOS HIG Pattern:**
```gdscript
# Destructive confirmation using native modal
ModalFactory.show_destructive_confirmation(
    self,
    "Delete Character?",
    "This cannot be undone.",
    func(): _delete_character()
)
```

**❌ INCORRECT - Gaming UI Hack:**
```gdscript
# Two-tap button state machine (NOT iOS HIG)
if delete_state == 0:
    button.text = "Tap Again to Confirm"
    delete_state = 1
elif delete_state == 1:
    _delete_character()
```

### Mobile-First Validation

Before marking mobile work "COMPLETE":
```
□ Follows iOS HIG (not gaming UI patterns)
□ Uses approved mobile components (MobileModal, ModalFactory)
□ Tested on physical iOS device
□ No desktop patterns mixed in
□ Can defend every UI choice with HIG citation
```

---

## Scene Layout Compatibility Rules

**Effective**: 2025-11-22 (After iOS layout mode crash)

### The Problem

iOS strictly validates layout constraints. Incompatible layout modes crash with SIGKILL (no error message).

**Common Conflict:**
- Node with `anchors_preset` (standalone positioning)
- Added to `VBoxContainer` or `HBoxContainer` (container layout)
- **Result**: iOS detects unsolvable constraint → SIGKILL

### Before Modifying .tscn Files

**Layout Compatibility Checklist:**
```
□ Is this node going into a container (VBox/HBox)?
□ Does it have anchors_preset set?
□ Does it have layout_mode = 2 and size_flags?
□ Will it work in BOTH contexts (standalone AND container)?
```

### Container-Compatible Node Requirements

**If adding Control node to VBoxContainer/HBoxContainer:**

**MUST have:**
- `layout_mode = 2` (container layout mode)
- `size_flags_horizontal` and/or `size_flags_vertical`
- Optional: `custom_minimum_size`

**MUST NOT have:**
- `anchors_preset` (incompatible with containers)
- `anchor_left`, `anchor_right`, `anchor_top`, `anchor_bottom`
- `grow_horizontal`, `grow_vertical` (unless using anchors)

### Validation Before Commit

**After modifying any .tscn file:**

1. **Read the scene file** - Check layout_mode and anchors
2. **Test instantiation** - Run scene_instantiation_validator.py
3. **Test on iOS device** - Desktop may not show the issue
4. **Check parent context** - Where is this scene being used?

### Red Flags

- 🚩 Scene has `anchors_preset = 8` (CENTER) but is used in VBoxContainer
- 🚩 Scene works on desktop but crashes on iOS (layout conflict)
- 🚩 Modified .tscn without testing in actual usage context
- 🚩 "It instantiates fine" but haven't tested where it's actually used

---

## Definition of "Complete"

**Effective**: 2025-11-22 (After premature completion claims)

### What "Complete" Actually Means

**Code Complete ≠ Work Complete**

**NOT ENOUGH to mark work "COMPLETE":**
- ❌ Code written and committed
- ❌ Automated tests pass (647/671 passing)
- ❌ Validators pass
- ❌ "It works on desktop"
- ❌ Documentation written

**REQUIRED to mark work "COMPLETE":**
- ✅ Code written and committed
- ✅ Automated tests pass
- ✅ Validators pass
- ✅ **Manual QA pass on target device** (iPhone for mobile work)
- ✅ **All acceptance criteria met** (not just coded)
- ✅ **No known bugs** in the feature
- ✅ **Integration tested** (not just unit tested)

### Phase Completion Checklist

Before marking Phase X "COMPLETE":
```
□ All objectives coded and committed?
□ All automated tests passing?
□ Manual QA pass on device (not simulator)?
□ Success criteria from plan ALL met?
□ No known bugs or workarounds?
□ User approved the work?
□ Documentation updated?
```

**If ANY checkbox unchecked → Phase NOT complete**

### Honest Status Reporting

**Use these statuses accurately:**
- ✅ **COMPLETE** - All criteria met, QA passed on device, zero known issues
- 🔨 **CODE COMPLETE** - Coded but not QA tested yet
- 🧪 **IN QA** - Coded, in testing, may have bugs
- 🐛 **BROKEN** - Coded but has critical bugs
- ⏭️ **PENDING** - Not started yet

**NEVER report "COMPLETE" before device QA**

---

## QA & Investigation Protocol

**Effective**: 2025-11-22 (After 5 QA passes doing trial-and-error)

### When QA Fails: Investigation Tiers

**Tier 1: Quick Fix (1 attempt)**
- Obvious typo, syntax error, missing file
- Fix immediately, retest

**Tier 2: Stop and Investigate (After 1 failed QA pass)**
- Read diagnostic logs
- Check recent changes
- Review code for obvious issues
- **If unclear → Tier 3**

**Tier 3: Systematic Investigation (Spawn Expert Agent)**
- Use Task tool with subagent_type="general-purpose"
- Evidence-based investigation
- Root cause analysis
- Technical debt identification

### NEVER Do This

❌ **Trial-and-error for 3+ QA passes**
- Wastes user's time (rebuild, redeploy, retest)
- Misses root cause
- Creates technical debt

✅ **Instead: Spawn investigation agent after Pass 1 failure**
- Systematic analysis
- Evidence-based fixes
- One proper fix vs. five guesses

### Investigation Agent Trigger

**Spawn investigation agent if:**
- QA pass 1 fails with unclear root cause
- Error message doesn't make sense
- "It should work but doesn't"
- No error logs or crash with no message
- iOS-specific issue (works on desktop, fails on device)

**Agent Prompt Template:**
```
You are investigating [ISSUE].

Evidence:
- QA log: [path]
- Error: [description or "no error, just killed"]
- Platform: iOS/Desktop
- Recent changes: [commits]

Tasks:
1. Read relevant code files
2. Identify root cause with file:line evidence
3. Explain why it fails (technical reason)
4. Provide correct fix (not workaround)
5. Identify why this wasn't caught earlier

Return: Root cause analysis + correct fix + prevention recommendations
```

### Investigation > Guessing

**After 1 QA failure:**
- ✅ Read logs systematically
- ✅ Spawn expert investigation agent
- ✅ Find root cause with evidence
- ✅ Apply correct fix once

**Don't do:**
- ❌ "Let me try adding this log..."
- ❌ "Maybe it's this, let me change it..."
- ❌ "Let's rebuild and see if it works now..."
- ❌ 5 QA passes doing trial-and-error

---

## Enforcement Mechanism

**User's role**: Call me out when I violate these rules

**My commitment**:
1. Follow blocking protocol for high-risk actions
2. Show evidence checklist when investigating
3. Stop after 2 failed attempts and investigate
4. Never bypass gates or use `--no-verify`

**If I violate**: User stops me, I acknowledge, we review what went wrong

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

## Evidence-Based Engineering Examples

### ✅ CORRECT: Modifying test validator
```
"Test method validator blocking .new() calls. Before modifying:
□ Read .system/validators/test_method_validator.py ✓
□ Found docs/godot-reference.md:365 showing Sprite2D.new() ✓
□ Found docs/godot-testing-research.md with 30+ .new() examples ✓
□ Verified WaveManager is NOT autoload in project.godot ✓
□ Can cite evidence: Regular classes use .new(), autoloads don't ✓

Evidence complete. Modifying validator with documented reasoning."
```

### ❌ INCORRECT: Bypassing gates
```
"Commit failed 3 times with format errors.
Using --no-verify to bypass and move forward."
← VIOLATION: Should have read .git/hooks/commit-msg instead
```

## Multi-Scene Commit Warning (AUTOMATIC)

**BEFORE committing changes to multiple scene files, Claude MUST output:**

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

**Exceptions** (allowed bulk commits):
- Renaming operations across multiple files
- Global search/replace that's been tested
- User explicitly requests bulk commit

---

## Session Continuity Protocol

**Purpose**: Maintain context across sessions for multi-phase projects

### At Session Start (AUTOMATIC)

**I MUST do this at the beginning of EVERY session:**

1. **Check for `.system/NEXT_SESSION.md`**
   - If file exists → Read it IMMEDIATELY (before user's first request)
   - If file doesn't exist → Proceed normally

2. **Acknowledge current state** (if file exists):
   - "I see we're currently working on [PHASE] - [STATUS]"
   - "Phase [X] is complete, Phase [Y] is in progress"
   - Show awareness of what was accomplished in previous session

3. **Use Quick Start Prompt** (if user says "continue"):
   - Use the prompt from `.system/NEXT_SESSION.md`
   - Load all referenced files
   - Present plan for current phase

### At Session End (AUTOMATIC)

**When wrapping up a session, I MUST:**

1. **Update `.system/NEXT_SESSION.md`** with:
   - Current date/time
   - Current phase and status (complete/in progress)
   - What we accomplished this session
   - Next phase objectives
   - Ready-to-paste Quick Start Prompt for next session
   - Any important decisions made
   - Current test status
   - Current git status (branch, last commit)

2. **Ask for approval to commit** (per Blocking Protocol):
   - "**APPROVAL REQUIRED**: Commit session handoff update"
   - Show what changed in `.system/NEXT_SESSION.md`
   - Wait for user "yes"

3. **Commit the update**:
   ```
   git add .system/NEXT_SESSION.md
   git commit -m "docs: update session handoff for [PHASE]"
   ```

### Session Continuity Triggers

**User says any of these → I read NEXT_SESSION.md automatically:**
- "continue"
- "continue from last session"
- "where did we leave off?"
- "what's next?"
- "resume"

**User starts with a new task → I don't use NEXT_SESSION.md:**
- User provides specific instructions unrelated to NEXT_SESSION.md content
- User explicitly says "ignore NEXT_SESSION.md"

### Staleness Check

**If `.system/NEXT_SESSION.md` is more than 7 days old:**
- Alert user: "⚠️ NEXT_SESSION.md is X days old - is this still current?"
- Wait for confirmation before using it

### Branch Mismatch Detection

**If current git branch ≠ branch in NEXT_SESSION.md:**
- Alert user: "⚠️ Branch mismatch: Currently on [BRANCH], NEXT_SESSION.md says [OTHER_BRANCH]"
- Ask which is correct

---

## Godot 4 Dynamic UI Development (CRITICAL)

**Effective**: 2025-11-22 (After Week 16 iOS SIGKILL crash investigation)

### The Parent-First Protocol

**MANDATORY for ALL dynamic Control node creation in Godot 4.x**

```gdscript
# ✅ CORRECT - Parent-First Protocol (ALWAYS use this)
var node = VBoxContainer.new()
parent_container.add_child(node)  # 1. Parent FIRST
node.layout_mode = 2  # 2. Explicit Mode 2 (Container mode) for iOS safety
node.add_theme_constant_override("separation", 16)  # 3. Configure AFTER

# ❌ WRONG - Configure-Then-Parent (Godot 3.x pattern - DO NOT USE)
var node = VBoxContainer.new()
node.add_theme_constant_override("separation", 16)  # ❌ Configure first
parent_container.add_child(node)  # ❌ Parent last → iOS SIGKILL
```

**Note**: Use `layout_mode = 2` (integer value). The enum constants (LAYOUT_MODE_CONTAINER, etc.) are not exposed in Godot 4.5.1's public GDScript API.

### Why This Matters

**Godot 4 Architecture Change:**
- Control nodes have internal `layout_mode` property (values: 0, 1, 2)
- `.new()` defaults to Mode 1 (Anchors)
- Containers expect Mode 2 (Container-controlled layout)
- **Configure-then-parent creates Mode 1 → Mode 2 conflict**

**iOS Consequence:**
- Container sorts layout → Child rejects (anchors) → Container re-sorts → **Infinite loop**
- Main thread locked → iOS Watchdog timeout (5-10s) → **SIGKILL (0x8badf00d)**
- **No error message** - app just disappears
- Desktop more tolerant (masks the problem)

### The Rules

**NEVER:**
1. ❌ Configure ANY properties before `add_child()`
2. ❌ Set `name`, `text`, `size_flags`, etc. before parenting
3. ❌ Use `set_anchors_preset()` on Container children
4. ❌ Assume desktop behavior = iOS behavior

**ALWAYS:**
1. ✅ Parent immediately after `.new()`
2. ✅ Set `layout_mode = 2` for Container children
3. ✅ Configure ALL properties AFTER parenting
4. ✅ Test on actual iOS device (simulator may not crash)

### Code Review Checklist

Before approving ANY code with dynamic UI:
```
□ All `.new()` calls followed immediately by `add_child()`
□ All Container children have `layout_mode = 2`
□ Zero lines of configuration between `.new()` and `add_child()`
□ No `set_anchors_preset()` calls on Container children
```

### Common Violations

**Labels, Buttons, Controls:**
```gdscript
# ❌ WRONG
var label = Label.new()
label.text = "Hello"  # ❌ Configure first
hbox.add_child(label)

# ✅ CORRECT
var label = Label.new()
hbox.add_child(label)  # Parent FIRST
label.layout_mode = 2
label.text = "Hello"  # Configure AFTER
```

**Containers (VBox, HBox, etc.):**
```gdscript
# ❌ WRONG
var section = VBoxContainer.new()
section.name = "Section"  # ❌ Even innocent properties are wrong
parent.add_child(section)

# ✅ CORRECT
var section = VBoxContainer.new()
parent.add_child(section)  # Parent FIRST
section.layout_mode = 2
section.name = "Section"  # Configure AFTER
```

### If This Is Violated

**Symptoms:**
- iOS app crashes with SIGKILL (no error)
- App freezes when opening modals/dialogs
- Desktop works fine, iOS fails
- Device logs show 0x8badf00d

**Response:**
1. Read `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md`
2. Read `docs/godot-ios-sigkill-research.md`
3. Fix ALL dynamic node creation (not just the crash site)
4. Test on iOS device before claiming fix

### Documentation

**Primary Reference:**
- `docs/lessons-learned/44-godot4-parent-first-ui-protocol.md` (examples, detection, prevention)

**Research:**
- `docs/godot-ios-sigkill-research.md` (forensic analysis, Watchdog mechanism, infinite loop details)

**Related:**
- Godot Issue #104598 (scene editor fix in 4.5, but `.new()` still defaults to Mode 1)

---

## Modal & Dialog Layout Protocol (CRITICAL)

**Effective**: 2025-11-23 (After Character Details 21 QA passes)

### The Order-of-Operations Rule

**CRITICAL**: When positioning modals/dialogs dynamically, SIZE MUST be set FIRST, then position calculations.

```gdscript
# ❌ WRONG - Position calculated before size set
modal_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)  # Offsets calculated with size = 0
modal_container.size = Vector2(target_width, 300)  # Size set AFTER → wrong centering

# ✅ CORRECT - Size first, then position
modal_container.size = Vector2(target_width, 300)  # 1. Set size FIRST

# 2. Set anchors manually
modal_container.anchor_left = 0.5
modal_container.anchor_top = 0.5
modal_container.anchor_right = 0.5
modal_container.anchor_bottom = 0.5

# 3. Calculate offsets based on ACTUAL size
var half_width = target_width / 2.0
var half_height = 300.0 / 2.0
modal_container.offset_left = -half_width
modal_container.offset_top = -half_height
modal_container.offset_right = half_width
modal_container.offset_bottom = half_height
```

### Why This Matters

**Problem**: Godot's `set_anchors_and_offsets_preset()` calculates offsets based on the control's CURRENT size.
- If size = 0 when preset is called → offsets = 0
- Control appears with upper-left at anchor point (not centered)
- Changing size later doesn't update offsets automatically

**Solution**: Manual calculation with correct order:
1. **Set size** (gives actual dimensions)
2. **Set anchors** (defines anchor point location in parent)
3. **Calculate offsets** (positions control relative to anchor based on size)

### Godot Control Positioning System

**Anchors** (percentages of parent size):
- `(0.5, 0.5, 0.5, 0.5)` = anchor point at parent's center
- Range: 0.0 (left/top edge) to 1.0 (right/bottom edge)

**Offsets** (pixel distances from anchor points):
- For centered control with size (W, H):
  - `offset_left = -W/2` (left edge W/2 pixels left of anchor)
  - `offset_top = -H/2` (top edge H/2 pixels above anchor)
  - `offset_right = W/2` (right edge W/2 pixels right of anchor)
  - `offset_bottom = H/2` (bottom edge H/2 pixels below anchor)

### When to Use Manual Calculation

**Use `set_anchors_and_offsets_preset()`:**
- Static controls in scene editor
- Size is already set and won't change

**Use Manual Calculation:**
- Dynamic sizing (runtime calculation)
- Size depends on screen dimensions
- Responsive layouts that adapt to viewport

### Red Flags

- 🚩 Calling `set_anchors_and_offsets_preset()` before setting size
- 🚩 Modal appears shifted from intended position
- 🚩 "Centering API doesn't work" (probably order-of-operations issue)
- 🚩 Different positioning on different screen sizes (offsets calculated wrong)

### Lessons Learned Source

From Character Details Polish (QA Passes 19-21):
- QA Pass 19: Used wrong API (`set_anchors_preset` instead of `set_anchors_and_offsets_preset`)
- QA Pass 20: Right API, wrong timing (called before size set) → modal shifted right/down
- QA Pass 21: Manual calculation with correct order → TRUE centering achieved

---

## Destructive Operation UI Standards

**Effective**: 2025-11-23 (After Character Details modal sizing lessons)

### Prominence Principle

**Rule**: Destructive operations MUST have visually prominent UI that conveys seriousness and reduces accidental taps.

### Size Requirements for Destructive Confirmations

**Minimum Standards** (iOS mobile):
- **Modal height**: 300px minimum (not 220px)
- **Modal width**: 90% of screen width, max 500px
- **Title font**: 28pt (not 24pt)
- **Message font**: 20pt (not 18pt)
- **Button size**: 140×64px minimum (not 120×56px)
- **Button font**: 20pt (not 18-19pt)
- **Padding**: 36px (not 28px)
- **Content spacing**: 24px between elements (not 20px)

### Why Size Matters

**Psychology**: Larger, more prominent UI signals importance
- Small modal (220px) = "This is a minor decision"
- Large modal (300px) = "This is a serious decision"
- Users PAY ATTENTION to prominent UI
- Reduces accidental taps (fat finger protection)

**Comparison**:
- 220px modal felt "not serious enough" for character deletion
- 300px modal (+36% larger) felt appropriately serious
- User feedback: "success current modal is sufficient for this polish pass"

### Destructive Operation Checklist

Before implementing delete/destructive confirmation:
```
□ Modal height ≥300px (prominence)
□ Modal width 90% screen (up to 500px max)
□ Title font ≥28pt (impact)
□ Message font ≥20pt (readability)
□ Buttons ≥140×64px (easy to tap, hard to mis-tap)
□ Button font ≥20pt (clarity)
□ Generous padding/spacing (visual breathing room)
□ Properly centered (manual calculation if dynamic sizing)
□ Tested on device (not just simulator)
```

### Additional Protections (Optional but Recommended)

**Progressive Confirmation**:
- First tap: Show "Are you sure?" modal
- Second tap (within 3 seconds): Actually delete
- Prevents single-tap accidents

**Undo Toast**:
- After deletion, show "Undo Delete" toast for 5 seconds
- Industry standard pattern
- Reduces user rage from accidents

**Visual Signals**:
- Red color for destructive actions
- Warning icons (skull, trash, danger symbol)
- Clear button labels ("Delete Character" not just "Delete")
- Include consequences in message ("This cannot be undone")

### Red Flags

- 🚩 Delete confirmation modal < 300px tall (too small)
- 🚩 Delete confirmation buttons < 140×64px (mis-tap risk)
- 🚩 No visual distinction between "Cancel" and "Delete" buttons
- 🚩 Can accidentally tap "Delete" when aiming for "Cancel" (too close)
- 🚩 Modal feels "generic" not "serious"

### Lessons Learned Source

From Character Details Polish (QA Pass 20-21):
- Initial modal: 220px tall, felt too small for serious action
- Revised modal: 300px tall (+36%), buttons 140×64px (+17%), larger fonts
- User feedback: "make the modal larger and more prominent" → we did → success

---

## Session & Week Plan Management Protocol

**Effective**: 2025-11-23 (Established during Week 16 planning handoff)

### Philosophy: Immutable Plans, Living Sessions

**The System:**
1. **Week Plans = 95% Immutable** - The master blueprint doesn't change (except status tracker)
2. **NEXT_SESSION.md = Fully Dynamic** - Living document tracking actual progress

### Week Plan Structure

**Immutable Content** (never changes after creation):
- Phase descriptions
- Estimated effort
- Task breakdowns
- Acceptance criteria
- Expert panel reviews
- Code examples
- Timeline diagrams
- Phase dependencies

**Living Content** (ONE section that updates):
```markdown
## Implementation Status (LIVING SECTION - Updated During Execution)

**Last Updated**: YYYY-MM-DD by Claude Code
**Current Session**: See `.system/NEXT_SESSION.md` for detailed notes

| Phase | Planned Effort | Actual Effort | Status | Completion Date | Notes |
|-------|---------------|---------------|--------|-----------------|-------|
| Phase 0 | 0.5h | 0.5h | ✅ Complete | 2025-11-18 | Infrastructure setup |
| Phase 1 | 2.5h | 0h | ⏭️ SKIPPED | N/A | Audit done informally |
| Pre-Work | (unplanned) | 4h | ✅ Complete | 2025-11-22 | Theme System |
| Detour | (unplanned) | 6h | ✅ Complete | 2025-11-23 | Character Details |
| Phase 2 | 2.5h | 3h | ✅ Complete | 2025-11-22 | Took longer than estimated |
| Phase 3 | 3h | - | 🔨 IN PROGRESS | - | 60% complete |
| ... | ... | ... | ... | ... | ... |

**Current Phase**: Phase 3 - Touch Targets
**Next Phase**: Phase 4 - Dialogs
**Total Progress**: ~65% complete
**Actual Time Spent**: 16.5h (vs 16h planned)
**Remaining Estimate**: 5.5h
```

### Why This Approach Wins

**Benefits of Immutable Week Plans:**
1. **Post-Mortem Analysis** - Compare estimated vs actual time, learn for next planning
2. **Accountability** - Can't retroactively change what we said we'd do
3. **Historical Record** - See what we THOUGHT it would take
4. **Multi-Session Reference** - Plan doesn't change, safe for parallel work
5. **Change Tracking** - Deviations visible in status tracker (skipped phases, detours, overruns)

**Benefits of Dynamic NEXT_SESSION.md:**
1. **Reality Tracking** - Captures what ACTUALLY happened (detours, discoveries, bugs)
2. **Session Handoff** - Next Claude session knows exactly where we are
3. **Learnings Preserved** - "Order matters for modal centering" gets documented
4. **Flexible** - Can add notes, findings, decisions without touching master plan
5. **Archivable** - Gets archived at milestones, creating historical trail

### NEXT_SESSION.md Content

**What Belongs:**
- ✅ Current status ("QA Pass 21 complete, ready for Phase 6")
- ✅ Pointer to week plan ("Currently on Week 16, Phase 6 next")
- ✅ Session accomplishments ("Fixed modal centering in 2 commits")
- ✅ Lessons learned ("Size first, then calculate position")
- ✅ Detours/discoveries ("Character Details took 6h, not planned")
- ✅ Quick Start Prompt (for next session: "Read files X, Y, Z and continue with...")
- ✅ Git status (branch, last commit, test status)
- ✅ Decision log ("Decided manual centering instead of preset API, here's why...")

**What Does NOT Belong** (goes in week plan status tracker):
- ❌ Phase completion percentages
- ❌ Overall week progress tracking
- ❌ Planned vs actual time tracking (status tracker handles this)

### Archive Naming Convention

**Format:**
```
.system/archive/NEXT_SESSION_{YYYY-MM-DD}_week{N}-{milestone-slug}.md
```

**Examples:**
```
NEXT_SESSION_2025-11-23_week16-character-details-complete.md
NEXT_SESSION_2025-11-22_week16-theme-haptics-complete.md
NEXT_SESSION_2025-11-20_week15-hub-roster-complete.md
NEXT_SESSION_2025-11-25_week16-typography-phase-complete.md
```

**Why This Format:**
- ✅ **Chronological**: Date prefix sorts naturally
- ✅ **Traceable**: Week number shows which plan was active
- ✅ **Descriptive**: Milestone slug is human-readable and searchable
- ✅ **Consistent**: Easy to script, easy to grep

### Process Flow

```
Week Plan Created (immutable blueprint)
    ↓
NEXT_SESSION.md tracks daily work
    ↓
Major Milestone Reached (phase complete, feature shipped)
    ↓
Archive NEXT_SESSION.md with descriptive name
    ↓
Update Week Plan Status Tracker (1 line per phase)
    ↓
Create New NEXT_SESSION.md pointing to next phase
    ↓
Repeat
```

### When to Archive NEXT_SESSION.md

**Archive Triggers:**
- ✅ Phase complete (e.g., "Phase 2 Typography complete")
- ✅ Major feature complete (e.g., "Character Details Polish complete")
- ✅ Week plan complete (e.g., "Week 16 complete")
- ✅ Significant milestone (e.g., "Theme System complete")
- ✅ Before starting new week plan

**Don't Archive For:**
- ❌ Every commit (too granular)
- ❌ Every QA pass (unless it's the final pass)
- ❌ Daily sessions (unless major milestone reached)

### Update Frequency

**Week Plan Status Tracker:**
- Update when phase status changes (started, completed, skipped)
- Update when detours occur (unplanned work added)
- Update when estimates change (phase took longer than planned)
- **Frequency**: ~1-3 times per session, only when status changes

**NEXT_SESSION.md:**
- Update continuously during work
- Update at end of every session (session handoff)
- **Frequency**: Multiple times per session

### Red Flags

- 🚩 Changing week plan content (phases, criteria) after execution started
- 🚩 NEXT_SESSION.md without pointer to week plan ("Which plan are we following?")
- 🚩 Archive file without week number ("Which plan was this session for?")
- 🚩 Archive file with generic name ("session-2025-11-23.md" - what was accomplished?)
- 🚩 Status tracker not updated for >1 week (losing sync with reality)

### Best Practices

**Week Planning:**
1. Create complete plan before execution starts
2. Include status tracker section at end (initially all "Pending")
3. Mark as "immutable" in header
4. Commit to repo (plan is source of truth)

**During Execution:**
1. Update status tracker when phase status changes
2. Add rows for unplanned work (detours, pre-work)
3. Record actual time spent
4. Note why estimates were wrong (learning)

**Session Handoffs:**
1. Update NEXT_SESSION.md at end of session
2. Include "Quick Start Prompt" for next Claude
3. Point to current phase in week plan
4. Archive when major milestone reached
5. Create new NEXT_SESSION.md for next phase

**Archiving:**
1. Use consistent naming: `NEXT_SESSION_{date}_week{N}-{milestone}.md`
2. Archive to `.system/archive/`
3. Update week plan status tracker
4. Create new NEXT_SESSION.md pointing forward
5. Don't delete old NEXT_SESSION.md, move it to archive

---

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

**Application**: Use this for all future week plans starting Week 17+

---

**Last Updated**: 2025-11-23 by Claude Code (Added Process Quality Gates: Pre-Implementation Spec Checkpoint, Scene Modification Protocol, Multi-Scene Commit Warning, Thinking Transparency, Time Pressure Detection, Phase Breakdown Strategy)
**Next Review**: When violations occur or user requests update
