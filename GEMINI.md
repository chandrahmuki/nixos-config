# Configuration Gemini CLI - NixOS Project

> [!NOTE]
> Je dispose de compétences spécialisées (Skills) situées dans `.gemini/skills/`. Elles complètent ces règles de base et sont prioritaires.

<global_directives>
  <directive>Utiliser les outils natifs (`list_dir`, `read_file`, `grep_search`, `glob`) en priorité absolue. Interdiction d'utiliser `ls` ou `cat` dans le terminal.</directive>
  <directive>Garder le workspace 100% propre : zéro création de dossier ou fichier caché inutile (ex: `.vscode`, `.tmp`) sans demande explicite. Vérifier avec `ls -a` en fin de tâche.</directive>
  <directive>Budget d'actions : max 5-10 appels d'outils pour la documentation. Si une commande échoue après 2 tentatives, arrêter et demander l'avis de l'utilisateur.</directive>
  <directive>Analyse chirurgicale : Ne lire QUE les fichiers modifiés via `git show --stat` ou `git log -n 1 --stat`. Pas de recherche profonde dans l'historique sans demande explicite.</directive>
</global_directives>

<token_management_policy>
  <rule priority="critical">Budget Control : Interdiction de scanner la racine du projet (`./`) ou de lire l'intégralité de la codebase. Utiliser `grep_search` ou `list_dir` pour cibler uniquement le nécessaire.</rule>
  <rule>Recherche Chirurgicale : Utiliser systématiquement `names_only=true` pour localiser des fichiers avant de lire leur contenu.</rule>
  <rule>Lecture Fragmentée : Pour tout fichier > 100 lignes, utiliser obligatoirement `limit` et `offset` dans `read_file` pour ne charger que les sections pertinentes.</rule>
  <rule>Diff over Read : Préférer `git diff` ou `git show` pour comprendre une modification récente plutôt que de relire le fichier entier.</rule>
  <rule>Optimisation du Contexte : Ne jamais charger de fichiers volumineux non essentiels (ex: `flake.lock`, dossiers `.git`, logs de build).</rule>
  <rule>Hygiène de Session : L'agent DOIT suggérer un `[/context-switch]` de manière préventive (toutes les 10-15 interactions ou à la fin de chaque sous-tâche logique), BIEN AVANT que le contexte ne sature. L'objectif est de maintenir une "mémoire de travail" minimaliste et ultra-performante en permanence.</rule>
</token_management_policy>

<nixos_workflow>
  <rule priority="critical">OBLIGATION d'utiliser l'outil `mcp_nixos_nix` AVANT toute recherche web pour les options NixOS/Home Manager ou les paquets. Utiliser `fetch` uniquement si le MCP échoue.</rule>
  <rule>Précision absolue : Ne jamais deviner le nom ou le format d'une option NixOS. Toujours valider son existence exacte via le MCP pour ne pas casser le build.</rule>
  <rule>Toujours commenter le code Nix pour expliquer *pourquoi* une option spécifique est utilisée, surtout si elle est inhabituelle ou liée à CachyOS.</rule>
</nixos_workflow>

<git_workflow>
  <rule priority="critical">Nix Flakes : TOUJOURS exécuter `git add <fichier>` pour les nouveaux fichiers, sinon Nix ne les verra pas dans le sandbox (erreur "path does not exist").</rule>
  <rule priority="critical">Itération Sécurisée : À CHAQUE étape d'une itération complexe (avant d'appliquer une nouvelle modification), faire un `git add` et un `git commit`. Cela garantit un point de restauration (revert) en cas d'échec ou de régression.</rule>
  <rule>Routine après modification fonctionnelle : `git add .` suivi d'un `git commit` avec un message descriptif approprié.</rule>
  <rule>Post-Installation : Toujours lancer le workflow `[/git-sync]` après l'installation d'un nouveau module.</rule>
</git_workflow>

<rad_gsd_principles>
  <rule priority="high">Vitesse d'Exécution : Prioriser le code fonctionnel sur la documentation exhaustive. Documenter via des KIs uniquement une fois la feature stable.</rule>
  <rule>Prototypage Silencieux : Création libre de fichiers de test ou de brouillon dans `.gemini/tmp/` sans confirmation préalable.</rule>
  <rule>Surgical Actions : Préférer une modification `replace` unique et précise sur plusieurs blocs plutôt que des cycles de lecture/écriture complets.</rule>
  <rule>Autonomie de Validation : Lancer systématiquement les commandes de vérification locales (`nix check`, `just check`) après une modification structurelle sans demander permission.</rule>
</rad_gsd_principles>

<system_commands>
  <command name="nos">`nos` - The ONLY command to apply NixOS/Home-Manager changes. Built-in fish function: `nh os switch . --hostname muggy-nixos --ask -L --diff always`.</command>
  <command name="flake update global">`nix flake update nixpkgs home-manager niri noctalia antigravity` (Followed by `nos` to apply).</command>
  <command name="flake update kernel">`nix flake update nix-cachyos` (Followed by `nos` to apply).</command>
</system_commands>

<roles_and_knowledge>
  <roles>
    <role name="Codeur">Moi-même. Focus 100% sur l'implémentation et la vérification fonctionnelle (tests).</role>
    <role name="Auditeur">Focus 100% sur la qualité, la propreté du code (Audit) et la conformité aux règles. Ne fait aucune modification.</role>
    <role name="Archiviste">Focus 100% sur la documentation et les Knowledge Items.</role>
    <process>Le Codeur passe le relais à l'Auditeur ou à l'Archiviste via le workflow `/auto-doc`.</process>
  </roles>
  <knowledge_management>
    <definition>`./docs/` est pour les humains (fiches, guides). `./.gemini/knowledge/` est pour la mémoire IA (Knowledge Items - KI).</definition>
    <rule priority="high">Consommation Obligatoire : Avant de rédiger quoi que ce soit, VÉRIFIER si un KI existe déjà sur le sujet pour le mettre à jour au lieu d'en créer un nouveau.</rule>
    <rule priority="high">Priorité KI : Pour toute modification technique structurelle, la création ou mise à jour d'un KI est prioritaire sur la documentation markdown classique.</rule>
  </knowledge_management>
</roles_and_knowledge>
