// @ts-ignore - lightweight patch application logic
import { describe, it, expect } from 'jest';

type Patch = {
  id: string;
  content: string;
};

class PatchEngine {
  private applied: Set<string> = new Set();
  applyPatch(patch: Patch): { applied: boolean; reason?: string } {
    if (this.applied.has(patch.id)) {
      return { applied: false, reason: 'already-applied' };
    }
    // If patch content contains a special marker, simulate conflict
    if (patch.content.includes('CONFLICT')) {
      return { applied: false, reason: 'conflict' };
    }
    this.applied.add(patch.id);
    return { applied: true };
  }
  getApplied(): string[] {
    return Array.from(this.applied);
  }
}

describe('Unit: patch-apply', () => {
  it('should apply patches cleanly', () => {
    const engine = new PatchEngine();
    const p1: Patch = { id: 'patch-001', content: 'add feature A' };
    const p2: Patch = { id: 'patch-002', content: 'fix bug B' };
    expect(engine.applyPatch(p1).applied).toBe(true);
    expect(engine.applyPatch(p2).applied).toBe(true);
    const applied = engine.getApplied();
    expect(applied).toContain('patch-001');
    expect(applied).toContain('patch-002');
  });

  it('should detect already-applied patches', () => {
    const engine = new PatchEngine();
    const p: Patch = { id: 'patch-003', content: 'update config' };
    expect(engine.applyPatch(p).applied).toBe(true);
    // Applying same patch again should indicate already-applied
    const res = engine.applyPatch(p);
    expect(res.applied).toBe(false);
    expect(res.reason).toBe('already-applied');
  });

  it('should fail on patch conflicts', () => {
    const engine = new PatchEngine();
    const conflictPatch: Patch = { id: 'patch-conflict', content: 'THIS WILL CAUSE CONFLICT CONFLICT' };
    const res = engine.applyPatch(conflictPatch);
    expect(res.applied).toBe(false);
    expect(res.reason).toBe('conflict');
  });
});
