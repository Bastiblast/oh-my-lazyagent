#!/usr/bin/env bash
set -euo pipefail

# Big-Brother Agent Runner
# Usage: big-brother <task-description> or via stdin

LAZY_DIR="${HOME}/.config/opencode/lazyagent"
BIG_BROTHER_DIR="$LAZY_DIR/lazyagent/agents/big-brother"

if [[ ! -d "$BIG_BROTHER_DIR" ]]; then
    echo "❌ Big-Brother not found at $BIG_BROTHER_DIR" >&2
    echo "   Run: lazyagent install" >&2
    exit 1
fi

# Read task from argument or stdin
TASK="${1:-}"
if [[ -z "$TASK" ]]; then
    if [[ -t 0 ]]; then
        echo "Usage: big-brother <task-description>" >&2
        echo "   or: echo 'task' | big-brother" >&2
        exit 1
    else
        TASK=$(cat)
    fi
fi

# Build escalation report
REPORT=$(cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "task_description": "$TASK",
  "failure_count": 3,
  "error_history": [
    "Previous attempts failed",
    "Manual intervention required"
  ],
  "files_modified": [],
  "previous_approaches": [
    "Standard troubleshooting"
  ],
  "request_type": "user_direct"
}
EOF
)

echo "🧠 Big-Brother Agent (Escalation Mode)"
echo "=========================================="
echo ""
echo "Task: $TASK"
echo ""
echo "--- Big-Brother Analysis ---"
echo ""

# For now, display the agent's capability
# In a full implementation, this would call the agent via opencode
cat "$BIG_BROTHER_DIR/agent.md" | grep -A 50 "System role:"
