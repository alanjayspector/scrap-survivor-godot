#!/usr/bin/env tsx

/**
 * RUN PATTERN VALIDATION
 *
 * Validates files against extracted patterns.
 * Called by: .claude/hooks/stop.ts, npm run validate:patterns
 *
 * Created: 2025-11-09
 * Version: 1.0.0
 */

import * as fs from 'fs';
import * as path from 'path';

/**
 * Validation result for a single file
 */
export interface ValidationResult {
  file: string;
  valid: boolean;
  warnings: string[];
  errors: string[];
}

/**
 * Determine pattern type from filename
 */
function getPatternType(filename: string): string | null {
  if (filename.endsWith('Service.ts') && !filename.endsWith('.test.ts')) {
    return 'service';
  }
  if (filename.endsWith('Coordinator.ts') && !filename.endsWith('.test.ts')) {
    return 'coordinator';
  }
  if (filename.match(/^use[A-Z].*\.ts$/) && !filename.endsWith('.test.ts')) {
    return 'hook';
  }
  if (filename.endsWith('.tsx') && !filename.match(/\.test\.tsx$/)) {
    return 'component';
  }
  return null;
}

/**
 * Validate service pattern
 */
function validateServicePattern(file: string, content: string): ValidationResult {
  const result: ValidationResult = {
    file,
    valid: true,
    warnings: [],
    errors: [],
  };

  // Check for ProtectedSupabaseClient
  if (content.includes('supabase.from') || content.includes('getSupabase')) {
    if (!content.includes('ProtectedSupabaseClient')) {
      result.errors.push(
        `Service uses database but missing ProtectedSupabaseClient\n` +
        `   WHY: Circuit breaker prevents cascading failures (saved us from 3-hour outage)\n` +
        `   FIX: Use ProtectedSupabaseClient instead of raw Supabase client\n` +
        `   See: packages/core/src/services/BankingService.ts`
      );
      result.valid = false;
    }
  }

  // Check for Logger
  if (!content.includes('Logger') && !content.includes('logger')) {
    result.warnings.push(
      `Service missing Logger\n` +
      `   RECOMMENDED: Add Logger for error handling and debugging\n` +
      `   See: packages/core/src/services/BankingService.ts`
    );
  }

  // Check for telemetry on user-facing operations
  if (content.match(/async\s+\w+\s*\([^)]*\).*{/) && !content.includes('telemetry')) {
    result.warnings.push(
      `Service may be missing telemetry\n` +
      `   RECOMMENDED: Add telemetry for user-facing operations\n` +
      `   WHY: Caught 80% of bugs before user reports`
    );
  }

  // Check for .data access on Supabase (common mistake)
  if (content.match(/supabase\.from.*\.data/) || content.match(/protectedSupabase\..*\.data/)) {
    result.errors.push(
      `CRITICAL: Direct .data access on Supabase client\n` +
      `   NEVER access .data directly\n` +
      `   ALWAYS use .execute() instead\n` +
      `   See Lesson 23: Circuit Breaker`
    );
    result.valid = false;
  }

  return result;
}

/**
 * Validate coordinator pattern
 */
function validateCoordinatorPattern(file: string, content: string): ValidationResult {
  const result: ValidationResult = {
    file,
    valid: true,
    warnings: [],
    errors: [],
  };

  // Check for Logger
  if (!content.includes('Logger') && !content.includes('logger')) {
    result.errors.push(
      `Coordinator missing Logger\n` +
      `   REQUIRED: Coordinators must have Logger for error handling\n` +
      `   See: packages/core/src/coordinators/InventoryCoordinator.ts`
    );
    result.valid = false;
  }

  return result;
}

/**
 * Validate hook pattern
 */
function validateHookPattern(file: string, content: string): ValidationResult {
  const result: ValidationResult = {
    file,
    valid: true,
    warnings: [],
    errors: [],
  };

  // Check for SSR safety (window/document checks)
  if (content.includes('window.') || content.includes('document.')) {
    if (!content.includes('typeof window') && !content.includes('typeof document')) {
      result.warnings.push(
        `Hook uses window/document without SSR safety check\n` +
        `   RECOMMENDED: Check for window/document before use\n` +
        `   Example: if (typeof window !== 'undefined') { ... }`
      );
    }
  }

  return result;
}

/**
 * Validate component pattern
 */
function validateComponentPattern(file: string, content: string): ValidationResult {
  const result: ValidationResult = {
    file,
    valid: true,
    warnings: [],
    errors: [],
  };

  // Check for React.memo
  if (!content.includes('memo')) {
    result.warnings.push(
      `Component not wrapped in React.memo\n` +
      `   RECOMMENDED: Use React.memo() for performance\n` +
      `   Especially important for list items`
    );
  }

  // Check for hardcoded colors/spacing
  if (content.match(/#[0-9a-fA-F]{3,6}|rgb\(|rgba\(/)) {
    result.errors.push(
      `Component has hardcoded colors\n` +
      `   REQUIRED: Use design tokens instead\n` +
      `   WHY: Maintainable theming and consistent design`
    );
    result.valid = false;
  }

  return result;
}

/**
 * Validate a single file
 */
export function validateFile(filePath: string): ValidationResult {
  const filename = path.basename(filePath);
  const patternType = getPatternType(filename);

  if (!patternType) {
    // Not a pattern file, skip validation
    return {
      file: filePath,
      valid: true,
      warnings: [],
      errors: [],
    };
  }

  try {
    const content = fs.readFileSync(filePath, 'utf-8');

    switch (patternType) {
      case 'service':
        return validateServicePattern(filePath, content);
      case 'coordinator':
        return validateCoordinatorPattern(filePath, content);
      case 'hook':
        return validateHookPattern(filePath, content);
      case 'component':
        return validateComponentPattern(filePath, content);
      default:
        return {
          file: filePath,
          valid: true,
          warnings: [],
          errors: [],
        };
    }
  } catch (error) {
    return {
      file: filePath,
      valid: false,
      warnings: [],
      errors: [`Failed to validate: ${error instanceof Error ? error.message : String(error)}`],
    };
  }
}

/**
 * Validate multiple files
 */
export function validateFiles(filePaths: string[]): ValidationResult[] {
  return filePaths.map(validateFile);
}

/**
 * Print validation results
 */
export function printValidationResults(results: ValidationResult[]): void {
  const hasIssues = results.some(r => r.errors.length > 0 || r.warnings.length > 0);

  if (!hasIssues) {
    console.log('✅ All pattern validations passed\n');
    return;
  }

  console.log('📋 PATTERN VALIDATION:\n');

  for (const result of results) {
    if (result.errors.length === 0 && result.warnings.length === 0) {
      continue;
    }

    const filename = path.basename(result.file);
    const patternType = getPatternType(filename);

    if (result.errors.length > 0) {
      console.log(`❌ ${filename} (${patternType} pattern):`);
      result.errors.forEach(err => {
        console.log(`   ${err}\n`);
      });
    }

    if (result.warnings.length > 0) {
      console.log(`⚠️  ${filename} (${patternType} pattern):`);
      result.warnings.forEach(warn => {
        console.log(`   ${warn}\n`);
      });
    }
  }
}

/**
 * Command-line usage
 */
if (import.meta.url === `file://${process.argv[1]}`) {
  const files = process.argv.slice(2);

  if (files.length === 0) {
    console.error('Usage: tsx run-validate-patterns.ts <file1> <file2> ...');
    process.exit(1);
  }

  const results = validateFiles(files);
  printValidationResults(results);

  const hasErrors = results.some(r => r.errors.length > 0);
  process.exit(hasErrors ? 1 : 0);
}
