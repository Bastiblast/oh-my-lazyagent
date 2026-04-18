# oh-my-lazyagent

> **Un fork communautaire de [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) avec l'agent Big-Brother pour l'escalade intelligente**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![Fork](https://img.shields.io/badge/fork-oh--my--openagent-orange.svg)](https://github.com/code-yeongyu/oh-my-openagent)

## 🎯 Le Projet

**oh-my-lazyagent** est un fork d'oh-my-openagent (OmO) qui ajoute une couche d'extensibilité communautaire avec un système d'escalade intelligent. Contrairement à un simple plugin, ce fork modifie minimalement le cœur d'OmO (3 patches seulement) pour permettre :

- 🧠 **Big-Brother Agent** - Un agent senior qui prend le relais quand Sisyphus est bloqué après 3 échecs
- 📦 **Architecture Drop-in** - Ajoutez des agents en créant simplement des dossiers
- 🔄 **Synchronisation Upstream** - Gardez votre fork à jour avec OmO automatiquement
- 🧪 **Tests E2E** - Suite de tests complète pour valider l'escalade

## 🚀 Installation Rapide

```bash
# One-line install (depuis ce fork)
curl -fsSL https://raw.githubusercontent.com/Bastiblast/oh-my-lazyagent/main/scripts/install.sh | bash

# Rechargez votre shell
export PATH="$HOME/.local/bin:$PATH"
```

## 🎮 Utilisation

Après installation, la commande `lazyagent` est disponible globalement :

```bash
# Initialiser lazyagent dans un projet
cd mon-projet
lazyagent init

# Synchroniser avec oh-my-openagent upstream  
lazyagent sync

# Valider un agent
lazyagent validate lazyagent/agents/big-brother

# Valider tout le projet
lazyagent validate-all

# Mettre à jour le registre
lazyagent generate-registry

# Voir toutes les commandes
lazyagent help
```

### Sans la commande globale

Si vous préférez utiliser les scripts directement :

```bash
~/.config/opencode/lazyagent/scripts/init-project.sh    # Init projet
~/.config/opencode/lazyagent/scripts/sync-upstream.sh   # Sync upstream
~/.config/opencode/lazyagent/scripts/validate-agent.sh  # Validation
```

## 🏗️ Architecture

### Modèle Fork + Drop-in

```
oh-my-lazyagent/
├── lazyagent/              ← Votre couche d'extensions
│   ├── agents/
│   │   └── big-brother/    ← Agent d'escalade phare
│   │       ├── agent.md    ← Définition OpenCode
│   │       ├── config.json ← Configuration modèle/permissions
│   │       └── prompts/
│   │           └── escalation.md
│   ├── skills/
│   │   └── debug-plan/
│   │       └── SKILL.md    ← Skill de planification debug
│   └── hooks/
│       ├── escalation.ts   ← Détection seuil d'escalade
│       └── types.ts        ← Interfaces TypeScript
│
├── patches/                ← 3 patches minimaux pour OmO
│   ├── agent-registry.patch      ← Discovery lazyagent/agents/
│   ├── sisyphus-escalation.patch ← Logique d'escalade
│   ├── hook-extension.patch      ← Enregistrement hooks
│   └── apply.sh                  ← Application idempotente
│
├── config/
│   └── lazyagent.jsonc     ← Configuration overlay JSONC
│
├── scripts/                ← Utilitaires
│   ├── install.sh          ← Installateur principal
│   ├── sync-upstream.sh    ← Sync avec OmO upstream
│   ├── validate-*.sh       ← Validation agents/structure
│   └── generate-registry.sh ← Générateur registre
│
└── tests/                  ← Tests complets
    ├── e2e/
    │   └── escalation-flow.test.ts
    └── unit/
        ├── config-merge.test.ts
        └── patch-apply.test.ts
```

### Flow d'Escalade Big-Brother

```
Sisyphus travaille sur une tâche
    ↓ Échec détecté
    Incrémente failure_count
    ↓ 3 échecs consécutifs ?
    Génère rapport d'escalade
    ↓
task(category="escalation", prompt=rapport)
    ↓
Big-Brother analyse & répond
    ↓
Sisyphus reprend avec plan de debug
```

## 🎨 Contribuer

Ce fork est conçu pour être **community-driven**. Ajoutez vos agents facilement :

```bash
# 1. Créez un dossier pour votre agent
mkdir lazyagent/agents/mon-agent

# 2. Ajoutez les fichiers requis:
#    - agent.md (définition OpenCode)
#    - config.json (modèle, permissions)
#    - prompts/ (templates de prompts)

# 3. Validez votre agent
./scripts/validate-agent.sh lazyagent/agents/mon-agent

# 4. Mettez à jour le registre
./scripts/generate-registry.sh

# 5. Soumettez une PR !
```

Voir [CONTRIBUTING.md](./CONTRIBUTING.md) pour les détails complets.

## 🔄 Synchronisation avec Upstream

Gardez votre fork à jour avec oh-my-openagent :

```bash
./scripts/sync-upstream.sh
# Gère les conflits, vérifie la compatibilité, met à jour les patches
```

**Seulement 3 patches à maintenir** - tous petits et bien documentés.

## 📦 Historique des Commits

Projet construit avec des commits atomiques :

```
08bc9f4 fix: update install script with correct repo URL
5b023f6 docs: add CHANGELOG and CONTRIBUTING  
421a0c0 chore: add LICENSE and original SPEC
65df5da feat: add documentation and test suite
ce2e116 feat: add OmO integration patches and config system
456994b feat: initialize project structure
```

## 🧪 Tests

```bash
# Validation structurelle
./scripts/validate-structure.sh

# Tests unitaires
npm run test:unit

# Tests E2E
npm run test:e2e
```

## 📚 Documentation

- [Architecture](./docs/architecture.md) - Design système et décisions
- [Contributing](./CONTRIBUTING.md) - Guide contribution détaillé
- [Changelog](./CHANGELOG.md) - Historique des versions

## 🔗 Liens

- **Upstream** : [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)
- **Ce fork** : [Bastiblast/oh-my-lazyagent](https://github.com/Bastiblast/oh-my-lazyagent)
- **Issues** : [GitHub Issues](https://github.com/Bastiblast/oh-my-lazyagent/issues)

## 📝 License

MIT - Voir [LICENSE](./LICENSE)

---

**Fork créé avec ❤️ pour la communauté oh-my-openagent**

⭐ Star ce repo si tu trouves ça utile !
