# Oh My LazyAgent Architecture

This document describes the high-level architecture of Oh My LazyAgent, explaining how components interact and why certain design decisions were made.

## Overview

Oh My LazyAgent is a lightweight extension system for OmO (OhMyOpenCode) that adds intelligent task management through agents, skills, and hooks. It uses a patch-based approach to integrate with OmO without requiring core modifications.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface                            │
│              (OmO CLI / IDE Integration)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Oh My LazyAgent Core                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Config    │  │   Patch     │  │   Hook Lifecycle    │  │
│  │   System    │  │   System    │  │   Manager           │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                    │             │
│         └────────────────┼────────────────────┘             │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Agent Orchestration                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │  Sisyphus   │  │   Boulder   │  │ Big-Brother │ │   │
│  │  │  (Executor) │  │  (Planner)  │  │  (Monitor)  │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              OmO Core (Unmodified)                         │
│         ┌─────────────┐         ┌─────────────┐            │
│         │   Agents    │         │   Skills    │            │
│         │   System    │         │   Registry  │            │
│         └─────────────┘         └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## Component Descriptions

### lazyagent/ Directory Structure

```
/home/bastien/oh-my-lazyagent/lazyagent/
├── agents/           # Agent definitions and configurations
│   ├── big-brother/
│   ├── boulder/
│   └── sisyphus/
├── skills/           # Reusable skill modules
│   └── debug-plan/
├── hooks/            # Lifecycle hook implementations
│   ├── pre-execute/
│   └── post-execute/
├── config/           # Configuration schemas and defaults
└── lib/              # Shared utilities and helpers
```

### Patch System

The patch system enables Oh My LazyAgent to extend OmO without modifying its core:

**How it works:**

1. Patches are stored in `/home/bastien/oh-my-lazyagent/patches/`
2. Each patch targets a specific OmO file or behavior
3. Patches are applied during installation via `install.sh`
4. Original files are backed up for uninstallation

**Patch types:**

- **Config patches** - Add lazyagent configuration loading
- **Hook patches** - Inject lifecycle hooks into OmO execution
- **Agent patches** - Register custom agents with OmO

**Example patch flow:**

```
OmO starts → Load config → Apply patches → Register agents → Execute task
                │              │                │
                ▼              ▼                ▼
         Read lazyagent/   Modify OmO      Add Big-Brother,
         config.jsonc      behavior         Boulder, Sisyphus
```

### Config Overlay

Configuration uses a layered approach:

1. **Base config** - `/home/bastien/oh-my-lazyagent/lazyagent/config/default.jsonc`
2. **User config** - `~/.config/oh-my-lazyagent/config.jsonc`
3. **Project config** - `.lazyagent/config.jsonc` (in project root)
4. **Environment variables** - `LAZYAGENT_*` overrides

Later layers override earlier ones. This allows:

- Sensible defaults
- User preferences
- Project-specific settings
- Temporary overrides

### Hook Lifecycle

Hooks intercept OmO execution at key points:

```
┌─────────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐    ┌─────────┐
│  Start  │───▶│  Pre-    │───▶│  OmO    │───▶│  Post-   │───▶│  End    │
│  Task   │    │  Execute │    │  Core   │    │  Execute │    │  Task   │
└─────────┘    └──────────┘    └─────────┘    └──────────┘    └─────────┘
                    │                              │
                    ▼                              ▼
            ┌──────────────┐              ┌──────────────┐
            │ Check for    │              │ Log results  │
            │ escalation   │              │ Update plan  │
            │ Load context │              │ Cleanup      │
            └──────────────┘              └──────────────┘
```

**Pre-execute hooks:**

- Load task context from Big-Brother
- Check for escalation triggers
- Validate prerequisites

**Post-execute hooks:**

- Log execution results
- Update Boulder plan status
- Trigger follow-up actions

## Data Flow

### Sisyphus → Boulder → Escalation → Big-Brother

This is the core task management flow:

```
┌──────────┐     ┌──────────┐     ┌──────────────┐     ┌──────────────┐
│ Sisyphus │────▶│ Boulder  │────▶│  Escalation  │────▶│ Big-Brother  │
│          │     │          │     │    Hooks     │     │              │
│ Execute  │     │  Plan    │     │              │     │   Track &    │
│  Tasks   │     │  Tasks   │     │  Detect      │     │   Monitor    │
│          │     │          │     │  Issues      │     │              │
└──────────┘     └──────────┘     └──────────────┘     └──────────────┘
      │                │                │                    │
      │                │                │                    │
      ▼                ▼                ▼                    ▼
 Run commands    Break down      Detect stuck tasks    Maintain
                 work into       or failures           task history
                 steps                                 and context
```

**Flow explanation:**

1. **Sisyphus** receives a task and begins execution
2. **Boulder** breaks the task into steps and tracks progress
3. **Escalation hooks** monitor for issues (stuck tasks, failures)
4. **Big-Brother** maintains context across sessions and tracks all activity

## Design Decisions

### Why Fork vs Plugin

We chose a patch-based approach over forking OmO:

**Fork approach (rejected):**
- Would require maintaining a separate OmO fork
- Updates to upstream OmO would need manual merging
- Fragmentation of the ecosystem

**Patch approach (chosen):**
- Works with stock OmO installation
- Patches are versioned and reversible
- Can adapt to OmO updates by updating patches
- Users can opt-in to specific features

### Why Minimal Patches

Patches are kept as small as possible:

- **Easier maintenance** - Small patches are easier to update when OmO changes
- **Lower risk** - Minimal changes reduce chance of breaking OmO
- **Clear intent** - Each patch does one thing
- **Debugging** - Easier to identify which patch causes issues

### Why JSONC Over JSON

Configuration uses JSONC (JSON with Comments):

- **Self-documenting** - Comments explain configuration options
- **Familiar syntax** - Still valid JSON for parsers
- **No YAML complexity** - Avoids YAML's edge cases and indentation issues
- **Tooling support** - Most editors support JSONC

## Integration Points with OmO

Oh My LazyAgent integrates with OmO at these points:

| OmO Component | Integration Method | Purpose |
|----------------|-------------------|---------|
| Agent system | Patch registration | Add Sisyphus, Boulder, Big-Brother |
| Skill registry | Config overlay | Add debug-plan skill |
| Config loader | Patch | Load lazyagent configs |
| Task execution | Hook injection | Pre/post execution handling |
| CLI commands | Wrapper scripts | Add lazyagent-specific commands |

## Future Extensibility

The architecture supports these future enhancements:

### Planned Extensions

1. **Additional Agents**
   - Code review agent
   - Documentation agent
   - Testing agent

2. **More Skills**
   - Git advanced operations
   - Database migration helpers
   - API testing utilities

3. **Hook Enhancements**
   - Pre-commit hooks
   - CI/CD integration hooks
   - Notification hooks

4. **Configuration**
   - GUI configuration editor
   - Configuration validation
   - Migration tools

### Extension Points

New components can be added by:

1. **Agents** - Create directory in `lazyagent/agents/`, add AGENTS.md
2. **Skills** - Add to `lazyagent/skills/`, update registry
3. **Hooks** - Implement in `lazyagent/hooks/`, register in config
4. **Patches** - Create in `patches/`, add to install script

The modular design ensures each component can evolve independently while maintaining compatibility with the core system.
