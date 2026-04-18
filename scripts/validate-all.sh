#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "Starting project-wide validation..."

"$SCRIPTS_DIR/validate-structure.sh" || exit 1

for d in "$ROOT_DIR"/lazyagent/agents/*/; do
  if [[ -d "$d" ]]; then
    "$SCRIPTS_DIR/validate-agent.sh" "$d" || exit 1
  fi
done

echo "All validations passed."
exit 0
