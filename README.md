# oh-my-lazyagent

> Community-driven agent distribution for [oh-my-openagent](https://github.com/oh-my-openagent/om-o)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/oh-my-lazyagent/oh-my-lazyagent)
[![Contributors](https://img.shields.io/badge/contributors-welcome-green.svg)](CONTRIBUTING.md)

## Overview

oh-my-lazyagent is a community-driven distribution platform that extends [oh-my-openagent (OmO)](https://github.com/oh-my-openagent/om-o) with a lazy-loading extensibility layer. It provides a curated marketplace of agents, skills, hooks, and prompts that can be easily installed and managed.

### Key Features

- **Lazy Loading**: Agents and skills load on-demand, keeping your environment lean
- **Community Driven**: Open contribution model for agents, skills, and prompts
- **Extensible Hooks**: Customize agent behavior with pre/post execution hooks
- **Registry System**: Auto-generated index of all available extensions
- **Zero Dependencies**: Core remains lightweight, extensions are optional

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/oh-my-lazyagent/oh-my-lazyagent/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/oh-my-lazyagent/oh-my-lazyagent.git
cd oh-my-lazyagent
./install.sh
```

## Quick Start

1. **List Available Agents**

   ```bash
   ls lazyagent/agents/
   ```

2. **Enable an Agent**

   Copy the agent directory to your om-o agents directory or link it.

3. **Use Big-Brother Agent**

   ```bash
   om-o agent big-brother --context "your task here"
   ```

## Available Agents

### Big-Brother

A surveillance agent that monitors system resources, tracks process changes, and provides real-time system insights.

**Location**: `lazyagent/agents/big-brother/`

**Capabilities**:
- System resource monitoring
- Process tracking
- Real-time alerts
- Log analysis

## Architecture

```
oh-my-lazyagent/
├── lazyagent/           # Extension root
│   ├── agents/          # Agent definitions
│   ├── skills/          # Skill modules
│   ├── hooks/           # Execution hooks
│   └── prompts/         # Prompt templates
├── scripts/             # Utility scripts
├── registry.json        # Auto-generated extension index
└── README.md
```

### Components

- **Agents**: Standalone agent implementations with their own prompts and logic
- **Skills**: Reusable capability modules that agents can utilize
- **Hooks**: Pre/post execution scripts for customization
- **Prompts**: Template prompts used by agents

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Adding an Agent

1. Create a new directory under `lazyagent/agents/your-agent-name/`
2. Add `agent.yaml` with agent metadata
3. Add prompt templates in `prompts/`
4. Update `registry.json` by running `scripts/update-registry.sh`
5. Submit a pull request

### Adding a Skill

1. Create a new directory under `lazyagent/skills/your-skill-name/`
2. Add `skill.yaml` with skill metadata
3. Submit a pull request

## Directory Structure

```
.
├── lazyagent/
│   ├── agents/          # Agent definitions
│   ├── skills/           # Skill modules
│   ├── hooks/            # Execution hooks
│   ├── prompts/          # Prompt templates
│   └── registry.json     # Extension registry
├── scripts/              # Utility scripts
├── CONTRIBUTING.md       # Contribution guidelines
├── LICENSE               # MIT License
└── README.md             # This file
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [oh-my-openagent (OmO)](https://github.com/oh-my-openagent/om-o)
- [Documentation](https://github.com/oh-my-lazyagent/oh-my-lazyagent/wiki)
- [Issue Tracker](https://github.com/oh-my-lazyagent/oh-my-lazyagent/issues)

## Maintainers

- [Bastien](https://github.com/bastien) - Maintainer

---

**Star us if you find this useful!** ⭐