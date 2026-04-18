#!/usr/bin/env bash
set -euo pipefail

# oh-my-lazyagent Setup for oh-my-openagent
# This script configures OmO to use lazyagent agents

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

print_green() { printf "${GREEN}%s${NC}\n" "$1"; }
print_yellow() { printf "${YELLOW}%s${NC}\n" "$1"; }
print_red() { printf "${RED}%s${NC}\n" "$1"; }

GLOBAL_LAZY_DIR="${HOME}/.config/opencode/lazyagent"
OMO_CONFIG="${HOME}/.config/opencode/oh-my-openagent.json"

echo "=========================================="
echo "oh-my-lazyagent Setup for OmO"
echo "=========================================="
echo ""

# Check prerequisites
if [[ ! -d "$GLOBAL_LAZY_DIR" ]]; then
    print_red "❌ oh-my-lazyagent not installed"
    echo "   Run: curl -fsSL .../install.sh | bash"
    exit 1
fi

if [[ ! -f "$OMO_CONFIG" ]]; then
    print_red "❌ oh-my-openagent not configured"
    echo "   OmO config not found at $OMO_CONFIG"
    exit 1
fi

echo "✓ oh-my-lazyagent found: $GLOBAL_LAZY_DIR"
echo "✓ OmO config found: $OMO_CONFIG"
echo ""

# Check if jq is available
if ! command -v jq &> /dev/null; then
    print_red "❌ jq is required but not installed"
    echo "   Install: apt-get install jq  (or equivalent)"
    exit 1
fi

# Backup original config
echo "Creating backup..."
cp "$OMO_CONFIG" "$OMO_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
print_green "✓ Backup created"
echo ""

# Add big-brother agent to OmO config
echo "Configuring agents..."

# Check if big-brother already exists
if jq -e '.agents["big-brother"]' "$OMO_CONFIG" &>/dev/null; then
    print_yellow "⚠ big-brother already configured"
else
    # Add big-brother agent
    tmp=$(mktemp)
    jq '.agents["big-brother"] = {
        "model": "opencode-go/glm-5",
        "fallback_models": [{"model": "opencode-go/kimi-k2.5"}],
        "category": "escalation",
        "mode": "subagent"
    }' "$OMO_CONFIG" > "$tmp" && mv "$tmp" "$OMO_CONFIG"
    print_green "✓ big-brother agent added"
fi

# Add escalation category if not exists
if jq -e '.categories["escalation"]' "$OMO_CONFIG" &>/dev/null; then
    print_yellow "⚠ escalation category already exists"
else
    tmp=$(mktemp)
    jq '.categories["escalation"] = {
        "model": "opencode-go/glm-5"
    }' "$OMO_CONFIG" > "$tmp" && mv "$tmp" "$OMO_CONFIG"
    print_green "✓ escalation category added"
fi

echo ""
print_green "=========================================="
print_green "Setup complete!"
print_green "=========================================="
echo ""
echo "Configured agents:"
jq '.agents | keys' "$OMO_CONFIG"
echo ""
echo "Configured categories:"
jq '.categories | keys' "$OMO_CONFIG"
echo ""
echo "Next steps:"
echo "1. Restart OpenCode/VS Code"
echo "2. Run: lazyagent init  (in your project)"
echo "3. Big-Brother is now available via task(category='escalation')"
