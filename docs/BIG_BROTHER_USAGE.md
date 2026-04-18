# Utilisation de Big-Brother Agent

## 🧠 Qu'est-ce que Big-Brother ?

Big-Brother est l'**agent d'escalade phare** de oh-my-lazyagent. Conçu pour être utilisé comme subagent dans vos projets via OpenCode/OmO.

## 🚀 Workflow: Une install, un init par projet

### Étape 1: Installer globalement (une seule fois)

```bash
curl -fsSL https://raw.githubusercontent.com/Bastiblast/oh-my-lazyagent/main/scripts/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
```

Big-Brother est installé dans `~/.config/opencode/lazyagent/lazyagent/agents/big-brother/`.

### Étape 2: Initialiser dans votre projet

```bash
cd mon-projet
lazyagent init
```

Cela crée un symlink `.opencode/lazyagent` → installation globale.

### Étape 3: Utiliser Big-Brother dans votre projet

Une fois initialisé, Big-Brother est accessible via OpenCode/OmO qui découvrent automatiquement les agents dans `.opencode/lazyagent/agents/`.

## ⚙️ Configuration

### Emplacement

- **Installation**: `~/.config/opencode/lazyagent/lazyagent/agents/big-brother/`
- **Dans projet**: `.opencode/lazyagent/agents/big-brother` (symlink)

### Config modèle et permissions

```json
{
  "name": "big-brother",
  "model": "opencode-go/glm-5",
  "fallback_models": [{ "model": "opencode-go/kimi-k2.5" }],
  "category": "escalation",
  "mode": "subagent",
  "permissions": {
    "read": "allow",
    "edit": "allow",
    "bash": "allow",
    "task": "allow"
  }
}
```

## 🔧 Intégration complète avec OmO

Pour l'escalade automatique après 3 échecs de Sisyphus :

```bash
# Si OmO est installé
cd ~/.config/opencode/lazyagent/patches
./apply.sh
```

## 📝 Vérification

```bash
# Vérifier l'installation globale
lazyagent validate ~/.config/opencode/lazyagent/lazyagent/agents/big-brother

# Dans un projet initialisé
ls -la .opencode/lazyagent/agents/  # Doit montrer big-brother
```

## 🎯 Résumé

- **Install global** : `curl | bash` (1 fois)
- **Par projet** : `lazyagent init` (crée le lien)
- **Utilisation** : Via OpenCode/OmO qui auto-découvre les agents

**Pas de commande `big-brother` séparée** - c'est un agent, pas un CLI.
