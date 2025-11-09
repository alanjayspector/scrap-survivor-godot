/**
 * GIT AUTONOMY AUDIT LOGGER
 *
 * Logs all autonomous git operations for transparency and debugging.
 * Helps answer: "What did the agent do automatically?"
 *
 * Created: 2025-11-09
 * Version: 1.0.0
 */

import * as fs from 'fs';
import * as path from 'path';
import { AutonomyTier } from './autonomy-tiers';

/**
 * Audit log entry
 */
export interface AuditLogEntry {
  timestamp: string;
  command: string;
  tier: AutonomyTier;
  approved: boolean;
  agent: string; // 'claude-code', 'cursor', 'copilot', etc.
  outcome: 'success' | 'blocked' | 'denied' | 'error';
  reason?: string;
  error?: string;
  context?: Record<string, unknown>;
}

/**
 * Audit logger class
 */
export class AuditLogger {
  private logPath: string;

  constructor(logPath = '.system/logs/git-autonomy.log') {
    this.logPath = path.resolve(logPath);
    this.ensureLogDirectory();
  }

  /**
   * Ensure log directory exists
   */
  private ensureLogDirectory(): void {
    const dir = path.dirname(this.logPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  /**
   * Log a git operation
   */
  log(entry: AuditLogEntry): void {
    const logLine = JSON.stringify({
      ...entry,
      timestamp: entry.timestamp || new Date().toISOString(),
    }) + '\n';

    try {
      fs.appendFileSync(this.logPath, logLine, 'utf-8');
    } catch (error) {
      console.error('Failed to write audit log:', error);
    }
  }

  /**
   * Log a successful operation
   */
  logSuccess(command: string, tier: AutonomyTier, agent: string, approved: boolean, context?: Record<string, unknown>): void {
    this.log({
      timestamp: new Date().toISOString(),
      command,
      tier,
      approved,
      agent,
      outcome: 'success',
      context,
    });
  }

  /**
   * Log a blocked operation
   */
  logBlocked(command: string, tier: AutonomyTier, agent: string, reason: string): void {
    this.log({
      timestamp: new Date().toISOString(),
      command,
      tier,
      approved: false,
      agent,
      outcome: 'blocked',
      reason,
    });
  }

  /**
   * Log a denied operation (user rejected approval)
   */
  logDenied(command: string, tier: AutonomyTier, agent: string, reason: string): void {
    this.log({
      timestamp: new Date().toISOString(),
      command,
      tier,
      approved: false,
      agent,
      outcome: 'denied',
      reason,
    });
  }

  /**
   * Log an error
   */
  logError(command: string, tier: AutonomyTier, agent: string, error: string): void {
    this.log({
      timestamp: new Date().toISOString(),
      command,
      tier,
      approved: false,
      agent,
      outcome: 'error',
      error,
    });
  }

  /**
   * Read recent log entries
   */
  readRecent(limit = 50): AuditLogEntry[] {
    if (!fs.existsSync(this.logPath)) {
      return [];
    }

    try {
      const content = fs.readFileSync(this.logPath, 'utf-8');
      const lines = content.trim().split('\n').filter(Boolean);

      // Get last N lines
      const recentLines = lines.slice(-limit);

      return recentLines.map(line => {
        try {
          return JSON.parse(line) as AuditLogEntry;
        } catch {
          return null;
        }
      }).filter((entry): entry is AuditLogEntry => entry !== null);
    } catch (error) {
      console.error('Failed to read audit log:', error);
      return [];
    }
  }

  /**
   * Get statistics from audit log
   */
  getStats(since?: Date): AuditStats {
    const entries = this.readRecent(1000); // Read up to 1000 entries

    const filtered = since
      ? entries.filter(e => new Date(e.timestamp) >= since)
      : entries;

    const stats: AuditStats = {
      total: filtered.length,
      byTier: {
        safe: filtered.filter(e => e.tier === AutonomyTier.SAFE).length,
        impactful: filtered.filter(e => e.tier === AutonomyTier.IMPACTFUL).length,
        blocked: filtered.filter(e => e.tier === AutonomyTier.BLOCKED).length,
      },
      byOutcome: {
        success: filtered.filter(e => e.outcome === 'success').length,
        blocked: filtered.filter(e => e.outcome === 'blocked').length,
        denied: filtered.filter(e => e.outcome === 'denied').length,
        error: filtered.filter(e => e.outcome === 'error').length,
      },
      approvalRate: 0,
      mostCommonCommands: [],
    };

    // Calculate approval rate
    const approvable = filtered.filter(e => e.tier === AutonomyTier.IMPACTFUL);
    if (approvable.length > 0) {
      const approved = approvable.filter(e => e.approved).length;
      stats.approvalRate = (approved / approvable.length) * 100;
    }

    // Find most common commands
    const commandCounts = new Map<string, number>();
    for (const entry of filtered) {
      const cmd = entry.command.split(' ')[0]; // Get base command
      commandCounts.set(cmd, (commandCounts.get(cmd) || 0) + 1);
    }

    stats.mostCommonCommands = Array.from(commandCounts.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([command, count]) => ({ command, count }));

    return stats;
  }

  /**
   * Clear old log entries (keep last N days)
   */
  rotate(keepDays = 30): void {
    if (!fs.existsSync(this.logPath)) {
      return;
    }

    try {
      const entries = this.readRecent(10000); // Read up to 10k entries
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - keepDays);

      const kept = entries.filter(e => new Date(e.timestamp) >= cutoff);

      // Rewrite log file with only kept entries
      const content = kept.map(e => JSON.stringify(e)).join('\n') + '\n';
      fs.writeFileSync(this.logPath, content, 'utf-8');

      console.log(`Audit log rotated: kept ${kept.length} entries from last ${keepDays} days`);
    } catch (error) {
      console.error('Failed to rotate audit log:', error);
    }
  }
}

/**
 * Audit statistics
 */
export interface AuditStats {
  total: number;
  byTier: {
    safe: number;
    impactful: number;
    blocked: number;
  };
  byOutcome: {
    success: number;
    blocked: number;
    denied: number;
    error: number;
  };
  approvalRate: number; // Percentage of impactful operations approved
  mostCommonCommands: Array<{ command: string; count: number }>;
}

/**
 * Singleton instance
 */
export const auditLogger = new AuditLogger();

/**
 * Example usage:
 *
 * ```typescript
 * import { auditLogger } from '.system/git/audit-logger';
 * import { classifyGitCommand } from '.system/git/autonomy-tiers';
 *
 * // Log a successful operation
 * const classification = classifyGitCommand('git status');
 * auditLogger.logSuccess('git status', classification.tier, 'claude-code', false);
 *
 * // Log a blocked operation
 * auditLogger.logBlocked('git push --force', AutonomyTier.BLOCKED, 'claude-code', 'Force push to main blocked');
 *
 * // Get stats
 * const stats = auditLogger.getStats();
 * console.log(`Total operations: ${stats.total}`);
 * console.log(`Approval rate: ${stats.approvalRate}%`);
 *
 * // Read recent entries
 * const recent = auditLogger.readRecent(10);
 * console.log(recent);
 * ```
 */
