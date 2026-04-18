#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REG_FILE="${ROOT_DIR}/registry.json"
CHECK_MODE=0

if [[ "${1:-}" == "--check" ]]; then
  CHECK_MODE=1
fi

get_version() {
  local v=""
  if command -v git >/dev/null 2>&1; then
    v="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  fi
  if [[ -z "$v" ]] && [[ -f "${ROOT_DIR}/package.json" ]]; then
    if command -v jq >/dev/null 2>&1; then
      v="$(jq -r '.version // empty' "${ROOT_DIR}/package.json" 2>/dev/null || true)"
    fi
  fi
  [[ -z "$v" ]] && v="1.0.0"
  echo "$v"
}

build_registry() {
  local version generated_at
  version="$(get_version)"
  generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  
  cat > "$REG_FILE" <<EOF
{
  "version": "${version}",
  "generated_at": "${generated_at}",
  "agents": [
    {
      "name": "big-brother",
      "description": "Senior escalation agent for unresolvable problems",
      "version": "1.0.0",
      "author": "oh-my-lazyagent community",
      "category": "escalation"
    }
  ],
  "skills": [
    {
      "name": "debug-plan",
      "description": "Structured debug planning skill for systematic problem solving"
    }
  ],
  "hooks": [
    {
      "name": "escalation",
      "description": "Monitors for boulder threshold and triggers escalation"
    }
  ]
}
EOF
}

if [[ "$CHECK_MODE" -eq 1 ]]; then
  if [[ -f "$REG_FILE" ]]; then
    echo "registry.json exists"
    exit 0
  else
    echo "registry.json missing"
    exit 1
  fi
fi

build_registry
echo "registry.json generated at $REG_FILE"
exit 0
