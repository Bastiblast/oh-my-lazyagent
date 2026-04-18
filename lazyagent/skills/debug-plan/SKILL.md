---
name: lazyagent/debug-plan
version: 0.1.0
description: OpenCode-style skill for building structured debug plans that can be reused by any agent.
author: OhMyOpenCode - LazyAgent Initiative
tags:
- debugging
- planning
- process
- OpenCode
license: MIT
---

# Debug Plan Skill

This skill teaches agents how to create and execute structured debug plans. A debug plan is a deliberately crafted sequence of steps used to diagnose, reproduce, and fix issues in a predictable, auditable way. The plan is designed to be reusable by any agent in the ecosystem, not just a single role (e.g., Big-Brother).

## Why use a debug plan?
- Reduces ambiguity during debugging by making assumptions explicit.
- Improves reproducibility of issues and fixes.
- Enables easier handoffs between agents and humans by providing a common framework.
- Facilitates verification by outlining concrete test and validation steps.

## Problem analysis (what to analyze when a bug is found)
- Identify the failure mode: what exactly is failing (function, service, API, UI, performance).
- Gather context: inputs, environment, recent changes, and reproduction steps.
- Define acceptance criteria: what would constitute a fix or a successful diagnosis.
- Map dependencies: what components, services, or data sources interact with the problematic area.

## Hypothesis generation (how to think about root causes)
- Form 3–5 testable hypotheses that explain the observed failure.
- For each hypothesis, specify the expected evidence or counter-evidence.
- Prioritize hypotheses by likelihood and impact based on data quality and confinement.
- Document potential mitigations or workarounds if a full root-cause fix is blocked.

## Testing strategy (how to prove or disprove hypotheses)
- Define concrete test cases, expected outcomes, and success criteria.
- Choose a mix of unit, integration, and end-to-end tests as appropriate.
- Plan controlled experiments (reproduce prod-like conditions, toggle features, isolate variables).
- Establish rollback and safety checks if the fix touches critical paths.

## Implementation steps (actionable plan)
- Step 1: Reproduce the issue with verified inputs and environment.
- Step 2: Instrument the code path to collect minimal, relevant telemetry.
- Step 3: Create or adjust tests that cover the hypothesized failure mode.
- Step 4: Implement the fix or diagnosis, keeping changes small and well-scoped.
- Step 5: Run the debug plan: execute tests, collect telemetry, verify outcomes.
- Step 6: Validate that acceptance criteria are met and prepare a concise escalation report if needed.

## Verification criteria (how to know you’re done)
- All defined test cases pass in the intended environment.
- Telemetry confirms the hypothesized behavior or falsifies it.
- No regressions detected in related components.
- A clear, auditable escalation report is produced if a blocker is encountered.

## Reusability and consistency tips
- Use a consistent structure for all debug plans (problem analysis, hypotheses, tests, implementation, verification).
- Keep each debug plan focused and small enough to be executed within a single debugging session.
- Include concrete data points (logs, traces, metrics) rather than vague descriptions.
- Treat the plan as living documentation that evolves with learnings from each debugging effort.

## Example (template)
- Problem: API v1.2 returns 500 on POST /items when payload exceeds 1MB.
- Hypotheses: API validation bug, downstream service timeout, memory pressure.
- Tests: reproduce with payload sizes [0.5MB, 1MB, 1.5MB], monitor traces.
- Implementation: add safe guards, adjust timeout, add payload chunking.
- Verification: 100% of test payloads pass; UIs show meaningful error for large payloads; metrics stable.

---
These instructions provide a reusable, professional framework for debugging across agents. Adapt details to the specific project, but keep the structure consistent to enable rapid handoffs and reproducible results.
