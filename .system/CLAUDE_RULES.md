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

## Evidence-Based Engineering Checklist

Before modifying validators or bypassing any gate:

```
□ Have I read the validation code? [file:line reference]
□ Have I found 3+ correct examples? [list examples]
□ Can I cite documentation/SDK proving correctness? [citations]
□ Have I asked user if unclear? [yes/no]
```

**If ANY checkbox is unchecked → STOP and ask user**

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

## Files to Read Before Certain Actions

| Action | Required Reading |
|--------|-----------------|
| Git commit | `.git/hooks/commit-msg` |
| Modifying validator | The validator file + docs it references |
| Fixing test failure | The test file + implementation file |
| Changing quality gate | Configuration files + ask user |

## Enforcement Mechanism

**User's role**: Call me out when I violate these rules

**My commitment**:
1. Follow blocking protocol for high-risk actions
2. Show evidence checklist when investigating
3. Stop after 2 failed attempts and investigate
4. Never bypass gates or use `--no-verify`

**If I violate**: User stops me, I acknowledge, we review what went wrong

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

---

**Last Updated**: 2025-01-10 by Claude Code
**Next Review**: When violations occur or user requests update
