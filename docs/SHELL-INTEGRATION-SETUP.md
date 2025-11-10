# Shell Integration Setup (Optional)

**Purpose**: Add an extra layer of protection against bypassing git hooks

**Status**: Optional - Recommended for teams with multiple contributors

---

## Overview

The `scripts/check-no-verify.sh` script creates a wrapper around the `git` command that warns before executing any command with `--no-verify` or similar bypass flags.

This is an **optional** extra safety layer on top of the mandatory rules in [DEVELOPMENT-RULES.md](./DEVELOPMENT-RULES.md).

---

## Installation

### For Bash Users

Add to your `~/.bashrc`:

```bash
# Scrap Survivor - Git bypass detector
source ~/Developer/scrap-survivor-godot/scripts/check-no-verify.sh
```

Then reload:
```bash
source ~/.bashrc
```

### For Zsh Users

Add to your `~/.zshrc`:

```zsh
# Scrap Survivor - Git bypass detector
source ~/Developer/scrap-survivor-godot/scripts/check-no-verify.sh
```

Then reload:
```bash
source ~/.zshrc
```

### For Fish Users

Add to your `~/.config/fish/config.fish`:

```fish
# Scrap Survivor - Git bypass detector
bass source ~/Developer/scrap-survivor-godot/scripts/check-no-verify.sh
```

(Requires `bass` plugin: `fisher install edc/bass`)

---

## How It Works

### Without the Script

```bash
$ git commit --no-verify -m "quick fix"
# Commits immediately, bypassing all hooks
```

### With the Script

```bash
$ git commit --no-verify -m "quick fix"

⚠️  ============================================
⚠️  WARNING: Attempting to bypass git hooks!
⚠️  ============================================

❌ This is FORBIDDEN per docs/DEVELOPMENT-RULES.md

💡 Instead, you should:
   1. Read the error message from the hook
   2. Fix the actual issue (linting, formatting, tests)
   3. Re-attempt the commit WITHOUT --no-verify

📚 See: docs/DEVELOPMENT-RULES.md for complete rules

Are you ABSOLUTELY SURE you want to bypass hooks? (type 'yes' to proceed): _
```

If you type anything other than "yes", the command is aborted.

---

## What Gets Logged

If you do proceed with a bypass (after typing "yes"), the action is logged to `.git/bypass-log.txt`:

```
[Mon Jan 10 10:30:45 PST 2025] Bypassed hooks: git commit --no-verify -m "quick fix"
[Mon Jan 10 10:32:12 PST 2025] Bypassed hooks: git push --no-verify
```

This log helps identify patterns of hook bypassing that may indicate:
- Broken hooks that need fixing
- Misunderstanding of the commit workflow
- Deliberate circumvention of quality standards

---

## Uninstallation

If you need to remove the wrapper:

1. Remove the `source` line from your shell config file
2. Reload your shell:
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

The native `git` command will work normally after this.

---

## Limitations

### This Script Does NOT:

- ❌ Actually prevent bypassing hooks (it's just a wrapper)
- ❌ Replace the pre-commit hooks
- ❌ Enforce rules at the Git level
- ❌ Work for GUI git clients (GitKraken, SourceTree, etc.)

### This Script DOES:

- ✅ Add a warning/confirmation step before bypass
- ✅ Log bypass attempts for review
- ✅ Remind developers of proper workflow
- ✅ Create a "speed bump" to prevent accidental bypassing

---

## Alternative: Git Alias

If you don't want to modify your shell, you can create a git alias that runs the check:

```bash
git config alias.commit-safe '!f() {
  if echo "$@" | grep -q -- "--no-verify"; then
    echo "❌ --no-verify is forbidden";
    return 1;
  fi;
  git commit "$@";
}; f'
```

Then use:
```bash
git commit-safe -m "my message"  # Safe commit
```

---

## FAQ

### Q: Is this required?

**A:** No, this is optional. The **mandatory** rules are in [DEVELOPMENT-RULES.md](./DEVELOPMENT-RULES.md).

### Q: What if I legitimately need to bypass hooks?

**A:** You almost certainly don't. If you think you do:
1. Review [DEVELOPMENT-RULES.md](./DEVELOPMENT-RULES.md)
2. Ask the team lead
3. Document why in the commit message

### Q: Does this slow down git commands?

**A:** Only commands with `--no-verify` or similar flags. Normal commits are unaffected.

### Q: Can I customize the warning message?

**A:** Yes! Edit `scripts/check-no-verify.sh` and modify the echo statements.

---

## Related Documentation

- [DEVELOPMENT-RULES.md](./DEVELOPMENT-RULES.md) - Mandatory commit rules
- [godot-testing-research.md](./godot-testing-research.md) - Testing workflow
- [RUNNING-TESTS-IN-GODOT.md](./RUNNING-TESTS-IN-GODOT.md) - Running tests manually

---

**Document Version**: 1.0
**Last Updated**: 2025-01-10
**Maintained By**: Scrap Survivor Dev Team
