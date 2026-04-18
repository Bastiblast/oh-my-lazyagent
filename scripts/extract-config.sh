#!/usr/bin/env bash
set -euo pipefail

BASE_CONFIG="/home/bastien/oh-my-lazyagent/oh-my-openagent.jsonc"

if [ ! -f "$BASE_CONFIG" ]; then
  echo "Base config not found: $BASE_CONFIG" >&2
  exit 1
fi

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT
perl -0777 -pe 's/\/\*.*?\*\///gs' "$BASE_CONFIG" | sed 's#//.*$##g' > "$TMP_JSON"

if command -v jq >/dev/null 2>&1; then
  jq '.' "$TMP_JSON"
else
  cat "$TMP_JSON"
fi
exit 0
