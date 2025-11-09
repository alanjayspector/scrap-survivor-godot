#!/usr/bin/env tsx

/**
 * RUN SYSTEM HEALTH CHECK
 *
 * Entry point for running system health monitor.
 * Called by: npm run validate:system, pre-commit hook, GitHub Actions
 */

import { checkSystemHealth, printHealthReport } from './health-monitor';

async function main() {
  try {
    const health = await checkSystemHealth();
    printHealthReport(health);

    // Exit with error code if system unhealthy
    if (health.overallStatus === 'error') {
      console.error('\n❌ System health check failed\n');
      process.exit(1);
    }

    console.log('✅ System health check passed\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Health check error:', error);
    process.exit(1);
  }
}

main();
