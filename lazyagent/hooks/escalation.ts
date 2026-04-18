import { HookContext, BoulderState, EscalationData } from './types';

/**
 * escalationHook
 * Monitors BoulderState for escalation-worthy conditions and triggers
 * an escalation task to Big-Brother when thresholds are exceeded.
 * The hook is intentionally self-contained and can be used by any agent.
 */
export function escalationHook(ctx: HookContext): void {
  // Locate Boulder state from the hook context. Support multiple shapes for flexibility.
  const boulder: BoulderState | undefined = (ctx as any).state?.boulder ?? ctx.state?.boulder ?? ctx.data?.boulder;
  if (!boulder) {
    return; // nothing to do if we have no state to inspect
  }

  // Determine threshold (default to 3 consecutive failures)
  const threshold = (boulder.threshold ?? 3);
  if (boulder.consecutiveFailures < threshold) {
    return; // not enough consecutive failures to escalate yet
  }

  // Build a human-readable escalation report from the Boulder state
  const report: string = buildReport(boulder);

  // Compose escalation payload
  const payload: EscalationData = {
    from: 'Sisyphus',
    to: 'Big-Brother',
    reason: `Three consecutive failures detected by Boulder (threshold=${threshold})`,
    report,
    timestamp: Date.now(),
  };

  // Trigger escalation via the platform's task mechanism if available
  // The environment provides a global `task` function in the OpenCode ecosystem
  // Fallback to no-op if not present
  const globalAny: any = globalThis as any;
  const maybeTask = globalAny.task ?? globalAny.OmO_task ?? null;
  if (typeof maybeTask === 'function') {
    try {
      maybeTask({ category: 'escalation', payload });
    } catch (e) {
      // Avoid throwing in a hook; just log for visibility
      console.info('Escalation hook failed to dispatch task', e);
    }
  } else {
    // Fallback logging for environments without a task runner
    console.info('[Escalation] Detected escalation condition, but no task runner is available.', payload);
  }
}

/**
 * Build a readable escalation report from the Boulder state.
 */
function buildReport(state: BoulderState): string {
  const lines: string[] = [];
  lines.push('Escalation Report: Boulder state');
  lines.push(`Timestamp: ${new Date().toISOString()}`);
  lines.push(`Consecutive Failures: ${state.consecutiveFailures ?? 0}`);
  const recent = state.lastResults?.slice(-6) ?? [];
  if (recent.length > 0) {
    lines.push('Recent results:');
    for (const r of recent) {
      const ts = new Date(r.timestamp).toISOString();
      lines.push(`- ${ts} | ${r.ok ? 'SUCCESS' : 'FAILURE'}${r.message ? ' | ' + r.message : ''}`);
    }
  }
  return lines.join('\n');
}
