#!/usr/bin/env bash
set -euo pipefail

# Test script pour vérifier la configuration OpenCode
# Usage: ./test-opencode-config.sh [project_directory]

PROJECT_DIR="${1:-$(pwd)}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

print_red() { printf "${RED}%s${NC}\n" "$1"; }
print_green() { printf "${GREEN}%s${NC}\n" "$1"; }
print_yellow() { printf "${YELLOW}%s${NC}\n" "$1"; }

echo "=========================================="
echo "Test de configuration OpenCode"
echo "Répertoire: $PROJECT_DIR"
echo "=========================================="
echo ""

# Test 1: Vérifier l'existence du répertoire .opencode
echo "Test 1: Vérification de .opencode/"
if [[ -d "$PROJECT_DIR/.opencode" ]]; then
    print_green "✓ Répertoire .opencode existe"
else
    print_red "✗ Répertoire .opencode manquant"
    exit 1
fi

# Test 2: Vérifier opencode.json
echo ""
echo "Test 2: Vérification de opencode.json"
if [[ -f "$PROJECT_DIR/.opencode/opencode.json" ]]; then
    if jq empty "$PROJECT_DIR/.opencode/opencode.json" 2>/dev/null; then
        print_green "✓ opencode.json existe et est valide"
        echo "  Contenu:"
        jq '.' "$PROJECT_DIR/.opencode/opencode.json" | sed 's/^/    /'
    else
        print_red "✗ opencode.json existe mais est invalide"
        exit 1
    fi
else
    print_red "✗ opencode.json manquant"
    exit 1
fi

# Test 3: Vérifier oh-my-openagent.json
echo ""
echo "Test 3: Vérification de oh-my-openagent.json"
if [[ -f "$PROJECT_DIR/.opencode/oh-my-openagent.json" ]]; then
    if jq empty "$PROJECT_DIR/.opencode/oh-my-openagent.json" 2>/dev/null; then
        print_green "✓ oh-my-openagent.json existe et est valide"
        echo "  Agents configurés:"
        jq '.agents | keys' "$PROJECT_DIR/.opencode/oh-my-openagent.json" | sed 's/^/    /'
    else
        print_red "✗ oh-my-openagent.json existe mais est invalide"
        exit 1
    fi
else
    print_red "✗ oh-my-openagent.json manquant"
    exit 1
fi

# Test 4: Vérifier le symlink lazyagent
echo ""
echo "Test 4: Vérification du symlink lazyagent"
if [[ -L "$PROJECT_DIR/.opencode/lazyagent" ]]; then
    if [[ -d "$PROJECT_DIR/.opencode/lazyagent" ]]; then
        print_green "✓ Symlink lazyagent existe et pointe vers un répertoire valide"
        echo "  Cible: $(readlink "$PROJECT_DIR/.opencode/lazyagent")"
    else
        print_red "✗ Symlink lazyagent existe mais pointe vers une cible invalide"
        exit 1
    fi
else
    print_yellow "⚠ Symlink lazyagent n'existe pas (optionnel pour certains cas)"
fi

# Test 5: Vérifier que les agents sont accessibles via le symlink
echo ""
echo "Test 5: Vérification des agents via symlink"
if [[ -d "$PROJECT_DIR/.opencode/lazyagent/lazyagent/agents" ]]; then
    print_green "✓ Répertoire agents accessible"
    echo "  Agents disponibles:"
    ls "$PROJECT_DIR/.opencode/lazyagent/lazyagent/agents/" | sed 's/^/    - /'
else
    print_red "✗ Répertoire agents non accessible"
    exit 1
fi

# Test 6: Vérifier les permissions
echo ""
echo "Test 6: Vérification des permissions"
if [[ -r "$PROJECT_DIR/.opencode/opencode.json" && -r "$PROJECT_DIR/.opencode/oh-my-openagent.json" ]]; then
    print_green "✓ Fichiers lisibles"
else
    print_red "✗ Problème de permissions sur les fichiers"
    exit 1
fi

# Test 7: Comparer avec la config globale
echo ""
echo "Test 7: Comparaison avec la configuration globale"
GLOBAL_CONFIG="$HOME/.config/opencode/opencode.json"
if [[ -f "$GLOBAL_CONFIG" ]]; then
    echo "  Config globale: $GLOBAL_CONFIG"
    if [[ -f "$PROJECT_DIR/.opencode/opencode.json" ]]; then
        echo "  Différences entre globale et locale:"
        diff -u "$GLOBAL_CONFIG" "$PROJECT_DIR/.opencode/opencode.json" || true
    fi
else
    print_yellow "⚠ Pas de config globale trouvée"
fi

echo ""
echo "=========================================="
print_green "Tous les tests ont réussi !"
echo "=========================================="
echo ""
echo "Pour activer dans OpenCode:"
echo "1. Redémarrer VS Code/Cursor ou recharger la fenêtre"
echo "2. La config locale devrait être chargée depuis $PROJECT_DIR/.opencode/"
