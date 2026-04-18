// Shared hook type definitions for OhMyLazyAgent hooks

export interface BoulderResult {
  timestamp: number;
  ok: boolean;
  message?: string;
}

export interface BoulderState {
  // Sequence of recent results from the Boulder (the failing agent) runs
  lastResults: BoulderResult[];
  // Count of consecutive failures at the current point in time
  consecutiveFailures: number;
  // Optional configurable threshold for escalation (default 3)
  threshold?: number;
}

export interface HookContext {
  // Arbitrary context/data carrier for hooks
  state?: {
    boulder?: BoulderState;
    [key: string]: any;
  };
  data?: any;
  [key: string]: any;
}

export interface EscalationData {
  from: string; // sender or initiator, e.g., 'Sisyphus'
  to: string; // recipient, e.g., 'Big-Brother'
  reason: string; // concise escalation reason
  report: string; // human-readable report payload
  timestamp: number; // epoch ms
  escalationId?: string; // optional unique id for the escalation event
}
