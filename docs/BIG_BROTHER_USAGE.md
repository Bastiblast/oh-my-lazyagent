# Utilisation de Big-Brother Agent

## 🧠 Qu'est-ce que Big-Brother ?

Big-Brother est un **agent d'escalade senior** pour oh-my-openagent. Il prend le relais quand Sisyphus est bloqué après 3 échecs consécutifs.

## 📦 Installation

```bash
# Installation complète (inclut Big-Brother)
curl -fsSL https://raw.githubusercontent.com/Bastiblast/oh-my-lazyagent/main/scripts/install.sh | bash

# Ajoutez au PATH
export PATH="$HOME/.local/bin:$PATH"
```

## 🚀 Utilisation

### 1. **Via la commande `big-brother`** (directe)

```bash
# Voir les informations sur Big-Brother
big-brother

# Output:
# 🧠 Big-Brother Agent
#    Senior escalation agent for unresolvable problems
#    
#    Usage with oh-my-openagent:
#    task(category="escalation", prompt="your task here")
```

### 2. **Via `lazyagent` command**

```bash
# Valider que Big-Brother est correctement installé
lazyagent validate agents/big-brother

# Output: Validation PASSED
```

### 3. **Via oh-my-openagent (OmO)**

Quand OmO est installé avec les patches, Big-Brother est automatiquement disponible comme subagent :

```typescript
// Dans votre code ou configuration OmO
task(category="escalation", prompt=`
  Task: [votre tâche ici]
  
  Contexte: 
  - Sisyphus a échoué 3 fois
  - Erreurs précédentes: [liste des erreurs]
  - Fichiers modifiés: [liste des fichiers]
`)
```

### 4. **Dans les prompts Sisyphus**

Le patch `sisyphus-escalation.patch` modifie Sisyphus pour automatiquement appeler Big-Brother après 3 échecs.

## ⚙️ Configuration

### Configuration de l'agent

Fichier: `~/.config/opencode/lazyagent/lazyagent/agents/big-brother/config.json`

```json
{
  "name": "big-brother",
  "version": "1.0.0",
  "description": "Senior escalation agent for unresolvable problems",
  "model": "opencode-go/glm-5",
  "fallback_models": [
    { "model": "opencode-go/kimi-k2.2.5" }
  ],
  "temperature": 0.2,
  "thinking": {
    "type": "enabled",
    "budgetTokens": 8000
  },
  "category": "escalation",
  "mode": "subagent",
  "permissions": {
    "read": "allow",
    "edit": "allow",
    "bash": "allow",
    "task": "allow",
    "webfetch": "allow"
  },
  "triggers": {
    "boulder_threshold": 3,
    "consecutive_failures": 3
  }
}
```

### Modèle et permissions

- **Modèle**: `opencode-go/glm-5` (configurable)
- **Fallback**: `opencode-go/kimi-k2.5` si glm-5 n'est pas disponible
- **Permissions**: Lecture, écriture, bash, task, webfetch - tout est autorisé pour un maximum de flexibilité
- **Mode**: `subagent` - peut être appelé par d'autres agents

## 🔧 Intégration avec OmO

### Étape 1: Installer OmO (si pas déjà fait)

```bash
# Installez oh-my-openagent selon leur documentation
```

### Étape 2: Appliquer les patches

```bash
# Les patches sont dans ~/.config/opencode/lazyagent/patches/
cd ~/.config/opencode/lazyagent/patches
./apply.sh
```

### Étape 3: Vérifier l'intégration

```bash
# Redémarrez OmO ou rechargez la configuration
# Big-Brother devrait maintenant être disponible dans la liste des agents
```

## 📊 Flow d'escalade automatique

```
Sisyphus exécute une tâche
    ↓ Échec #1
    Sisyphus réessaie
    ↓ Échec #2  
    Sisyphus réessaie encore
    ↓ Échec #3
    
    [SEUIL ATTEINT - 3 échecs]
    
    ↓
    Sisyphus génère un rapport d'escalade
    ↓
    task(category="escalation", prompt=rapport)
    ↓
    Big-Brother reçoit le rapport
    ↓
    Big-Brother analyse et répond avec un plan de debug
    ↓
    Sisyphus reçoit le plan et continue
```

## 📝 Exemple de rapport d'escalade

```typescript
const escalationReport = {
  timestamp: "2025-01-18T10:30:00Z",
  task_description: "Implémenter l'authentification JWT",
  failure_count: 3,
  error_history: [
    "TypeError: Cannot read property 'sign' of undefined",
    "Error: JWT secret not configured", 
    "ReferenceError: jwt is not defined"
  ],
  files_modified: [
    "/src/auth/jwt.ts",
    "/src/config/auth.ts"
  ],
  previous_approaches: [
    "Installé jsonwebtoken via npm",
    "Configuré JWT_SECRET dans .env",
    "Modifié le middleware d'auth"
  ]
};
```

## 🎮 Exemple d'utilisation manuelle

Si vous voulez utiliser Big-Brother directement sans attendre les 3 échecs :

```bash
# Via lazyagent
lazyagent help

# Voir la config de Big-Brother
cat ~/.config/opencode/lazyagent/lazyagent/agents/big-brother/config.json

# Voir le prompt système
cat ~/.config/opencode/lazyagent/lazyagent/agents/big-brother/agent.md
```

## 🔍 Dépannage

### Problème: Big-Brother n'est pas disponible

**Cause**: Les patches OmO ne sont pas appliqués ou OmO n'est pas installé.

**Solution**:
```bash
# Vérifiez que lazyagent est installé
which lazyagent

# Vérifiez la structure
lazyagent validate-all

# Si OmO est installé, appliquez les patches
cd ~/.config/opencode/lazyagent/patches
./apply.sh
```

### Problème: Permission denied

**Solution**:
```bash
chmod +x ~/.config/opencode/lazyagent/scripts/*.sh
chmod +x ~/.config/opencode/lazyagent/patches/apply.sh
```

## 📚 Ressources

- [Documentation Architecture](../docs/architecture.md)
- [Configuration de l'agent](../lazyagent/agents/big-brother/config.json)
- [Prompt système](../lazyagent/agents/big-brother/agent.md)

---

**Big-Brother est prêt à vous aider quand Sisyphus est coincé !** 🧠
