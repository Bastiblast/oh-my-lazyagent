#!/usr/bin/env bash
set -euo pipefail

# Wave 5: Install and Sync - Main installation script
# - One-command install (curl | bash pattern)
# - Idempotent, with --dry-run and --force
# - Colored output (green=success, red=error)
# - Steps:
#   a) Detect OmO installation
#   b) Verify git installed
#   c) Clone oh-my-lazyagent to ~/.config/opencode/lazyagent/
#   d) Apply patches to OmO
#   e) Merge config
#   f) Create symlinks for agents/skills
#   g) Validate installation
#   h) Print success and next steps

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_green() { printf "%b%s%b\n" "$GREEN" "$1" "$NC"; }
print_red()   { printf "%b%s%b\n" "$RED" "$1" "$NC"; }
print_info()  { printf "INFO: %s\n" "$1"; }

DRY_RUN=0
FORCE=0
REPO_LAZY=${REPO_LAZY:-https://github.com/oh-my-lazyagent/oh-my-lazyagent.git}
GLOBAL_LAZY_DIR="$HOME/.config/opencode/lazyagent"
OMO_ROOT="$HOME/.config/oh-my-openagent"

usage() {
  echo "Usage: install.sh [--dry-run] [--force]" 1>&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    *)           usage; exit 1 ;;
  esac
done

echo "Wave 5: Install and Sync (One-shot)"

if [ "$DRY_RUN" -eq 1 ]; then
  print_info "Running in DRY-RUN mode. No filesystem changes will be made."
fi

require_git() {
  if [ "$DRY_RUN" -eq 0 ]; then
    if ! command -v git >/dev/null 2>&1; then
      print_red "git is not installed. Please install git and re-run."
      exit 1
    fi
  fi
}

detect_omo() {
  if [ -d "$OMO_ROOT" ]; then
    return 0
  else
    return 1
  fi
}

clone_lazyagent() {
  mkdir -p "$(dirname "$GLOBAL_LAZY_DIR")"
  if [ -d "$GLOBAL_LAZY_DIR" ]; then
    if [ "$FORCE" -eq 0 ]; then
      print_green "oh-my-lazyagent already installed at $GLOBAL_LAZY_DIR. Re-run with --force to overwrite."
      return 0
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      print_info "[DRY-RUN] Would remove existing lazyagent at $GLOBAL_LAZY_DIR"; return 0
    fi
    rm -rf "$GLOBAL_LAZY_DIR"
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    print_info "[DRY-RUN] Would clone lazyagent from $REPO_LAZY to $GLOBAL_LAZY_DIR"
    return 0
  fi
  git clone --depth 1 "$REPO_LAZY" "$GLOBAL_LAZY_DIR" >/dev/null 2>&1 || {
    print_red "Failed to clone lazyagent repository."
    exit 1
  }
  print_green "Cloned oh-my-lazyagent to $GLOBAL_LAZY_DIR"
}

apply_patches() {
  if detect_omo; then
    PATCH_SCRIPT="$OMO_ROOT/patches/apply.sh"
    if [ -x "$PATCH_SCRIPT" ]; then
      if [ "$DRY_RUN" -eq 1 ]; then
        print_info "[DRY-RUN] Would apply patches via $PATCH_SCRIPT"
      else
        "$PATCH_SCRIPT" || {
          print_red "Patching OmO failed"
          exit 1
        }
        print_green "Patched OmO successfully"
      fi
    else
      print_info "No patches/apply.sh found at $PATCH_SCRIPT; skipping patch step."
    fi
  else
    print_info "OmO not detected; skipping patch step."
  fi
}

merge_config() {
  # Merge project-specific config if present
  DEST_CONFIG="$GLOBAL_LAZY_DIR/config/project-config.json"
  PROJECT_CONFIG="$HOME/.config/opencode/project-config.json"
  if [ -f "$PROJECT_CONFIG" ]; then
    if [ ! -d "$(dirname "$DEST_CONFIG")" ]; then
      mkdir -p "$(dirname "$DEST_CONFIG")"
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      print_info "[DRY-RUN] Would merge project-config.json into global config"
      return 0
    fi
    if command -v jq >/dev/null 2>&1; then
      tmp=$(mktemp)
      jq -s '.[0] * .[1]' "$DEST_CONFIG" "$PROJECT_CONFIG" > "$tmp" && mv "$tmp" "$DEST_CONFIG"
      print_green "Merged project-config.json into global config"
    else
      cp -f "$PROJECT_CONFIG" "$DEST_CONFIG" >/dev/null 2>&1
      print_info "jq not found; overwrote global config with project-config.json"
    fi
  else
    print_info "No project-config.json found in user config; skipping merge."
  fi
}

symlink_agents() {
  if [ "$DRY_RUN" -eq 1 ]; then
    print_info "[DRY-RUN] Would symlink agents/skills into OmO"
    return 0
  fi
  if detect_omo; then
    mkdir -p "$OMO_ROOT" 2>/dev/null || true
    ln -sfn "$GLOBAL_LAZY_DIR/agents" "$OMO_ROOT/agents" >/dev/null 2>&1 || true
    ln -sfn "$GLOBAL_LAZY_DIR/skills" "$OMO_ROOT/skills" >/dev/null 2>&1 || true
    print_green "Symlinks created for OmO agents/skills"
  else
    print_red "OmO not detected; cannot create symlinks."
  fi
}

validate_install() {
  if [ -f "$GLOBAL_LAZY_DIR/validate-structure.sh" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      print_info "[DRY-RUN] Would run validate-structure.sh"
    else
      "$GLOBAL_LAZY_DIR/validate-structure.sh" || {
        print_red "Validation failed during install"
        exit 1
      }
      print_green "Validation passed"
    fi
  else
    print_info "No validate-structure.sh found; skipping validation."
  fi
}

main() {
  print_info "Starting installation sequence..."
  require_git

  if ! detect_omo; then
    print_info "OmO not detected. The installer will install lazyagent into your environment."
  fi

  clone_lazyagent
  apply_patches
  merge_config
  symlink_agents
  validate_install

  print_green "Wave 5 installation completed successfully."
  echo
  echo "Next steps:"
  echo " - Use per-project init (scripts/init-project.sh) to enable LazyAgent in projects" 
  echo " - Run with --dry-run to test changes; use --force to overwrite existing installations"
}

main "$@"
