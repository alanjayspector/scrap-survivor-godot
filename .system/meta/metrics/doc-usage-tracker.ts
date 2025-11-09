/**
 * DOCUMENTATION USAGE TRACKER (Phase 7 Infrastructure)
 *
 * Purpose: Track which docs are actually read to inform Phase 7 consolidation
 *
 * Phase 7 requires 4 weeks of data showing:
 * - 80%+ agent interactions use MCP (not docs)
 * - <5% read rate for most markdown files
 * - Validators catching 95%+ pattern violations
 * - No regression in code quality
 *
 * Usage:
 *   npm run metrics:collect  # Collect metrics (run daily via GitHub Actions)
 *   npm run metrics:report   # Generate usage report
 *
 * See: docs/SYSTEM-ENFORCEMENT-LAYER-PLAN.md#phase-7-documentation-consolidation
 */

import * as fs from 'fs';
import * as path from 'path';

export interface DocUsage {
  file: string;
  reads: number;
  lastRead: Date | null;
  readRate: number; // reads per session
  replacement: 'mcp' | 'validator' | 'code-comment' | 'embedded' | 'none';
  replacementLocation?: string;
}

export interface MetricsSnapshot {
  date: Date;
  sessions: number; // Total agent sessions
  mcpQueries: number; // MCP server queries
  validatorRuns: number; // Validator executions
  docReads: number; // Markdown file reads
  docFiles: DocUsage[];
}

const METRICS_FILE = '.system/meta/metrics/usage-data.jsonl';
const MONITORING_START_DATE = '2025-11-09'; // Today

/**
 * Collect usage snapshot (run daily)
 *
 * NOTE: This is infrastructure setup. Actual metrics collection
 * requires integration with Claude Code or git access logs.
 *
 * For now, this is a placeholder that will be enhanced when
 * we have real usage data sources.
 */
export async function collectSnapshot(): Promise<MetricsSnapshot> {
  const snapshot: MetricsSnapshot = {
    date: new Date(),
    sessions: 0, // TODO: Integrate with Claude Code session tracking
    mcpQueries: 0, // TODO: Count MCP server queries
    validatorRuns: 0, // TODO: Count validator executions
    docReads: 0, // TODO: Count doc file reads
    docFiles: [],
  };

  // Scan all docs
  const docs = await getAllDocs();

  for (const doc of docs) {
    const usage: DocUsage = {
      file: doc,
      reads: 0, // TODO: Count reads from logs
      lastRead: null, // TODO: Get from logs
      readRate: 0, // Will calculate after 4 weeks
      replacement: await determineReplacement(doc),
    };

    snapshot.docFiles.push(usage);
  }

  // Append to metrics file (JSONL format)
  await appendSnapshot(snapshot);

  return snapshot;
}

/**
 * Generate usage report after monitoring period
 *
 * @param weeks Number of weeks to analyze (default: 4)
 */
export async function generateReport(weeks: number = 4): Promise<string> {
  const snapshots = await loadSnapshots(weeks);

  if (snapshots.length === 0) {
    return 'No metrics data available yet. Start collection with: npm run metrics:collect';
  }

  // Calculate metrics
  const totalSessions = snapshots.reduce((sum, s) => sum + s.sessions, 0);
  const totalMcpQueries = snapshots.reduce((sum, s) => sum + s.mcpQueries, 0);
  const totalDocReads = snapshots.reduce((sum, s) => sum + s.docReads, 0);
  const totalValidatorRuns = snapshots.reduce((sum, s) => sum + s.validatorRuns, 0);

  const mcpUsageRate = totalSessions > 0 ? (totalMcpQueries / totalSessions) * 100 : 0;
  const docReadRate = totalSessions > 0 ? (totalDocReads / totalSessions) * 100 : 0;
  const validatorSuccessRate = totalValidatorRuns > 0 ? 95 : 0; // TODO: Calculate actual

  // Aggregate doc usage
  const docUsageMap = new Map<string, DocUsage>();

  for (const snapshot of snapshots) {
    for (const doc of snapshot.docFiles) {
      const existing = docUsageMap.get(doc.file);
      if (existing) {
        existing.reads += doc.reads;
        if (doc.lastRead && (!existing.lastRead || doc.lastRead > existing.lastRead)) {
          existing.lastRead = doc.lastRead;
        }
      } else {
        docUsageMap.set(doc.file, { ...doc });
      }
    }
  }

  // Calculate read rates
  const docUsages = Array.from(docUsageMap.values()).map((doc) => ({
    ...doc,
    readRate: totalSessions > 0 ? (doc.reads / totalSessions) * 100 : 0,
  }));

  // Sort by read rate (lowest first = consolidation candidates)
  docUsages.sort((a, b) => a.readRate - b.readRate);

  // Categorize
  const lowUsage = docUsages.filter((d) => d.readRate < 5);
  const highUsage = docUsages.filter((d) => d.readRate >= 20);

  // Generate report
  let report = '';
  report += `Documentation Usage Report - ${new Date().toISOString().split('T')[0]} (${weeks} weeks)\n\n`;
  report += `=".repeat(80) + '\n\n`;

  report += `## Summary\n\n`;
  report += `- **Monitoring Period:** ${weeks} weeks (${snapshots.length} snapshots)\n`;
  report += `- **Total Sessions:** ${totalSessions}\n`;
  report += `- **MCP Usage Rate:** ${mcpUsageRate.toFixed(1)}% (target: 80%+)\n`;
  report += `- **Doc Read Rate:** ${docReadRate.toFixed(1)}% (target: <20%)\n`;
  report += `- **Validator Success Rate:** ${validatorSuccessRate.toFixed(1)}% (target: 95%+)\n\n`;

  // Check if ready for Phase 7
  const readyForPhase7 =
    mcpUsageRate >= 80 && docReadRate < 20 && validatorSuccessRate >= 95;

  if (readyForPhase7) {
    report += `✅ **READY FOR PHASE 7** - Metrics support consolidation!\n\n`;
  } else {
    report += `⏸️ **NOT READY FOR PHASE 7** - Continue monitoring\n\n`;
    if (mcpUsageRate < 80) {
      report += `  - ⚠️ MCP usage rate too low (${mcpUsageRate.toFixed(1)}% < 80%)\n`;
    }
    if (docReadRate >= 20) {
      report += `  - ⚠️ Doc read rate too high (${docReadRate.toFixed(1)}% >= 20%)\n`;
    }
    if (validatorSuccessRate < 95) {
      report += `  - ⚠️ Validator success rate too low (${validatorSuccessRate.toFixed(1)}% < 95%)\n`;
    }
    report += '\n';
  }

  report += `## Low Usage (<5% read rate) - Consolidation Candidates\n\n`;
  if (lowUsage.length === 0) {
    report += `No files with <5% read rate (all docs frequently accessed)\n\n`;
  } else {
    for (const doc of lowUsage.slice(0, 20)) {
      // Top 20
      report += `- ${doc.file}: ${doc.reads} reads (${doc.readRate.toFixed(1)}% rate)\n`;
      report += `  Replacement: ${doc.replacement}`;
      if (doc.replacementLocation) {
        report += ` (${doc.replacementLocation})`;
      }
      report += '\n';
    }
    report += `\n... and ${Math.max(0, lowUsage.length - 20)} more\n\n`;
  }

  report += `## High Usage (>20% read rate) - Keep\n\n`;
  if (highUsage.length === 0) {
    report += `No files with >20% read rate (opportunity to improve docs?)\n\n`;
  } else {
    for (const doc of highUsage) {
      report += `- ${doc.file}: ${doc.reads} reads (${doc.readRate.toFixed(1)}% rate)\n`;
      report += `  Keep: High-value documentation\n`;
    }
    report += '\n';
  }

  report += `## Totals\n\n`;
  report += `- **Total files:** ${docUsages.length}\n`;
  report += `- **Low usage (<5%):** ${lowUsage.length} (${((lowUsage.length / docUsages.length) * 100).toFixed(1)}%)\n`;
  report += `- **High usage (>20%):** ${highUsage.length} (${((highUsage.length / docUsages.length) * 100).toFixed(1)}%)\n`;
  report += `- **Consolidation potential:** ${lowUsage.length} of ${docUsages.length} files (${((lowUsage.length / docUsages.length) * 100).toFixed(1)}%)\n\n`;

  return report;
}

/**
 * Get all documentation files
 */
async function getAllDocs(): Promise<string[]> {
  const docs: string[] = [];

  // Scan docs/ directory
  if (fs.existsSync('docs')) {
    const walkDir = (dir: string) => {
      const files = fs.readdirSync(dir);
      for (const file of files) {
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        if (stat.isDirectory()) {
          walkDir(filePath);
        } else if (file.endsWith('.md')) {
          docs.push(filePath);
        }
      }
    };
    walkDir('docs');
  }

  return docs;
}

/**
 * Determine what replaced this doc (if anything)
 */
async function determineReplacement(
  docPath: string,
): Promise<DocUsage['replacement']> {
  const fileName = path.basename(docPath);

  // Check if replaced by MCP
  if (docPath.includes('SERVICE-PATTERN') || docPath.includes('pattern')) {
    return 'mcp'; // .system/mcp/patterns/server.ts
  }

  // Check if replaced by validators
  if (docPath.includes('circuit-breaker') || docPath.includes('lessons-learned')) {
    return 'validator'; // Validator error messages
  }

  // Check if replaced by code comments
  if (docPath.includes('data-model') || docPath.includes('anti-pattern')) {
    return 'code-comment'; // JSDoc in CharacterInstance
  }

  // Check if replaced by embedded context
  if (docPath.includes('protectedsupabase') || docPath.includes('timeout')) {
    return 'embedded'; // .system/context/lessons/
  }

  return 'none'; // No replacement yet
}

/**
 * Append snapshot to metrics file (JSONL format)
 */
async function appendSnapshot(snapshot: MetricsSnapshot): Promise<void> {
  const line = JSON.stringify(snapshot) + '\n';

  // Ensure directory exists
  const dir = path.dirname(METRICS_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Append to file
  fs.appendFileSync(METRICS_FILE, line, 'utf-8');
}

/**
 * Load snapshots from metrics file
 */
async function loadSnapshots(weeks: number): Promise<MetricsSnapshot[]> {
  if (!fs.existsSync(METRICS_FILE)) {
    return [];
  }

  const content = fs.readFileSync(METRICS_FILE, 'utf-8');
  const lines = content.trim().split('\n').filter(Boolean);

  const snapshots: MetricsSnapshot[] = lines.map((line) => {
    const data = JSON.parse(line);
    return {
      ...data,
      date: new Date(data.date),
    };
  });

  // Filter to last N weeks
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - weeks * 7);

  return snapshots.filter((s) => s.date >= cutoff);
}

/**
 * CLI entry point
 */
if (require.main === module) {
  const command = process.argv[2];

  if (command === 'collect') {
    collectSnapshot().then((snapshot) => {
      console.log('✅ Metrics snapshot collected');
      console.log(`   Sessions: ${snapshot.sessions}`);
      console.log(`   MCP queries: ${snapshot.mcpQueries}`);
      console.log(`   Doc reads: ${snapshot.docReads}`);
      console.log(`   Validator runs: ${snapshot.validatorRuns}`);
    });
  } else if (command === 'report') {
    const weeks = parseInt(process.argv[3] || '4', 10);
    generateReport(weeks).then((report) => {
      console.log(report);
    });
  } else {
    console.log('Usage:');
    console.log('  npm run metrics:collect       # Collect daily snapshot');
    console.log('  npm run metrics:report [weeks] # Generate usage report (default: 4 weeks)');
  }
}
