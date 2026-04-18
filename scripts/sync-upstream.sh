#!/usr/bin/env bash
set -euo pipefail

# Wave 5: Upstream synchronization
# - Checks for upstream remote
# - Fetches latest from oh-my-openagent
# - Creates a sync branch and attempts merge
# - Detects conflicts and prints manual guidance
# - Validates on success
# - Supports --dry-run and version compatibility check

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_green() { printf "%b%s%b\n" "$GREEN" "$1" "$NC"; }
print_red()   { printf "%b%s%b\n" "$RED" "$1" "$NC"; }
print_info()  { printf "INFO: %s\n" "$1"; }

DRY_RUN=0
usage() { echo "Usage: sync-upstream.sh [--dry-run]" 1>&2; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    *)        usage; exit 1 ;;
  esac
done

if [ "$DRY_RUN" -eq 1 ]; then
  print_info "Running in DRY-RUN mode. No changes will be made."
fi

ensure_git_repo() {
  if [ ! -d .git ]; then
    print_red "Current directory is not a git repository. Run this inside a repo."; exit 1
  fi
}

has_upstream() {
  git remote -v | awk '{print $1}' | grep -q '^upstream$' || return 1
  return 0
}

fetch_upstream() {
  if [ "$DRY_RUN" -eq 1 ]; then
    print_info "[DRY-RUN] Would fetch upstream"; return 0
  fi
  git fetch upstream || { print_red "Failed to fetch upstream"; exit 1; }
}

compat_check() {
  # Simple version compatibility check via wave-version file if present
  LOCAL_WAVE="$(test -f wave-version && cat wave-version || echo '')"
  UPSTREAM_WAVE="$(git show upstream/main:wave-version 2>/dev/null || true)"
  if [ -n "$LOCAL_WAVE" ] && [ -n "$UPSTREAM_WAVE" ]; then
    if [ "$LOCAL_WAVE" != "$UPSTREAM_WAVE" ]; then
      print_info "Version mismatch: local=$LOCAL_WAVE upstream=$UPSTREAM_WAVE"
    else
      print_info "Version compatible: $LOCAL_WAVE"
    fi
  fi
}

merge_upstream() {
  TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
  SYNC_BRANCH="wave5-sync-$TIMESTAMP"
  if [ "$DRY_RUN" -eq 1 ]; then
    print_info "[DRY-RUN] Would create branch $SYNC_BRANCH and merge upstream/main"
    return 0
  fi
  git checkout -b "$SYNC_BRANCH" >/dev/null
  MERGE_OUT=$(git merge --no-ff upstream/main -m "Wave 5 sync: upstream/main into $SYNC_BRANCH" 2>&1 || true)
  if echo "$MERGE_OUT" | grep -q -i "CONFLICT"; then
    print_red "Conflicts detected during merge. Please resolve in branch $SYNC_BRANCH and commit manually."
    git status --porcelain
    exit 1
  else
    print_green "Upstream merged cleanly into $SYNC_BRANCH"
  fi
  compat_check
  if [ -f validate-structure.sh ]; then
    bash validate-structure.sh || {
      print_red "Validation failed after upstream sync"
      exit 1
    }
  fi
  print_green "Wave 5 upstream sync completed successfully."
}

main() {
  ensure_git_repo
  if ! has_upstream; then
    print_red "Upstream remote 'upstream' not found. Add upstream to continue."
    exit 1
  fi
  fetch_upstream
  merge_upstream
}

main "$@"
