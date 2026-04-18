# Contributing to Oh My LazyAgent

Welcome! We're glad you're here. This project thrives on community contributions, whether you're fixing a bug, adding a feature, or improving documentation.

## Code of Conduct

This project follows the standard open source code of conduct: be respectful, be constructive, and assume good faith. Harassment and toxic behavior will not be tolerated.

## How to Contribute

### Reporting Bugs

Found something broken? Help us fix it:

1. Check existing issues first to avoid duplicates
2. Use the bug report template when creating an issue
3. Include:
   - What you expected to happen
   - What actually happened
   - Steps to reproduce
   - Your environment (OS, shell, OmO version)
   - Relevant logs or error messages

### Suggesting Features

Have an idea? We'd love to hear it:

1. Open a feature request issue
2. Describe the problem you're solving
3. Explain your proposed solution
4. Note any alternatives you've considered

### Adding New Agents

Agents live in `/home/bastien/oh-my-lazyagent/lazyagent/agents/`. Each agent needs:

- `AGENTS.md` - The agent definition and prompts
- `config.json` - Agent configuration (optional)
- `validate.sh` - Validation script (optional)

Before submitting:

1. Run `./scripts/validate-agent.sh your-agent-name`
2. Ensure your agent follows the naming conventions
3. Test integration with the patch system

### Adding Skills or Hooks

Skills go in `/home/bastien/oh-my-lazyagent/lazyagent/skills/`. Hooks go in `/home/bastien/oh-my-lazyagent/lazyagent/hooks/`.

Each skill needs:
- Clear documentation in the skill file
- Example usage
- Error handling

Each hook needs:
- Proper lifecycle integration
- Documentation of when it triggers
- Cleanup on failure

## Development Setup

1. **Fork the repository** on GitHub

2. **Clone locally**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/oh-my-lazyagent.git
   cd oh-my-lazyagent
   ```

3. **Run validation**:
   ```bash
   ./scripts/validate-all.sh
   ```

4. **Make your changes** and test them

## Pull Request Process

### Branch Naming

Use descriptive prefixes:

- `feature/` - New features or enhancements
- `bugfix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions or improvements

Examples:
```
feature/add-kubernetes-agent
bugfix/fix-hook-cleanup
docs/update-install-guide
```

### Commit Messages

We use conventional commits. Format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting, missing semicolons, etc.
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `test` - Adding tests
- `chore` - Maintenance tasks

Examples:
```
feat(agents): add Big-Brother agent for task tracking

fix(hooks): resolve cleanup issue in escalation hook

docs: update CONTRIBUTING with PR template info
```

### Required Checks

Before submitting your PR:

1. Run `./scripts/validate-all.sh` - all checks must pass
2. Update documentation if needed
3. Add tests for new functionality
4. Ensure your code follows existing style

### PR Description

Include:
- What changed and why
- How to test the changes
- Any breaking changes
- Related issue numbers

## Agent Contribution Template

When adding a new agent, include these files:

### Required Files

```
lazyagent/agents/your-agent/
├── AGENTS.md          # Required: Agent definition
├── config.json        # Optional: Default configuration
└── validate.sh        # Optional: Custom validation
```

### Config Schema

Your `config.json` should follow this structure:

```json
{
  "name": "your-agent",
  "version": "1.0.0",
  "description": "What this agent does",
  "author": "Your Name",
  "requires": [],
  "hooks": {
    "pre-execute": null,
    "post-execute": null
  }
}
```

### Prompt Guidelines

Agent prompts in `AGENTS.md` should:

- Be clear and specific about the agent's role
- Include examples of good output
- Define boundaries (what the agent should NOT do)
- Use the OmO agent format with proper frontmatter

Example structure:
```markdown
---
name: your-agent
description: Brief description
version: 1.0.0
---

# Your Agent Name

## Role

Clear description of what this agent does.

## Guidelines

- Guideline 1
- Guideline 2

## Examples

### Good Output
```
Example here
```

### Bad Output
```
Example here
```
```

## Recognition

Contributors will be:

- Listed in the README contributors section
- Mentioned in release notes for significant contributions
- Given credit in commit messages when co-authoring

## Questions and Support

- **General questions**: Open a discussion on GitHub
- **Bug reports**: Use the issue tracker with the bug template
- **Security issues**: Email security@oh-my-lazyagent.dev (do not open public issues)
- **Real-time chat**: Join our Discord (link in README)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
