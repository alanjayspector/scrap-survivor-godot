/**
 * PATTERN VALIDATORS (AUTO-GENERATED)
 *
 * Version: 1.0.0
 * Generated: 2025-11-09T02:32:45.747Z
 * Source: Extracted from packages/core/src/
 *
 * DO NOT EDIT MANUALLY
 * Run: npm run sync:validators
 */

import * as fs from 'fs';


/**
 * Validate service pattern
 *
 * Required imports: ProtectedSupabaseClient, Logger
 * Examples: 19 files
 * Last seen: 2025-11-09T02:32:45.747Z
 */
export function validateServicePattern(file: string): void {
  const content = fs.readFileSync(file, 'utf-8');

  // Check required imports
  const requiredImports = ["ProtectedSupabaseClient","Logger"];
  for (const required of requiredImports) {
    if (!content.includes(required)) {
      throw new Error(`
        Service pattern violation: ${file}

        REQUIRED: Service pattern: ProtectedSupabaseClient + Logger + Telemetry
        Missing import: ${required}

        See example: packages/core/src/services/statService.ts
      `);
    }
  }

  console.log(`✅ Service pattern valid: ${file}`);
}

/**
 * Validate coordinator pattern
 *
 * Required imports: Logger
 * Examples: 1 files
 * Last seen: 2025-11-09T02:32:45.742Z
 */
export function validateCoordinatorPattern(file: string): void {
  const content = fs.readFileSync(file, 'utf-8');

  // Check required imports
  const requiredImports = ["Logger"];
  for (const required of requiredImports) {
    if (!content.includes(required)) {
      throw new Error(`
        Coordinator pattern violation: ${file}

        REQUIRED: Coordinator pattern: Multi-service orchestration
        Missing import: ${required}

        See example: packages/core/src/services/RecyclerCoordinator.ts
      `);
    }
  }

  console.log(`✅ Coordinator pattern valid: ${file}`);
}
