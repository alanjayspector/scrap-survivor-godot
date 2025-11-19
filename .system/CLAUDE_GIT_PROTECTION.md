# Claude Code Git Protection System

**Version**: 1.0
**Created**: 2025-11-18
**Purpose**: Multi-layer defense against banned git operations during AI-assisted development

## Overview

This system provides **three layers of protection** to prevent Claude Code from violating git safety rules, especially during context rollover situations where the AI might forget the rules from `.system/CLAUDE_RULES.md`.

## Architecture

```
User Request → git-wrapper.sh → Git → pre-commit hook → Validators → Commit
               ↓ Layer 1        ↓      ↓ Layer 2         ↓ Layer 3
               Blocks banned    │      Shows reminder     Enforces quality
               flags before     │      Detects amend
               git runs         │      Pauses for review
```

## Layer 1: git-wrapper.sh (First Line of Defense)

**Location**: `git-wrapper.sh` (must be installed in PATH)

**Purpose**: Intercept git commands BEFORE they reach the actual git binary

### What It Does

- ✅ Monitors commands: `commit`, `push`, `rebase`, `reset`
- ✅ Blocks banned flags: `--no-verify`, `--force`, `-f`, `--amend`, `--skip-ci`, `--no-gpg-sign`
- ✅ Pass-through for safe commands: `status`, `log`, `diff`, etc.
- ✅ Shows loud error referencing CLAUDE_RULES.md

### Installation

```bash
# Make executable
chmod +x git-wrapper.sh

# Option A: Install in ~/bin (recommended)
mkdir -p ~/bin
cp git-wrapper.sh ~/bin/git
# Add to ~/.zshrc or ~/.bashrc:
export PATH="$HOME/bin:$PATH"

# Option B: Create shell alias
echo 'alias git="$PWD/git-wrapper.sh"' >> ~/.zshrc
source ~/.zshrc
```

### Test It

```bash
# Should BLOCK with error
./git-wrapper.sh commit --no-verify -m "test"

# Should pass through normally
./git-wrapper.sh status
```

### Example Output (Blocked)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 BANNED FLAG DETECTED: --no-verify
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Command attempted: git commit --no-verify -m "test"

This flag violates .system/CLAUDE_RULES.md

⚠️  CLAUDE: You MUST now:
    1. Re-read .system/CLAUDE_RULES.md
    2. Announce to user what you were about to do
    3. Wait for explicit approval

Required reading: .system/CLAUDE_RULES.md (lines 22, 29)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Limitations

- ⚠️ Can be bypassed with `/usr/bin/git` or `command git`
- ⚠️ Only works if installed in PATH before actual git binary
- ⚠️ Requires shell session (won't catch IDE git operations)

## Layer 2: .git/hooks/pre-commit (Second Line)

**Location**: `.git/hooks/pre-commit`

**Purpose**: Show reminders and detect dangerous git states during commit

### What It Does

- ✅ Shows prominent CLAUDE_RULES.md reminder on EVERY commit
- ✅ Lists all banned flags with explanations
- ✅ Shows blocking protocol steps
- ✅ **Detects `--amend` operations** and shows extra warning
- ✅ Detects merge commits
- ✅ Pauses 3 seconds on amend to ensure visibility
- ✅ Shows current commit author (to check if amending someone else's work)

### Example Output (Normal Commit)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  CLAUDE CODE REMINDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Before committing, verify compliance with:
  📋 .system/CLAUDE_RULES.md

BANNED FLAGS (will fail if used):
  ❌ --no-verify  (bypasses this hook - use git-wrapper.sh to catch)
  ❌ --amend      (detected above if present)
  ❌ --force      (push only)
  ❌ --skip-ci    (CI bypass)

BLOCKING PROTOCOL (CLAUDE_RULES.md lines 7-24):
  1. Announce: 'APPROVAL REQUIRED: [action]'
  2. Show evidence checklist
  3. Show exact command
  4. WAIT for user 'yes'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Example Output (Amend Detected)

```
🚨 AMEND DETECTED - Check CLAUDE_RULES.md line 22

WARNING: Amend detected!
  - Check authorship: git log -1 --format='%an %ae'
  - Ensure commit not pushed: git status
  - CLAUDE: Did you get explicit user approval?

  Current HEAD author: Alan Developer <alan@example.com>

Continuing in 3 seconds (Ctrl+C to abort)...
```

### Limitations

- ⚠️ **Cannot catch `--no-verify`** - that flag bypasses hooks entirely
- ⚠️ Cannot prevent commit, only warn (that's what Layer 3 validators do)
- ⚠️ Amend detection is heuristic-based (checks ORIG_HEAD)

## Layer 3: CLAUDE_RULES.md (Core Protocol)

**Location**: `.system/CLAUDE_RULES.md`

**Purpose**: Core rules and blocking protocol that Claude Code must follow

### Blocking Protocol

Before executing high-risk actions, Claude MUST:

1. **Announce**: `"**APPROVAL REQUIRED**: [action description]"`
2. **Show evidence**: Completed checklist proving work is correct
3. **Show command**: Exact command to be executed
4. **WAIT**: For user to type "yes" before proceeding

### High-Risk Actions

- Any `git commit` (even if validation passes)
- Any `git push`
- Using flags: `--no-verify`, `--force`, `--amend`, `--skip-ci`
- Modifying validators in `.system/validators/`
- Changing quality gate expectations

### NEVER Rules (Zero Tolerance)

1. ❌ NEVER use `--no-verify` on git commits
2. ❌ NEVER bypass quality gates
3. ❌ NEVER modify validators without evidence
4. ❌ NEVER assume validation is wrong - investigate first
5. ❌ NEVER take shortcuts when frustrated

## Defense-in-Depth Benefits

### What Each Layer Protects Against

| Scenario | Layer 1 | Layer 2 | Layer 3 |
|----------|---------|---------|---------|
| Context rollover - forgot rules | ✅ Blocks | ✅ Reminds | ✅ Should remember |
| Accidental `--no-verify` | ✅ Blocks | ❌ Bypassed | ❌ Never ran |
| Accidental `--amend` | ✅ Blocks | ✅ Warns + pauses | ✅ Should ask first |
| Amending wrong author | ⚠️ Blocks flag | ✅ Shows author | ✅ Should check |
| Force push | ✅ Blocks | ⚠️ Warns | ✅ Should ask first |
| Fast context switch | ✅ Still active | ✅ Still shows | ⚠️ Might forget |

### Why Multiple Layers?

**No single layer is perfect:**

- Layer 1 can be bypassed with full path to git
- Layer 2 can be bypassed with `--no-verify`
- Layer 3 depends on AI context (can be lost in rollover)

**Together they create redundancy:**

- If Claude forgets rules (Layer 3 fails) → Layer 1 or 2 catches
- If wrapper not in PATH (Layer 1 fails) → Layer 2 and 3 catch
- If `--no-verify` used (Layer 2 bypassed) → Layer 1 should catch first

## Maintenance

### Updating Banned Flags

To add a new banned flag:

1. Add to `git-wrapper.sh` BANNED_FLAGS array
2. Add to `.git/hooks/pre-commit` reminder section
3. Add to `.system/CLAUDE_RULES.md` High-Risk Actions list
4. Test all three layers

### Testing the System

```bash
# Test Layer 1
./git-wrapper.sh commit --no-verify -m "test"
# Expected: Blocked with error

# Test Layer 2
git commit -m "test: something"
# Expected: Shows reminder banner
# Note: Will fail validators - that's fine for testing

# Test Layer 3
# Have Claude attempt a commit
# Expected: Claude should announce "APPROVAL REQUIRED" first
```

### Monitoring

Check for violations:

```bash
# Check recent commits for amends
git log --oneline --all --graph -10

# Check if wrapper is in PATH
which git
# Should show ~/bin/git if wrapper installed

# Verify pre-commit hook is executable
ls -l .git/hooks/pre-commit
# Should show -rwxr-xr-x
```

## Troubleshooting

### "Wrapper not blocking commands"

- Check PATH: `echo $PATH | grep -o '[^:]*' | head -5`
- Wrapper must appear before `/usr/bin`
- Verify wrapper is executable: `chmod +x ~/bin/git`

### "Pre-commit not running"

- Check if hook is executable: `chmod +x .git/hooks/pre-commit`
- Verify file exists: `ls -l .git/hooks/pre-commit`
- Check for `--no-verify` usage (bypasses hooks)

### "Claude still violated rules"

- Check which layer failed
- Review git history: `git log -3`
- Check if wrapper was in PATH at the time
- Consider adding more checks to failed layer

## Design Philosophy

This system follows **defense-in-depth** security principles:

1. **Assume failure**: Each layer assumes others might fail
2. **Fail loudly**: Errors are prominent and reference documentation
3. **Pause for human**: Critical operations pause to allow intervention
4. **Audit trail**: Git history shows what protections were active
5. **Progressive enforcement**: Warnings → Blocks → Hard stops

## Version History

- **1.0** (2025-11-18): Initial implementation
  - Created git-wrapper.sh
  - Enhanced pre-commit hook
  - This documentation

## See Also

- [CLAUDE_RULES.md](.system/CLAUDE_RULES.md) - Core rules and blocking protocol
- [.git/hooks/pre-commit](../.git/hooks/pre-commit) - Validation and reminder hook
- [git-wrapper.sh](../git-wrapper.sh) - First line of defense wrapper

---

**Remember**: These protections are **training wheels, not handcuffs**. They help Claude Code maintain safety during context rollover, but human oversight is still the ultimate protection.
