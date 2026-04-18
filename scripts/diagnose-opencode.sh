#!/usr/bin/env bash
set -euo pipefail

# Diagnostic et réparation de la configuration OpenCode

PROJECT_DIR="${1:-$(pwd)}"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_green() { printf "${GREEN}%s${NC}\n" "$1"; }
print_red() { printf "${RED}%s${NC}\n" "$1"; }
print_yellow() { printf "${YELLOW}%s${NC}\n" "$1"; }
print_blue() { printf "${BLUE}%s${NC}\n" "$1"; }

echo "=========================================="
echo "DIAGNOSTIC OpenCode Configuration"
echo "=========================================="
echo ""

# Vérifier la structure complète
print_blue "1. Structure du projet"
echo "   Répertoire: $PROJECT_DIR"
echo ""

if [[ ! -d "$PROJECT_DIR/.opencode" ]]; then
    print_red "   ✗ .opencode/ manquant"
    echo ""
    print_yellow "   Réparation: Création de .opencode/"
    mkdir -p "$PROJECT_DIR/.opencode"
fi

# Lister tout ce qui est dans .opencode
echo "   Contenu de .opencode/:"
ls -la "$PROJECT_DIR/.opencode/" | sed 's/^/     /'
echo ""

# Vérifier les fichiers critiques
print_blue "2. Vérification des fichiers de configuration"
echo ""

FILES_OK=true

# opencode.json
if [[ -f "$PROJECT_DIR/.opencode/opencode.json" ]]; then
    if jq empty "$PROJECT_DIR/.opencode/opencode.json" 2>/dev/null; then
        print_green "   ✓ .opencode/opencode.json - VALIDE"
        echo ""
        echo "     Contenu:"
        jq '.' "$PROJECT_DIR/.opencode/opencode.json" 2>/dev/null | sed 's/^/       /'
    else
        print_red "   ✗ .opencode/opencode.json - INVALIDE"
        FILES_OK=false
    fi
else
    print_red "   ✗ .opencode/opencode.json - MANQUANT"
    FILES_OK=false
fi
echo ""

# oh-my-openagent.json
if [[ -f "$PROJECT_DIR/.opencode/oh-my-openagent.json" ]]; then
    if jq empty "$PROJECT_DIR/.opencode/oh-my-openagent.json" 2>/dev/null; then
        print_green "   ✓ .opencode/oh-my-openagent.json - VALIDE"
        echo ""
        echo "     Agents configurés:"
        jq '.agents | keys' "$PROJECT_DIR/.opencode/oh-my-openagent.json" 2>/dev/null | sed 's/^/       /'
    else
        print_red "   ✗ .opencode/oh-my-openagent.json - INVALIDE"
        FILES_OK=false
    fi
else
    print_red "   ✗ .opencode/oh-my-openagent.json - MANQUANT"
    FILES_OK=false
fi
echo ""

# Vérifier la config globale
print_blue "3. Configuration globale"
GLOBAL_OPENCODE="$HOME/.config/opencode/opencode.json"
GLOBAL_OMO="$HOME/.config/opencode/oh-my-openagent.json"

if [[ -f "$GLOBAL_OPENCODE" ]]; then
    print_green "   ✓ Config globale opencode.json existe"
    echo "     Chemin: $GLOBAL_OPENCODE"
    jq '.plugin // "non défini"' "$GLOBAL_OPENCODE" 2>/dev/null | sed 's/^/     Plugins: /'
else
    print_yellow "   ⚠ Config globale opencode.json absente"
fi
echo ""

if [[ -f "$GLOBAL_OMO" ]]; then
    print_green "   ✓ Config globale oh-my-openagent.json existe"
    echo "     Chemin: $GLOBAL_OMO"
    echo "     Agents globaux:"
    jq '.agents | keys' "$GLOBAL_OMO" 2>/dev/null | sed 's/^/       /'
else
    print_yellow "   ⚠ Config globale oh-my-openagent.json absente"
fi
echo ""

# Test de chargement simulé
print_blue "4. Test de chargement de configuration"
echo ""

if [[ "$FILES_OK" == "true" ]]; then
    # Simuler le merge des configs
    TEMP_CONFIG=$(mktemp)
    
    # Charger la config globale si elle existe
    if [[ -f "$GLOBAL_OMO" ]]; then
        jq '.' "$GLOBAL_OMO" > "$TEMP_CONFIG" 2>/dev/null || echo '{}' > "$TEMP_CONFIG"
    else
        echo '{}' > "$TEMP_CONFIG"
    fi
    
    # Merger avec la config locale
    if [[ -f "$PROJECT_DIR/.opencode/oh-my-openagent.json" ]]; then
        LOCAL_TEMP=$(mktemp)
        jq -s '.[0] * .[1]' "$TEMP_CONFIG" "$PROJECT_DIR/.opencode/oh-my-openagent.json" > "$LOCAL_TEMP" 2>/dev/null
        mv "$LOCAL_TEMP" "$TEMP_CONFIG"
    fi
    
    echo "   Configuration effective (simulation):"
    jq '.agents | keys' "$TEMP_CONFIG" 2>/dev/null | sed 's/^/     Agents: /'
    rm -f "$TEMP_CONFIG"
    print_green "   ✓ Merge réussi"
else
    print_red "   ✗ Impossible de tester - fichiers invalides ou manquants"
fi
echo ""

# Recommandations
print_blue "5. Recommandations"
echo ""

if [[ "$FILES_OK" == "true" ]]; then
    print_green "   ✓ La configuration locale est correcte"
    echo ""
    echo "   Si OpenCode ne charge pas la config locale:"
    echo ""
    echo "   1. Vérifier que VS Code/Cursor est bien ouvert sur:"
    echo "      $PROJECT_DIR"
    echo ""
    echo "   2. Redémarrer la fenêtre OpenCode:"
    echo "      - Command Palette (Ctrl+Shift+P)"
    echo "      - 'Developer: Reload Window'"
    echo ""
    echo "   3. Vérifier la console OpenCode pour les erreurs:"
    echo "      - Output → OpenCode"
    echo ""
    echo "   4. Si le problème persiste, vérifier que le plugin"
    echo "      oh-my-openagent est bien activé dans la config"
    echo ""
    print_yellow "   Note: La hiérarchie de chargement OpenCode est:"
    echo "   1. ~/.config/opencode/opencode.json (global)"
    echo "   2. ./.opencode/opencode.json (projet - override global)"
    echo "   3. Variables d'environnement (override tout)"
    
else
    print_red "   ✗ La configuration locale a des problèmes"
    echo ""
    echo "   Exécutez: lazyagent init"
    echo "   pour recréer la configuration"
fi

echo ""
echo "=========================================="

# Mode réparation si demandé
if [[ "${2:-}" == "--fix" ]]; then
    echo ""
    print_blue "MODE RÉPARATION"
    echo ""
    
    if command -v lazyagent >/dev/null 2>&1; then
        print_yellow "Recréation de la configuration..."
        cd "$PROJECT_DIR"
        rm -rf .opencode
        lazyagent init
        print_green "✓ Configuration recréée"
    else
        print_red "✗ Commande lazyagent non trouvée"
        exit 1
    fi
fi
