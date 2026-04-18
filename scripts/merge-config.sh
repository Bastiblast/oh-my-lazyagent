#!/usr/bin/env bash
set -euo pipefail

# Absolute paths (adjust if your environment layout differs)
BASE_CONFIG="/home/bastien/oh-my-lazyagent/oh-my-openagent.jsonc"
OVERLAY_CONFIG="/home/bastien/oh-my-lazyagent/config/lazyagent.jsonc"

USAGE="Usage: $(basename "$0") [--dry-run]"

# Parse args
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    *)
      echo "Unknown option: $arg"
      echo "$USAGE"
      exit 1
      ;;
  esac
done

if [ ! -f "$BASE_CONFIG" ]; then
  echo "ERROR: Base config not found: $BASE_CONFIG" >&2
  exit 1
fi
if [ ! -f "$OVERLAY_CONFIG" ]; then
  echo "ERROR: Overlay config not found: $OVERLAY_CONFIG" >&2
  exit 1
fi

# Back up existing base config
BACKUP="${BASE_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
cp -a "$BASE_CONFIG" "$BACKUP"
echo "Backup created: $BACKUP"

strip_jsonc() {
  # Remove block comments (/* ... */) and line comments (// ...)
  # Output is valid JSON (without comments)
  perl -0777 -pe 's/\/\*.*?\*\///gs' "$1" | sed 's#//.*$##g'
}

TMP_BASE="$(mktemp)"
TMP_OVERLAY="$(mktemp)"
trap 'rm -f "$TMP_BASE" "$TMP_OVERLAY"' EXIT

strip_jsonc "$BASE_CONFIG" > "$TMP_BASE"
strip_jsonc "$OVERLAY_CONFIG" > "$TMP_OVERLAY"

apply_with_jq() {
  local merged
  merged=$(jq -s 'def deepmerge(a;b):
    if ((a|type)=="object") and ((b|type)=="object") then
      reduce (b|to_entries[]) as $e (a;
        if ($e.value|type) == "object" and (.[$e.key]|type) == "object" then
          .[$e.key] = (deepmerge (.[$e.key] // {}) $e.value)
        else
          .[$e.key] = $e.value
        end
      )
    else
      b
    end;
  deepmerge(.[0]; .[1])' "$TMP_BASE" "$TMP_OVERLAY")
  echo "$merged"
}

if command -v jq >/dev/null 2>&1; then
  MERGED_JSON=$(apply_with_jq)
  if [ -z "$MERGED_JSON" ]; then
    echo "ERROR: Merge resulted in empty JSON" >&2
    exit 1
  fi
  if [ "$DRY_RUN" = true ]; then
    echo "Dry-run: merging overlay into base. Result (pretty-printed):"
    echo "$MERGED_JSON" | jq '.'
    exit 0
  fi
  echo "$MERGED_JSON" | jq '.' > "$BASE_CONFIG"
  echo "Merged overlay into base config: $BASE_CONFIG"
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  PYMERGE=$(mktemp)
  cat > "$PYMERGE" <<'PY'
import json,sys
base_path = sys.argv[1]
overlay_path = sys.argv[2]
with open(base_path,'r',encoding='utf-8') as f:
    base = json.load(f)
with open(overlay_path,'r',encoding='utf-8') as f:
    overlay = json.load(f)
def merge(a,b):
  for k,v in b.items():
    if k in a and isinstance(a[k], dict) and isinstance(v, dict):
      merge(a[k], v)
    else:
      a[k] = v
merge(base, overlay)
print(json.dumps(base, indent=2))
PY
  MERGED_JSON=$(python3 "$PYMERGE" "$TMP_BASE" "$TMP_OVERLAY")
  rm -f "$PYMERGE"
  if [ -z "$MERGED_JSON" ]; then
    echo "ERROR: Python merge produced no output" >&2
    exit 1
  fi
  if [ "$DRY_RUN" = true ]; then
    echo "Dry-run: would merge overlay into base (Python fallback). Result:"
    echo "$MERGED_JSON"
    exit 0
  fi
  echo "$MERGED_JSON" | python3 -m json.tool > "$BASE_CONFIG"
  echo "Merged overlay into base config (Python fallback): $BASE_CONFIG"
  exit 0
fi

echo "ERROR: No JSON processor available (jq/python3) to merge configurations." >&2
exit 1
