#!/usr/bin/env tsx

/**
 * RUN VALIDATOR SYNC
 *
 * Extracts patterns from code and updates validators.
 * Called by: npm run sync:validators, sync-all.sh
 */

import * as fs from 'fs';
import { extractPatterns, consolidatePatterns, generateValidatorCode } from './pattern-extractor';

async function main() {
  try {
    console.log('📝 Extracting patterns from code...\n');

    // Extract all patterns
    const patterns = await extractPatterns();
    console.log(`Found ${patterns.size} pattern instances\n`);

    // Consolidate by type
    const consolidated = consolidatePatterns(patterns);
    console.log(`Consolidated to ${consolidated.size} pattern types:`);

    for (const [type, pattern] of consolidated) {
      console.log(`  - ${type}: ${pattern.usageCount} usages, ${pattern.examples.length} examples`);
    }

    console.log('');

    // Generate validator code
    const validatorCode = generateValidatorCode(consolidated);

    // Write to validators file
    const validatorPath = '.system/validators/patterns.ts';
    fs.writeFileSync(validatorPath, validatorCode);

    console.log(`✅ Validators updated: ${validatorPath}\n`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Validator sync error:', error);
    process.exit(1);
  }
}

main();
