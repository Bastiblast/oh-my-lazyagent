#!/usr/bin/env bash
set -euo pipefail

# oh-my-lazyagent - Installation autonome et complète
# Ce script clone, configure et installe tout automatiquement

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

print_green() { printf "%b%s%b\n" "$GREEN" "$1" "$NC"; }
print_yellow() { printf "%b%s%b\n" "$YELLOW" "$1" "$NC"; }
print_red() { printf "%b%s%b\n" "$RED" "$1" "$NC"; }
print_info() { printf "ℹ️  %s\n" "$1"; }

# Configuration
REPO_LAZY="https://github.com/Bastiblast/oh-my-lazyagent.git"
GLOBAL_LAZY_DIR="${HOME}/.config/opencode/lazyagent"
LOCAL_BIN="${HOME}/.local/bin"
OMO_ROOT="${HOME}/.config/oh-my-openagent"

# Flags
DRY_RUN=0
FORCE=0
VERBOSE=0

usage() {
    cat <<EOF
Usage: install.sh [OPTIONS]

Options:
    --dry-run       Simulate installation without making changes
    --force         Overwrite existing installation
    --verbose       Show detailed output
    -h, --help      Show this help message

Examples:
    # Installation standard
    curl -fsSL https://raw.githubusercontent.com/Bastiblast/oh-my-lazyagent/main/scripts/install.sh | bash

    # Forcer la réinstallation
    ./install.sh --force

    # Test sans modifications
    ./install.sh --dry-run --verbose
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) DRY_RUN=1; shift ;;
            --force) FORCE=1; shift ;;
            --verbose) VERBOSE=1; shift ;;
            -h|--help) usage; exit 0 ;;
            *) print_red "Unknown option: $1"; usage; exit 1 ;;
        esac
    done
}

log() {
    [[ $VERBOSE -eq 1 ]] && print_info "$1"
}

detect_omo() {
    [[ -d "$OMO_ROOT" ]]
}

# Étape 1: Vérifier les prérequis
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v git >/dev/null 2>&1; then
        print_red "❌ git is not installed. Please install git first."
        print_info "  Ubuntu/Debian: sudo apt-get install git"
        print_info "  macOS: brew install git"
        exit 1
    fi
    
    log "✓ git found"
}

# Étape 2: Cloner ou mettre à jour le repository
setup_repository() {
    log "Setting up repository..."
    
    if [[ -d "$GLOBAL_LAZY_DIR" ]]; then
        if [[ $FORCE -eq 0 ]]; then
            print_yellow "⚠️  oh-my-lazyagent already installed at $GLOBAL_LAZY_DIR"
            print_info "   Run with --force to overwrite, or run 'lazyagent sync' to update"
            return 0
        fi
        
        if [[ $DRY_RUN -eq 1 ]]; then
            log "[DRY-RUN] Would remove existing directory: $GLOBAL_LAZY_DIR"
            return 0
        fi
        
        print_info "Removing existing installation..."
        rm -rf "$GLOBAL_LAZY_DIR"
    fi
    
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Would clone $REPO_LAZY to $GLOBAL_LAZY_DIR"
        return 0
    fi
    
    print_info "📦 Cloning oh-my-lazyagent..."
    mkdir -p "$(dirname "$GLOBAL_LAZY_DIR")"
    
    if ! git clone --depth 1 "$REPO_LAZY" "$GLOBAL_LAZY_DIR" 2>&1; then
        print_red "❌ Failed to clone repository"
        print_info "   Check your internet connection and try again"
        exit 1
    fi
    
    print_green "✓ Repository cloned to $GLOBAL_LAZY_DIR"
}

# Étape 3: Corriger les permissions des scripts
fix_permissions() {
    log "Fixing script permissions..."
    
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Would make all .sh files executable"
        return 0
    fi
    
    local scripts_dir="$GLOBAL_LAZY_DIR/scripts"
    local patches_dir="$GLOBAL_LAZY_DIR/patches"
    
    if [[ -d "$scripts_dir" ]]; then
        chmod +x "$scripts_dir"/*.sh 2>/dev/null || true
        log "✓ Scripts made executable"
    fi
    
    if [[ -d "$patches_dir" ]]; then
        chmod +x "$patches_dir"/apply.sh 2>/dev/null || true
        log "✓ Patch script made executable"
    fi
}

# Étape 4: Créer la commande globale lazyagent
create_global_command() {
    log "Creating global lazyagent command..."
    
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Would create $LOCAL_BIN/lazyagent"
        return 0
    fi
    
    mkdir -p "$LOCAL_BIN"
    
    cat > "$LOCAL_BIN/lazyagent" <<'LAZYEOF'
#!/usr/bin/env bash
# oh-my-lazyagent - Commande globale
set -euo pipefail

LAZY_DIR="${HOME}/.config/opencode/lazyagent"

if [[ ! -d "$LAZY_DIR" ]]; then
    echo "❌ Error: oh-my-lazyagent not installed at $LAZY_DIR" >&2
    echo "   Run: curl -fsSL https://raw.githubusercontent.com/Bastiblast/oh-my-lazyagent/main/scripts/install.sh | bash" >&2
    exit 1
fi

show_help() {
    cat <<EOF
oh-my-lazyagent - Community fork of oh-my-openagent with Big-Brother escalation

Usage: lazyagent <command> [options]

Commands:
    init [path]          Initialize lazyagent in a project directory
    sync                 Sync with oh-my-openagent upstream
    validate <agent>     Validate an agent directory
    validate-all         Validate all agents and structure
    generate-registry    Update registry.json
    help                 Show this help message

Examples:
    lazyagent init                      # Init in current directory
    lazyagent init ~/mon-projet         # Init in specific directory
    lazyagent sync                      # Sync with upstream
    lazyagent validate agents/big-brother

Repository: https://github.com/Bastiblast/oh-my-lazyagent
EOF
}

case "${1:-help}" in
    init)
        shift
        exec "$LAZY_DIR/scripts/init-project.sh" "$@"
        ;;
    sync)
        exec "$LAZY_DIR/scripts/sync-upstream.sh"
        ;;
    validate)
        shift
        exec "$LAZY_DIR/scripts/validate-agent.sh" "$@"
        ;;
    validate-all)
        exec "$LAZY_DIR/scripts/validate-all.sh"
        ;;
    generate-registry)
        exec "$LAZY_DIR/scripts/generate-registry.sh"
        ;;
    help|--help|-h)
        show_help
        exit 0
        ;;
    *)
        echo "❌ Unknown command: $1" >&2
        echo "   Run 'lazyagent help' for usage" >&2
        exit 1
        ;;
esac
LAZYEOF
    
    chmod +x "$LOCAL_BIN/lazyagent"
    
    # Create big-brother specific command
    cat > "$LOCAL_BIN/big-brother" <<'BBEOF'
#!/usr/bin/env bash
# Big-Brother Agent - Direct access

LAZY_DIR="${HOME}/.config/opencode/lazyagent"
BIG_BROTHER_DIR="$LAZY_DIR/lazyagent/agents/big-brother"

if [[ ! -d "$BIG_BROTHER_DIR" ]]; then
    echo "❌ Big-Brother not installed. Run: curl ... | bash" >&2
    exit 1
fi

cat <<'HEADER'
🧠 Big-Brother Agent
   Senior escalation agent for unresolvable problems

   Usage with oh-my-openagent:
   task(category="escalation", prompt="your task here")

   Configuration: ~/.config/opencode/lazyagent/lazyagent/agents/big-brother/

Agent Capabilities:
HEADER

# Show agent capabilities from agent.md
grep -A 30 "System role:" "$BIG_BROTHER_DIR/agent.md" 2>/dev/null || echo "   - Analyze complex problems"
echo ""
echo "📖 Full docs: https://github.com/Bastiblast/oh-my-lazyagent"
BBEOF
    chmod +x "$LOCAL_BIN/big-brother"
    
    print_green "✓ Global commands created: lazyagent, big-brother"
}

# Étape 5: Créer les symlinks pour OmO (si présent)
link_to_omo() {
    if ! detect_omo; then
        log "OmO not detected, skipping symlinks"
        return 0
    fi
    
    log "Creating symlinks for OmO..."
    
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Would symlink agents and skills to $OMO_ROOT"
        return 0
    fi
    
    mkdir -p "$OMO_ROOT" 2>/dev/null || true
    
    ln -sfn "$GLOBAL_LAZY_DIR/lazyagent/agents" "$OMO_ROOT/agents" 2>/dev/null || true
    ln -sfn "$GLOBAL_LAZY_DIR/lazyagent/skills" "$OMO_ROOT/skills" 2>/dev/null || true
    
    print_green "✓ Linked to oh-my-openagent"
}

# Étape 6: Valider l'installation
validate_installation() {
    log "Validating installation..."
    
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Would run validation"
        return 0
    fi
    
    local validate_script="$GLOBAL_LAZY_DIR/scripts/validate-structure.sh"
    
    if [[ -x "$validate_script" ]]; then
        if "$validate_script" >/dev/null 2>&1; then
            print_green "✓ Installation validated"
        else
            print_yellow "⚠️  Validation had issues (non-critical)"
        fi
    else
        log "Validation script not found or not executable"
    fi
}

# Étape 7: Vérifier le PATH
check_path() {
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_yellow "⚠️  ~/.local/bin is not in your PATH"
        print_info "   Add this to your ~/.bashrc or ~/.zshrc:"
        print_info '   export PATH="$HOME/.local/bin:$PATH"'
        print_info ""
        print_info "   Or run this command now:"
        print_info '   export PATH="$HOME/.local/bin:$PATH"'
        return 1
    fi
    return 0
}

# Étape 8: Afficher le résumé
show_summary() {
    echo ""
    print_green "🎉 Installation completed successfully!"
    echo ""
    echo "📍 Installation location: $GLOBAL_LAZY_DIR"
    echo "🚀 Global command: lazyagent"
    echo ""
    echo "Quick start:"
    echo ""
    
    if ! check_path >/dev/null 2>&1; then
        echo "   1. Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "   2. Then use: lazyagent help"
    else
        echo "   lazyagent help              # Show all commands"
        echo "   lazyagent init              # Initialize in current directory"
        echo "   lazyagent sync              # Sync with upstream"
    fi
    
    echo ""
    echo "Documentation: https://github.com/Bastiblast/oh-my-lazyagent"
}

# Fonction principale
main() {
    parse_args "$@"
    
    if [[ $DRY_RUN -eq 1 ]]; then
        print_yellow "🔍 DRY-RUN MODE: No changes will be made"
        echo ""
    fi
    
    print_info "🚀 Installing oh-my-lazyagent..."
    
    check_prerequisites
    setup_repository
    fix_permissions
    create_global_command
    link_to_omo
    validate_installation
    show_summary
}

main "$@"
