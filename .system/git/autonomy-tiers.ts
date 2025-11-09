/**
 * GIT AUTONOMY TIERS
 *
 * Defines what git operations agents can perform autonomously.
 * Based on: Reddit post "Stop Teaching Your AI Agents"
 *
 * Three tiers:
 * 1. SAFE - Auto-allowed, no approval needed
 * 2. IMPACTFUL - Requires user approval
 * 3. BLOCKED - Never allowed (destructive)
 *
 * Created: 2025-11-09
 * Version: 1.0.0
 */

/**
 * Autonomy tier classification
 */
export enum AutonomyTier {
  SAFE = 'safe',
  IMPACTFUL = 'impactful',
  BLOCKED = 'blocked',
}

/**
 * Git operation classification
 */
export interface GitOperation {
  command: string;
  tier: AutonomyTier;
  reason: string;
  requiresApproval: boolean;
  logToAudit: boolean;
}

/**
 * TIER 1: SAFE OPERATIONS
 * Auto-allowed, logged for transparency
 *
 * Philosophy: Information gathering and safe state checks
 * User impact: Zero - read-only operations
 */
export const SAFE_OPERATIONS: GitOperation[] = [
  {
    command: 'git status',
    tier: AutonomyTier.SAFE,
    reason: 'Read-only: Shows working tree status',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git diff',
    tier: AutonomyTier.SAFE,
    reason: 'Read-only: Shows changes',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git log',
    tier: AutonomyTier.SAFE,
    reason: 'Read-only: Shows commit history',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git show',
    tier: AutonomyTier.SAFE,
    reason: 'Read-only: Shows commit details',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git branch --list',
    tier: AutonomyTier.SAFE,
    reason: 'Read-only: Lists branches',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git remote -v',
    tier: AutonomyTier.SAFE,
    reason: 'Read-only: Shows remote repositories',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git add',
    tier: AutonomyTier.SAFE,
    reason: 'Staging is reversible (git reset)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git reset HEAD',
    tier: AutonomyTier.SAFE,
    reason: 'Unstages files without data loss',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git stash',
    tier: AutonomyTier.SAFE,
    reason: 'Temporary storage, easily reversible',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git stash pop',
    tier: AutonomyTier.SAFE,
    reason: 'Restores stashed changes',
    requiresApproval: false,
    logToAudit: true,
  },
];

/**
 * TIER 2: IMPACTFUL OPERATIONS
 * Require user approval before execution
 *
 * Philosophy: Operations that change history or remote state
 * User impact: Medium - can be undone but requires effort
 */
export const IMPACTFUL_OPERATIONS: GitOperation[] = [
  {
    command: 'git commit',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Creates permanent history entry (requires approval for commit message)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git push',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Affects remote repository (visible to team)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git pull',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Merges remote changes (potential conflicts)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git merge',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Combines branches (can create conflicts)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git rebase',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Rewrites commit history (requires care)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git branch -d',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Deletes local branch (recoverable from remote)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git checkout',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Switches branches or restores files (can lose uncommitted work)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git switch',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Switches branches (can lose uncommitted work)',
    requiresApproval: true,
    logToAudit: true,
  },
  {
    command: 'git restore',
    tier: AutonomyTier.IMPACTFUL,
    reason: 'Discards local changes (potential data loss)',
    requiresApproval: true,
    logToAudit: true,
  },
];

/**
 * TIER 3: BLOCKED OPERATIONS
 * Never allowed - destructive and irreversible
 *
 * Philosophy: Prevent catastrophic mistakes
 * User impact: High - data loss, history destruction, team disruption
 */
export const BLOCKED_OPERATIONS: GitOperation[] = [
  {
    command: 'git push --force',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Overwrites remote history (breaks team workflow)',
    requiresApproval: false, // Not even with approval
    logToAudit: true,
  },
  {
    command: 'git push -f',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Force push shorthand (breaks team workflow)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git reset --hard',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Permanently discards uncommitted changes',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git clean -fd',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Permanently deletes untracked files',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git branch -D',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Force deletes branch (loses unmerged work)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git push --delete',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Deletes remote branch (affects team)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git rebase -i',
    tier: AutonomyTier.BLOCKED,
    reason: 'INTERACTIVE: Requires manual input (not automatable)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git commit --amend',
    tier: AutonomyTier.BLOCKED,
    reason: 'HISTORY REWRITE: Changes last commit (can break remote)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git filter-branch',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Rewrites entire history (catastrophic if misused)',
    requiresApproval: false,
    logToAudit: true,
  },
  {
    command: 'git reflog expire',
    tier: AutonomyTier.BLOCKED,
    reason: 'DESTRUCTIVE: Removes safety net for recovery',
    requiresApproval: false,
    logToAudit: true,
  },
];

/**
 * Special case: Force push to non-protected branches
 * User explicitly requested "aggressive but prevent history destruction"
 *
 * Solution: Allow force push ONLY to feature branches, BLOCK for main/stable
 */
export const FORCE_PUSH_RULES = {
  allowed: ['feature/*', 'fix/*', 'chore/*'], // Can force push to feature branches
  blocked: ['main', 'master', 'stable', 'production'], // Never force push to protected branches

  check(branch: string): AutonomyTier {
    // Check if branch is protected
    if (this.blocked.includes(branch)) {
      return AutonomyTier.BLOCKED;
    }

    // Check if branch matches allowed pattern
    for (const pattern of this.allowed) {
      const regex = new RegExp(`^${pattern.replace('*', '.*')}$`);
      if (regex.test(branch)) {
        return AutonomyTier.IMPACTFUL; // Require approval for force push
      }
    }

    // Default: block if not explicitly allowed
    return AutonomyTier.BLOCKED;
  },
};

/**
 * Classify a git command by autonomy tier
 */
export function classifyGitCommand(command: string): GitOperation | null {
  const normalizedCommand = command.trim().toLowerCase();

  // Check BLOCKED first (highest priority)
  for (const op of BLOCKED_OPERATIONS) {
    if (normalizedCommand.includes(op.command.toLowerCase())) {
      return op;
    }
  }

  // Special case: force push with branch context
  if (normalizedCommand.includes('push') && (normalizedCommand.includes('--force') || normalizedCommand.includes(' -f'))) {
    // Extract branch name (this is simplified - real implementation would parse properly)
    // For now, return BLOCKED and let the hook handler check branch
    return {
      command: 'git push --force',
      tier: AutonomyTier.BLOCKED,
      reason: 'Force push requires branch context check',
      requiresApproval: false,
      logToAudit: true,
    };
  }

  // Check IMPACTFUL
  for (const op of IMPACTFUL_OPERATIONS) {
    if (normalizedCommand.startsWith(op.command.toLowerCase())) {
      return op;
    }
  }

  // Check SAFE
  for (const op of SAFE_OPERATIONS) {
    if (normalizedCommand.startsWith(op.command.toLowerCase())) {
      return op;
    }
  }

  // Unknown command - default to BLOCKED for safety
  return {
    command: command,
    tier: AutonomyTier.BLOCKED,
    reason: 'Unknown git command - defaulting to blocked for safety',
    requiresApproval: false,
    logToAudit: true,
  };
}

/**
 * Get all operations by tier
 */
export function getOperationsByTier(tier: AutonomyTier): GitOperation[] {
  switch (tier) {
    case AutonomyTier.SAFE:
      return SAFE_OPERATIONS;
    case AutonomyTier.IMPACTFUL:
      return IMPACTFUL_OPERATIONS;
    case AutonomyTier.BLOCKED:
      return BLOCKED_OPERATIONS;
  }
}

/**
 * Check if operation is allowed
 */
export function isOperationAllowed(command: string): { allowed: boolean; tier: AutonomyTier; reason: string } {
  const classification = classifyGitCommand(command);

  if (!classification) {
    return {
      allowed: false,
      tier: AutonomyTier.BLOCKED,
      reason: 'Unknown command',
    };
  }

  if (classification.tier === AutonomyTier.BLOCKED) {
    return {
      allowed: false,
      tier: classification.tier,
      reason: classification.reason,
    };
  }

  if (classification.tier === AutonomyTier.IMPACTFUL) {
    return {
      allowed: true, // Allowed with approval
      tier: classification.tier,
      reason: `${classification.reason} - Requires user approval`,
    };
  }

  // SAFE tier
  return {
    allowed: true,
    tier: classification.tier,
    reason: classification.reason,
  };
}

/**
 * Example usage:
 *
 * ```typescript
 * import { classifyGitCommand, isOperationAllowed } from '.system/git/autonomy-tiers';
 *
 * // Check if command is allowed
 * const result = isOperationAllowed('git push --force');
 * if (!result.allowed) {
 *   console.error(`Blocked: ${result.reason}`);
 *   return;
 * }
 *
 * // Classify command
 * const classification = classifyGitCommand('git commit -m "feat: add feature"');
 * if (classification.requiresApproval) {
 *   // Ask user for approval
 *   const approved = await promptUser(`Allow: ${classification.command}?`);
 *   if (!approved) return;
 * }
 *
 * // Log to audit
 * if (classification.logToAudit) {
 *   auditLog.write({ command, tier: classification.tier, timestamp: new Date() });
 * }
 * ```
 */
