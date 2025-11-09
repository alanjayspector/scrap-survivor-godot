/**
 * GIT APPROVAL SYSTEM
 *
 * Handles approval workflow for IMPACTFUL git operations.
 * Integrates with .claude/hooks/user-prompt-submit.ts
 *
 * Created: 2025-11-09
 * Version: 1.0.0
 */

import { AutonomyTier, classifyGitCommand, FORCE_PUSH_RULES } from './autonomy-tiers';
import { auditLogger } from './audit-logger';

/**
 * Approval request
 */
export interface ApprovalRequest {
  command: string;
  tier: AutonomyTier;
  reason: string;
  context?: {
    branch?: string;
    files?: string[];
    commitMessage?: string;
  };
}

/**
 * Approval result
 */
export interface ApprovalResult {
  approved: boolean;
  tier: AutonomyTier;
  reason: string;
  modifiedCommand?: string; // If user wants to modify command
}

/**
 * Check if a git command in user prompt requires approval
 */
export function checkGitCommandInPrompt(prompt: string): ApprovalRequest | null {
  // Extract git commands from prompt
  const gitCommandRegex = /git\s+[a-z-]+(?:\s+[^\n]*)?/gi;
  const matches = prompt.match(gitCommandRegex);

  if (!matches || matches.length === 0) {
    return null;
  }

  // Check first git command (agents usually run one at a time)
  const command = matches[0];
  const classification = classifyGitCommand(command);

  if (!classification) {
    return null;
  }

  // If BLOCKED, return approval request (will be denied automatically)
  if (classification.tier === AutonomyTier.BLOCKED) {
    return {
      command,
      tier: classification.tier,
      reason: classification.reason,
    };
  }

  // If IMPACTFUL, return approval request
  if (classification.tier === AutonomyTier.IMPACTFUL) {
    return {
      command,
      tier: classification.tier,
      reason: classification.reason,
    };
  }

  // SAFE tier - no approval needed
  return null;
}

/**
 * Handle approval request
 * Returns HTML/markdown message to show user
 */
export function handleApprovalRequest(request: ApprovalRequest): string {
  if (request.tier === AutonomyTier.BLOCKED) {
    // Log blocked operation
    auditLogger.logBlocked(request.command, request.tier, 'claude-code', request.reason);

    return `
🚫 **GIT OPERATION BLOCKED**

**Command:** \`${request.command}\`
**Reason:** ${request.reason}

**Why blocked:**
Destructive git operations are prevented to avoid accidental data loss or history corruption.

**What to do instead:**
1. Review the git autonomy tiers: \`.system/git/autonomy-tiers.ts\`
2. If you really need this operation, run it manually outside Claude Code
3. Check audit log: \`.system/logs/git-autonomy.log\`

**Protected branches:**
- \`main\`, \`master\`, \`stable\`, \`production\` - No force push allowed

**Need help?**
- See: \`docs/SYSTEM-ENFORCEMENT-LAYER-PLAN.md\` (Phase 3: Git Autonomy)
- Check recent git operations: \`npm run git:audit\`
`.trim();
  }

  if (request.tier === AutonomyTier.IMPACTFUL) {
    return `
⚠️  **GIT OPERATION REQUIRES APPROVAL**

**Command:** \`${request.command}\`
**Tier:** IMPACTFUL
**Reason:** ${request.reason}

**Impact:**
This operation will change git history or remote state. It's reversible but requires effort to undo.

**Options:**
1. **Approve:** Allow Claude Code to run this command
2. **Deny:** Block this operation
3. **Modify:** Provide alternative command

**To approve:** Reply "yes", "approve", or "go ahead"
**To deny:** Reply "no", "deny", or "block"
**To modify:** Provide the corrected command

**This will be logged to:** \`.system/logs/git-autonomy.log\`
`.trim();
  }

  return '';
}

/**
 * Parse user response to approval request
 */
export function parseApprovalResponse(response: string): 'approve' | 'deny' | 'modify' {
  const normalized = response.toLowerCase().trim();

  // Approval phrases
  const approvalPhrases = ['yes', 'approve', 'go ahead', 'do it', 'proceed', 'ok', 'sure'];
  if (approvalPhrases.some(phrase => normalized.includes(phrase))) {
    return 'approve';
  }

  // Denial phrases
  const denialPhrases = ['no', 'deny', 'block', 'stop', 'cancel', 'don\'t'];
  if (denialPhrases.some(phrase => normalized.includes(phrase))) {
    return 'deny';
  }

  // If contains "git", assume it's a modified command
  if (normalized.includes('git')) {
    return 'modify';
  }

  // Default: deny for safety
  return 'deny';
}

/**
 * Validate force push based on branch
 */
export function validateForcePush(branch: string): { allowed: boolean; reason: string } {
  const tier = FORCE_PUSH_RULES.check(branch);

  if (tier === AutonomyTier.BLOCKED) {
    return {
      allowed: false,
      reason: `Force push to '${branch}' is blocked. Protected branches: ${FORCE_PUSH_RULES.blocked.join(', ')}`,
    };
  }

  if (tier === AutonomyTier.IMPACTFUL) {
    return {
      allowed: true,
      reason: `Force push to '${branch}' requires approval (feature branch)`,
    };
  }

  return {
    allowed: false,
    reason: 'Force push not allowed to this branch',
  };
}

/**
 * Get current git branch
 */
export async function getCurrentBranch(): Promise<string | null> {
  try {
    const { execSync } = await import('child_process');
    const branch = execSync('git branch --show-current', {
      encoding: 'utf-8',
      cwd: process.cwd(),
    }).trim();
    return branch || null;
  } catch {
    return null;
  }
}

/**
 * Check if command is safe to run
 * Returns { safe: boolean, message?: string }
 */
export async function checkCommandSafety(command: string): Promise<{ safe: boolean; message?: string; tier: AutonomyTier }> {
  const classification = classifyGitCommand(command);

  if (!classification) {
    return {
      safe: false,
      message: 'Unknown git command',
      tier: AutonomyTier.BLOCKED,
    };
  }

  // SAFE tier - always allowed
  if (classification.tier === AutonomyTier.SAFE) {
    auditLogger.logSuccess(command, classification.tier, 'claude-code', false);
    return {
      safe: true,
      tier: classification.tier,
    };
  }

  // BLOCKED tier - never allowed
  if (classification.tier === AutonomyTier.BLOCKED) {
    auditLogger.logBlocked(command, classification.tier, 'claude-code', classification.reason);
    return {
      safe: false,
      message: handleApprovalRequest({
        command,
        tier: classification.tier,
        reason: classification.reason,
      }),
      tier: classification.tier,
    };
  }

  // IMPACTFUL tier - requires approval
  if (classification.tier === AutonomyTier.IMPACTFUL) {
    // Special case: force push
    if (command.includes('push') && (command.includes('--force') || command.includes(' -f'))) {
      const branch = await getCurrentBranch();
      if (branch) {
        const validation = validateForcePush(branch);
        if (!validation.allowed) {
          auditLogger.logBlocked(command, AutonomyTier.BLOCKED, 'claude-code', validation.reason);
          return {
            safe: false,
            message: handleApprovalRequest({
              command,
              tier: AutonomyTier.BLOCKED,
              reason: validation.reason,
            }),
            tier: AutonomyTier.BLOCKED,
          };
        }
      }
    }

    // Return approval request
    return {
      safe: false,
      message: handleApprovalRequest({
        command,
        tier: classification.tier,
        reason: classification.reason,
      }),
      tier: classification.tier,
    };
  }

  return {
    safe: false,
    message: 'Unknown error in command safety check',
    tier: AutonomyTier.BLOCKED,
  };
}

/**
 * Example usage in user-prompt-submit hook:
 *
 * ```typescript
 * import { checkGitCommandInPrompt, handleApprovalRequest } from '.system/git/approval-system';
 *
 * export default async function userPromptSubmit(payload: UserPromptSubmitPayload) {
 *   const prompt = payload.userMessage;
 *
 *   // Check if prompt contains git command
 *   const approvalRequest = checkGitCommandInPrompt(prompt);
 *
 *   if (approvalRequest) {
 *     // Show approval UI
 *     const message = handleApprovalRequest(approvalRequest);
 *     console.log(message);
 *
 *     // For Claude Code, this would pause and wait for user response
 *     // (implementation depends on hook capabilities)
 *   }
 * }
 * ```
 */
