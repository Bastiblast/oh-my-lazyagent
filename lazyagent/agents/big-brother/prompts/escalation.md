# Escalation Logic Prompt

This prompt defines how Big-Brother analyzes escalation reports and formats its advice. It is invoked when Sisyphus reaches the boulder threshold and requires deep diagnostics, root-cause analysis, and actionable changes.

Definitions:
- EscalationReport: The complete data context that led to escalation, including task description, failure history, error messages, stack traces, modified files, and prior approaches.
- RootCause: A short, validated statement of the underlying cause(s) of repeated failures that can be addressed with concrete changes.
- DebugPlan: A prioritized, stepwise plan to diagnose and fix the escalation, with acceptance criteria and rollback guidance.

Escalation report format (what Sisyphus should send to Big-Brother):
- Task description: A concise statement of the goal and the ASC (Assumptions, Constraints, Scope).
- Failure count and history: Number of failures, dates, and the sequence of events leading up to escalation.
- Error messages and stack traces: Raw logs, with sensitive data redacted where appropriate, and timestamps.
- Modified files during attempts: Absolute file paths with a short summary of changes attempted and their effects.
- Previous approaches tried: A bulleted list of methods attempted, outcomes, and why they failed to resolve the issue.
- Environment context: OS, runtime, versions, and key environment variables if relevant.

Example escalation report structure (structure only):
```
{
  "taskDescription": "Resolve intermittent timeout in data-sync worker",
  "failureHistory": [
    {"timestamp": "2026-04-01T12:34:56Z", "event": "worker timeout"},
    {"timestamp": "2026-04-03T09:20:11Z", "event": "retry limit reached"},
    {"timestamp": "2026-04-05T15:02:33Z", "event": "error observed in logs"}
  ],
  "errors": ["timeout after 30s", "context canceled"],
  "stackTraces": ["at Worker.run (workers.go:220)", "at Schedule.next (schedule.go:88)"],
  "modifiedFiles": [
    {"path": "/home/bastien/oh-my-lazyagent/lazyagent/workers/data_sync.go", "summary": "reworked timeout handling"},
    {"path": "/home/bastien/oh-my-lazyagent/lazyagent/core/context.go", "summary": "improved context cancellation propagation"}
  ],
  "previousApproaches": ["increased timeout to 60s", "added retries with exponential backoff"],
  "environment": {"os": "linux", "goVersion": "go1.20.4", "env": {"DATA_SYNC_ENDPOINT": "https://..."}}
}
```

Escalation analysis instructions for Big-Brother:
- Step 1: Read the escalation report in full. Note any missing context that blocks analysis.
- Step 2: Identify root causes using systematic techniques (e.g., 5 Whys, Ishikawa/Fishbone diagram).
- Step 3: Validate root causes by correlating failure history with code changes and environment.
- Step 4: Draft a DebugPlan with concrete, testable actions and risk assessment.
- Step 5: Propose precise code changes with absolute file paths and, if possible, patch suggestions.
- Step 6: Produce a concise final output summarizing root cause, recommended fixes, and acceptance criteria.

Escalation output should be minimal but precise, enabling rapid handoff to engineers.
