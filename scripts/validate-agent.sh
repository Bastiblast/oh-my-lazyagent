#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

AGENT_DIR="${1:-}"
if [[ -z "$AGENT_DIR" || ! -d "$AGENT_DIR" ]]; then
  echo "ERROR: Agent directory '${AGENT_DIR}' does not exist."
  exit 1
fi

AGENT_MD="$AGENT_DIR/agent.md"
CONFIG_JSON="$AGENT_DIR/config.json"

if [[ ! -f "$AGENT_MD" ]]; then
  echo "ERROR: agent.md is missing in $AGENT_DIR"
  exit 1
fi

if [[ ! -f "$CONFIG_JSON" ]]; then
  echo "ERROR: config.json is missing in $AGENT_DIR"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  if ! jq empty "$CONFIG_JSON" >/dev/null 2>&1; then
    echo "ERROR: config.json is not valid JSON"
    exit 1
  fi
  name=$(jq -r '.name // empty' "$CONFIG_JSON")
  if [[ -z "$name" ]]; then
    echo "ERROR: config.json missing 'name' field"
    exit 1
  fi
fi

echo "Validation PASSED for $AGENT_DIR"
exit 0
