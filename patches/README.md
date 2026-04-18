# Patches for oh-my-openagent

## ⚠️ Important Notice

**These are NOT applicable patches!**

The files in this directory are **code templates/reference only**. They **CANNOT** be applied with `patch -p0` or any patch tool because:

1. **Target files don't exist here** - They reference OmO core files (`src/plugin-handlers/agents/index.ts`, etc.) that are in the oh-my-openagent repository, not this one
2. **Wrong repository** - These patches must be applied to OmO's source code, not oh-my-lazyagent
3. **Not for end users** - They are provided for reference only, for developers who want to fork and modify OmO

### ❌ Don't try to apply these patches here

```bash
# This will FAIL - files don't exist here
patch -p0 < agent-registry.patch
# Error: can't find file to patch at input line 3
```

### ✅ Use setup-omo instead

For end users, use the configuration-based approach:

## 🎯 Purpose

These templates show what modifications would be needed to integrate oh-my-lazyagent directly into OmO's source code. They are provided for:
- Reference
- Manual implementation
- Future development

## 📁 Files

- `agent-registry.patch` - Shows how to add lazyagent agent discovery to OmO
- `sisyphus-escalation.patch` - Shows how to add escalation logic to Sisyphus
- `hook-extension.patch` - Shows how to load custom hooks from lazyagent

## ✅ Recommended Approach

Instead of patching OmO's source code, use the **configuration-based setup**:

```bash
# Configure OmO to use lazyagent agents
setup-omo

# Or manually edit ~/.config/opencode/oh-my-openagent.json
# and add big-brother agent configuration
```

## 🔧 Alternative: Manual Configuration

If you need to modify OmO's behavior, you can:

1. **Fork oh-my-openagent** from https://github.com/code-yeongyu/oh-my-openagent
2. **Apply changes** shown in the patch templates manually
3. **Build and install** your modified version
4. **Configure OpenCode** to use your fork

## 📚 See Also

- `scripts/setup-omo.sh` - Automated configuration script
- `docs/BIG_BROTHER_USAGE.md` - Usage documentation
