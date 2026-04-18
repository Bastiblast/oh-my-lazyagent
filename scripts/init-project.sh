#!/usr/bin/env bash
set -euo pipefail

# Wave 5: Per-project initialization
# - Enable lazyagent for a given project directory
# - Create .opencode/lazyagent symlink to global installation
# - Merge project-specific config
# - Validate project readiness

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_green() { printf "%b%s%b\n" "$GREEN" "$1" "$NC"; }
print_red()   { printf "%b%s%b\n" "$RED" "$1" "$NC"; }
print_info()  { printf "INFO: %s\n" "$1"; }

PROJECT_DIR="$(pwd)"
GLOBAL_LAZY_DIR="$HOME/.config/opencode/lazyagent"
PROJECT_LAZY_LINK="$PROJECT_DIR/.opencode/lazyagent"
PROJECT_CONFIG="$PROJECT_DIR/.config/project-config.json"

usage() {
  echo "Usage: init-project.sh" 1>&2
}

if [ "$#" -gt 0 ]; then
  usage
  exit 1
fi

main() {
  print_info "Initializing project for lazyagent: $PROJECT_DIR"

  # Ensure global lazyagent exists
  if [ ! -d "$GLOBAL_LAZY_DIR" ]; then
    print_red "Global lazyagent not found at $GLOBAL_LAZY_DIR. Please run install.sh first."
    exit 1
  fi

  # Create .opencode directory if missing
  mkdir -p "$PROJECT_DIR/.opencode"

  # Create symlink to global lazyagent in project
  if [ -L "$PROJECT_LAZY_LINK" ]; then
    : # already linked
  else
    if [ -e "$PROJECT_LAZY_LINK" ]; then
      rm -rf "$PROJECT_LAZY_LINK"
    fi
    ln -sfn "$GLOBAL_LAZY_DIR" "$PROJECT_LAZY_LINK"
  fi

  # Configure Big-Brother in oh-my-openagent
  # OmO reads agents from ~/.config/opencode/oh-my-openagent.json
  OMO_CONFIG="$HOME/.config/opencode/oh-my-openagent.json"
  
  if [[ -f "$OMO_CONFIG" ]]; then
    if command -v jq >/dev/null 2>&1; then
      # Add big-brother to agents section
      tmp=$(mktemp)
      jq '.agents["big-brother"] = {
        "model": "opencode-go/glm-5",
        "fallback_models": [{"model": "opencode-go/kimi-k2.5"}],
        "category": "escalation",
        "mode": "subagent"
      } | .categories["escalation"] = {
        "model": "opencode-go/glm-5"
      }' "$OMO_CONFIG" > "$tmp" && mv "$tmp" "$OMO_CONFIG"
      print_green "Configured big-brother in oh-my-openagent"
    else
      print_info "jq not available, cannot auto-configure oh-my-openagent"
      print_info "Please manually add big-brother to $OMO_CONFIG"
    fi
  else
    print_info "oh-my-openagent config not found at $OMO_CONFIG"
  fi

  # Merge project-specific config if present
  if [ -f "$PROJECT_CONFIG" ]; then
    DEST_CONFIG="$GLOBAL_LAZY_DIR/config/project-config.json"
    if command -v jq >/dev/null 2>&1; then
      tmp=$(mktemp)
      mkdir -p "$(dirname "$DEST_CONFIG")"
      jq -s '.[0] * .[1]' "$DEST_CONFIG" "$PROJECT_CONFIG" > "$tmp" && mv "$tmp" "$DEST_CONFIG" || {
        print_red "Failed to merge project-config.json with jq"
        exit 1
      }
      print_green "Merged project-config.json into global config"
    else
      cp -f "$PROJECT_CONFIG" "$DEST_CONFIG" || true
      print_info "jq not available; copied project-config.json over global config"
    fi
  else
    print_info "No per-project config found; nothing to merge."
  fi

  # Basic validation (if a validation script exists in the lazyagent repo, use it)
  if [ -f "$GLOBAL_LAZY_DIR/validate-project.sh" ]; then
    if ! bash "$GLOBAL_LAZY_DIR/validate-project.sh"; then
      print_red "Project validation failed."
      exit 1
    fi
    print_green "Project validation passed"
  else
    print_info "No validate-project.sh found; skipping project validation."
  fi
}

main "$@"
