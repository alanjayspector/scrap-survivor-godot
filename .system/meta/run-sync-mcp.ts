#!/usr/bin/env tsx

/**
 * RUN MCP SYNC
 *
 * Updates MCP servers from extracted patterns.
 * Called by: npm run sync:mcp, sync-all.sh
 */

import * as fs from 'fs';
import { extractPatterns, consolidatePatterns } from './pattern-extractor';

async function main() {
  try {
    console.log('🔌 Syncing MCP servers from patterns...\n');

    // Extract current patterns
    const patterns = await extractPatterns();
    const consolidated = consolidatePatterns(patterns);

    console.log(`Found ${consolidated.size} pattern types\n`);

    // Update patterns MCP server
    const patternsServerPath = '.system/mcp/patterns/server.ts';
    const currentContent = fs.readFileSync(patternsServerPath, 'utf-8');

    // Update usage counts in the file
    let updatedContent = currentContent;

    for (const [type, pattern] of consolidated) {
      // Update usageCount for this pattern type
      const regex = new RegExp(`(${type}:\\s*{[^}]*usageCount:\\s*)(\\d+)`, 's');
      updatedContent = updatedContent.replace(regex, `$1${pattern.usageCount}`);

      // Update examples list
      const examplesStr = JSON.stringify(pattern.examples.slice(0, 3), null, 6);
      const examplesRegex = new RegExp(`(${type}:\\s*{[^}]*examples:\\s*)\\[[^\\]]*\\]`, 's');
      updatedContent = updatedContent.replace(examplesRegex, `$1${examplesStr}`);
    }

    // Update last sync timestamp
    const now = new Date().toISOString();
    updatedContent = updatedContent.replace(
      /export const LAST_SYNC = new Date\('[^']+'\);/,
      `export const LAST_SYNC = new Date('${now}');`
    );

    // Write updated content
    fs.writeFileSync(patternsServerPath, updatedContent);

    console.log(`✅ MCP patterns server updated: ${patternsServerPath}`);
    console.log(`   Last sync: ${now}\n`);

    // Update project structure MCP server
    const structureServerPath = '.system/mcp/project-structure/server.ts';
    let structureContent = fs.readFileSync(structureServerPath, 'utf-8');

    // Update counts for each pattern type
    for (const [type, pattern] of consolidated) {
      const countRegex = new RegExp(`(${type}s?:\\s*{[^}]*count:\\s*)(\\d+)`, 's');
      structureContent = structureContent.replace(countRegex, `$1${pattern.usageCount}`);
    }

    // Update last sync
    structureContent = structureContent.replace(
      /export const LAST_SYNC = new Date\('[^']+'\);/,
      `export const LAST_SYNC = new Date('${now}');`
    );

    fs.writeFileSync(structureServerPath, structureContent);

    console.log(`✅ MCP project structure server updated: ${structureServerPath}`);
    console.log(`   Last sync: ${now}\n`);

    console.log('✅ MCP sync complete\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ MCP sync error:', error);
    process.exit(1);
  }
}

main();
