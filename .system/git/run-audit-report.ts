#!/usr/bin/env tsx

/**
 * GIT AUDIT REPORT
 *
 * Displays recent git operations and statistics.
 * Shows what git commands were allowed/blocked automatically.
 *
 * Created: 2025-11-09
 * Version: 1.0.0
 */

import { auditLogger } from './audit-logger';
import { AutonomyTier } from './autonomy-tiers';

/**
 * Format tier for display
 */
function formatTier(tier: AutonomyTier): string {
  switch (tier) {
    case AutonomyTier.SAFE:
      return '✅ SAFE';
    case AutonomyTier.IMPACTFUL:
      return '⚠️  IMPACTFUL';
    case AutonomyTier.BLOCKED:
      return '🚫 BLOCKED';
  }
}

/**
 * Format outcome for display
 */
function formatOutcome(outcome: string): string {
  switch (outcome) {
    case 'success':
      return '✅ Success';
    case 'blocked':
      return '🚫 Blocked';
    case 'denied':
      return '❌ Denied';
    case 'error':
      return '⚠️  Error';
    default:
      return outcome;
  }
}

/**
 * Main report function
 */
async function main() {
  const limit = process.argv[2] ? parseInt(process.argv[2], 10) : 20;

  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║          GIT AUTONOMY AUDIT LOG                          ║');
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  // Get recent entries
  const entries = auditLogger.readRecent(limit);

  if (entries.length === 0) {
    console.log('No git operations logged yet.\n');
    console.log('Git autonomy system will log operations automatically.');
    console.log('Try running a git command via Claude Code to see it logged here.\n');
    return;
  }

  // Get stats
  const stats = auditLogger.getStats();

  // Display stats
  console.log('┌─────────────────────────────────────────────────────────┐');
  console.log('│ STATISTICS                                               │');
  console.log('├─────────────────────────────────────────────────────────┤');
  console.log(`│ Total operations:     ${stats.total.toString().padEnd(35)} │`);
  console.log(`│                                                         │`);
  console.log(`│ By Tier:                                                │`);
  console.log(`│   SAFE operations:    ${stats.byTier.safe.toString().padEnd(35)} │`);
  console.log(`│   IMPACTFUL:          ${stats.byTier.impactful.toString().padEnd(35)} │`);
  console.log(`│   BLOCKED:            ${stats.byTier.blocked.toString().padEnd(35)} │`);
  console.log(`│                                                         │`);
  console.log(`│ By Outcome:                                             │`);
  console.log(`│   Success:            ${stats.byOutcome.success.toString().padEnd(35)} │`);
  console.log(`│   Blocked:            ${stats.byOutcome.blocked.toString().padEnd(35)} │`);
  console.log(`│   Denied:             ${stats.byOutcome.denied.toString().padEnd(35)} │`);
  console.log(`│   Error:              ${stats.byOutcome.error.toString().padEnd(35)} │`);
  console.log(`│                                                         │`);
  console.log(`│ Approval Rate:        ${stats.approvalRate.toFixed(1)}%${' '.repeat(35 - stats.approvalRate.toFixed(1).length - 1)} │`);
  console.log('└─────────────────────────────────────────────────────────┘\n');

  // Display most common commands
  if (stats.mostCommonCommands.length > 0) {
    console.log('┌─────────────────────────────────────────────────────────┐');
    console.log('│ MOST COMMON COMMANDS                                    │');
    console.log('├─────────────────────────────────────────────────────────┤');
    for (const { command, count } of stats.mostCommonCommands) {
      const line = `│ ${command.padEnd(40)} ${count.toString().padStart(12)} │`;
      console.log(line);
    }
    console.log('└─────────────────────────────────────────────────────────┘\n');
  }

  // Display recent entries
  console.log('┌─────────────────────────────────────────────────────────┐');
  console.log(`│ RECENT OPERATIONS (last ${limit})${' '.repeat(32 - limit.toString().length)} │`);
  console.log('├─────────────────────────────────────────────────────────┤');

  for (const entry of entries.slice().reverse()) {
    const timestamp = new Date(entry.timestamp).toLocaleString();
    const tier = formatTier(entry.tier);
    const outcome = formatOutcome(entry.outcome);

    console.log(`│                                                         │`);
    console.log(`│ ${timestamp.padEnd(53)} │`);
    console.log(`│ Command: ${entry.command.padEnd(44)} │`);
    console.log(`│ Tier:    ${tier.padEnd(44)} │`);
    console.log(`│ Outcome: ${outcome.padEnd(44)} │`);

    if (entry.reason) {
      const truncatedReason = entry.reason.length > 44 ? entry.reason.slice(0, 41) + '...' : entry.reason;
      console.log(`│ Reason:  ${truncatedReason.padEnd(44)} │`);
    }

    if (entry.error) {
      const truncatedError = entry.error.length > 44 ? entry.error.slice(0, 41) + '...' : entry.error;
      console.log(`│ Error:   ${truncatedError.padEnd(44)} │`);
    }
  }

  console.log('└─────────────────────────────────────────────────────────┘\n');

  // Footer
  console.log('💡 Full log: .system/logs/git-autonomy.log');
  console.log('💡 View more: npm run git:audit [limit]');
  console.log('💡 Rotate log: npm run git:rotate [days]\n');
}

main().catch(error => {
  console.error('Error generating audit report:', error);
  process.exit(1);
});
