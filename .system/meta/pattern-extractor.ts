/**
 * PATTERN EXTRACTOR
 *
 * Scans codebase for patterns, auto-updates validators + MCP servers.
 * Runs on: pre-commit, daily cron, manual trigger
 *
 * Created: 2025-11-08
 * Version: 1.0.0
 */

import * as fs from 'fs';
import * as path from 'path';
import { glob } from 'glob';

export const PATTERN_EXTRACTOR_VERSION = '1.0.0';

/**
 * Pattern types we extract from code
 */
export type PatternType = 'service' | 'coordinator' | 'hook' | 'component' | 'test';

/**
 * Extracted pattern structure
 */
export interface ExtractedPattern {
  name: string;
  type: PatternType;
  file: string;
  requiredImports: string[];
  requiredMethods: string[];
  requiredProps?: string[];
  template: string;
  examples: string[];
  lastSeen: Date;
  usageCount: number;
  description?: string;
}

/**
 * Configuration for pattern extraction
 */
export const EXTRACTION_CONFIG = {
  /**
   * Directories to scan for patterns
   * Note: Paths are relative to project root
   */
  scanDirectories: [
    'packages/core/src/services',
    'packages/core/src/coordinators',
    'packages/core/src/hooks',
    'packages/app/src/components',
  ],

  /**
   * Directories to IGNORE (avoid conflicts with other agents)
   */
  ignorePatterns: [
    '**/tests/**',
    '**/__tests__/**',
    '**/node_modules/**',
    'docs/sprints/**',           // Other agent working here
    'packages/e2e/tests/**',     // Other agent working here
    '**/*.test.ts',
    '**/*.test.tsx',
    '**/*.spec.ts',
  ],

  /**
   * Pattern detection rules
   */
  patterns: {
    service: {
      filePattern: '*Service.ts',
      requiredImports: ['ProtectedSupabaseClient', 'Logger'],
      optionalImports: ['telemetry'],
      description: 'Service pattern: ProtectedSupabaseClient + Logger + Telemetry',
    },
    coordinator: {
      filePattern: '*Coordinator.ts',
      requiredImports: ['Logger'],
      optionalImports: ['ProtectedSupabaseClient'],
      description: 'Coordinator pattern: Multi-service orchestration',
    },
    hook: {
      filePattern: 'use*.ts',
      requiredImports: [],
      optionalImports: ['useState', 'useEffect', 'useCallback'],
      description: 'React hook pattern: SSR safe, error boundaries',
    },
    component: {
      filePattern: '*.tsx',
      requiredImports: ['React'],
      optionalImports: ['memo'],
      description: 'Component pattern: React.memo, design tokens',
    },
    test: {
      filePattern: '*.test.ts',
      requiredImports: ['describe', 'it', 'expect'],
      optionalImports: ['vi', 'mock'],
      description: 'Test pattern: Vitest, hoisted mocks',
    },
  },
} as const;

/**
 * Extract imports from TypeScript file content
 */
export function extractImports(content: string): string[] {
  const imports: string[] = [];
  const importRegex = /import\s+(?:{([^}]+)}|(\w+))\s+from\s+['"]([^'"]+)['"]/g;

  let match;
  while ((match = importRegex.exec(content)) !== null) {
    if (match[1]) {
      // Named imports: import { A, B } from '...'
      const namedImports = match[1].split(',').map(i => i.trim());
      imports.push(...namedImports);
    } else if (match[2]) {
      // Default import: import A from '...'
      imports.push(match[2]);
    }
  }

  return imports;
}

/**
 * Extract class methods from TypeScript file content
 */
export function extractMethods(content: string): string[] {
  const methods: string[] = [];

  // Match: async methodName(...) or methodName(...) {
  const methodRegex = /(?:async\s+)?(\w+)\s*\([^)]*\)\s*(?::\s*[^{]+)?\s*{/g;

  let match;
  while ((match = methodRegex.exec(content)) !== null) {
    const methodName = match[1];
    // Filter out keywords that aren't methods
    if (!['if', 'for', 'while', 'switch', 'catch'].includes(methodName)) {
      methods.push(methodName);
    }
  }

  return methods;
}

/**
 * Determine pattern type from filename
 */
export function determinePatternType(filename: string): PatternType | null {
  if (filename.endsWith('Service.ts')) return 'service';
  if (filename.endsWith('Coordinator.ts')) return 'coordinator';
  if (filename.startsWith('use') && filename.endsWith('.ts')) return 'hook';
  if (filename.endsWith('.tsx')) return 'component';
  if (filename.endsWith('.test.ts') || filename.endsWith('.spec.ts')) return 'test';
  return null;
}

/**
 * Extract pattern from a single file
 */
export async function extractPatternFromFile(
  filePath: string
): Promise<ExtractedPattern | null> {
  const filename = path.basename(filePath);
  const patternType = determinePatternType(filename);

  if (!patternType) {
    return null;
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  const imports = extractImports(content);
  const methods = extractMethods(content);

  const config = EXTRACTION_CONFIG.patterns[patternType];

  // For Phase 0, don't require specific imports - just detect pattern by filename
  // Phase 2 will add strict validation
  // const hasRequiredImports = config.requiredImports.every(required =>
  //   imports.some(imp => imp.includes(required))
  // );
  //
  // if (!hasRequiredImports) {
  //   // File doesn't match pattern requirements
  //   return null;
  // }

  const pattern: ExtractedPattern = {
    name: filename.replace(/\.(ts|tsx)$/, ''),
    type: patternType,
    file: filePath,
    requiredImports: config.requiredImports,  // Expected imports
    requiredMethods: methods,                  // Actual methods found
    template: content,
    examples: [filePath],
    lastSeen: new Date(),
    usageCount: 1,
    description: config.description,
  };

  return pattern;
}

/**
 * Scan directories for patterns
 */
export async function extractPatterns(
  directories: string[] = EXTRACTION_CONFIG.scanDirectories
): Promise<Map<string, ExtractedPattern>> {
  const patterns = new Map<string, ExtractedPattern>();

  for (const dir of directories) {
    // Get all TypeScript files in directory
    const files = await glob(`${dir}/**/*.{ts,tsx}`, {
      ignore: EXTRACTION_CONFIG.ignorePatterns,
      cwd: process.cwd(),
    });

    for (const file of files) {
      const pattern = await extractPatternFromFile(file);

      if (pattern) {
        const key = `${pattern.type}:${pattern.name}`;

        if (patterns.has(key)) {
          // Pattern already exists, increment usage count
          const existing = patterns.get(key)!;
          existing.usageCount++;
          existing.examples.push(file);
          existing.lastSeen = new Date();
        } else {
          // New pattern
          patterns.set(key, pattern);
        }
      }
    }
  }

  return patterns;
}

/**
 * Consolidate similar patterns
 *
 * If multiple files have same pattern type and similar structure,
 * consolidate into single pattern with multiple examples.
 */
export function consolidatePatterns(
  patterns: Map<string, ExtractedPattern>
): Map<PatternType, ExtractedPattern> {
  const consolidated = new Map<PatternType, ExtractedPattern>();

  for (const [key, pattern] of patterns) {
    const type = pattern.type;

    if (!consolidated.has(type)) {
      // First pattern of this type, use as canonical
      consolidated.set(type, pattern);
    } else {
      // Pattern type already exists, merge examples
      const canonical = consolidated.get(type)!;
      canonical.usageCount += pattern.usageCount;
      canonical.examples.push(...pattern.examples);
      canonical.lastSeen = new Date();

      // Keep the most recent template as canonical
      if (pattern.lastSeen > canonical.lastSeen) {
        canonical.template = pattern.template;
      }
    }
  }

  return consolidated;
}

/**
 * Count pattern usage across codebase
 */
export async function countPatternUsage(patternName: string): Promise<number> {
  const allFiles = await glob('packages/**/*.{ts,tsx}', {
    ignore: EXTRACTION_CONFIG.ignorePatterns,
  });

  let count = 0;
  for (const file of allFiles) {
    const filename = path.basename(file);
    if (filename.includes(patternName)) {
      count++;
    }
  }

  return count;
}

/**
 * Generate validator code from extracted patterns
 *
 * This will be used in Phase 2 to auto-generate validators.
 */
export function generateValidatorCode(patterns: Map<PatternType, ExtractedPattern>): string {
  let code = `/**
 * PATTERN VALIDATORS (AUTO-GENERATED)
 *
 * Version: ${PATTERN_EXTRACTOR_VERSION}
 * Generated: ${new Date().toISOString()}
 * Source: Extracted from packages/core/src/
 *
 * DO NOT EDIT MANUALLY
 * Run: npm run sync:validators
 */

import * as fs from 'fs';

`;

  for (const [type, pattern] of patterns) {
    code += `
/**
 * Validate ${type} pattern
 *
 * Required imports: ${pattern.requiredImports.join(', ')}
 * Examples: ${pattern.examples.length} files
 * Last seen: ${pattern.lastSeen.toISOString()}
 */
export function validate${capitalize(type)}Pattern(file: string): void {
  const content = fs.readFileSync(file, 'utf-8');

  // Check required imports
  const requiredImports = ${JSON.stringify(pattern.requiredImports)};
  for (const required of requiredImports) {
    if (!content.includes(required)) {
      throw new Error(\`
        ${capitalize(type)} pattern violation: \${file}

        REQUIRED: ${pattern.description}
        Missing import: \${required}

        See example: ${pattern.examples[0]}
      \`);
    }
  }

  console.log(\`✅ ${capitalize(type)} pattern valid: \${file}\`);
}
`;
  }

  return code;
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
 * import { extractPatterns, consolidatePatterns, generateValidatorCode } from '.system/meta/pattern-extractor';
 *
 * // Extract all patterns from codebase
 * const patterns = await extractPatterns();
 * console.log(`Found ${patterns.size} pattern instances`);
 *
 * // Consolidate by type
 * const consolidated = consolidatePatterns(patterns);
 * console.log(`Consolidated to ${consolidated.size} pattern types`);
 *
 * // Generate validator code
 * const validatorCode = generateValidatorCode(consolidated);
 * fs.writeFileSync('.system/validators/patterns.ts', validatorCode);
 * console.log('✅ Validators updated');
 * ```
 */
