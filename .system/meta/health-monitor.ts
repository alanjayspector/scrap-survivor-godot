/**
 * SYSTEM HEALTH MONITOR
 *
 * Detects drift between system components.
 * Validates that validators, MCP, hooks, and docs stay synchronized.
 *
 * Created: 2025-11-08
 * Version: 1.0.0
 */

import * as fs from 'fs';
import * as path from 'path';
import { glob } from 'glob';
import { SOURCE_OF_TRUTH, DRIFT_THRESHOLDS, getDriftThreshold } from './source-of-truth';
import { extractPatterns, consolidatePatterns, PATTERN_EXTRACTOR_VERSION } from './pattern-extractor';

export const HEALTH_MONITOR_VERSION = '1.0.0';

/**
 * Drift report structure
 */
export interface DriftReport {
  type: 'pattern-mismatch' | 'validator-outdated' | 'mcp-stale' | 'doc-code-divergence' | 'version-mismatch' | 'pattern-unused' | 'validator-runtime';
  severity: 'error' | 'warning' | 'info';
  component: string;
  message: string;
  fix: string;
  details?: Record<string, unknown>;
}

/**
 * Component health status
 */
export interface ComponentHealth {
  name: string;
  version: string;
  lastSync: Date | null;
  status: 'healthy' | 'warning' | 'error';
  drift: DriftReport[];
}

/**
 * Overall system health
 */
export interface SystemHealth {
  timestamp: Date;
  overallStatus: 'healthy' | 'warning' | 'error';
  components: {
    validators: ComponentHealth;
    mcp: ComponentHealth;
    hooks: ComponentHealth;
    docs: ComponentHealth;
  };
  drift: DriftReport[];
  recommendations: string[];
}

/**
 * Check if validators match actual code patterns
 */
export async function checkValidatorDrift(): Promise<DriftReport[]> {
  const drift: DriftReport[] = [];

  try {
    // Extract current patterns from code
    const actualPatterns = await extractPatterns();
    const consolidated = consolidatePatterns(actualPatterns);

    // Check if validator file exists
    const validatorPath = '.system/validators/patterns.ts';
    if (!fs.existsSync(validatorPath)) {
      drift.push({
        type: 'validator-outdated',
        severity: 'warning',
        component: 'validators',
        message: 'Validator file does not exist yet',
        fix: 'Run: npm run sync:validators',
        details: {
          expectedPath: validatorPath,
          patternsFound: consolidated.size,
        },
      });
      return drift;
    }

    // Read validator file
    const validatorContent = fs.readFileSync(validatorPath, 'utf-8');

    // Check each pattern type
    for (const [type, pattern] of consolidated) {
      const validatorFunctionName = `validate${capitalize(type)}Pattern`;

      if (!validatorContent.includes(validatorFunctionName)) {
        drift.push({
          type: 'pattern-mismatch',
          severity: 'error',
          component: 'validators',
          message: `Pattern '${type}' found in code but no validator exists`,
          fix: 'Run: npm run sync:validators',
          details: {
            patternType: type,
            usageCount: pattern.usageCount,
            examples: pattern.examples.slice(0, 3),
          },
        });
      }
    }

    // Check validator version
    const versionMatch = validatorContent.match(/Version:\s*(\d+\.\d+\.\d+)/);
    if (versionMatch) {
      const validatorVersion = versionMatch[1];
      if (validatorVersion !== PATTERN_EXTRACTOR_VERSION) {
        drift.push({
          type: 'version-mismatch',
          severity: 'warning',
          component: 'validators',
          message: `Validator version ${validatorVersion} doesn't match pattern extractor ${PATTERN_EXTRACTOR_VERSION}`,
          fix: 'Run: npm run sync:validators',
        });
      }
    }
  } catch (error) {
    drift.push({
      type: 'validator-outdated',
      severity: 'error',
      component: 'validators',
      message: `Error checking validator drift: ${error instanceof Error ? error.message : String(error)}`,
      fix: 'Check error logs and run: npm run sync:validators',
    });
  }

  return drift;
}

/**
 * Check if MCP servers are stale
 */
export async function checkMCPDrift(): Promise<DriftReport[]> {
  const drift: DriftReport[] = [];

  try {
    // Check MCP directories exist
    const mcpDirs = [
      '.system/mcp/project-structure',
      '.system/mcp/patterns',
    ];

    for (const dir of mcpDirs) {
      if (!fs.existsSync(dir)) {
        drift.push({
          type: 'mcp-stale',
          severity: 'warning',
          component: 'mcp',
          message: `MCP directory ${dir} does not exist yet`,
          fix: 'This is expected during Phase 0. Will be created in Phase 1.',
          details: { expectedDir: dir },
        });
      }
    }

    // Check if MCP pattern server exists
    const mcpPatternPath = '.system/mcp/patterns/server.ts';
    if (fs.existsSync(mcpPatternPath)) {
      const mcpContent = fs.readFileSync(mcpPatternPath, 'utf-8');

      // Check MCP version vs validator version
      const mcpVersionMatch = mcpContent.match(/MCP_VERSION\s*=\s*['"]([^'"]+)['"]/);
      const patternsVersionMatch = mcpContent.match(/PATTERNS_VERSION\s*=\s*['"]([^'"]+)['"]/);

      if (mcpVersionMatch && patternsVersionMatch) {
        const patternsVersion = patternsVersionMatch[1];
        if (patternsVersion !== PATTERN_EXTRACTOR_VERSION) {
          drift.push({
            type: 'mcp-stale',
            severity: 'error',
            component: 'mcp',
            message: `MCP patterns version ${patternsVersion} doesn't match extractor ${PATTERN_EXTRACTOR_VERSION}`,
            fix: 'Run: npm run sync:mcp',
          });
        }
      }

      // Check last modified time
      const stats = fs.statSync(mcpPatternPath);
      const ageMs = Date.now() - stats.mtimeMs;
      const threshold = getDriftThreshold('patterns');

      if (ageMs > threshold.maxAge) {
        drift.push({
          type: 'mcp-stale',
          severity: 'warning',
          component: 'mcp',
          message: `MCP patterns server hasn't been updated in ${Math.floor(ageMs / (1000 * 60 * 60))} hours`,
          fix: 'Run: npm run sync:mcp',
          details: {
            lastModified: stats.mtime,
            ageHours: Math.floor(ageMs / (1000 * 60 * 60)),
          },
        });
      }
    }
  } catch (error) {
    drift.push({
      type: 'mcp-stale',
      severity: 'error',
      component: 'mcp',
      message: `Error checking MCP drift: ${error instanceof Error ? error.message : String(error)}`,
      fix: 'Check error logs and run: npm run sync:mcp',
    });
  }

  return drift;
}

/**
 * Check if docs diverge from code
 */
export async function checkDocDrift(): Promise<DriftReport[]> {
  const drift: DriftReport[] = [];

  try {
    // Phase 4: Check embedded context lessons
    const contextLessonsPath = '.system/context/lessons';
    if (!fs.existsSync(contextLessonsPath)) {
      drift.push({
        type: 'doc-code-divergence',
        severity: 'info',
        component: 'docs',
        message: 'Embedded lessons directory does not exist yet',
        fix: 'This is expected during Phase 0-3. Created in Phase 4.',
      });
    } else {
      // Check for required lesson files
      const requiredLessons = [
        '05-data-model-anti-patterns.ts',
        '38-protectedsupabase-timeouts.ts',
        'index.ts',
        'README.md',
      ];

      for (const lesson of requiredLessons) {
        const lessonPath = path.join(contextLessonsPath, lesson);
        if (!fs.existsSync(lessonPath)) {
          drift.push({
            type: 'doc-code-divergence',
            severity: 'warning',
            component: 'docs',
            message: `Missing embedded lesson: ${lesson}`,
            fix: `Create ${lessonPath} with WHY extracted from docs/lessons-learned/`,
          });
        }
      }
    }

    // Phase 4: Check Data Model MCP server
    const dataModelMCPPath = '.system/mcp/data-model/server.ts';
    if (!fs.existsSync(dataModelMCPPath)) {
      drift.push({
        type: 'doc-code-divergence',
        severity: 'warning',
        component: 'docs',
        message: 'Data Model MCP server does not exist',
        fix: 'Run Phase 4: Create .system/mcp/data-model/server.ts',
      });
    }

    // Check if JSDoc comments exist on CharacterInstance
    const modelsTypePath = 'packages/core/src/types/models.ts';
    if (fs.existsSync(modelsTypePath)) {
      const modelsContent = fs.readFileSync(modelsTypePath, 'utf-8');

      if (!modelsContent.includes('CRITICAL ANTI-PATTERN')) {
        drift.push({
          type: 'doc-code-divergence',
          severity: 'warning',
          component: 'docs',
          message: 'CharacterInstance missing embedded anti-pattern comments',
          fix: 'Add JSDoc to CharacterInstance warning about character.items not existing',
        });
      }
    }

    // Check if docs directory exists
    if (!fs.existsSync('docs')) {
      drift.push({
        type: 'doc-code-divergence',
        severity: 'error',
        component: 'docs',
        message: 'docs/ directory does not exist',
        fix: 'Unexpected error - docs directory should exist',
      });
    }
  } catch (error) {
    drift.push({
      type: 'doc-code-divergence',
      severity: 'error',
      component: 'docs',
      message: `Error checking doc drift: ${error instanceof Error ? error.message : String(error)}`,
      fix: 'Check error logs',
    });
  }

  return drift;
}

/**
 * Check hooks health (Phase 6: Universal Hooks)
 */
export async function checkHookHealth(): Promise<DriftReport[]> {
  const drift: DriftReport[] = [];

  try {
    // Phase 6: Check universal hooks (.system/hooks/)
    const universalHooksPath = '.system/hooks';
    if (!fs.existsSync(universalHooksPath)) {
      drift.push({
        type: 'validator-outdated',
        severity: 'info',
        component: 'hooks',
        message: 'Universal hook interface does not exist yet',
        fix: 'This is expected during Phase 0. Will be created in Phase 6.',
      });
      return drift;
    }

    // Check required universal hook files
    const requiredHooks = [
      'interface.ts', // Protocol definition
      'validate.sh', // Safety validation
      'context-inject.sh', // Context injection
      'check-patterns.sh', // Pattern validation
      'README.md', // Setup documentation
    ];

    for (const hook of requiredHooks) {
      const hookPath = path.join(universalHooksPath, hook);
      if (!fs.existsSync(hookPath)) {
        drift.push({
          type: 'validator-outdated',
          severity: 'warning',
          component: 'hooks',
          message: `Missing universal hook: ${hook}`,
          fix: `Create ${hookPath}`,
        });
      } else {
        // Check if shell scripts are executable
        if (hook.endsWith('.sh')) {
          try {
            const stats = fs.statSync(hookPath);
            const isExecutable = !!(stats.mode & 0o100); // Check owner execute bit

            if (!isExecutable) {
              drift.push({
                type: 'validator-outdated',
                severity: 'warning',
                component: 'hooks',
                message: `Hook ${hook} is not executable`,
                fix: `Run: chmod +x ${hookPath}`,
              });
            }
          } catch (error) {
            // Ignore stat errors
          }
        }
      }
    }

    // Check if .claude/hooks directory exists (Claude Code specific hooks)
    if (!fs.existsSync('.claude/hooks')) {
      drift.push({
        type: 'validator-outdated',
        severity: 'info',
        component: 'hooks',
        message: '.claude/hooks directory does not exist',
        fix: 'This is expected - Claude Code hooks are optional. Universal hooks work without them.',
      });
      return drift;
    }

    // Check key Claude Code hooks exist (if directory present)
    const keyHooks = [
      '.claude/hooks/user-prompt-submit.ts',
      '.claude/hooks/stop.ts',
    ];

    for (const hook of keyHooks) {
      if (!fs.existsSync(hook)) {
        drift.push({
          type: 'validator-outdated',
          severity: 'warning',
          component: 'hooks',
          message: `Key hook ${hook} does not exist`,
          fix: 'This hook should exist based on documentation',
        });
      }
    }

    // Check if stop hook has pattern validation (Phase 2)
    const stopHookPath = '.claude/hooks/stop.ts';
    if (fs.existsSync(stopHookPath)) {
      const stopHookContent = fs.readFileSync(stopHookPath, 'utf-8');
      if (!stopHookContent.includes('runPatternValidation')) {
        drift.push({
          type: 'validator-runtime',
          severity: 'warning',
          component: 'hooks',
          message: 'Stop hook missing pattern validation integration',
          fix: 'Add runPatternValidation() to stop hook (Phase 2)',
        });
      }
    }

    // Check universal hooks (Phase 6)
    const universalHookPath = '.system/hooks/interface.ts';
    if (!fs.existsSync(universalHookPath)) {
      drift.push({
        type: 'validator-outdated',
        severity: 'info',
        component: 'hooks',
        message: 'Universal hook interface does not exist yet',
        fix: 'This is expected during Phase 0. Will be created in Phase 6.',
      });
    }
  } catch (error) {
    drift.push({
      type: 'validator-outdated',
      severity: 'error',
      component: 'hooks',
      message: `Error checking hook health: ${error instanceof Error ? error.message : String(error)}`,
      fix: 'Check error logs',
    });
  }

  return drift;
}

/**
 * Check for stale/unused patterns (Phase 2)
 * Detects pattern files that haven't been modified in 90 days
 */
export async function checkPatternStaleness(): Promise<DriftReport[]> {
  const drift: DriftReport[] = [];

  try {
    // Extract current patterns
    const patterns = await extractPatterns();
    const consolidated = consolidatePatterns(patterns);

    const now = Date.now();
    const NINETY_DAYS = 90 * 24 * 60 * 60 * 1000;

    for (const [type, pattern] of consolidated) {
      // Get last modified time from first example file
      if (pattern.examples.length > 0) {
        const examplePath = pattern.examples[0];
        if (fs.existsSync(examplePath)) {
          const stats = fs.statSync(examplePath);
          const age = now - stats.mtimeMs;

          if (age > NINETY_DAYS) {
            drift.push({
              type: 'pattern-unused',
              severity: 'info',
              component: 'validators',
              message: `Pattern '${type}' hasn't been modified in ${Math.floor(age / (24 * 60 * 60 * 1000))} days`,
              fix: 'Review if pattern is still needed or needs updating',
              details: {
                pattern: type,
                exampleFile: examplePath,
                lastModified: stats.mtime,
                usageCount: pattern.usageCount,
              },
            });
          }
        }
      }

      // Check if pattern has zero usage (no files found)
      if (pattern.usageCount === 0) {
        drift.push({
          type: 'pattern-unused',
          severity: 'warning',
          component: 'validators',
          message: `Pattern '${type}' has zero usage - no files found matching this pattern`,
          fix: 'Remove pattern or check if extraction config is correct',
          details: {
            pattern: type,
            template: pattern.template,
          },
        });
      }
    }
  } catch (error) {
    drift.push({
      type: 'pattern-unused',
      severity: 'error',
      component: 'validators',
      message: `Error checking pattern staleness: ${error instanceof Error ? error.message : String(error)}`,
      fix: 'Check error logs',
    });
  }

  return drift;
}

/**
 * Get component health status
 */
function getComponentHealth(
  name: string,
  version: string,
  lastSync: Date | null,
  drift: DriftReport[]
): ComponentHealth {
  let status: 'healthy' | 'warning' | 'error' = 'healthy';

  if (drift.some(d => d.severity === 'error')) {
    status = 'error';
  } else if (drift.some(d => d.severity === 'warning')) {
    status = 'warning';
  }

  return {
    name,
    version,
    lastSync,
    status,
    drift,
  };
}

/**
 * Check test quality health (Test Quality Standards Integration)
 */
export async function checkTestQualityHealth(): Promise<DriftReport[]> {
  const drift: DriftReport[] = [];

  try {
    // Check if test-validator exists
    const testValidatorPath = '.system/validators/test-validator.ts';
    if (!fs.existsSync(testValidatorPath)) {
      drift.push({
        type: 'validator-outdated',
        severity: 'info',
        component: 'test-quality',
        message: 'Test quality validator does not exist yet',
        fix: 'Test quality standards not yet integrated',
      });
      return drift;
    }

    // Import and run test quality validation
    const { validateAllTests } = await import('../validators/test-validator');
    const summary = await validateAllTests();

    // Report C-grade tests (critical - must be fixed)
    if (summary.cGradeTests.length > 0) {
      drift.push({
        type: 'doc-code-divergence',
        severity: 'error',
        component: 'test-quality',
        message: `${summary.cGradeTests.length} C-grade tests need immediate improvement`,
        fix: 'Review and fix placeholder tests, "would test" comments',
        details: {
          cGradeCount: summary.cGradeTests.length,
          files: summary.cGradeTests.map(t => t.file),
          commonViolations: summary.commonViolations,
        },
      });
    }

    // Report B-grade tests (warning - should be improved)
    if (summary.bGradeTests.length > 0) {
      drift.push({
        type: 'doc-code-divergence',
        severity: 'warning',
        component: 'test-quality',
        message: `${summary.bGradeTests.length} B-grade tests could be improved`,
        fix: 'Review and improve to A+ standards when touching files',
        details: {
          bGradeCount: summary.bGradeTests.length,
        },
      });
    }

    // Info: Report A+ grade percentage
    const aPlusPercentage = (summary.gradeDistribution['A+'] / summary.totalTests) * 100;
    if (aPlusPercentage < 80) {
      drift.push({
        type: 'doc-code-divergence',
        severity: 'info',
        component: 'test-quality',
        message: `Test quality: ${aPlusPercentage.toFixed(1)}% A+ grade (target: 80%+)`,
        fix: 'Gradually improve test quality to A+ standards',
        details: {
          distribution: summary.gradeDistribution,
          totalTests: summary.totalTests,
        },
      });
    }
  } catch (error) {
    drift.push({
      type: 'validator-outdated',
      severity: 'warning',
      component: 'test-quality',
      message: `Error checking test quality: ${error instanceof Error ? error.message : String(error)}`,
      fix: 'Check error logs',
    });
  }

  return drift;
}

/**
 * Run full system health check
 */
export async function checkSystemHealth(): Promise<SystemHealth> {
  console.log('🏥 Running system health check...\n');

  // Check each component (Phase 2: added staleness check, Test Quality Standards: added test quality)
  const [validatorDrift, mcpDrift, docDrift, hookDrift, stalenessDrift, testQualityDrift] = await Promise.all([
    checkValidatorDrift(),
    checkMCPDrift(),
    checkDocDrift(),
    checkHookHealth(),
    checkPatternStaleness(),
    checkTestQualityHealth(),
  ]);

  // Combine all drift reports
  const allDrift = [...validatorDrift, ...mcpDrift, ...docDrift, ...hookDrift, ...stalenessDrift, ...testQualityDrift];

  // Determine overall status
  let overallStatus: 'healthy' | 'warning' | 'error' = 'healthy';
  if (allDrift.some(d => d.severity === 'error')) {
    overallStatus = 'error';
  } else if (allDrift.some(d => d.severity === 'warning')) {
    overallStatus = 'warning';
  }

  // Generate recommendations
  const recommendations: string[] = [];

  if (validatorDrift.some(d => d.type === 'pattern-mismatch')) {
    recommendations.push('New patterns detected - run: npm run sync:validators');
  }

  if (mcpDrift.some(d => d.type === 'mcp-stale')) {
    recommendations.push('MCP servers out of date - run: npm run sync:mcp');
  }

  if (stalenessDrift.some(d => d.type === 'pattern-unused')) {
    recommendations.push('Unused patterns detected - review pattern catalog');
  }

  if (hookDrift.some(d => d.type === 'validator-runtime')) {
    recommendations.push('Runtime validators need integration - check stop hook');
  }

  if (allDrift.some(d => d.severity === 'error')) {
    recommendations.push('Errors detected - run: npm run sync:all');
  }

  // Build health report
  const health: SystemHealth = {
    timestamp: new Date(),
    overallStatus,
    components: {
      validators: getComponentHealth('validators', PATTERN_EXTRACTOR_VERSION, null, validatorDrift),
      mcp: getComponentHealth('mcp', '0.1.0', null, mcpDrift),
      hooks: getComponentHealth('hooks', '1.0.0', null, hookDrift),
      docs: getComponentHealth('docs', '1.0.0', null, docDrift),
    },
    drift: allDrift,
    recommendations,
  };

  return health;
}

/**
 * Print health report to console
 */
export function printHealthReport(health: SystemHealth): void {
  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║        SYSTEM ENFORCEMENT LAYER - HEALTH STATUS          ║');
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  const statusSymbol = {
    healthy: '✅',
    warning: '⚠️',
    error: '❌',
  };

  console.log(`Overall Status: ${statusSymbol[health.overallStatus]} ${health.overallStatus.toUpperCase()}`);
  console.log(`Timestamp: ${health.timestamp.toISOString()}\n`);

  console.log('┌─────────────────────────────────────────────────────────┐');
  console.log('│ COMPONENTS                                              │');
  console.log('├─────────────────────────────────────────────────────────┤');

  for (const [key, component] of Object.entries(health.components)) {
    const symbol = statusSymbol[component.status];
    const driftCount = component.drift.length;
    console.log(`│ ${key.padEnd(12)} v${component.version.padEnd(6)} ${symbol} ${component.status.padEnd(7)} ${driftCount} drift │`);
  }

  console.log('└─────────────────────────────────────────────────────────┘\n');

  if (health.drift.length > 0) {
    console.log('┌─────────────────────────────────────────────────────────┐');
    console.log('│ DRIFT DETECTED                                          │');
    console.log('├─────────────────────────────────────────────────────────┤');

    for (const drift of health.drift) {
      const symbol = drift.severity === 'error' ? '❌' : drift.severity === 'warning' ? '⚠️' : 'ℹ️';
      console.log(`│ ${symbol} [${drift.component}] ${drift.message}`);
      console.log(`│   Fix: ${drift.fix}`);
    }

    console.log('└─────────────────────────────────────────────────────────┘\n');
  }

  if (health.recommendations.length > 0) {
    console.log('┌─────────────────────────────────────────────────────────┐');
    console.log('│ RECOMMENDATIONS                                         │');
    console.log('├─────────────────────────────────────────────────────────┤');

    for (const rec of health.recommendations) {
      console.log(`│ • ${rec}`);
    }

    console.log('└─────────────────────────────────────────────────────────┘\n');
  }

  if (health.overallStatus === 'healthy') {
    console.log('✅ System is healthy - all components in sync\n');
  } else if (health.overallStatus === 'warning') {
    console.log('⚠️  System has warnings - recommend running sync commands\n');
  } else {
    console.log('❌ System has errors - run: npm run sync:all\n');
  }
}

/**
 * Helper: Capitalize first letter
 */
function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Example usage:
 *
 * ```typescript
 * import { checkSystemHealth, printHealthReport } from '.system/meta/health-monitor';
 *
 * // Run health check
 * const health = await checkSystemHealth();
 *
 * // Print report
 * printHealthReport(health);
 *
 * // Exit with error code if unhealthy
 * if (health.overallStatus === 'error') {
 *   process.exit(1);
 * }
 * ```
 */
