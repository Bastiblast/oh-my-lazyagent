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

Cela crée :
- Un symlink `.opencode/lazyagent` → installation globale
- Un fichier `.opencode/lazyagent.json` avec la configuration des agents pour OpenCode

### Étape 3: Activer dans OpenCode (VS Code/Cursor)

Dans votre éditeur avec l'extension OpenCode :

1. **Vérifiez que le fichier existe** :
   ```bash
   ls -la .opencode/lazyagent.json
   # Doit montrer le fichier avec la config de big-brother
   ```

2. **Rechargez la fenêtre OpenCode** (si nécessaire) :
   - Command Palette → "Developer: Reload Window"
   - Ou redémarrez VS Code/Cursor

3. **Vérifiez que l'agent est disponible** :
   ```bash
   cat .opencode/lazyagent.json | grep big-brother
   # Doit montrer la configuration de big-brother
   ```

### Étape 4: Utiliser Big-Brother

Une fois activé, utilisez Big-Brother dans vos conversations avec Sisyphus :

```typescript
// Si Sisyphus est bloqué après 3 échecs
// Big-Brother est automatiquement invoqué via category="escalation"

task(category="escalation", prompt=`
  Problème: [votre problème ici]
  Contexte: [erreurs précédentes]
  Fichiers modifiés: [liste]
`)
```

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

## 🔍 Dépannage OpenCode

### Problème : OpenCode ne voit pas les agents

**Symptôme** : Le fichier `.opencode/lazyagent.json` existe mais OpenCode ne détecte pas big-brother.

**Solutions** :

1. **Vérifier la structure** :
   ```bash
   # Doit montrer:
   # .opencode/lazyagent.json (config)
   # .opencode/lazyagent/ -> ~/.config/opencode/lazyagent (symlink)
   ls -la .opencode/
   
   # Doit montrer big-brother/
   ls .opencode/lazyagent/lazyagent/agents/
   ```

2. **Vérifier le contenu JSON** :
   ```bash
   cat .opencode/lazyagent.json
   # Doit contenir "agents" avec "big-brother"
   ```

3. **Si le fichier n'existe pas, recréez-le** :
   ```bash
   lazyagent init  # Recrée le fichier
   ```

4. **Manuellement** (si `lazyagent init` ne fonctionne pas) :
   ```bash
   cat > .opencode/lazyagent.json <<'EOF'
{
  "agents": {
    "big-brother": {
      "path": ".opencode/lazyagent/lazyagent/agents/big-brother",
      "enabled": true,
      "category": "escalation"
    }
  }
}
EOF
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
