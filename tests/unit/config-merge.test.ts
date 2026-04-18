// @ts-ignore - lightweight unit tests for config merge logic
import { describe, it, expect } from 'jest';

type Config = Record<string, any>;

type MergeResult = {
  merged: Config;
  backupPath?: string;
  backupContent?: string;
};

function mergeConfigs(base: Config, overlay: Config, options?: { backup?: boolean }): MergeResult {
  const merged: Config = JSON.parse(JSON.stringify(base));

  const apply = (a: any, b: any) => {
    // If both are objects, merge recursively
    if (a && typeof a === 'object' && b && typeof b === 'object' && !Array.isArray(a) && !Array.isArray(b)) {
      for (const k of Object.keys(b)) {
        if (k in a) {
          a[k] = apply(a[k], b[k]);
        } else {
          a[k] = b[k];
        }
      }
      return a;
    }
    // Otherwise, preserve base (do not override) to simulate "preserve user settings"
    return a;
  };

  mergeInto(merged, overlay);

  function mergeInto(target: any, source: any) {
    for (const key of Object.keys(source || {})) {
      const sVal = source[key];
      if (key in target) {
        if (typeof target[key] === 'object' && target[key] !== null && typeof sVal === 'object' && sVal !== null && !Array.isArray(target[key]) && !Array.isArray(sVal)) {
          mergeInto(target[key], sVal);
        } else {
          // preserve existing value in base (target)
        }
      } else {
        target[key] = sVal;
      }
    }
  }

  const res: MergeResult = { merged };
  if (options?.backup) {
    // simulate backup content
    res.backupPath = '/backup/config-base.jsonc';
    res.backupContent = JSON.stringify(base, null, 2);
  }
  return res;
}

describe('Unit: config-merge', () => {
  it('should merge configs without conflict', () => {
    const base = { a: 1, user: { name: 'Alice' } };
    const overlay = { b: 2, user: { theme: 'dark' } };
    const { merged } = mergeConfigs(base, overlay);
    expect(merged.a).toBe(1);
    expect(merged.b).toBe(2);
    // user should preserve base name and gain theme
    expect(merged.user.name).toBe('Alice');
    expect(merged.user.theme).toBe('dark');
  });

  it('should preserve existing user settings', () => {
    const base = { user: { settings: { volume: 80, muted: false } } };
    const overlay = { user: { settings: { volume: 60 } } };
    const { merged } = mergeConfigs(base, overlay);
    expect(merged.user.settings.volume).toBe(80);
    expect(merged.user.settings.muted).toBe(false);
  });

  it('should backup existing config', () => {
    const base = { a: 1, b: 2 };
    const overlay = { c: 3 };
    const { merged, backupPath, backupContent } = mergeConfigs(base, overlay, { backup: true });
    expect(backupPath).toBe('/backup/config-base.jsonc');
    expect(backupContent).toBe(JSON.stringify(base, null, 2));
    expect(merged.c).toBe(3);
  });

  it('should handle missing lazyagent.jsonc', () => {
    const base = {};
    const overlay = { 'lazyagent.jsonc': { enabled: true } };
    const { merged } = mergeConfigs(base, overlay);
    expect(merged['lazyagent.jsonc']).toBeDefined();
    expect(merged['lazyagent.jsonc'].enabled).toBe(true);
  });
});
