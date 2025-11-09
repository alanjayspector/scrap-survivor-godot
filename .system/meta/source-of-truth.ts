/**
 * SOURCE OF TRUTH HIERARCHY
 *
 * Defines what syncs to what to prevent circular dependencies.
 * When components diverge, this hierarchy determines priority.
 *
 * Created: 2025-11-08
 * Version: 1.0.0
 */

export const SOURCE_OF_TRUTH_VERSION = '1.0.0';

/**
 * Sync direction: SOURCE → DERIVED
 * Always sync FROM source TO derived, never reverse
 */
export const SOURCE_OF_TRUTH = {
  /**
   * 1. CODE IS KING (highest authority)
   *
   * The actual source code is the ultimate source of truth.
   * All patterns, validators, and MCP servers are extracted FROM code.
   */
  patterns: {
    source: 'packages/core/src/**/*.ts',
    syncsTo: ['.system/validators/patterns.ts', '.system/mcp/patterns/'],
    rule: 'Code patterns extracted via AST analysis → pushed to validators + MCP',
    syncTrigger: 'On commit, daily cron',
    examples: [
      'packages/core/src/services/TierService.ts (source)',
      '  ↓',
      '.system/validators/patterns.ts (validates service pattern)',
      '  ↓',
      '.system/mcp/patterns/server.ts (serves template)',
    ],
  },

  /**
   * 2. TYPES ARE AUTHORITATIVE
   *
   * TypeScript type definitions define the data model.
   * Documentation is generated FROM types, not vice versa.
   */
  dataModel: {
    source: 'packages/core/src/types/**/*.ts',
    syncsTo: [
      '.system/context/data-model/',
      'docs/core-architecture/DATA-MODEL.md',
    ],
    rule: 'Type definitions extracted → embedded docs + markdown sync from types',
    syncTrigger: 'On commit, daily cron',
    examples: [
      'packages/core/src/types/Character.ts (source)',
      '  ↓',
      '.system/context/data-model/Character.md (extracted comments)',
      '  ↓',
      'docs/core-architecture/DATA-MODEL.md (generated from types)',
    ],
  },

  /**
   * 3. VALIDATORS DERIVE FROM CODE
   *
   * Validators are auto-generated from actual code patterns.
   * MCP servers serve validator rules at runtime.
   */
  validators: {
    source: 'packages/core/src/**/*.ts (via pattern extraction)',
    syncsTo: ['.system/mcp/patterns/', '.system/mcp/project-structure/'],
    rule: 'Validators generated from code patterns → MCP serves them',
    syncTrigger: 'After pattern extraction, daily cron',
    examples: [
      'Pattern extractor scans packages/core/src/',
      '  ↓',
      '.system/validators/patterns.ts (generated validators)',
      '  ↓',
      '.system/mcp/patterns/server.ts (serves validation rules)',
    ],
  },

  /**
   * 4. DOCS ARE REFERENCE ONLY
   *
   * Documentation is generated from code + types.
   * External markdown docs are lowest priority.
   */
  documentation: {
    source: 'DERIVED from code + types + validators',
    syncsTo: ['docs/', '.system/docs/'],
    rule: 'Documentation generated from code, not written manually',
    syncTrigger: 'After code/types change, daily cron',
    examples: [
      'Code + types (source)',
      '  ↓',
      '.system/docs/ (consolidated, auto-generated)',
      '  ↓',
      'docs/ (archive, reference only)',
    ],
  },
} as const;

/**
 * Sync Rules
 *
 * These rules govern how synchronization happens.
 */
export const SYNC_RULES = {
  /**
   * Rule 1: Never reverse sync
   *
   * If docs diverge from code, code wins.
   * Exception: Manual override with explicit approval.
   */
  reverseSync: 'deny' as const,

  /**
   * Rule 2: Version locking
   *
   * All derived components must lock to source version.
   * Version mismatch = drift detected.
   */
  versionLocking: 'required' as const,

  /**
   * Rule 3: Fail on drift
   *
   * If source and derived diverge beyond threshold, fail build.
   * Forces manual resolution.
   */
  driftTolerance: 'zero' as const,

  /**
   * Rule 4: Auto-sync on commit
   *
   * Pre-commit hook triggers sync if needed.
   * Blocks commit if sync fails.
   */
  autoSync: 'on-commit' as const,
} as const;

/**
 * Sync Priority
 *
 * When multiple sync operations needed, order matters.
 */
export const SYNC_PRIORITY = [
  'patterns',     // 1. Extract patterns from code first
  'dataModel',    // 2. Then extract data model from types
  'validators',   // 3. Then generate validators from patterns
  'documentation', // 4. Finally generate docs from everything
] as const;

/**
 * Drift Detection
 *
 * What constitutes "drift" between source and derived.
 */
export interface DriftThresholds {
  patterns: {
    maxAge: number;           // Max milliseconds since last sync
    maxDivergence: number;    // Max number of patterns that differ
  };
  dataModel: {
    maxAge: number;
    maxDivergence: number;
  };
  validators: {
    maxAge: number;
    maxDivergence: number;
  };
  documentation: {
    maxAge: number;
    maxDivergence: number;
  };
}

export const DRIFT_THRESHOLDS: DriftThresholds = {
  patterns: {
    maxAge: 24 * 60 * 60 * 1000,  // 24 hours
    maxDivergence: 0,              // Zero tolerance - must be exact
  },
  dataModel: {
    maxAge: 24 * 60 * 60 * 1000,  // 24 hours
    maxDivergence: 0,              // Zero tolerance
  },
  validators: {
    maxAge: 1 * 60 * 60 * 1000,   // 1 hour (stricter - these run frequently)
    maxDivergence: 0,              // Zero tolerance
  },
  documentation: {
    maxAge: 7 * 24 * 60 * 60 * 1000,  // 7 days (more lenient)
    maxDivergence: 5,                  // Allow minor divergence
  },
};

/**
 * Helper: Get sync direction for a component
 */
export function getSyncDirection(component: keyof typeof SOURCE_OF_TRUTH) {
  return SOURCE_OF_TRUTH[component];
}

/**
 * Helper: Get sync priority order
 */
export function getSyncOrder() {
  return SYNC_PRIORITY;
}

/**
 * Helper: Check if reverse sync allowed
 */
export function isReverseSyncAllowed() {
  return SYNC_RULES.reverseSync === 'allow';
}

/**
 * Helper: Get drift threshold for component
 */
export function getDriftThreshold(component: keyof DriftThresholds) {
  return DRIFT_THRESHOLDS[component];
}

/**
 * Example usage:
 *
 * ```typescript
 * import { SOURCE_OF_TRUTH, getSyncDirection } from '.system/meta/source-of-truth';
 *
 * // Get sync direction for patterns
 * const patternsSync = getSyncDirection('patterns');
 * console.log(patternsSync.source); // 'packages/core/src/**\/*.ts'
 * console.log(patternsSync.syncsTo); // ['.system/validators/patterns.ts', ...]
 *
 * // Check if reverse sync allowed
 * if (isReverseSyncAllowed()) {
 *   // Sync docs → code (not allowed by default)
 * }
 * ```
 */
