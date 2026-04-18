# Patches for oh-my-openagent

## ⚠️ Important Notice

The files in this directory are **code templates**, not traditional patch files. They cannot be applied with the `patch` command because they require the actual oh-my-openagent (OmO) source files which are not publicly available in a patchable format.

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
