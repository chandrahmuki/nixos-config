---
description: Installer un serveur MCP / Skill de façon déclarative sur NixOS
---

# Workflow: `/add-mcp`

Ce workflow est conçu pour remplacer des outils instables (comme `skillfish`) par l'intelligence de l'Agent IA.
L'utilisateur te demandera d'installer un MCP via `/add-mcp <nom-ou-url>`.

## Étapes Obligatoires pour l'Agent (Toi) :

1. **Choix de la Cible**
   - Demande *toujours* à l'utilisateur : "Veux-tu installer ce MCP pour **Gemini CLI**, pour **Antigravity (IDE)**, ou **les deux** ?"
   - Attends sa réponse avant de continuer.

2. **Recherche Intelligente du MCP (Discovery)**
   - Si l'utilisateur donne un nom générique (ex: "Nix CI"), utilise impérativement l'outil `fetch` (fourni par le MCP `fetch-mcp` que tu as installé) pour lire le contenu des pages de recherche comme `https://skill.fish/search?q=...` ou `https://mcpmarket.com`. Cela permet de scraper rapidement sans subir les erreurs 429 de tes outils natifs et sans la lourdeur du `browser_subagent`.
   - Une fois le dépôt officiel du MCP trouvé sur GitHub ou npmjs :
   - Lis le `README.md` ou le `package.json` pour comprendre comment ce MCP se lance (ex: `npx -y @modelcontextprotocol/server-postgres`).
   - Identifie si ce MCP a des dépendances binaires critiques (ex: Python, Chromium/Playwright, sqlite).

3. **Application Déclarative (selon la cible)**
   - **Cible: Gemini CLI**
     - Ouvre `modules/gemini.nix`.
     - Ajoute les paquets binaires requis dans la liste `home.packages`.
     - Injecte proprement la structure JSON attendue dans `home.file."Documents/P-Project/.gemini/settings.json".text` sous `mcpServers`.
   - **Cible: Antigravity IDE**
     - Ouvre `.agent/mcp_config.json` à la racine de `nixos-config`.
     - Injecte le serveur dans la clé `mcpServers`. (Antigravity lira ce fichier dynamiquement).

4. **Synchronisation et Instructions**
   - Lancer le script de synchronisation `/git-sync` en arrière-plan.
   - Demander à l'utilisateur de lancer la commande `nos` (alias pour `nh os switch`) si `gemini.nix` a été modifié.
   - Lui demander de relancer son Agent Gemini ou son IDE Antigravity.
