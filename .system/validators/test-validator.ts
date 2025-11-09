/**
 * Test Quality Validator
 *
 * Validates test files against A+ quality standards
 *
 * WHY: Batch validation of all test files for quality assurance
 *
 * USAGE:
 * ```typescript
 * import { validateAllTests, validateTestFile } from '.system/validators/test-validator';
 *
 * const results = await validateAllTests();
 * console.log(`Found ${results.cGradeTests.length} C-grade tests`);
 * ```
 */

import * as fs from 'fs';
import * as path from 'path';
import { glob } from 'glob';
import {
  validateTestQuality,
  type TestQualityGrade,
  type TestAntiPattern,
} from '../context/lessons/06-test-quality-standards';

/**
 * Test validation result for a single file
 */
export interface TestValidationResult {
  file: string;
  grade: TestQualityGrade;
  violations: Array<{ pattern: TestAntiPattern; message: string }>;
  suggestions: string[];
  lineCount: number;
  hasDescribe: boolean;
  hasTests: boolean;
}

/**
 * Summary of all test validation results
 */
export interface TestValidationSummary {
  totalTests: number;
  gradeDistribution: Record<TestQualityGrade, number>;
  cGradeTests: TestValidationResult[];
  bGradeTests: TestValidationResult[];
  aGradeTests: TestValidationResult[];
  aPlusGradeTests: TestValidationResult[];
  commonViolations: Record<string, number>;
}

/**
 * Validate a single test file
 *
 * @param filePath - Path to test file
 * @returns Validation result
 */
export function validateTestFile(filePath: string): TestValidationResult {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');

  // Use the embedded lesson validator
  const qualityResult = validateTestQuality(content);

  // Additional metadata
  const hasDescribe = content.includes('describe(');
  const hasTests = /it\(|test\(/i.test(content);

  return {
    file: filePath,
    grade: qualityResult.grade,
    violations: qualityResult.violations,
    suggestions: qualityResult.suggestions,
    lineCount: lines.length,
    hasDescribe,
    hasTests,
  };
}

/**
 * Validate all test files in the project
 *
 * @param options - Validation options
 * @returns Validation summary
 */
export async function validateAllTests(options?: {
  pattern?: string;
  exclude?: string[];
}): Promise<TestValidationSummary> {
  const pattern = options?.pattern || '**/*.test.{ts,tsx}';
  const exclude = options?.exclude || ['**/node_modules/**', '**/dist/**', '**/.system/**'];

  // Find all test files
  const testFiles = await glob(pattern, {
    ignore: exclude,
    absolute: true,
  });

  // Validate each file
  const results = testFiles.map((file) => validateTestFile(file));

  // Calculate grade distribution
  const gradeDistribution: Record<TestQualityGrade, number> = {
    'A+': 0,
    A: 0,
    B: 0,
    C: 0,
  };

  const cGradeTests: TestValidationResult[] = [];
  const bGradeTests: TestValidationResult[] = [];
  const aGradeTests: TestValidationResult[] = [];
  const aPlusGradeTests: TestValidationResult[] = [];

  results.forEach((result) => {
    gradeDistribution[result.grade]++;

    switch (result.grade) {
      case 'C':
        cGradeTests.push(result);
        break;
      case 'B':
        bGradeTests.push(result);
        break;
      case 'A':
        aGradeTests.push(result);
        break;
      case 'A+':
        aPlusGradeTests.push(result);
        break;
    }
  });

  // Calculate common violations
  const commonViolations: Record<string, number> = {};
  results.forEach((result) => {
    result.violations.forEach((violation) => {
      const key = violation.pattern;
      commonViolations[key] = (commonViolations[key] || 0) + 1;
    });
  });

  return {
    totalTests: results.length,
    gradeDistribution,
    cGradeTests,
    bGradeTests,
    aGradeTests,
    aPlusGradeTests,
    commonViolations,
  };
}

/**
 * Generate a report of test quality issues
 *
 * @param summary - Validation summary
 * @returns Formatted report string
 */
export function generateTestQualityReport(summary: TestValidationSummary): string {
  let report = '# Test Quality Report\n\n';

  report += `## Summary\n\n`;
  report += `- Total test files: ${summary.totalTests}\n`;
  report += `- A+ grade: ${summary.gradeDistribution['A+']} (${((summary.gradeDistribution['A+'] / summary.totalTests) * 100).toFixed(1)}%)\n`;
  report += `- A grade: ${summary.gradeDistribution.A} (${((summary.gradeDistribution.A / summary.totalTests) * 100).toFixed(1)}%)\n`;
  report += `- B grade: ${summary.gradeDistribution.B} (${((summary.gradeDistribution.B / summary.totalTests) * 100).toFixed(1)}%)\n`;
  report += `- C grade: ${summary.gradeDistribution.C} (${((summary.gradeDistribution.C / summary.totalTests) * 100).toFixed(1)}%)\n\n`;

  if (Object.keys(summary.commonViolations).length > 0) {
    report += `## Common Violations\n\n`;
    const sortedViolations = Object.entries(summary.commonViolations).sort((a, b) => b[1] - a[1]);
    sortedViolations.forEach(([pattern, count]) => {
      report += `- ${pattern}: ${count} files\n`;
    });
    report += '\n';
  }

  if (summary.cGradeTests.length > 0) {
    report += `## C-Grade Tests (Need Immediate Improvement)\n\n`;
    summary.cGradeTests.forEach((test) => {
      report += `### ${test.file}\n\n`;
      test.violations.forEach((violation) => {
        report += `- ${violation.message}\n`;
      });
      test.suggestions.forEach((suggestion) => {
        report += `  - Fix: ${suggestion}\n`;
      });
      report += '\n';
    });
  }

  if (summary.bGradeTests.length > 0) {
    report += `## B-Grade Tests (Could Be Improved)\n\n`;
    summary.bGradeTests.forEach((test) => {
      report += `- ${test.file}\n`;
      test.violations.forEach((violation) => {
        report += `  - ${violation.message}\n`;
      });
    });
    report += '\n';
  }

  return report;
}

/**
 * Get test files that need improvement (C and B grades)
 *
 * @returns Array of file paths
 */
export async function getTestsNeedingImprovement(): Promise<string[]> {
  const summary = await validateAllTests();
  const needsImprovement = [...summary.cGradeTests, ...summary.bGradeTests];
  return needsImprovement.map((test) => test.file);
}

/**
 * Export for health monitor integration
 */
export default {
  validateTestFile,
  validateAllTests,
  generateTestQualityReport,
  getTestsNeedingImprovement,
};
