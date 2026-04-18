#!/usr/bin/env bash
set -euo pipefail
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then DRY_RUN=1; fi
APPLIED_DIR="$PATCH_DIR/.applied"
mkdir -p "$APPLIED_DIR"
PATCH_FILES=(agent-registry.patch sisyphus-escalation.patch hook-extension.patch)
EXIT_CODE=0
for PATCH in "${PATCH_FILES[@]}"; do
  if [[ -f "$APPLIED_DIR/$PATCH" ]]; then
    echo "[skipped] $PATCH already applied"
    continue
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] would apply $PATCH"
    continue
  fi
  if patch -p0 < "$PATCH_DIR/$PATCH"; then
    echo "[applied] $PATCH"
    touch "$APPLIED_DIR/$PATCH"
  else
    echo "[failed] applying $PATCH"
    EXIT_CODE=1
  fi
done
exit "$EXIT_CODE"
