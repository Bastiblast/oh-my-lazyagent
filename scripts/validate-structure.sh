#!/usr/bin/env bash
#
# validate-structure.sh
# Validates the oh-my-lazyagent directory structure
#

set -e

BASE_DIR="/home/bastien/oh-my-lazyagent"
ERRORS=0

echo "Validating oh-my-lazyagent structure..."

# Check required directories
REQUIRED_DIRS=(
    "lazyagent/agents"
    "lazyagent/skills"
    "lazyagent/hooks"
    "lazyagent/prompts"
    "scripts"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$BASE_DIR/$dir" ]; then
        echo "✓ $dir exists"
    else
        echo "✗ $dir missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check .gitkeep files
GITKEEPS=(
    "lazyagent/agents/.gitkeep"
    "lazyagent/skills/.gitkeep"
    "lazyagent/hooks/.gitkeep"
    "lazyagent/prompts/.gitkeep"
)

for gk in "${GITKEEPS[@]}"; do
    if [ -f "$BASE_DIR/$gk" ]; then
        echo "✓ $gk exists"
    else
        echo "✗ $gk missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check registry.json is valid JSON
if [ -f "$BASE_DIR/lazyagent/registry.json" ]; then
    if command -v python3 &> /dev/null; then
        if python3 -c "import json; json.load(open('$BASE_DIR/lazyagent/registry.json'))" 2>/dev/null; then
            echo "✓ lazyagent/registry.json is valid JSON"
        else
            echo "✗ lazyagent/registry.json is invalid JSON"
            ERRORS=$((ERRORS + 1))
        fi
    elif command -v node &> /dev/null; then
        if node -e "JSON.parse(require('fs').readFileSync('$BASE_DIR/lazyagent/registry.json'))" 2>/dev/null; then
            echo "✓ lazyagent/registry.json is valid JSON"
        else
            echo "✗ lazyagent/registry.json is invalid JSON"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "! Cannot validate JSON (no python3 or node available)"
    fi
else
    echo "✗ lazyagent/registry.json missing"
    ERRORS=$((ERRORS + 1))
fi

# Check README.md exists
if [ -f "$BASE_DIR/README.md" ]; then
    echo "✓ README.md exists"
else
    echo "✗ README.md missing"
    ERRORS=$((ERRORS + 1))
fi

# Check .gitignore exists
if [ -f "$BASE_DIR/.gitignore" ]; then
    echo "✓ .gitignore exists"
else
    echo "✗ .gitignore missing"
    ERRORS=$((ERRORS + 1))
fi

# Check scripts directory
if [ -d "$BASE_DIR/scripts" ]; then
    echo "✓ scripts/ directory exists"
else
    echo "✗ scripts/ directory missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✓ Structure valid"
    exit 0
else
    echo "✗ Structure invalid: $ERRORS error(s) found"
    exit 1
fi