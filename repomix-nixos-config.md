This file is a merged representation of the entire codebase, combined into a single document by Repomix.

<file_summary>
This section contains a summary of this file.

<purpose>
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.
</purpose>

<file_format>
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  - File path as an attribute
  - Full contents of the file
</file_format>

<usage_guidelines>
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.
</usage_guidelines>

<notes>
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)
</notes>

</file_summary>

<directory_structure>
.agent/
  skills/
    commit-pro/
      SKILL.md
    knowledge-archivist/
      SKILL.md
    nix-flake-maintainer/
      SKILL.md
    nixos-architect/
      references/
        gaming/
          gaming-expertise.md
        nvme/
          nvme-transition.md
      SKILL.md
    nixos-auditor/
      SKILL.md
    nixos-flakes/
      references/
        best-practices.md
        dev-environments.md
        flakes.md
        home-manager.md
        nix-language.md
        nixpkgs-advanced.md
        templates.md
      SKILL.md
    nixos-project-manager/
      SKILL.md
    nixos-research-strategy/
      SKILL.md
    scratchpad/
      references/
        examples.md
      scripts/
        scratch_pad.py
      SKILL.md
  workflows/
    archive.md
    audit.md
    auto-doc.md
    full-index.md
    git-sync.md
.direnv/
  bin/
    nix-direnv-reload
docs/
  brave.md
  tealdeer.md
  triple-relay.md
generated/
  fuzzel.ini
  mako
  yazi.toml
hosts/
  muggy-nixos/
    default.nix
    hardware-configuration.nix
modules/
  antigravity-settings.json
  antigravity.nix
  atuin.nix
  brave-system.nix
  brave.nix
  btop.nix
  direnv.nix
  discord.nix
  fastfetch.nix
  font.nix
  fuzzel.nix
  git.nix
  lact.nix
  music-menu.nix
  neovim.nix
  nh.nix
  noctalia.nix
  notifications.nix
  parsec.nix
  pdf.nix
  steam.nix
  tealdeer.nix
  terminal.nix
  utils.nix
  vscode.nix
  xdg.nix
  yazi.nix
  yt-dlp.nix
nvim/
  lua/
    core/
      init.lua
      keymaps.lua
      options.lua
    plugins/
      better-escape.lua
      bufferline.lua
      completion.lua
      crates.lua
      flash.lua
      icons.lua
      lsp.lua
      mason.lua
      move.lua
      rustaceanvim.lua
      snacks.lua
      treesitter.lua
      ui.lua
      whichkey.lua
  .stylua.toml
  init.lua
templates/
  fuzzel.conf
  mako.conf
  matugen.toml
  yazi.conf
wm/
  binds.nix
  niri.nix
  style.nix
.gitignore
flake.lock
flake.nix
GEMINI.md
home.nix
install.sh
overlays.nix
README.md
</directory_structure>

<files>
This section contains the contents of the repository's files.

<file path=".agent/skills/commit-pro/SKILL.md">
---
name: commit-pro
description: Maître des messages de commit, assurant un historique Git propre et professionnel.
---

# Commit Pro Skill

Cette compétence impose l'utilisation des **Conventional Commits** pour maintenir un historique clair et exploitable.

## Format des messages
Chaque commit doit suivre la structure : `<type>(<scope>): <description>`

### Types autorisés
- **feat**: Une nouvelle fonctionnalité (ex: un nouveau module).
- **fix**: Correction d'un bug ou d'un problème de config.
- **docs**: Changement dans la documentation ou les commentaires.
- **style**: Changement de mise en forme (espace, virgule) sans impact fonctionnel.
- **refactor**: Modification du code qui ne change pas le comportement.
- **perf**: Amélioration des performances.

## Règles d'or
1. Message court et explicite (max 72 caractères pour la première ligne).
2. Toujours en anglais (standard de l'industrie).
3. Décrire l'intention du changement.

---
*Note: Cette compétence est activée avant chaque exécution de la commande `git commit`.*
</file>

<file path=".agent/skills/nix-flake-maintainer/SKILL.md">
---
name: nix-flake-maintainer
description: Expert in NixOS system maintenance, focusing on safe flake updates, garbage collection, and configuration health.
---

# nix-flake-maintainer

You are an expert at maintaining NixOS systems. Your primary goal is to keep the system up-to-date and healthy while strictly following the user's update policies.

## Core Responsibilities

1.  **Safe Flake Updates**:
    -   Perform `nix flake update` for specific inputs as requested.
    -   **CRITICAL**: Follow the rules in `GEMINI.md`. Specifically:
        -   To update most things: `nix flake update nixpkgs home-manager niri noctalia antigravity`.
        -   To update the kernel (nix-cachyos): Only upon explicit request or if essential.
    -   After updates, advise the user to run `nos` (alias for `nh os switch`) in an external terminal.

2.  **Storage Management**:
    -   Monitor and suggest garbage collection when needed.
    -   Use `nh clean all` or `nix-collect-garbage -d`.
    -   Explain the impact of cleaning (e.g., losing the ability to rollback to certain versions).

3.  **Rollback Management**:
    -   Help the user troubleshoot issues after an update.
    -   Suggest using `boot.loader.systemd-boot.configurationLimit` if the boot menu is too cluttered.

4.  **Configuration Health**:
    -   Identify redundant or deprecated options in `flake.nix` and `home.nix`.
    -   Ensure `nh` (Nix Helper) is used for building and cleaning as it's the user's preferred tool.

## Standard Procedures

-   **Before Updating**: Always check `flake.lock` to see current versions.
-   **After Updating**: Remind the user about the `nos` command.
-   **When cleaning**: Summarize how much space was freed if possible.

## Interaction Style

-   Be proactive but cautious.
-   Always explain *what* will be updated before running the command.
-   Comment every change in the configuration files as per the "Commentaires et Clarté" rule.
</file>

<file path=".agent/skills/nixos-architect/references/gaming/gaming-expertise.md">
# Expertise NixOS : Gaming & Performance (GPU AMD)

## Contexte Matériel (David)
- **GPU** : AMD Radeon (Série 7000 suggérée par le contexte ReBAR).
- **VRAM** : 16 Go.
- **Kernel** : CachyOS (par défaut pour la performance).

## Optimisations de Base (Validées)

### 1. Resizable BAR (ReBAR)
- **État** : Doit être activé dans le BIOS et vérifié via `boot.kernelParams`.
- **NixOS Option** : Nécessite souvent `amdgpu.noretry=0` ou des réglages spécifiques pour éviter les stutterings en mode 16Go.
- **Vérification** : `dmesg | grep BAR`

### 2. NTSYNC (Sync Haute Performance)
- **Usage** : Alternative à Fsync/Esync pour Proton.
- **NixOS Configuration** :
  ```nix
  services.ntsync.enable = true;
  ```
- **Proton custom** : Utiliser des versions de Proton supportant NTSYNC pour un gain de fluidité dans PoE2 et Elden Ring.

### 3. Gestion de la VRAM (16 Go)
- **Problématique** : Éviter les débordements (Overflow) qui causent des chutes brutales de FPS.
- **Réglages Mesa** : `RADV_PERFTEST=gpl` (activé par défaut sur les versions récentes mais bon à garder en tête).

## Patterns de Debugging
1. **Stuttering** : Vérifier en premier le scheduler (SCX de CachyOS) et les versions de Proton.
2. **I/O Latency** : Utiliser les optimisations de disque (NVMe) présentes dans `modules/utils.nix`.

## Sources de Référence
- [CachyOS Wiki - Gaming](https://wiki.cachyos.org/configuration/gaming/)
- [NixOS Wiki - NVIDIA/AMD](https://nixos.wiki/wiki/AMD_GPU)
</file>

<file path=".agent/skills/scratchpad/references/examples.md">
# Scratch Pad Usage Examples

## Basic Research Task

```bash
# Initialize
SCRATCH="/tmp/scratch_research.md"
python scripts/scratch_pad.py --file $SCRATCH init "Competitor Analysis"

# Log searches
python scripts/scratch_pad.py --file $SCRATCH log-tool "web_search" '{"query": "competitor A"}' "Found 10 results"
python scripts/scratch_pad.py --file $SCRATCH finding "Competitor A has 30% market share" --category "Market"

python scripts/scratch_pad.py --file $SCRATCH log-tool "web_search" '{"query": "competitor B"}' "Found 8 results"  
python scripts/scratch_pad.py --file $SCRATCH finding "Competitor B focuses on enterprise" --category "Market"

# Add summary
python scripts/scratch_pad.py --file $SCRATCH summary "Three main competitors identified with different market strategies"

# Read for response
python scripts/scratch_pad.py --file $SCRATCH read
```

## Multi-Step Processing

```bash
# Initialize
SCRATCH="/tmp/scratch_process.md"
python scripts/scratch_pad.py --file $SCRATCH init "Data Processing Pipeline"

# Step 1: Load
python scripts/scratch_pad.py --file $SCRATCH section "Step 1: Load Data"
python scripts/scratch_pad.py --file $SCRATCH log-tool "file_read" '{"path": "data.csv"}' "Loaded 1000 rows"
python scripts/scratch_pad.py --file $SCRATCH checkpoint "Data loaded"

# Step 2: Process  
python scripts/scratch_pad.py --file $SCRATCH section "Step 2: Process Data"
python scripts/scratch_pad.py --file $SCRATCH append "Removed 50 duplicate rows"
python scripts/scratch_pad.py --file $SCRATCH append "Applied normalization"
python scripts/scratch_pad.py --file $SCRATCH checkpoint "Processing complete"

# Step 3: Save
python scripts/scratch_pad.py --file $SCRATCH section "Step 3: Save Results"
python scripts/scratch_pad.py --file $SCRATCH log-tool "file_write" '{"path": "output.csv"}' "Saved 950 rows"

# Mark complete
python scripts/scratch_pad.py --file $SCRATCH complete
```

## Document Analysis

```bash
# Initialize
SCRATCH="/tmp/scratch_docs.md"
python scripts/scratch_pad.py --file $SCRATCH init "Confluence Documentation Review"

# Process each page
python scripts/scratch_pad.py --file $SCRATCH section "Main Page Analysis"
python scripts/scratch_pad.py --file $SCRATCH log-tool "confluence_read" '{"page_id": "123"}' "Read main page"
python scripts/scratch_pad.py --file $SCRATCH finding "Main page covers project overview"

python scripts/scratch_pad.py --file $SCRATCH section "Child Pages"
python scripts/scratch_pad.py --file $SCRATCH todo "Review technical specs page"
python scripts/scratch_pad.py --file $SCRATCH todo "Check API documentation" 
python scripts/scratch_pad.py --file $SCRATCH todo "Update outdated examples" --done

# Summary
python scripts/scratch_pad.py --file $SCRATCH summary "Documentation is mostly complete but needs updates in 3 areas"
```

## Quick Patterns

### Finding Pattern
```bash
python scripts/scratch_pad.py --file $SCRATCH finding "Discovery text" --category "Category"
```

### Tool Logging Pattern
```bash
# Before execution
python scripts/scratch_pad.py --file $SCRATCH log-tool "tool_name" '{"params": "value"}' ""
# After execution  
python scripts/scratch_pad.py --file $SCRATCH append "Result: Success with X items"
```

### Section Organization
```bash
python scripts/scratch_pad.py --file $SCRATCH section "Phase 1: Research"
# ... add content ...
python scripts/scratch_pad.py --file $SCRATCH section "Phase 2: Analysis"  
# ... add content ...
python scripts/scratch_pad.py --file $SCRATCH section "Phase 3: Conclusions"
```
</file>

<file path=".agent/skills/scratchpad/scripts/scratch_pad.py">
#!/usr/bin/env python3
"""
Scratch Pad Manager (Markdown Version) - Direct markdown file management for long-running tasks

Module usage:
    from scripts.scratch_pad_md import ScratchPadManager
    
    manager = ScratchPadManager('/tmp/scratch.md')
    manager.init("My Task")
    manager.add_section("## Research Findings")
    manager.append("Found 3 key competitors...")
    manager.log_tool("web_search", {"query": "AI trends"}, "Found 10 results")

CLI usage:
    python scripts/scratch_pad.py init "My Task" 
    python scripts/scratch_pad.py append "## Section Title"
    python scripts/scratch_pad.py append "Content to add..."
    python scripts/scratch_pad.py log-tool "web_search" '{"query": "test"}' "Result text"
"""

import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Any
import argparse
import json

class ScratchPadManager:
    """Markdown-based scratch pad manager"""
    
    def __init__(self, pad_file: str = "/tmp/scratch_pad.md"):
        """Initialize scratch pad manager
        
        Args:
            pad_file: Path to the markdown file
        """
        self.pad_file = Path(pad_file)
        
    def init(self, task_name: str = "Untitled Task") -> Dict[str, Any]:
        """Initialize a new scratch pad with header
        
        Args:
            task_name: Name of the task
            
        Returns:
            Dict with status and message
        """
        # Ensure directory exists
        self.pad_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Create initial content
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        content = f"""# 📋 {task_name}

**Created:** {timestamp}  
**Status:** 🔄 In Progress

---

## 📝 Task Overview
Task: {task_name}
Started: {timestamp}

---

"""
        
        with open(self.pad_file, 'w', encoding='utf-8') as f:
            f.write(content)
            
        return {
            "status": "success",
            "message": f"Initialized scratch pad: {task_name}",
            "file": str(self.pad_file)
        }
    
    def append(self, content: str) -> Dict[str, Any]:
        """Append content to the scratch pad
        
        Args:
            content: Content to append (can include markdown formatting)
            
        Returns:
            Dict with status
        """
        # Add timestamp if content is not a header
        if not content.strip().startswith('#'):
            timestamp = datetime.now().strftime("%H:%M:%S")
            content = f"[{timestamp}] {content}"
        
        # Ensure file exists
        if not self.pad_file.exists():
            self.init()
        
        with open(self.pad_file, 'a', encoding='utf-8') as f:
            f.write(content + "\n\n")
            
        return {"status": "success", "message": "Content appended"}
    
    def add_section(self, title: str) -> Dict[str, Any]:
        """Add a new section with timestamp
        
        Args:
            title: Section title (will be formatted as ## header)
        """
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        # Ensure it's a proper header
        if not title.startswith('#'):
            title = f"## {title}"
            
        content = f"{title} ({timestamp})\n"
        return self.append(content)
    
    def log_tool(self, tool_name: str, parameters: Dict[str, Any], result: str = "") -> Dict[str, Any]:
        """Log a tool call in markdown format
        
        Args:
            tool_name: Name of the tool
            parameters: Tool parameters
            result: Tool result (as string)
        """
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        # Format as collapsible detail
        content = f"""### 🔧 [{timestamp}] Tool: {tool_name}

**Parameters:**
```json
{json.dumps(parameters, indent=2, ensure_ascii=False)}
```

**Result:**
```
{result if result else "⏳ Pending..."}
```

---"""
        
        return self.append(content)
    
    def add_finding(self, finding: str, category: str = "General") -> Dict[str, Any]:
        """Add a key finding or observation
        
        Args:
            finding: The finding text
            category: Category of finding
        """
        timestamp = datetime.now().strftime("%H:%M:%S")
        content = f"**[{timestamp}] {category}:** {finding}"
        return self.append(content)
    
    def add_checkpoint(self, name: str, description: str = "") -> Dict[str, Any]:
        """Add a checkpoint/milestone marker
        
        Args:
            name: Checkpoint name
            description: Optional description
        """
        timestamp = datetime.now().strftime("%H:%M:%S")
        content = f"""---

### ✅ Checkpoint: {name}
**Time:** {timestamp}  
{description}

---"""
        return self.append(content)
    
    def add_summary(self, summary: str) -> Dict[str, Any]:
        """Add a summary section
        
        Args:
            summary: Summary text
        """
        content = f"""## 📊 Summary

{summary}

---"""
        return self.append(content)
    
    def add_todo(self, task: str, completed: bool = False) -> Dict[str, Any]:
        """Add a TODO item
        
        Args:
            task: Task description
            completed: Whether task is completed
        """
        checkbox = "✅" if completed else "⬜"
        content = f"- {checkbox} {task}"
        return self.append(content)
    
    def read(self) -> str:
        """Read the entire scratch pad content"""
        if not self.pad_file.exists():
            return ""
        
        with open(self.pad_file, 'r', encoding='utf-8') as f:
            return f.read()
    
    def get_size(self) -> int:
        """Get file size in bytes"""
        if not self.pad_file.exists():
            return 0
        return self.pad_file.stat().st_size
    
    def complete(self) -> Dict[str, Any]:
        """Mark the task as complete"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        content = f"""---

## ✅ Task Complete

**Completed:** {timestamp}  
**Status:** ✅ Complete

---"""
        return self.append(content)


def main():
    """CLI interface for markdown scratch pad"""
    parser = argparse.ArgumentParser(description="Markdown Scratch Pad Manager")
    parser.add_argument("--file", default="/tmp/scratch_pad.md", help="Path to scratch pad file")
    
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # Init command
    init_parser = subparsers.add_parser("init", help="Initialize new scratch pad")
    init_parser.add_argument("task_name", nargs="?", default="Untitled Task", help="Name of the task")
    
    # Append command
    append_parser = subparsers.add_parser("append", help="Append content")
    append_parser.add_argument("content", help="Content to append")
    
    # Section command
    section_parser = subparsers.add_parser("section", help="Add a new section")
    section_parser.add_argument("title", help="Section title")
    
    # Log tool command
    log_parser = subparsers.add_parser("log-tool", help="Log a tool call")
    log_parser.add_argument("tool_name", help="Tool name")
    log_parser.add_argument("parameters", help="Parameters (JSON)")
    log_parser.add_argument("--result", default="", help="Result")
    
    # Finding command
    finding_parser = subparsers.add_parser("finding", help="Add a finding")
    finding_parser.add_argument("finding", help="Finding text")
    finding_parser.add_argument("--category", default="General", help="Category")
    
    # Checkpoint command
    checkpoint_parser = subparsers.add_parser("checkpoint", help="Add checkpoint")
    checkpoint_parser.add_argument("name", help="Checkpoint name")
    checkpoint_parser.add_argument("--description", default="", help="Description")
    
    # TODO command
    todo_parser = subparsers.add_parser("todo", help="Add TODO item")
    todo_parser.add_argument("task", help="Task description")
    todo_parser.add_argument("--done", action="store_true", help="Mark as done")
    
    # Summary command
    summary_parser = subparsers.add_parser("summary", help="Add summary")
    summary_parser.add_argument("text", help="Summary text")
    
    # Read command
    read_parser = subparsers.add_parser("read", help="Read entire pad")
    
    # Complete command
    complete_parser = subparsers.add_parser("complete", help="Mark task complete")
    
    args = parser.parse_args()
    
    manager = ScratchPadManager(args.file)
    
    if args.command == "init":
        result = manager.init(args.task_name)
        print(f"✅ {result['message']}")
        
    elif args.command == "append":
        manager.append(args.content)
        print("✅ Content appended")
        
    elif args.command == "section":
        manager.add_section(args.title)
        print(f"✅ Section added: {args.title}")
        
    elif args.command == "log-tool":
        try:
            params = json.loads(args.parameters)
        except:
            params = {"raw": args.parameters}
        manager.log_tool(args.tool_name, params, args.result)
        print(f"✅ Logged tool: {args.tool_name}")
        
    elif args.command == "finding":
        manager.add_finding(args.finding, args.category)
        print(f"✅ Finding added: {args.category}")
        
    elif args.command == "checkpoint":
        manager.add_checkpoint(args.name, args.description)
        print(f"✅ Checkpoint: {args.name}")
        
    elif args.command == "todo":
        manager.add_todo(args.task, args.done)
        print(f"✅ TODO added")
        
    elif args.command == "summary":
        manager.add_summary(args.text)
        print("✅ Summary added")
        
    elif args.command == "read":
        content = manager.read()
        print(content)
        
    elif args.command == "complete":
        manager.complete()
        print("✅ Task marked complete")
        
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
</file>

<file path=".agent/skills/scratchpad/SKILL.md">
---
name: scratchpad
description: |
  Mémoire vive au format Markdown pour les tâches complexes. À utiliser quand : plus de 5 appels d'outils sont nécessaires, en cas de recherche multi-sources, ou pour des analyses comparatives. 
  Enregistrer le processus → S'y référer pour la réponse → Archiver après usage.
---

# Scratchpad - Mémoire de Travail Avancée (Style Kira)

Le scratchpad est un outil interne permettant de suivre l'avancement d'une tâche complexe sans perdre le fil technique. Cette version améliorée utilise un script Python pour automatisé l'horodatage et la structuration.

## Structure du Skill

- `scripts/scratch_pad.py` : Moteur de journalisation (CLI).
- `references/examples.md` : Modèles d'utilisation.

## Utilisation via CLI

Le script Python permet de gérer le scratchpad de manière structurée :

1.  **Initialisation** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] init "[Task Name]"`
2.  **Journalisation d'outil** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] log-tool "tool_name" '{"param": "val"}' --result "Output"`
3.  **Ajout de découverte** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] finding "Texte de la découverte" --category "Genre"`
4.  **Points de passage** : 
    `python3 .agent/skills/scratchpad/scripts/scratch_pad.py --file [PATH] checkpoint "Nom de l'étape"`

## Patterns Recommandés

Voir [examples.md](file:///home/david/nixos-config/.agent/skills/scratchpad/references/examples.md) pour les détails sur les patterns :
- **Recherche** : Log des outils et findings.
- **Multi-étapes** : Sections et checkpoints.
- **Analyse** : TODOs et résumés.

## Règles de Conduite

- **Référence interne uniquement** : Ne jamais copier-coller le scratchpad brut dans la réponse à l'utilisateur.
- **Synthèse** : Extraire uniquement les points pertinents pour l'utilisateur.
- **Nomenclature** : Toujours utiliser des chemins absolus pour les fichiers cités.
- **Persistence** : Le fichier doit être créé dans le dossier des artifacts de la session (`/home/david/.gemini/antigravity/brain/[ID]/`).
</file>

<file path=".agent/workflows/git-sync.md">
---
description: Synchroniser les changements avec Git (Add, Review, Commit, Pull, Push)
---

Ce workflow automatise la synchronisation complète. Il inclut désormais une phase de **Code Review** pour garantir la qualité avant le commit.

// turbo-all
1. Préparer les changements
```bash
git add .
```

2. Revue de Code Automatisée
L'assistant analyse les changements indexés, vérifie la conformité avec `GEMINI.md` et propose des optimisations via le skill `architect`.
```bash
git diff --cached --stat
# [INTERNAL REVIEW] : L'IA analyse maintenant le contenu détaillé de ces fichiers...
```

3. Créer un commit avec un message intelligent
On utilise `commit-pro` pour générer un message au format Conventional Commits.
```bash
# L'assistant génère le message ici
```

4. Récupérer les changements distants (Pull)
```bash
git pull --rebase
```

5. Envoyer les changements (Push)
```bash
git push
```

6. Résumé de la Session
L'assistant fournit un topo clair de la revue de code effectuée (points vérifiés, optimisations trouvées) et confirme l'état final de la synchronisation.
</file>

<file path=".direnv/bin/nix-direnv-reload">
#!/usr/bin/env bash
set -e
if [[ ! -d "/home/david/nixos-config" ]]; then
  echo "Cannot find source directory; Did you move it?"
  echo "(Looking for "/home/david/nixos-config")"
  echo 'Cannot force reload with this script - use "direnv reload" manually and then try again'
  exit 1
fi

# rebuild the cache forcefully
_nix_direnv_force_reload=1 direnv exec "/home/david/nixos-config" true

# Update the mtime for .envrc.
# This will cause direnv to reload again - but without re-building.
touch "/home/david/nixos-config/.envrc"

# Also update the timestamp of whatever profile_rc we have.
# This makes sure that we know we are up to date.
touch -r "/home/david/nixos-config/.envrc" "/home/david/nixos-config/.direnv"/*.rc
</file>

<file path="hosts/muggy-nixos/hardware-configuration.nix">
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/59f5b271-11c1-41f9-927d-ed3221a6b404";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/59f5b271-11c1-41f9-927d-ed3221a6b404";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/59f5b271-11c1-41f9-927d-ed3221a6b404";
      fsType = "btrfs";
      options = [ "subvol=@log" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/59f5b271-11c1-41f9-927d-ed3221a6b404";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/83F7-5789";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
</file>

<file path="modules/btop.nix">
{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      vim_keys = true;
    };
  };
}
</file>

<file path="modules/direnv.nix">
{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };
}
</file>

<file path="modules/discord.nix">
{ pkgs, ... }:

{
  # Installation de Vesktop (client Discord alternatif optimisé pour Wayland)
  home.packages = with pkgs; [
    vesktop # Supporte le partage d'écran audio/vidéo sous Wayland et inclut Vencord
  ];
}
</file>

<file path="modules/font.nix">
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # La version "Nerd Font" de Hack (indispensable pour les icônes)
    nerd-fonts.hack
    
    # Optionnel : Emojis et polices de base si tu ne les as pas
    noto-fonts-color-emoji
    font-awesome
  ];

  # Optimisation pour le rendu des polices (plus net)
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Hack Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };
}
</file>

<file path="modules/lact.nix">
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Install LACT (Linux AMDGpu Control Tool)
  environment.systemPackages = with pkgs; [
    lact
  ];

  # Enable the lactd daemon service required for applying settings
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Unlock advanced AMDGPU features (overclocking, fan control, voltage)
  # ppfeaturemask=0xffffffff enables all features
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
}
</file>

<file path="modules/neovim.nix">
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Dependencies for lazy.nvim, mason, and common plugins
    extraPackages = with pkgs; [
      # Build tools
      gcc
      gnumake
      unzip
      wget
      curl
      # git (Managed by git.nix)

      # Runtime dependencies
      ripgrep
      # fd (Managed by utils.nix)
      # fzf (Managed by utils.nix)
      nodejs
      python3
      lua-language-server
      nil # Nix LSP
      nixfmt # Nix Formatter
      stylua # For stylua.toml in your config
    ];
  };

  # Link the personal configuration from the internal nixos-config folder
  home.file.".config/nvim" = {
    source = ./../nvim;
    recursive = true;
  };
}
</file>

<file path="modules/parsec.nix">
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    parsec-bin
  ];
}
</file>

<file path="modules/steam.nix">
{ pkgs, ... }:

{

  # 2. Les outils qu'on veut pouvoir lancer manuellement au terminal
  environment.systemPackages = with pkgs; [
    mangohud # L'overlay pour surveiller ta RX 6800 (FPS, température)
    protonup-qt # Super utile pour installer GE-Proton (indispensable sous Linux)
  ];

  # 3. La configuration du module Steam
  programs.steam = {
    enable = true;

    # Ouvre le pare-feu pour le Remote Play et les serveurs locaux
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # Active Gamescope pour pouvoir lancer une session Steam Deck
    gamescopeSession.enable = true;
  };

  # 4. Configuration globale de Gamescope (Setuid et permissions)
  programs.gamescope = {
    enable = true;
    # On peut ajouter ici des options globales si besoin
  };

  # 5. Optimise les performances des jeux (GameMode de Feral Interactive)
  # Cela permet de booster le CPU et de prioriser le GPU quand un jeu est lancé
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10; # Augmente la priorité CPU des processus de jeu
        softrealtime = "auto";
      };
      gpu = {
        # Optimisations GPU AMD (bloque la fréquence à 'high')
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
</file>

<file path="modules/vscode.nix">
{ pkgs, ... }:

{
  # On installe les outils nécessaires au fonctionnement de l'IDE
  home.packages = with pkgs; [
    nixfmt # Le formateur officiel (RFC style)
    nil # Le "cerveau" (Language Server) pour Nix
  ];

  programs.vscode = {
    enable = true;

    profiles.default = {
      # Extensions installées et gérées par Nix
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix # Coloration syntaxique
        jnoortheen.nix-ide # Support IDE (LSP)
        dracula-theme.theme-dracula # Thème visuel
        christian-kohler.path-intellisense # Autocomplétion des chemins
      ];

      # Configuration de l'éditeur
      userSettings = {
        # Apparence et Police
        "editor.fontFamily" = "'Hack Nerd Font', 'monospace'";
        "editor.fontSize" = 16;
        "workbench.colorTheme" = "Dracula";
        "terminal.integrated.fontFamily" = "Hack Nerd Font";
        "window.titleBarStyle" = "custom";

        "path-intellisense.mappings" = {
          "./" = "\${workspaceRoot}";
        };

        # Automatisation du formatage (nixfmt)
        "editor.formatOnSave" = true;
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };

        # Configuration du support Nix (LSP nil)
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
            };
            # Ajout pour améliorer la détection des imports
            "diagnostics" = {
              "ignored" = [ ];
            };
            "nix" = {
              "flake" = {
                "autoArchive" = true;
                "autoEvalInputs" = true;
              };
            };
          };
        };
      };
    };
  };
}
</file>

<file path="nvim/lua/core/init.lua">
-- ~/.config/nvim/lua/core/init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
-- plus tard : require("core.autocmds")
</file>

<file path="nvim/lua/core/options.lua">
-- ~/.config/nvim/lua/core/options.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamedplus"
</file>

<file path="nvim/lua/plugins/better-escape.lua">
return {
  "max397574/better-escape.nvim",
  config = function()
    require("better_escape").setup()
  end,
}
</file>

<file path="nvim/lua/plugins/bufferline.lua">
-- plugins.lua (ou dans ton gestionnaire de plugins Lazy, Packer, etc.)
return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- ou "tabs"
          separator_style = "slant", -- "slant", "thick", "thin", etc.
          diagnostics = "nvim_lsp", -- affiche les erreurs LSP
          show_buffer_close_icons = true,
          show_close_icon = false,
        },
      })

  -- 🔹 Raccourcis
      vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
      vim.keymap.set("n", "<leader>bc", "<Cmd>bdelete<CR>", { desc = "Close buffer" })
      vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })

    end,
  }
}
</file>

<file path="nvim/lua/plugins/completion.lua">
return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim", -- icônes
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text", -- montre icône + texte
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip", priority = 800 },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        }),
      })

      -- complétion pour / ? (recherche)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- complétion pour :
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- ========================
      -- Couleurs Nord pour nvim-cmp
      -- ========================
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, "CmpItemAbbr", { fg = "#D8DEE9" })
      set_hl(0, "CmpItemAbbrMatch", { fg = "#88C0D0", bold = true })
      set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#88C0D0", bold = true })
      set_hl(0, "CmpItemMenu", { fg = "#616E88" })

      -- par kind
      set_hl(0, "CmpItemKindFunction", { fg = "#88C0D0" }) -- bleu clair
      set_hl(0, "CmpItemKindMethod",   { fg = "#88C0D0" })
      set_hl(0, "CmpItemKindKeyword",  { fg = "#81A1C1" }) -- bleu foncé
      set_hl(0, "CmpItemKindVariable", { fg = "#EBCB8B" }) -- jaune
      set_hl(0, "CmpItemKindField",    { fg = "#EBCB8B" })
      set_hl(0, "CmpItemKindProperty", { fg = "#EBCB8B" })
      set_hl(0, "CmpItemKindSnippet",  { fg = "#A3BE8C" }) -- vert
      set_hl(0, "CmpItemKindClass",    { fg = "#D08770" }) -- orange
      set_hl(0, "CmpItemKindInterface",{ fg = "#B48EAD" }) -- violet
    end,
  },
}
</file>

<file path="nvim/lua/plugins/crates.lua">
return {

  {
    'saecki/crates.nvim',
    event = { "BufRead Cargo.toml" },
    config = function()
        require('crates').setup()
    end,
  }

}
</file>

<file path="nvim/lua/plugins/flash.lua">
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
</file>

<file path="nvim/lua/plugins/icons.lua">
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
}
</file>

<file path="nvim/lua/plugins/lsp.lua">
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      -- Nix
      vim.lsp.enable("nil_ls")
      vim.lsp.config("nil_ls", {
        capabilities = capabilities,
      })

      -- Lua
      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
    end,
  },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
}
</file>

<file path="nvim/lua/plugins/mason.lua">
return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate", -- met à jour les registres lors de l’install
  config = function()
    require("mason").setup()
  end,
}
</file>

<file path="nvim/lua/plugins/move.lua">
return {
  "fedepujol/move.nvim",
  keys = {
    -- Normal Mode
    { "<A-j>", ":MoveLine(1)<CR>", desc = "Move Line Down" },
    { "<A-k>", ":MoveLine(-1)<CR>", desc = "Move Line Up" },
    { "<A-h>", ":MoveHChar(-1)<CR>", desc = "Move Character Left" },
    { "<A-l>", ":MoveHChar(1)<CR>", desc = "Move Character Right" },
    { "<leader>wb>", ":MoveWord(1)<CR>",  mode = { "n" }, desc = "Move Word Right" },
    { "<leader>wf>", ":MoveWord(-1)<CR>", mode = { "n" }, desc = "Move Word Left" },

    -- Visual Mode
    { "<A-j>", ":MoveBlock(1)<CR>",  mode = { "v" }, desc = "Move Block Down" },
    { "<A-k>", ":MoveBlock(-1)<CR>", mode = { "v" }, desc = "Move Block Up" },
    { "<A-h>", ":MoveHBlock(-1)<CR>", mode = { "v" }, desc = "Move Block Left" },
    { "<A-l>", ":MoveHBlock(1)<CR>",  mode = { "v" }, desc = "Move Block Right" },
  },
  opts = {
    -- Config here
  },
}
</file>

<file path="nvim/lua/plugins/rustaceanvim.lua">
return {

{
  'mrcjkb/rustaceanvim',
  version = '^6', -- Recommended
  lazy = false, -- This plugin is already lazy
}


}
</file>

<file path="nvim/lua/plugins/treesitter.lua">
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",

  opts = {
    highlight = { enable = true },
    indent = { enable = true }, -- ✅ active indentation Treesitter
  }
}
</file>

<file path="nvim/lua/plugins/ui.lua">
return {
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("nord")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup { options = { theme = "nord" } }
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup()
    end,
  },
}
</file>

<file path="nvim/.stylua.toml">
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
</file>

<file path="nvim/init.lua">
-- MuggyVim 🚀
-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- core
require("core")

-- setup lazy
require("lazy").setup("plugins", {
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})

-- load user overrides
pcall(require, "custom")

vim.notify("Welcome to MuggyVim ✨", vim.log.levels.INFO)
</file>

<file path=".gitignore">
# Secrets
modules/mcp_config.json

# Build results
result
result-*
</file>

<file path="overlays.nix">
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
    inputs.antigravity.overlays.default
  ];
}
</file>

<file path=".agent/skills/knowledge-archivist/SKILL.md">
---
name: knowledge-archivist
description: Focus 100% sur la documentation et les Knowledge Items (KIs). Garant de la validité et de la structure de la mémoire IA.
---

# Skill: Knowledge Archivist

Ce skill définit les standards de capitalisation du savoir pour le rôle d'Archiviste dans le workflow Relais Triple.

## Objectifs
- Transformer les commits techniques en apprentissages structurés (Knowledge Items).
- Garantir un format JSON strict pour les fichiers `metadata.json`.
- Maintenir la cohérence du graphe de connaissances via des liens inter-KIs.
- Assurer que les solutions techniques (spécifications) sont reproductibles.

## Structure d'un Knowledge Item (KI)

Chaque KI doit être situé dans `~/.gemini/antigravity/knowledge/[nom_du_ki]/` et contenir :

### 1. `metadata.json`
- **Champs obligatoires** : `title`, `summary`, `created_at`, `updated_at`, `categories`, `references`.
- **Validation** : Le JSON doit être valide (pas de virgules traînantes).
- **Format Date** : ISO 8601 UTC (ex: `2026-02-16T08:32:00Z`).

### 2. `artifacts/` (Dossier)
Contient les spécifications techniques (généralement `[nom]_specs.md`).
- Utiliser des titres H1/H2 clairs.
- Inclure des blocs de code NixOS testés.
- Ajouter des tables comparatives si nécessaire.

## Procédure d'Archivage

1. **Vérification de l'existence** : Avant de créer, vérifier si un KI similaire existe déjà. Si oui, le mettre à jour.
2. **Extraction du commit** : Analyser `git show --stat` pour identifier les fichiers clés et la logique métier.
3. **Rédaction des Specs** : Concentrer le savoir sur le "POURQUOI" et le "COMMENT" (valeur ajoutée par rapport au code brut).
4. **Mise à jour du lock** : S'assurer que le nouveau KI est mentionné dans la mémoire globale (via notification ou update du lock si géré).

## Qualité
- Langue : Français (pour les descriptions) et Anglais (pour les termes techniques/metadata).
- Style : Concis, chirurgical, sans placeholders.
</file>

<file path=".agent/skills/nixos-architect/references/nvme/nvme-transition.md">
# Transition vers le nouveau disque NVMe (Février 2026)

Cette note documente le passage d'une installation standard `ext4` vers une configuration optimisée `btrfs` sur le nouveau disque NVMe.

## Détails Techniques

### Système de Fichiers (BTRFS)
Nous avons abandonné `ext4` au profit de `btrfs` avec une structure de sous-volumes pour améliorer les performances et la maintenance :
- `@` : Racine du système.
- `@nix` : Stockage du store Nix (isolé pour les perfs).
- `@log` : Journaux système dans `/var/log`.
- `@home` : Données utilisateur.

### Optimisations SSD/NVMe
- **TRIM** : Activé via `services.fstrim.enable = true;` pour maintenir les performances du SSD sur le long terme.
- **ZRAM** : Utilisation de `zramSwap.enable = true;` pour le swap en RAM, évitant ainsi l'usure inutile du NVMe et améliorant la réactivité.
- **Kernel** : Utilisation du kernel `CachyOS` (bore) via `nix-cachyos` pour de meilleures performances globales et une meilleure gestion des entrées/sorties.

### Paramètres Kernel
- `amdgpu.gttsize=16384` : Augmentation de la taille GTT pour les performances graphiques (utile sur NVMe rapide).

## Ancienne Configuration (Avant transition)
- Racine sur `ext4`.
- Partition swap physique.
- UUID de boot : `95CA-4D08`.
- UUID racine : `fa83065a-443f-4836-9246-45983d2ebf49`.

## Nouvelle Configuration (Après transition)
- UUID de boot : `83F7-5789`.
- UUID BTRFS : `59f5b271-11c1-41f9-927d-ed3221a6b404`.
</file>

<file path=".agent/skills/nixos-architect/SKILL.md">
---
name: nixos-architect
description: Expert en architecture NixOS, garant de la propreté et de la clarté de la configuration.
---

# NixOS Architect Skill

Cette compétence assure que toute modification de la configuration NixOS respecte les standards de qualité du projet.

## Système d'Expertise locale
IMPORTANT : Toujours consulter le dossier `references/` avant toute modification majeure. Ce dossier contient notre savoir accumulé et les configurations validées pour le matériel de David.

## Principes de Base
0. **Expertise Avancée** : Pour tout ce qui concerne la syntaxe Nix, les Flakes, Home Manager ou les patterns avancés, se référer à la compétence [nix](../nixos-flakes/SKILL.md).
1. **Commentaires Systématiques** : Chaque bloc de configuration complexe doit être expliqué par un commentaire en français.
2. **Modularité** : Préférer la création de nouveaux fichiers dans `modules/` plutôt que d'alourdir le `default.nix`.
3. **Clarté des Imports** : Les fichiers doivent être importés de manière logique dans `home.nix` ou `default.nix`.

## Instructions de travail
Quand tu modifies un fichier `.nix` :
1. Analyse la structure existante.
2. Ajoute des commentaires expliquant le **pourquoi** de la modification, pas seulement le quoi.
3. Vérifie que les variables utilisées (comme `pkgs`) sont bien déclarées.
4. Si tu introduis une nouvelle fonctionnalité (ex: un nouvel outil), crée un module dédié.

---
*Note: Cette compétence est activée automatiquement dès qu'un fichier .nix est manipulé.*
</file>

<file path=".agent/skills/nixos-auditor/SKILL.md">
---
name: nixos-auditor
description: Expert en audit de configuration NixOS pour garantir la propreté, la performance et la conformité aux standards du projet.
---

# Skill: NixOS Auditor

Ce skill définit les responsabilités et les procédures d'audit pour le rôle d'Auditeur dans le workflow Relais Triple.

## Objectifs
- Garantir que chaque changement est documenté par des commentaires en français.
- Détecter les duplications d'options Nix (ex: `experimental-features` en double).
- Vérifier la conformité des noms de bibliothèques dans `nix-ld` (PascalCase requis).
- Assurer la propreté architecturale (séparation des modules, absence de hardcoding).

## Procédures d'Audit

### 1. Recherche de Doublons
L'Auditeur doit systématiquement vérifier si une option ajoutée n'existe pas déjà dans le fichier ou le module.
- **Action** : Utiliser `grep_search` ou `grep` sur le fichier cible avant validation.

### 2. Validation `nix-ld`
Les bibliothèques dans `programs.nix-ld.libraries` DOIVENT utiliser le format PascalCase et ne pas avoir de préfixe `xorg.`.
- **Correct** : `libX11`, `libXext`.
- **Incorrect** : `libx11`, `xorg.libX11`.

### 3. Exigence de Commentaires
Chaque bloc de configuration complexe ou spécifique à un bug DOIT être précédé d'un commentaire explicatif.
- **Action** : Si un bloc manque de contexte, demander au Codeur de l'ajouter.

### 4. Vérification Déclarative
Vérifier que les changements n'introduisent pas d'états impurs ou de chemins hardcodés vers `/home/david` (utiliser `${username}` ou `${config.home.homeDirectory}`).

## Feedback
L'auditeur doit fournir un rapport concis incluant :
- ✅ Points validés.
- 🛠️ Optimisations suggérées.
- 🚨 Bloquants (fautes de syntaxe, duplications critiques).
</file>

<file path=".agent/skills/nixos-flakes/references/best-practices.md">
# Best Practices

## Configuration Organization

### Modularization

Split large configurations into modules:

```
nixos-config/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── desktop/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── laptop/
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── common.nix
│   ├── desktop.nix
│   ├── development.nix
│   └── services/
│       ├── nginx.nix
│       └── postgres.nix
├── home/
│   ├── default.nix
│   ├── shell.nix
│   └── programs/
│       ├── git.nix
│       ├── neovim.nix
│       └── tmux.nix
└── overlays/
    └── default.nix
```

### Module Pattern

```nix
# modules/development.nix
{ config, lib, pkgs, ... }: {
  options.myConfig.development = {
    enable = lib.mkEnableOption "development tools";
  };

  config = lib.mkIf config.myConfig.development.enable {
    environment.systemPackages = with pkgs; [
      git vim nodejs
    ];
  };
}

# hosts/desktop/default.nix
{
  imports = [ ../../modules/development.nix ];
  myConfig.development.enable = true;
}
```

## Git Integration

### Version Control Your Config

```bash
# Initialize git in config directory
cd ~/nixos-config
git init
git add .
git commit -m "Initial config"
```

### Critical: Stage Files Before Build

Nix ignores untracked files in flakes:

```bash
# This FAILS if new files aren't staged
sudo nixos-rebuild switch --flake .

# Always stage first
git add .
sudo nixos-rebuild switch --flake .
```

### Move Config from /etc/nixos

```bash
# Option 1: Symlink
sudo mv /etc/nixos /etc/nixos.bak
sudo ln -s ~/nixos-config /etc/nixos

# Option 2: Specify path directly
sudo nixos-rebuild switch --flake ~/nixos-config#hostname
```

## Debugging

### Verbose Output

```bash
# Full debug output
sudo nixos-rebuild switch --flake .#hostname --show-trace --print-build-logs --verbose

# Shorthand
sudo nixos-rebuild switch --flake .#hostname --show-trace -L -v
```

### nix repl

Interactive debugging:

```bash
nix repl

# Load current flake
:lf .

# Explore structure
inputs.<TAB>
outputs.<TAB>
nixosConfigurations.hostname.config.services.<TAB>

# Open package in editor
:e pkgs.hello

# Build derivation
:b pkgs.hello

# Show logs
:log pkgs.hello

# Get derivation path
builtins.toString pkgs.hello
```

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "file not found" | Untracked file | `git add .` |
| "infinite recursion" | Self-referential config | Check `final` vs `prev` in overlays |
| "collision between" | Duplicate packages | Split into different profiles |
| "hash mismatch" | Source changed | Update hash in fetchurl/fetchFromGitHub |

## System Management

### Generation Management

```bash
# List all generations
nix profile history --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system

# Garbage collect
sudo nix-collect-garbage -d

# Or just GC without deleting generations
sudo nix store gc
```

### Automatic GC

```nix
# In configuration.nix
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Optimize store
  nix.optimise.automatic = true;
}
```

### Boot Entries

```nix
{
  # Limit boot menu entries
  boot.loader.systemd-boot.configurationLimit = 10;

  # Or for GRUB
  boot.loader.grub.configurationLimit = 10;
}
```

## Input Management

### Pin Versions

```bash
# Update all inputs
nix flake update

# Update single input
nix flake update nixpkgs

# Lock to specific commit
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/abc123
```

### Use follows

Always use `follows` to avoid multiple nixpkgs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  home-manager.inputs.nixpkgs.follows = "nixpkgs";
  nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  # Every input that uses nixpkgs should follow
};
```

### Mixing Stable and Unstable

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
};

outputs = { nixpkgs, nixpkgs-unstable, ... }: {
  nixosConfigurations.host = nixpkgs.lib.nixosSystem {\n    modules = [{
      nixpkgs.overlays = [
        (final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        })
      ];

      # Use stable by default
      environment.systemPackages = [ pkgs.vim ];

      # Use unstable for specific packages
      programs.firefox.package = pkgs.unstable.firefox;
    }];
  };
};
```

## Remote Deployment

### nixos-rebuild

```bash
# Deploy to remote host
nixos-rebuild switch --flake .#remote-host \
  --target-host user@remote \
  --build-host localhost  # Build locally, deploy result
```

### Colmena

```nix
# flake.nix
{
  outputs = { nixpkgs, ... }: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs { system = "x86_64-linux"; };
      };

      host1 = {
        deployment = {
          targetHost = "192.168.1.10";
          targetUser = "root";
        };
        imports = [ ./hosts/host1 ];
      };
    };
  };
}

# Deploy
nix run nixpkgs#colmena -- apply
```

## Binary Cache

### Using Cachix

```bash
# Install cachix
nix-env -iA cachix -f https://cachix.org/api/v1/install

# Use a cache
cachix use nix-community

# Or in configuration
nix.settings = {
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

## Security

### Secrets Management

Never commit secrets to git. Options:

1. **sops-nix** - Encrypted secrets in repo
2. **agenix** - Age-encrypted secrets
3. **Environment variables** - Runtime injection

```nix
# Example with sops-nix
{
  sops.secrets.my-secret = {
    sopsFile = ./secrets.yaml;
  };

  services.myservice.passwordFile = config.sops.secrets.my-secret.path;
}
```

### Principle of Least Privilege

```nix
{
  # Run services as unprivileged users
  systemd.services.myservice = {
    serviceConfig = {
      DynamicUser = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };
}
```

## Common Patterns

### Conditional Configuration

```nix
{ lib, config, ... }: {
  config = lib.mkMerge [
    # Always applied
    { environment.systemPackages = [ pkgs.vim ]; }

    # Conditional
    (lib.mkIf config.services.xserver.enable {
      environment.systemPackages = [ pkgs.firefox ];
    })
  ];
}
```

### Platform-Specific

```nix
{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    git
    vim
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux only
    inotify-tools
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS only
    darwin.apple_sdk.frameworks.Security
  ];
}
```

### DRY with Functions

```nix
# lib/mkHost.nix
{ inputs }: hostname: {
  system,
  modules ? [],
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../hosts/${hostname}
    ../modules/common.nix
  ] ++ modules;
  specialArgs = { inherit inputs; };
}

# flake.nix
{
  nixosConfigurations = {
    desktop = mkHost "desktop" { system = "x86_64-linux"; };
    laptop = mkHost "laptop" { system = "x86_64-linux"; };
  };
}
```
</file>

<file path=".agent/skills/nixos-flakes/references/dev-environments.md">
# Development Environments

## Overview

Three approaches for dev environments:
1. **nix shell** - Quick, temporary access to packages
2. **nix develop** - Full dev shell with build inputs
3. **direnv** - Automatic environment on directory entry

## nix shell

Temporary shell with packages available:

```bash
# Single package
nix shell nixpkgs#nodejs

# Multiple packages
nix shell nixpkgs#nodejs nixpkgs#yarn nixpkgs#python3

# Run command directly
nix shell nixpkgs#cowsay --command cowsay "Hello"

# From specific nixpkgs version
nix shell github:NixOS/nixpkgs/nixos-24.11#nodejs
```

## nix run

Run package without installing:

```bash
# Run default program
nix run nixpkgs#hello

# Run specific program from package
nix run nixpkgs#python3 -- script.py

# Run from flake
nix run .#myApp
```

## nix develop

Enter development shell defined in flake:

```bash
# Default devShell
nix develop

# Named devShell
nix develop .#python

# From remote flake
nix develop github:owner/repo

# Run command without entering shell
nix develop --command bash -c "npm install && npm test"
```

## pkgs.mkShell

Define development environment in `flake.nix`:

```nix
{
  outputs = { nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      # Packages available in shell
      packages = with pkgs; [
        nodejs_20
        yarn
        python3
        go
        rustc
        cargo
      ];

      # Build inputs (for compiling native extensions)
      buildInputs = with pkgs; [
        openssl
        zlib
      ];

      # Native build inputs (build tools)
      nativeBuildInputs = with pkgs; [
        pkg-config
        cmake
      ];

      # Environment variables
      MY_VAR = "value";
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

      # Shell hook (runs on entry)
      shellHook = ''
        echo "Welcome to dev environment!"
        export PATH="$PWD/node_modules/.bin:$PATH"
      '';

      # For C library headers
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.openssl
        pkgs.zlib
      ];
    };
  };
}
```

## Multi-Platform Support

```nix
{
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ nodejs ];
      };
    });
}
```

Or manually:

```nix
{
  outputs = { nixpkgs, ... }: let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
      pkgs = nixpkgs.legacyPackages.${system};
    });
  in {
    devShells = forAllSystems ({ pkgs }: {
      default = pkgs.mkShell { packages = [ pkgs.nodejs ]; };
    });
  };
}
```

## Multiple Dev Shells

```nix
{
  devShells.x86_64-linux = {
    default = pkgs.mkShell {
      packages = [ pkgs.nodejs ];
    };

    python = pkgs.mkShell {
      packages = [ pkgs.python3 pkgs.poetry ];
    };

    rust = pkgs.mkShell {
      packages = [ pkgs.rustc pkgs.cargo pkgs.rust-analyzer ];
    };
  };
}

# Usage:
# nix develop        # default
# nix develop .#python
# nix develop .#rust
```

## direnv Integration

Automatic environment activation:

### Setup

```nix
# In home.nix or configuration.nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;  # Better caching
};
```

### Usage

```bash
# In project root, create .envrc
echo "use flake" > .envrc

# Allow direnv
direnv allow

# Now environment activates automatically on cd
```

### Advanced .envrc

```bash
# Basic
use flake

# With impure (for unfree packages)
use flake --impure

# Specific devShell
use flake .#python

# From remote
use flake github:owner/repo

# Watch additional files (rebuild on change)
watch_file flake.nix
watch_file flake.lock

# Additional env vars
export MY_VAR="value"

# Load .env file
dotenv_if_exists
```

## FHS Environment (Downloaded Binaries)

NixOS doesn't follow standard Linux paths. For prebuilt binaries:

```nix
{ pkgs, ... }: {
  # Add to environment
  environment.systemPackages = [
    (pkgs.buildFHSEnv {
      name = "fhs";
      targetPkgs = pkgs: with pkgs; [
        # Common requirements
        zlib
        glib
        # Add what your binary needs
        openssl
        curl
        libGL
        xorg.libX11
      ];
      runScript = "bash";
    })
  ];
}

# Usage: enter with `fhs`, then run binaries normally
```

### For Specific Binary

```nix
{
  myBinary = pkgs.buildFHSEnv {
    name = "my-binary";
    targetPkgs = pkgs: [ pkgs.zlib ];
    runScript = "${./my-binary}";
  };
}
```

## nix-ld (Alternative for Binaries)

System-wide dynamic linker for unpatched binaries:

```nix
# In NixOS configuration
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      curl
    ];
  };
}
```

## Python Development

Python packages installed via pip fail on NixOS. Solutions:

### Virtual Environment

```nix
devShells.default = pkgs.mkShell {
  packages = [ pkgs.python3 ];
  shellHook = ''
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
  '';
};
```

### poetry2nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { nixpkgs, poetry2nix, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    p2n = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
  in {
    devShells.x86_64-linux.default = p2n.mkPoetryEnv {\n      projectDir = ./.;
    };
  };
}
```

## Language-Specific Shells

### Node.js
```nix
pkgs.mkShell {
  packages = with pkgs; [ nodejs_20 yarn nodePackages.pnpm ];
  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
  '';
}
```

### Rust
```nix
pkgs.mkShell {
  packages = with pkgs; [
    rustc cargo rust-analyzer rustfmt clippy
  ];
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
```

### Go
```nix
pkgs.mkShell {
  packages = with pkgs; [ go gopls gotools go-tools ];
  shellHook = ''
    export GOPATH="$PWD/.go"
    export PATH="$GOPATH/bin:$PATH"
  '';
}
```

### C/C++
```nix
pkgs.mkShell {
  packages = with pkgs; [ gcc cmake gnumake gdb ];
  buildInputs = with pkgs; [ openssl zlib ];
  nativeBuildInputs = [ pkgs.pkg-config ];
}
```

## Community Templates

Use existing templates instead of writing from scratch:

```bash
# List available templates
nix flake show templates

# Initialize from template
nix flake init -t github:the-nix-way/dev-templates#rust
nix flake init -t github:the-nix-way/dev-templates#node
nix flake init -t github:the-nix-way/dev-templates#python
```
</file>

<file path=".agent/skills/nixos-flakes/references/flakes.md">
# Flakes Reference

## Overview

Flakes provide:
- **Hermetic evaluation** - No impure operations
- **Lock file** - Reproducible dependency versions
- **Standard structure** - Consistent `inputs`/`outputs` schema
- **Composability** - Easy to combine multiple flakes

## Enabling Flakes

```nix
# In configuration.nix or nix.conf
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

## Input Types

### GitHub
```nix
inputs = {
  # Default branch
  nixpkgs.url = "github:NixOS/nixpkgs";

  # Specific branch
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  # Specific commit
  nixpkgs.url = "github:NixOS/nixpkgs/abc123def456";

  # Specific tag
  nixpkgs.url = "github:NixOS/nixpkgs/24.11";

  # Private repo (uses SSH)
  private.url = "github:owner/private-repo";
};
```

### Git
```nix
inputs = {
  # HTTPS
  repo.url = "git+https://git.example.com/repo.git";

  # SSH
  repo.url = "git+ssh://git@github.com/owner/repo.git";

  # Specific branch
  repo.url = "git+https://example.com/repo?ref=develop";

  # Specific tag
  repo.url = "git+https://example.com/repo?tag=v1.0.0";

  # Specific commit
  repo.url = "git+https://example.com/repo?rev=abc123";

  # Shallow clone
  repo.url = "git+ssh://git@github.com/owner/repo?shallow=1";
};
```

### Path (Local)
```nix
inputs = {
  # Local directory
  local.url = "path:/home/user/projects/my-flake";

  # Relative (from flake root)
  local.url = "path:./subdir";
};
```

### Tarball
```nix
inputs = {
  archive.url = "https://example.com/archive.tar.gz";
};
```

### Non-Flake Inputs
```nix
inputs = {
  # Config files, data, etc.
  dotfiles = {
    url = "github:user/dotfiles";
    flake = false;  # Don't evaluate as flake
  };
};

# Usage in outputs:
outputs = { dotfiles, ... }: {
  # Reference files directly
  home.file.".vimrc".source = "${dotfiles}/vimrc";
};
```

## Input Follows

Prevents downloading multiple versions of the same dependency:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  home-manager = {
    url = "github:nix-community/home-manager/release-24.11";
    inputs.nixpkgs.follows = "nixpkgs";  # Use OUR nixpkgs
  };

  # Nested follows
  foo = {
    url = "github:owner/foo";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.bar.follows = "bar";  # If foo has bar as input
  };
};
```

## Flake Outputs Schema

```nix
outputs = { self, nixpkgs, ... }: {
  # ===== Packages =====
  packages.<system>.<name> = derivation;
  packages.x86_64-linux.default = pkgs.hello;
  packages.x86_64-linux.myApp = pkgs.callPackage ./app.nix {};

  # ===== Applications =====
  apps.<system>.<name> = {
    type = "app";
    program = "${package}/bin/executable";
  };

  # ===== Development Shells =====
  devShells.<system>.<name> = pkgs.mkShell { ... };
  devShells.x86_64-linux.default = pkgs.mkShell {
    packages = [ pkgs.nodejs ];
  };

  # ===== NixOS Configurations =====
  nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./configuration.nix ];
    specialArgs = { inherit inputs; };  # Pass to modules
  };

  # ===== Darwin Configurations =====
  darwinConfigurations.<hostname> = darwin.lib.darwinSystem {\n    system = "aarch64-darwin";
    modules = [ ./darwin.nix ];
  };

  # ===== Home Manager Configurations =====
  homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    modules = [ ./home.nix ];
  };

  # ===== Overlays =====
  overlays.<name> = final: prev: { ... };
  overlays.default = final: prev: {
    myPackage = prev.myPackage.override { ... };
  };

  # ===== NixOS/Darwin Modules =====
  nixosModules.<name> = { config, ... }: { ... };
  darwinModules.<name> = { config, ... }: { ... };

  # ===== Templates =====
  templates.<name> = {
    path = ./template;
    description = "A template";
  };
  templates.default = { ... };

  # ===== Checks (CI) =====
  checks.<system>.<name> = derivation;

  # ===== Formatter =====
  formatter.<system> = pkgs.nixpkgs-fmt;  # or alejandra, nixfmt

  # ===== Library Functions =====
  lib = { ... };

  # ===== Hydra Jobs =====
  hydraJobs.<attr>.<system> = derivation;\n};
```

## Lock File (flake.lock)

Auto-generated, contains exact versions:

```json
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1234567890,
        "narHash": "sha256-...",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "abc123...",
        "type": "github"
      }
    }
  }
}
```

## Flake Commands

```bash
# Initialize new flake
nix flake init
nix flake init -t templates#rust  # From template

# Show flake info
nix flake show
nix flake show github:NixOS/nixpkgs

# Show flake metadata
nix flake metadata

# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Lock to specific version
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/abc123

# Check flake
nix flake check

# Build output
nix build .#packageName
nix build .#packages.x86_64-linux.default

# Run output
nix run .#appName

# Enter dev shell
nix develop
nix develop .#shellName

# Archive flake
nix flake archive

# Clone flake
nix flake clone github:owner/repo --dest ./local
```

## Self Reference

The `self` input refers to the current flake:

```nix
outputs = { self, nixpkgs, ... }: {
  packages.x86_64-linux.default = let
    # Access other outputs
    myLib = self.lib;

    # Access flake source
    src = self;
    version = self.rev or self.dirtyRev or "unknown";
  in
    # ...
};
```

## Flake Registry

Named shortcuts for common flakes:

```bash
# List registry
nix registry list

# Add to registry
nix registry add myflake github:owner/repo

# Pin version
nix registry pin nixpkgs

# Remove
nix registry remove myflake

# Use in commands
nix shell nixpkgs#hello  # Uses registry entry
nix shell github:NixOS/nixpkgs#hello  # Explicit
```
</file>

<file path=".agent/skills/nixos-flakes/references/home-manager.md">
# Home Manager Reference

## Overview

Home Manager manages user-specific:
- Packages in `~/.nix-profile`
- Dotfiles in `~/.config`, `~/.*`
- User services
- Shell configuration

## Installation Methods

### As NixOS Module
```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };\n  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.username = import ./home.nix;
          # Pass extra args to home.nix
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };\n  };\n}
```

### As Darwin Module
```nix
# Same pattern as NixOS
{
  outputs = { nix-darwin, home-manager, ... }: {
    darwinConfigurations.hostname = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.username = import ./home.nix;
        }
      ];
    };\n  };\n}
```

### Standalone
```nix
# flake.nix
{
  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
      extraSpecialArgs = { inherit inputs; };
    };
  };\n}

# Apply with:
# home-manager switch --flake .#user@hostname
```

## Basic home.nix

```nix
{ config, pkgs, ... }: {
  home.username = "username";
  home.homeDirectory = "/home/username";  # /Users/username on macOS

  # Packages
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    htop
  ];

  # IMPORTANT: Match your Home Manager version
  home.stateVersion = "24.11";

  # Let Home Manager manage itself (standalone only)
  programs.home-manager.enable = true;
}
```

## File Management

```nix
{
  # Copy file
  home.file.".config/app/config.toml".source = ./config.toml;

  # Create from text
  home.file.".config/app/config.toml".text = ''
    [section]
    key = "value"
  '';

  # Symlink
  home.file.".config/app".source = config.lib.file.mkOutOfStoreSymlink ./app-config;

  # Executable script
  home.file.".local/bin/myscript" = {
    executable = true;
    text = ''
      #!/bin/bash
      echo "Hello"
    '';
  };

  # Recursive directory
  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };

  # XDG config (equivalent to ~/.config)
  xdg.configFile."app/config.toml".source = ./config.toml;
}
```

## Program Modules

Home Manager has built-in modules for many programs:

### Git
```nix
{
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "you@example.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };

    aliases = {
      co = "checkout";
      st = "status";
    };

    ignores = [ ".DS_Store" "*.swp" ];

    signing = {
      key = "KEYID";
      signByDefault = true;
    };

    delta.enable = true;  # Better diffs
  };\n}
```

### Shell (Zsh)
```nix
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake .#hostname";
    };

    initExtra = ''
      # Custom init
      export PATH="$HOME/.local/bin:$PATH"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "robbyrussell";
    };\n  };\n}
```

### Shell (Fish)
```nix
{
  programs.fish = {
    enable = true;
    shellAliases = { ll = "ls -la"; };
    shellInit = ''
      set -gx PATH $HOME/.local/bin $PATH
    '';
    plugins = [
      { name = "z"; src = pkgs.fishPlugins.z.src; }
    ];
  };\n}
```

### Neovim
```nix
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [\n      nvim-treesitter.withAllGrammars
      telescope-nvim
      nvim-lspconfig
    ];

    extraLuaConfig = ''
      -- Lua config here
      vim.opt.number = true
    '';

    extraPackages = with pkgs; [
      lua-language-server
      nil  # Nix LSP
    ];
  };\n}
```

### Starship Prompt
```nix
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character.success_symbol = "[➜](bold green)";
    };\n  };\n}
```

### Direnv
```nix
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # Better Nix integration
  };\n}
```

### Tmux
```nix
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];
    extraConfig = ''
      set -g mouse on
    '';
  };\n}
```

## Environment Variables

```nix
{
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    MY_VAR = "value";
  };

  # Path additions
  home.sessionPath = [\n    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];
}
```

## User Services (systemd)

```nix
{
  # Linux only
  systemd.user.services.myservice = {
    Unit.Description = "My Service";
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pkgs.myapp}/bin/myapp";
      Restart = "always";
    };\n  };\n}
```

## macOS (launchd)

```nix
{
  # macOS only
  launchd.agents.myservice = {
    enable = true;
    config = {
      Program = "${pkgs.myapp}/bin/myapp";
      RunAtLoad = true;
      KeepAlive = true;\n    };\n  };\n}
```

## Activation Scripts

```nix
{
  home.activation = {
    myScript = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Run after home-manager writes files
      $DRY_RUN_CMD mkdir -p $HOME/.cache/myapp
    '';\n  };\n}
```

## NixOS vs Home Manager

| Aspect | NixOS | Home Manager |
|--------|-------|--------------|
| Scope | System-wide | Per-user |
| Requires | Root | No root needed |
| Services | systemd system | systemd user |
| Location | /etc, /run | ~/.config, ~/ |
| Packages | Available to all | User-specific |

**Use NixOS for:**
- System services (nginx, postgres)
- Hardware configuration
- Boot, kernel, networking
- System-wide packages

**Use Home Manager for:**
- User dotfiles
- User packages
- Shell configuration
- Desktop apps
- Portable configs (use across systems)
</file>

<file path=".agent/skills/nixos-flakes/references/nix-language.md">
# Nix Language Reference

## Overview

Nix is a pure, lazy, functional language. Key characteristics:
- **Pure**: Functions have no side effects
- **Lazy**: Values computed only when needed
- **Functional**: Functions are first-class citizens

## Basic Types

```nix
# Strings
"hello world"
''
  Multi-line
  string
''
"interpolation: ${pkgs.hello}"

# Numbers
42\n3.14

# Booleans
true
false

# Null
null

# Paths (NOT strings)
./relative/path
/absolute/path
~/home/path

# Lists
[ 1 2 3 "mixed" ./types ]

# Attribute Sets
{
  key = "value";
  nested.key = "works";
  "special-key" = "quoted";
}
```

## Attribute Sets

```nix
# Basic
let
  attrs = {
    a = 1;
    b = 2;
  };
in attrs.a  # => 1

# Recursive (rec)
rec {
  x = 1;
  y = x + 1;  # Can reference x
}

# Nested access
attrs.nested.deeply.value
attrs.nested.deeply.value or "default"  # with fallback

# Has attribute
attrs ? key  # => true/false

# Merge
attrs1 // attrs2  # attrs2 overrides attrs1
```

## Let Bindings

```nix
let
  x = 1;
  y = 2;
  f = a: a + 1;
in
  f x + y  # => 4
```

## Functions

```nix
# Single argument
x: x + 1

# Multiple arguments (curried)
x: y: x + y

# Attribute set argument
{ a, b }: a + b

# With defaults
{ a, b ? 0 }: a + b

# With extra attributes (@-pattern)
{ a, b, ... }@args: a + b + args.c

# Calling
(x: x + 1) 5  # => 6
(add 1) 2     # curried
func { a = 1; b = 2; }
```

## Control Flow

```nix
# If-then-else (expression, not statement!)
if x > 0 then "positive" else "non-positive"

# Assert
assert x > 0; x + 1  # fails if x <= 0

# With (brings attrs into scope)
with pkgs; [ git vim nodejs ]
# equivalent to: [ pkgs.git pkgs.vim pkgs.nodejs ]
```

## Inherit

```nix
# Shorthand for key = key
let
  x = 1;
  y = 2;
in {
  inherit x y;  # same as: x = x; y = y;
}

# From attribute set\n{
  inherit (pkgs) git vim;  # same as: git = pkgs.git; vim = pkgs.vim;
}
```

## Import

```nix
# Import evaluates a Nix file
import ./file.nix

# Import with arguments
import ./file.nix { inherit pkgs; }

# Import directory (uses default.nix)
import ./directory
```

## Builtins

```nix
# Common builtins
builtins.toString 42            # "42"
builtins.toJSON { a = 1; }      # "{\"a\":1}"
builtins.fromJSON "{\"a\":1}"   # { a = 1; }
builtins.readFile ./file.txt    # file contents
builtins.pathExists ./path      # true/false
builtins.attrNames { a=1; b=2; } # [ "a" "b" ]
builtins.attrValues { a=1; b=2; } # [ 1 2 ]
builtins.map (x: x+1) [1 2 3]   # [ 2 3 4 ]
builtins.filter (x: x>1) [1 2 3] # [ 2 3 ]
builtins.elem 2 [1 2 3]         # true
builtins.length [1 2 3]         # 3
builtins.head [1 2 3]           # 1
builtins.tail [1 2 3]           # [ 2 3 ]
builtins.concatLists [[1] [2]]  # [ 1 2 ]
builtins.genList (i: i) 3       # [ 0 1 2 ]
builtins.listToAttrs [{name="a"; value=1;}]  # { a = 1; }
builtins.mapAttrs (n: v: v+1) {a=1;}  # { a = 2; }
builtins.fetchurl { url = "..."; sha256 = "..."; }
builtins.fetchGit { url = "..."; }
builtins.currentSystem          # "x86_64-linux" etc.
```

## Lib Functions

Common `nixpkgs.lib` functions:

```nix
{ lib, ... }: {
  # Conditionals
  lib.mkIf condition { /* config */ }
  lib.mkMerge [ config1 config2 ]

  # Priority
  lib.mkDefault value      # priority 1000
  lib.mkForce value        # priority 50
  lib.mkOverride 100 value # custom priority

  # List ordering
  lib.mkBefore list  # prepend
  lib.mkAfter list   # append

  # Options
  lib.mkOption { type = lib.types.str; default = ""; }
  lib.mkEnableOption "feature"

  # Strings
  lib.concatStrings [ "a" "b" ]        # "ab"
  lib.concatStringsSep ", " [ "a" "b" ] # "a, b"
  lib.optionalString true "yes"        # "yes"
  lib.strings.hasPrefix "foo" "foobar" # true

  # Lists
  lib.optional true "item"    # [ "item" ]
  lib.optionals true [ 1 2 ]  # [ 1 2 ]
  lib.flatten [ [1] [2 3] ]   # [ 1 2 3 ]
  lib.unique [ 1 1 2 ]        # [ 1 2 ]

  # Attrs
  lib.filterAttrs (n: v: v != null) attrs
  lib.mapAttrs (n: v: v + 1) attrs
  lib.recursiveUpdate attrs1 attrs2
  lib.attrByPath ["a" "b"] default attrs

  # Paths
  lib.makeLibraryPath [ pkgs.openssl ]
  lib.makeBinPath [ pkgs.git ]

  # System
  lib.systems.elaborate "x86_64-linux"
}
```

## Learning Resources

- **nix.dev** - Official learning resource: https://nix.dev
- **Tour of Nix** - Interactive tutorial: https://nixcloud.io/tour
- **Noogle.dev** - Function search engine: https://noogle.dev
- **Nix Pills** - Deep dive series: https://nixos.org/guides/nix-pills
- **Nix Reference Manual** - Official docs: https://nix.dev/manual/nix
</file>

<file path=".agent/skills/nixos-flakes/references/nixpkgs-advanced.md">
# Nixpkgs Advanced Usage

## callPackage

`callPackage` auto-injects dependencies from nixpkgs:

```nix
# In your package definition (mypackage.nix)
{ lib, stdenv, fetchFromGitHub, cmake, openssl }:

stdenv.mkDerivation {
  pname = "mypackage";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];
}

# Calling it
pkgs.callPackage ./mypackage.nix { }

# With overrides
pkgs.callPackage ./mypackage.nix {
  openssl = pkgs.openssl_3;
}
```

### How callPackage Works

1. Detects function parameters from `{ lib, stdenv, ... }:`
2. Matches parameters against `pkgs` attributes
3. Injects matched dependencies automatically
4. Second argument allows explicit overrides

### Best Practice

Always use `callPackage` for custom derivations:
- Dependencies are explicit and discoverable
- Easy to override specific inputs
- Follows nixpkgs conventions

## override

Modifies function arguments (inputs to the derivation):

```nix
# Override specific arguments
pkgs.vim.override {
  python3 = pkgs.python311;
}

# Practical examples
pkgs.fcitx5-rime.override {
  rimeDataPkgs = [ ./custom-rime-data ];
}

pkgs.vscode.override {
  commandLineArgs = "--enable-features=UseOzonePlatform";
}

pkgs.firefox.override {
  nativeMessagingHosts = [ pkgs.tridactyl-native ];
}
```

### Finding Override Arguments

```bash
# In nix repl
nix repl -f '<nixpkgs>'
:e pkgs.vim  # Opens in editor

# Or check nixpkgs source on GitHub
```

## overrideAttrs

Modifies derivation attributes (build settings):

```nix
# Basic syntax
pkgs.hello.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [] ++ [ ./my-patch.patch ];
})

# Access and modify multiple attributes
pkgs.myPackage.overrideAttrs (old: rec {
  version = "2.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    sha256 = "sha256-...";
  };
})

# Disable tests
pkgs.myPackage.overrideAttrs (old: {
  doCheck = false;
})

# Add build flags
pkgs.myPackage.overrideAttrs (old: {
  configureFlags = old.configureFlags or [] ++ [ "--enable-feature" ];
})

# Change phases
pkgs.myPackage.overrideAttrs (old: {
  postInstall = ''
    ${old.postInstall or ""}
    cp extra-file $out/bin/
  '';
})
```

### Common Attributes to Override

| Attribute | Purpose |
|-----------|---------|
| `src` | Source code location |
| `version` | Package version |
| `patches` | List of patches |
| `buildInputs` | Runtime dependencies |
| `nativeBuildInputs` | Build-time dependencies |
| `configureFlags` | ./configure arguments |
| `cmakeFlags` | CMake arguments |
| `doCheck` | Run tests |
| `postInstall` | Post-install commands |

## Overlays

Overlays globally modify nixpkgs. All dependents use the modified version.

### Basic Structure

```nix
# Overlay is a function: final -> prev -> { modifications }
(final: prev: {
  # prev = original package set
  # final = resulting package set (with all overlays applied)

  myPackage = prev.myPackage.override { ... };
})
```

### Using final vs prev

```nix
(final: prev: {
  # Use prev to reference original package
  vim-modified = prev.vim.override { python = prev.python3; };

  # Use final to reference other overlaid packages (avoid infinite recursion)
  myApp = prev.callPackage ./app.nix {
    someLib = final.myLib;  # Uses potentially-overlaid myLib
  };
})
```

### Applying Overlays in Flakes

```nix
# Method 1: In nixosConfiguration
{
  nixpkgs.overlays = [
    (final: prev: {
      myPackage = prev.myPackage.override { ... };
    })

    # Import from file
    (import ./overlays/myoverlay.nix)
  ];
}

# Method 2: When importing nixpkgs
outputs = { nixpkgs, ... }: let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [
      (final: prev: { ... })
    ];
  };
in { ... };
```

### Practical Overlay Examples

```nix
# Chrome with custom flags
(final: prev: {
  google-chrome = prev.google-chrome.override {
    commandLineArgs = [
      "--proxy-server=127.0.0.1:1080"
      "--enable-features=VaapiVideoDecoder"
    ];
  };
})

# Steam with extra packages
(final: prev: {
  steam = prev.steam.override {
    extraPkgs = pkgs: with pkgs; [ keyutils libkrb5 ];
  };
})

# Add custom package
(final: prev: {
  myTool = prev.callPackage ./pkgs/mytool { };
})
```

### Exporting Overlays from Flakes

```nix
outputs = { self, nixpkgs, ... }: {
  # Export overlay for others to use
  overlays.default = final: prev: {
    myPackage = prev.callPackage ./package.nix { };
  };

  # Use in your own config
  nixosConfigurations.host = nixpkgs.lib.nixosSystem {
    modules = [{
      nixpkgs.overlays = [ self.overlays.default ];
    }];
  };
};
```

## Multiple Nixpkgs Instances

When overlays affect too many packages (cache invalidation), use separate instances:

```nix
outputs = { nixpkgs, ... }: let
  system = "x86_64-linux";

  # Main nixpkgs (clean, uses binary cache)
  pkgs = nixpkgs.legacyPackages.${system};

  # Custom nixpkgs with overlays (may build from source)
  pkgsCustom = import nixpkgs {
    inherit system;
    overlays = [ myHeavyOverlay ];
  };
in {
  # Use pkgs for most things
  environment.systemPackages = [ pkgs.vim pkgs.git ];

  # Use pkgsCustom only where needed
  programs.steam.package = pkgsCustom.steam;
};
```

## Unfree Packages

### Method 1: nixpkgs-unfree (Recommended)

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree";
  nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = { nixpkgs-unfree, ... }: {
  devShells.default = nixpkgs-unfree.legacyPackages.x86_64-linux.mkShell {
    packages = [ nixpkgs-unfree.legacyPackages.x86_64-linux.vscode ];
  };
};
```

### Method 2: Configuration

```nix
# In NixOS/Darwin configuration
{ nixpkgs.config.allowUnfree = true; }

# Or specific packages only
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "slack"
      "discord"
    ];
}
```

### Method 3: User Config

```nix
# ~/.config/nixpkgs/config.nix
{ allowUnfree = true; }
```

**Note:** `nixpkgs.config.allowUnfree` in flake.nix does NOT work with `nix develop`. Use nixpkgs-unfree or user config instead.

## Fetchers

```nix
# From GitHub
src = pkgs.fetchFromGitHub {
  owner = "owner";
  repo = "repo";
  rev = "v1.0.0";  # tag, branch, or commit
  sha256 = "";  # Leave empty first, nix will tell you
};

# From GitLab
src = pkgs.fetchFromGitLab {
  owner = "owner";
  repo = "repo";
  rev = "v1.0.0";
  sha256 = "";
};

# From URL
src = pkgs.fetchurl {
  url = "https://example.com/file.tar.gz";
  sha256 = "";
};

# From Git (with submodules)
src = pkgs.fetchgit {
  url = "https://github.com/owner/repo.git";
  rev = "abc123";
  sha256 = "";
  fetchSubmodules = true;
};

# Get hash for fetchurl
# nix-prefetch-url https://example.com/file.tar.gz

# Get hash for fetchFromGitHub
# nix-prefetch-url --unpack https://github.com/owner/repo/archive/v1.0.0.tar.gz
```
</file>

<file path=".agent/skills/nixos-flakes/references/templates.md">
# Nix Templates Reference

## Overview

Templates provide a quick way to bootstrap new Nix projects. Built-in and community templates cover everything from simple scripts to complex NixOS configurations.

## Built-in Templates

```bash
# List available templates in nixpkgs
nix flake show nixpkgs

# Initialize from built-in template
nix flake init -t nixpkgs#hello
```

## Community Templates (Recommended)

### The Nix Way (Modern Standard)
GitHub: `the-nix-way/dev-templates`

| Language | Command |
|----------|---------|
| Node.js | `nix flake init -t github:the-nix-way/dev-templates#node` |
| Python | `nix flake init -t github:the-nix-way/dev-templates#python` |
| Rust | `nix flake init -t github:the-nix-way/dev-templates#rust` |
| Go | `nix flake init -t github:the-nix-way/dev-templates#go` |
| C/C++ | `nix flake init -t github:the-nix-way/dev-templates#cpp` |

## Starter flake.nix Examples

### 1. Minimal Dev Shell
```nix
{
  description = "A simple development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.git pkgs.vim ];
        };
      }
    );
}
```

### 2. Personal NixOS Configuration
```nix
{
  description = "My personal NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.user = import ./home.nix;
        }
      ];
    };
  };
}
```

### 3. Application Package
```nix
{
  description = "A simple application package";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "myapp";
      version = "0.1.0";
      src = ./.;
      buildInputs = [ pkgs.hello ];
      installPhase = ''
        mkdir -p $out/bin
        cp myapp $out/bin/
      '';
    };
  };
}
```

## Creating Your Own Templates

In `flake.nix` of your templates repository:

```nix
{
  description = "My custom templates";

  outputs = { self }: {
    templates = {
      basic = {
        path = ./basic;
        description = "A basic template";
      };
      advanced = {
        path = ./advanced;
        description = "An advanced template";
      };
    };
    defaultTemplate = self.templates.basic;
  };
}
```

## Using Templates

| Task | Command |
|------|---------|
| List templates | `nix flake show github:owner/repo` |
| Initialize (Current Dir) | `nix flake init -t .#template-name` |
| Create New Project | `nix flake new my-project -t .#template-name` |
| Use Registry Template | `nix flake init -t myregistry#template` |

## Tips

1. **Keep it minimal** - Templates should be a starting point, not a complete app.
2. **Use flake-utils** - Simplifies multi-platform support.
3. **Include .envrc** - Add `use flake` to help users with direnv.
4. **README.md** - Briefly explain what's in the template and how to use it.
</file>

<file path=".agent/skills/nixos-flakes/SKILL.md">
---
name: nix
description: Comprehensive NixOS, Nix Flakes, Home Manager, and nix-darwin skill. Covers declarative system configuration, reproducible environments, package management, and cross-platform Nix workflows. Activate for any Nix/NixOS/Flakes/Home-Manager/nix-darwin tasks.
---

# Nix Ecosystem Guide

## Core Philosophy

1. **Declarative over Imperative** - Describe desired state, not steps to reach it
2. **Reproducibility** - Lock files (`flake.lock`) pin exact versions
3. **Immutability** - Nix Store is read-only; same inputs = same outputs
4. **Rollback (NixOS)** - Every generation preserved; instant recovery via boot menu

## Flake Structure

```nix
{
  description = "My Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";  # CRITICAL: avoid duplicate nixpkgs
    };
    # macOS support
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs: {
    # NixOS configurations
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };

    # macOS configurations
    darwinConfigurations.hostname = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # or x86_64-darwin for Intel
      modules = [ ./darwin.nix ];
    };

    # Development shells
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [ /* ... */ ];
    };
  };
}
```

## Essential Patterns

### Input Management
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Use parent's nixpkgs to avoid downloading multiple versions
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # Non-flake input (config files, etc.)
  private-config = {
    url = "git+ssh://git@github.com/user/config.git";
    flake = false;
  };
};
```

### Module System
```nix
# Modules have: imports, options, config
{ config, pkgs, lib, ... }: {
  imports = [ ./hardware.nix ./services.nix ];

  options.myOption = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.myOption {
    # conditional configuration
  };
}
```

### Priority Control
```nix
{
  # lib.mkDefault (priority 1000) - base module defaults
  services.nginx.enable = lib.mkDefault true;

  # Direct assignment (priority 100) - normal config
  services.nginx.enable = true;

  # lib.mkForce (priority 50) - override everything
  services.nginx.enable = lib.mkForce false;
}
```

### Package Customization
```nix
{
  # Override function arguments
  pkgs.fcitx5-rime.override { rimeDataPkgs = [ ./custom-rime ]; }

  # Override derivation attributes
  pkgs.hello.overrideAttrs (old: { doCheck = false; })

  # Overlays (global modification)
  nixpkgs.overlays = [
    (final: prev: {
      myPackage = prev.myPackage.override { /* ... */ };
    })
  ];
}
```

## Platform-Specific

### NixOS
```bash
sudo nixos-rebuild switch --flake .#hostname
sudo nixos-rebuild boot --flake .#hostname    # apply on next boot
sudo nixos-rebuild test --flake .#hostname    # test without boot entry
```

### nix-darwin (macOS)
```bash
darwin-rebuild switch --flake .#hostname
# TouchID for sudo:
# security.pam.services.sudo_local.touchIdAuth = true;
```

### Home Manager
```nix
# As NixOS/Darwin module:
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
home-manager.users.username = import ./home.nix;

# Standalone:
home-manager switch --flake .#username@hostname
```

## Commands Reference

| Task | Command |
|------|---------|
| Rebuild NixOS | `sudo nixos-rebuild switch --flake .#hostname` |
| Rebuild Darwin | `darwin-rebuild switch --flake .#hostname` |
| Dev shell | `nix develop` |
| Temp package | `nix shell nixpkgs#package` |
| Run package | `nix run nixpkgs#package` |
| Update all | `nix flake update` |
| Update one | `nix flake update nixpkgs` |
| GC old gens | `sudo nix-collect-garbage -d` |
| List gens | `nix profile history --profile /nix/var/nix/profiles/system` |
| Debug build | `nixos-rebuild switch --show-trace -L -v` |
| REPL | `nix repl` then `:lf .` to load flake |

## Common Gotchas

1. **Untracked files ignored** - `git add` before any flake command (nix build/run/shell/develop, nixos-rebuild, darwin-rebuild)
2. **allowUnfree fails in devShells** - Use `nixpkgs-unfree` overlay or `~/.config/nixpkgs/config.nix`
3. **Duplicate input downloads** - Use `follows` to pin dependencies (most common: `inputs.nixpkgs.follows`)
4. **Python pip fails** - Use `venv`, `poetry2nix`, or containers
5. **Downloaded binaries fail** - Use FHS environment or `nix-ld`
6. **Merge conflicts in lists** - Use `lib.mkBefore`/`lib.mkAfter` for ordering
7. **Build from source unexpectedly** - Check if overlays invalidate cache

## Development Environments

```nix
# In flake.nix outputs:
devShells.x86_64-linux.default = pkgs.mkShell {
  packages = with pkgs; [ nodejs python3 rustc ];

  shellHook = ''
    echo "Dev environment ready"
    export MY_VAR="value"
  '';

  # For C libraries
  LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.openssl ];
};
```

### direnv Integration
```bash
# .envrc
use flake
# or for unfree: use flake --impure
```

## Debugging

```bash
# Verbose rebuild
nixos-rebuild switch --show-trace --print-build-logs --verbose

# Interactive REPL
nix repl
:lf .                    # load current flake
:e pkgs.hello           # open in editor
:b pkgs.hello           # build derivation
inputs.<TAB>            # explore inputs
```

## References

For detailed information, see:
- `references/nix-language.md` - Nix language syntax
- `references/flakes.md` - Flake inputs/outputs details
- `references/home-manager.md` - User environment management
- `references/nix-darwin.md` - macOS configuration
- `references/nixpkgs-advanced.md` - Overlays, overrides, callPackage
- `references/dev-environments.md` - Dev shells, direnv, FHS
- `references/best-practices.md` - Modularization, debugging, deployment
- `references/templates.md` - Ready-to-use flake.nix examples
</file>

<file path=".agent/skills/nixos-project-manager/SKILL.md">
---
name: nixos-project-manager
description: Expert en gestion de projet et planification pour les configurations NixOS complexes.
---

# Skill: NixOS Project Manager

Ce skill définit le rôle de planification (PM) pour décomposer les demandes et anticiper les conflits.

## Missions
- **Analyse de Faisabilité** : Vérifier si une demande respecte l'architecture déclarative du projet.
- **Décomposition (WBS)** : Transformer une demande floue en une liste de tâches atomiques (`task.md`).
- **Anticipation des Conflits** : Identifier les modules Nix incompatibles avant l'implémentation (ex: deux bootloaders, deux gestionnaires de réseau).

## Livrables
Un `task.md` initialisé avec :
- Phases de Planning, Exécution et Vérification claires.
- Mention des modules Nix impactés.
- Critères d'acceptation précis.

## Stratégie
- Toujours privilégier `nh` (nixos helper) pour les tests si possible.
- Recommander des changements progressifs (un commit par fonctionnalité).
</file>

<file path=".agent/skills/nixos-research-strategy/SKILL.md">
---
name: nixos-research-strategy
description: |
  Stratégies de recherche systématique pour NixOS. Fournit des arbres de décision pour naviguer dans la documentation web et le code source de Nixpkgs.
  Utiliser pour déterminer la profondeur de lecture et choisir les bons outils (Fetch, GitHub MCP, Nix Search).
---

# NixOS Research Strategy

Guide stratégique pour l'exploration systématique de l'écosystème NixOS.

## Niveaux de Recherche

### 1. ⚡ Quick Scan (Recherche Rapide)
- **Quand** : Questions de syntaxe simple, vérification de version.
- **Action** : `Nix Search` pour les options, lecture du `README.md` via `Fetch`.
- **Objectif** : Une réponse immédiate basée sur la documentation officielle.

### 2. 🛡️ Standard Trace (Analyse Standard)
- **Quand** : Configuration de nouveaux modules, erreurs de build courantes.
- **Action** : `Quick Scan` + lecture du code du module dans Nixpkgs via `GitHub MCP`.
- **Objectif** : Comprendre comment les options sont implémentées.

### 3. 🔬 Nix-Deep-Dive (Immersion Totale)
- **Quand** : Bugs obscurs, comportements non documentés, intégration de flakes complexes.
- **Action** : `Standard Trace` + recherche d'issues GitHub, lecture des Pull Requests liées pour comprendre le "pourquoi" derrière une implémentation.
- [ ] **Objectif** : Résoudre des problèmes d'architecture ou des bugs de bas niveau.

### ⚡ 4. Surgical Context (Analyse Interne)
- **Quand** : Travailler sur des changements récents faits par un autre agent.
- **Action** : `git show --stat` (immédiat) ou lecture de `repomix-nixos-config.md`.
- **Objectif** : Identifier instantanément les fichiers modifiés sans scanner tout le projet.

## Arbre de Décision

```
Requête Utilisateur
├── Mots-clés : "Pourquoi", "Bizarre", "Bug", "Interne"
│   → **NIX-DEEP-DIVE**
│   → Outils : GitHub Search (Code + Issues + PRs)
│
├── Mots-clés : "Comment configurer", "Options pour"
│   → **STANDARD TRACE**
│   → Outils : Nix Search + View Contents (module.nix)
│
└── Mots-clés : "Est-ce que", "Version", "Qu'est-ce que"
    → **QUICK SCAN**
    → Outils : Nix Search + Fetch (README)
```

## Meilleures Pratiques
- **Toujours remonter à la source** : Le code source de Nixpkgs est la source de vérité ultime.
- **Vérifier l'historique** : Une option qui a changé de nom est souvent documentée dans le commit qui l'a modifiée.
- **Documenter la recherche** : Utiliser le skill `scratchpad` pour noter les fichiers parcourus.
</file>

<file path=".agent/workflows/full-index.md">
---
description: Mise à jour complète de l'index du projet (Repomix). À lancer après des changements structurels majeurs.
---

Ce workflow rafraîchit la "carte" du projet pour que tous les agents aient une vision globale parfaite.

// turbo-all
1. Régénération de l'index Repomix
```bash
repomix --output repomix-nixos-config.md
```

2. Synchronisation Git
```bash
git add repomix-nixos-config.md && git commit -m "chore: update project index (repomix)" && git push
```
</file>

<file path="docs/brave.md">
# 🌐 Configuration de Brave sur NixOS

Cette fiche explique comment Brave est configuré pour concilier sécurité (extensions forcées) et confort visuel (Wayland, Dark Mode).

## 🛡️ Politiques Système (Extensions & PWAs)
Nous utilisons les politiques **Chromium** globales pour forcer des éléments essentiels.
- **Fichier** : `modules/brave-system.nix`
- **Extensions forcées** : Bitwarden, uBlock Origin.
- **PWAs forcées** : Microsoft Teams.

## 🎨 Interface et Performance (UI & Wayland)
La configuration utilisateur via Home-Manager optimise le rendu graphique.
- **Fichier** : `modules/brave.nix`
- **Wayland Natif** : Activé via `--ozone-platform=wayland` pour une meilleure fluidité sur les tiling managers (Niri).
- **Dark Mode** : Forcé via `--force-dark-mode` (UI) et `--enable-features=WebContentsForceDark` (contenu).

## 🔧 Maintenance rapide
- **Ajouter une extension** : Ajouter l'ID dans `modules/brave-system.nix`.
- **Désactiver le Dark Mode** : Modifier `commandLineArgs` dans `modules/brave.nix`.
</file>

<file path="docs/tealdeer.md">
# 🦌 Module Tealdeer

## Description
`tealdeer` est une implémentation rapide et performante en **Rust** du projet `tldr`. Il permet d'afficher des pages d'aide simplifiées et communautaires pour les commandes Linux.

## Utilité
Contrairement aux `man pages` qui sont exhaustives mais souvent complexes, `tealdeer` fournit des exemples concrets et actionnables pour les commandes les plus courantes.

## Configuration actuelle
Le module est configuré dans `modules/tealdeer.nix` avec les options suivantes :
- **Mode Compact** : Affichage réduit pour plus de clarté.
- **Auto-Update** : Les pages d'aide sont mises à jour automatiquement.
- **Pager** : Utilisation du pager système pour la lecture.

## Utilisation
Une fois le système déployé, exécutez simplement :
```bash
tldr <commande>
```
*Exemple : `tldr tar`*
</file>

<file path="docs/triple-relay.md">
# 💎 Système de Relais Triple (Triple Relay)

Le projet utilise un système de collaboration agentique basé sur trois rôles distincts pour garantir la qualité et la pérennité de la configuration.

## Les Trois Rôles

1.  **Codeur (Toi/IA)** : Se concentre à 100% sur l'implémentation, la correction de bugs et les tests de validation.
2.  **Auditeur (IA - `/audit`)** : Effectue une revue de code rigoureuse. Vérifie la conformité à `GEMINI.md`, la propreté du code et propose des optimisations sans modifier le code lui-même.
3.  **Archiviste (IA - `/archive`)** : S'occupe de la capitalisation du savoir. Met à jour les **Knowledge Items (KI)** pour que l'IA garde une mémoire technique précise du projet.

## Commandes Slash

-   **/auto-doc** : À utiliser après un changement fonctionnel pour synchroniser la documentation et préparer le terrain pour l'IA suivante.
-   **/audit** : Pour lancer une analyse de qualité sur les changements récents.
-   **/archive** : Pour enregistrer les nouveaux apprentissages techniques.

## Philosophie : Focus Chirurgical
Chaque étape du relais doit être concise et efficace (**5-10 tours maximum**). On privilégie la précision et la mise à jour constante du savoir technique.
</file>

<file path="generated/fuzzel.ini">
[main]
font=Hack Nerd Font:size=18
terminal=ghostty
prompt='❯ '
layer=overlay
icons-enabled=yes
icon-theme=Papirus-Dark
width=40
lines=15

[colors]
background=#0e1415ff
text=#dee3e5ff
match=#82d3e1ff
selection=#3f484aff
selection-text=#bfc8caff
border=#82d3e1ff

[border]
width=2
radius=10
</file>

<file path="generated/yazi.toml">
[manager]
cwd = { fg = "#82d3e1" }
hovered = { fg = "#0e1415", bg = "#82d3e1", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "#82d3e1", italic = true }
find_position = { fg = "#b1cbd0", bg = "#0e1415" }

[status]
separator_open  = ""
separator_close = ""
separator_style = { fg = "#0e1415", bg = "#0e1415" }

[select]
border   = { fg = "#82d3e1" }
active   = { fg = "#82d3e1", bold = true }
inactive = { fg = "#dee3e5" }

[input]
border   = { fg = "#82d3e1" }
title    = { fg = "#82d3e1" }
value    = { fg = "#dee3e5" }

[completion]
border   = { fg = "#82d3e1" }
active   = { fg = "#0e1415", bg = "#82d3e1" }
inactive = { fg = "#dee3e5" }

[file]
selection = { fg = "#0e1415", bg = "#82d3e1" }
</file>

<file path="modules/git.nix">
{ username, ... }:

{
  programs.git = {
    enable = true;
    
# On utilise 'settings' pour tout ce qui concerne l'identité et les alias
    settings = {
      user = {
        name = username;
        email = "email@exemple.com";
      };

    # Des raccourcis qui vont te faire gagner un temps fou
    aliases = {
      s  = "status";
      a  = "add";
      c  = "commit";
      cm = "commit -m";
      p  = "push";
      lg = "log --graph --oneline --all"; # Une jolie vue de ton historique
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true; # Plus propre pour éviter les commits de "merge" inutiles
    };
  };
 };
}
</file>

<file path="modules/pdf.nix">
{ pkgs, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true; # Dark mode by default
      recolor-keephue = true;
      
      # Premium Dark Theme (Catppuccin-like)
      default-bg = "#1e1e2e";
      default-fg = "#cdd6f4";
      statusbar-bg = "#181825";
      statusbar-fg = "#cdd6f4";
      inputbar-bg = "#11111b";
      inputbar-fg = "#cdd6f4";
      recolor-lightcolor = "#1e1e2e";
      recolor-darkcolor = "#cdd6f4";
    };
  };
}
</file>

<file path="modules/tealdeer.nix">
{ pkgs, ... }:

{
  # tealdeer est une implémentation rust de tldr (pages d'aide simplifiées)
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
        use_pager = true;
      };
      updates = {
        auto_update = true;
      };
    };
  };
}
</file>

<file path="modules/yt-dlp.nix">
{ pkgs, inputs, ... }:

{
  programs.yt-dlp = {
    enable = true;
    package = inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.yt-dlp;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
      restrict-filenames = true;
      windows-filenames = true;
      output = "%(title)s.%(ext)s";
    };
  };

  programs.fish.functions = {
    yt = "yt-dlp -x --audio-format m4a $argv";
  };
}
</file>

<file path="templates/fuzzel.conf">
[main]
font=Hack Nerd Font:size=18
terminal=ghostty
prompt='❯ '
layer=overlay
icons-enabled=yes
icon-theme=Papirus-Dark
width=40
lines=15

[colors]
background={{colors.surface.default.hex}}ff
text={{colors.on_surface.default.hex}}ff
match={{colors.primary.default.hex}}ff
selection={{colors.surface_variant.default.hex}}ff
selection-text={{colors.on_surface_variant.default.hex}}ff
border={{colors.primary.default.hex}}ff

[border]
width=2
radius=10
</file>

<file path="templates/mako.conf">
anchor=top-right
layer=top
width=400
height=200
margin=10
padding=12
border-size=2
border-radius=8
background-color={{colors.surface.default.hex}}ee
text-color={{colors.on_surface.default.hex}}
border-color={{colors.primary.default.hex}}
progress-color={{colors.primary.default.hex}}
default-timeout=5000

[urgency=critical]
default-timeout=0
border-color={{colors.error.default.hex}}
</file>

<file path="templates/matugen.toml">
[config]
# Matugen global configuration
# Templates are used to generate files in ~/nixos-config/generated/
# Nix symlinks point to these generated files.

[templates.mako]
input_path = "/home/david/nixos-config/templates/mako.conf"
output_path = "/home/david/nixos-config/generated/mako"

[templates.fuzzel]
input_path = "/home/david/nixos-config/templates/fuzzel.conf"
output_path = "/home/david/nixos-config/generated/fuzzel.ini"

[templates.yazi]
input_path = "/home/david/nixos-config/templates/yazi.conf"
output_path = "/home/david/nixos-config/generated/yazi.toml"
</file>

<file path="templates/yazi.conf">
[manager]
cwd = { fg = "{{colors.primary.default.hex}}" }
hovered = { fg = "{{colors.surface.default.hex}}", bg = "{{colors.primary.default.hex}}", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "{{colors.primary.default.hex}}", italic = true }
find_position = { fg = "{{colors.secondary.default.hex}}", bg = "{{colors.surface.default.hex}}" }

[status]
separator_open  = ""
separator_close = ""
separator_style = { fg = "{{colors.surface.default.hex}}", bg = "{{colors.surface.default.hex}}" }

[select]
border   = { fg = "{{colors.primary.default.hex}}" }
active   = { fg = "{{colors.primary.default.hex}}", bold = true }
inactive = { fg = "{{colors.on_surface.default.hex}}" }

[input]
border   = { fg = "{{colors.primary.default.hex}}" }
title    = { fg = "{{colors.primary.default.hex}}" }
value    = { fg = "{{colors.on_surface.default.hex}}" }

[completion]
border   = { fg = "{{colors.primary.default.hex}}" }
active   = { fg = "{{colors.surface.default.hex}}", bg = "{{colors.primary.default.hex}}" }
inactive = { fg = "{{colors.on_surface.default.hex}}" }

[file]
selection = { fg = "{{colors.surface.default.hex}}", bg = "{{colors.primary.default.hex}}" }
</file>

<file path="wm/style.nix">
{ inputs, pkgs, ... }:
{
  programs.niri.settings = {
    layout = {
      gaps = 32;
      focus-ring.width = 6;
      focus-ring.active.color = "rgba(255,255,255,0.3)";
      focus-ring.inactive.color = "rgba(100,100,100,0.3)";
    };

    window-rules = [
      {
        matches = [ { app-id = "brave-browser"; } ];
        open-focused = true;
      }
      {
        geometry-corner-radius = {
          bottom-left = 12.0;
          bottom-right = 12.0;
          top-left = 12.0;
          top-right = 12.0;
        };
        clip-to-geometry = true;
      }
    ];

  };
}
</file>

<file path="generated/mako">
anchor=top-right
layer=top
width=400
height=200
margin=10
padding=12
border-size=2
border-radius=8
background-color=#0e1415ee
text-color=#dee3e5
border-color=#82d3e1
progress-color=#82d3e1
default-timeout=5000

[urgency=critical]
default-timeout=0
border-color=#ffb4ab
</file>

<file path="modules/antigravity-settings.json">
{
    "nix.enableLanguageServer": true,
    "nix.serverPath": "nil",
    "nix.serverSettings": {
        "nil": {
            "formatting": {
                "command": [ "nixfmt" ]
            }
        }
    },
    "editor.formatOnSave": true,
    "[nix]": {
        "editor.defaultFormatter": "jnoortheen.nix-ide"
    },
    "security.workspace.trust.untrustedFiles": "open",
    "antigravity.agent.terminal.autoExecutionPolicy": "Turbo",
    "antigravity.agent.terminal.confirmCommands": false,
    "antigravity.agent.workspace.gitignoreAccess": "On",
    "antigravity.reviewPolicy": "Always Proceed",
    "antigravity.confirmShellCommands": false,
    "terminal.integrated.env.linux": {
        "ELECTRON_OZONE_PLATFORM_HINT": "auto",
        "WAYLAND_DISPLAY": "wayland-1"
    }
}
</file>

<file path="modules/atuin.nix">
{ pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = false; # Desactivé pour éviter les blocages de l'agent
    settings = {
      auto_sync = true;
      update_check = false;
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };
}
</file>

<file path="modules/fastfetch.nix">
{ config, pkgs, ... }:
{
  home.packages = [ pkgs.chafa ];

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "${config.home.homeDirectory}/Pictures/nixos.png";
        type = "kitty";
        width = 24;
        height = 13;
        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };
      display = {
        separator = " → ";
        color = {
          keys = "magenta";
          separator = "cyan";
        };
      };
      modules = [
        "break"
        {
          type = "os";
          key = "╭─ OS";
          format = "{3}";
        }
        {
          type = "kernel";
          key = "├─ Kernel";
        }
        {
          type = "shell";
          key = "├─ Shell";
        }
        {
          type = "wm";
          key = "├─ WM";
          format = "{1}";
        }
        {
          type = "terminal";
          key = "├─ Terminal";
        }
        {
          type = "uptime";
          key = "╰─ Uptime";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 2;
        }
      ];
    };
  };
}
</file>

<file path="modules/nh.nix">
{ config, ... }:

{
  programs.nh = {
    enable = true;

    # Chemin vers votre flake NixOS
    # Adaptez ce chemin selon votre configuration
    flake = "${config.home.homeDirectory}/nixos-config";

    # Nettoyage automatique des anciennes générations
    clean = {
      enable = true;
      # Garde les générations des 7 derniers jours
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  programs.fish.functions = {
    nos = ''
      cd ${config.home.homeDirectory}/nixos-config
      nh os switch . --hostname muggy-nixos
    '';
  };
}
</file>

<file path="modules/xdg.nix">
{ config, pkgs, ... }:

{
  # Gestion des répertoires utilisateurs standards (Documents, Images, etc.)
  xdg.userDirs = {
    enable = true;
    createDirectories = true; # Crée les dossiers s'ils n'existent pas
    
    # Chemins par défaut
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    desktop = "${config.home.homeDirectory}/Desktop";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
  };

  # On peut aussi s'assurer que XDG lui-même est bien là (souvent implicite mais bon à avoir)
  xdg.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "com.brave.Browser.desktop";
      "x-scheme-handler/http" = "com.brave.Browser.desktop";
      "x-scheme-handler/https" = "com.brave.Browser.desktop";
    };
  };
}
</file>

<file path="nvim/lua/core/keymaps.lua">
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Basic keymaps
map("n", "<leader>qq", ":q<CR>", { desc = "Quit" })
map("n", "<leader>fs", ":w<CR>", { desc = "Save File" })

-- Clipboard paste
map("i", "<C-S-v>", '<Esc>"+pa', opts)
map("c", "<C-S-v>", '<C-R>+', opts)


-- Window navigation
map("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Move to upper window" })
</file>

<file path="wm/binds.nix">
{ config, ... }:
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+D".action = spawn "fuzzel";
    "Mod+M".action = spawn "music-menu";
    "Mod+Q".action = close-window;
    "Mod+Shift+F".action = fullscreen-window;
    "Mod+F".action = maximize-column;
    "Mod+T".action = spawn "ghostty";
    "Mod+Shift+E".action = quit { skip-confirmation = false; };
    "Mod+Shift+Slash".action = show-hotkey-overlay;
    "Mod+Shift+Space".action = toggle-window-floating;
    "Mod+Space".action = switch-focus-between-floating-and-tiling;
    "Mod+O".action.toggle-overview = [ ];

    "Mod+W".action = switch-preset-column-width;
    "Mod+H".action = switch-preset-window-height;
    "Mod+C".action = consume-window-into-column;
    "Mod+X".action = expel-window-from-column;

    #Focus
    "Mod+Left".action = focus-column-or-monitor-left;
    "Mod+Right".action = focus-column-or-monitor-right;
    "Mod+Up".action = focus-window-or-workspace-up;
    "Mod+Down".action = focus-window-or-workspace-down;

    "Mod+1".action = focus-workspace 1;
    "Mod+2".action = focus-workspace 2;
    "Mod+3".action = focus-workspace 3;
    "Mod+4".action = focus-workspace 4;
    "Mod+5".action = focus-workspace 5;
    "Mod+6".action = focus-workspace 6;
    "Mod+7".action = focus-workspace 7;
    "Mod+8".action = focus-workspace 8;
    "Mod+9".action = focus-workspace 9;

    "XF86MonBrightnessUp".action = spawn "brightnessctl s +10%";
    "XF86MonBrightnessDown".action = spawn "brightnessctl s -10%";
    #Move
    "Mod+Shift+Left".action = move-column-left-or-to-monitor-left;
    "Mod+Shift+Right".action = move-column-right-or-to-monitor-right;
    "Mod+Shift+Up".action = move-window-up-or-to-workspace-up; # ✅ CORRIGÉ
    "Mod+Shift+Down".action = move-window-down-or-to-workspace-down; # ✅ CORRIGÉ

    "Mod+Shift+1".action = move-column-to-index 1;
    "Mod+Shift+2".action = move-column-to-index 2;
    "Mod+Shift+3".action = move-column-to-index 3;
    "Mod+Shift+4".action = move-column-to-index 4;
    "Mod+Shift+5".action = move-column-to-index 5;
    "Mod+Shift+6".action = move-column-to-index 6;
    "Mod+Shift+7".action = move-column-to-index 7;
    "Mod+Shift+8".action = move-column-to-index 8;
    "Mod+Shift+9".action = move-column-to-index 9;

    # Passer à la fenêtre de DROITE avec Mod + Molette vers le BAS
    "Mod+WheelScrollDown".action = focus-column-right;

    # Passer à la fenêtre de GAUCHE avec Mod + Molette vers le HAUT
    "Mod+WheelScrollUp".action = focus-column-left;

    # Si tu veux que ça déplace carrément la fenêtre (Shift en plus)
    "Mod+Shift+WheelScrollDown".action = focus-workspace-down;
    "Mod+Shift+WheelScrollUp".action = focus-workspace-up;

    # Screenshots avec la syntaxe correcte
    "Ctrl+Mod+S".action.screenshot = [ ]; # Fenêtre active
    "Ctrl+Mod+Shift+S".action.screenshot-screen = [ ]; # Écran complet

  };
}
</file>

<file path="flake.nix">
{
  description = "NixOS Unstable avec Home Manager intégré";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Home Manager pointant sur la branche unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Force HM à utiliser votre version de nixpkgs
    };

    # Flake niri
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity = {
      url = "github:jacopone/antigravity-nix";
      # C'est ici que la magie opère :
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS Latest Kernel (xddxdd - has lantian cache)
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      home-manager,
      niri,
      antigravity,
      noctalia,
      nix-cachyos,
      ...
    }@inputs:
    let
      username = "david";
    in
    {
      nixosConfigurations.muggy-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs username; };
        modules = [
          ./hosts/muggy-nixos/default.nix
          ./overlays.nix

          # CachyOS kernel is set via boot.kernelPackages in default.nix

          # Le module Noctalia se charge au niveau SYSTEME (si besoin, mais on va surtout l'utiliser dans Home Manager)
          noctalia.nixosModules.default
          niri.nixosModules.niri # Le module Niri Système (Sodiboo)

          # Import du module Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;

            # Optionnel : passe les 'inputs' du flake au fichier home.nix
            home-manager.extraSpecialArgs = { inherit inputs username; };
          }
        ];
      };
    };
}
</file>

<file path=".agent/workflows/archive.md">
---
description: Capitalisation du savoir via Knowledge Items (Archiviste).
---

// turbo-all
1. Analyse du commit final
```bash
git show --stat
```

2. Gestion du Savoir (Skill: `knowledge-archivist`)
- Appliquer les standards du skill `knowledge-archivist`.
- Créer ou mettre à jour le **Knowledge Item (KI)** dans `~/.gemini/antigravity/knowledge/`.
- Valider le `metadata.json` et la structure des artifacts.

3. Clôture
- Confirme la mise à jour du savoir.
- **Focus Chirurgical** : Max 5-10 turns.
</file>

<file path=".agent/workflows/audit.md">
---
description: Revue de code et conformité (Auditeur).
---

// turbo-all
1. Analyse des changements récents
```bash
git show --stat
```

2. Revue de Code (Skill: `nixos-auditor`)
- Appliquer les contrôles du skill `nixos-auditor`.
- Vérifier les duplications, le style `nix-ld` et les commentaires.
- Lister les optimisations possibles (performance, clarté, sécurité).

3. Conclusion
- Valide la conformité ou propose des correctifs.
- Demande à l'utilisateur de passer à la phase **ARCHIVE** via `/archive` si tout est OK.
- **Focus Chirurgical** : Max 5-10 turns.
</file>

<file path="modules/brave-system.nix">
{ ... }:

{
  # On utilise le module Chromium système pour forcer les politiques dans Brave
  programs.chromium = {
    enable = true;
    extraOpts = {
      "ExtensionInstallForcelist" = [
        "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # Bitwarden
        "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx" # uBlock Origin
        "dcbfghmdnnkkkjjpmghnoaidojfickmj;https://clients2.google.com/service/update2/crx" # Theme: Thassos Sea View
      ];
      "WebAppInstallForceList" = [
        {
          url = "https://teams.microsoft.com/";
          default_launch_container = "window";
          create_desktop_shortcut = true;
        }
      ];
    };
  };
}
</file>

<file path="modules/music-menu.nix">
{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "music-menu" ''
      MUSIC_DIR="$HOME/Music"
      TAB=$'\t'
      
      # Find playlists (Display name \t Full path)
      LISTS=$(find "$MUSIC_DIR" -type f -name "*.m3u" -printf "󰲸  %f$TAB%p\n" | sort)
      
      # Find songs (Display name \t Full path)
      SONGS=$(find "$MUSIC_DIR" -type f \( -name "*.m4a" -o -name "*.mp3" -o -name "*.flac" \) -printf "  %f$TAB%p\n" | sort)
      
      # Construct the menu content
      SEP="────────────────────────────────────────────────"
      MENU_CONTENT="󰲸  --- PLAYLISTS ---$TAB\n$LISTS\n$SEP$TAB\n  --- SONGS ---$TAB\n$SONGS"
      
      # Select via Fuzzel
      # --with-nth=1: Only show titles
      # --accept-nth=2: Only return full path
      CHOICE=$(echo -e "$MENU_CONTENT" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="Music ❯ " --width=80 --lines=25 --with-nth=1 --accept-nth=2 --nth-delimiter="$TAB")
      
      # Exit if nothing selected or if a separator/header is picked (check if it's a valid file)
      [ -z "$CHOICE" ] || [ ! -f "$CHOICE" ] && exit
      
      # Play with mpv
      ${pkgs.mpv}/bin/mpv --no-video "$CHOICE"
    '')
  ];
}
</file>

<file path="modules/fuzzel.nix">
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme # Fallback for apps missing in Papirus
    hicolor-icon-theme # Base icon theme (fallback)
  ];

  programs.fuzzel = {
    enable = true;
    # La configuration est gérée dynamiquement par sync-colors.py via un lien symbolique
  };

  # Symlinks pour les icônes manquantes dans les thèmes standards
  home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source =
    "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

  # Pour Antigravity, on essaie de pointer vers son icône si elle est packagée
  # Note: Si l'icône n'est pas trouvée, HM ignorera ou on ajustera.
  home.file.".local/share/icons/hicolor/scalable/apps/antigravity.svg".source = "${
    pkgs.antigravity-unwrapped or pkgs.antigravity
  }/share/icons/hicolor/scalable/apps/antigravity.svg";
  # Lien vers la config générée dynamiquement
  home.file.".config/fuzzel/fuzzel.ini".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/generated/fuzzel.ini";
}
</file>

<file path="README.md">
# ❄️ NixOS Configuration (Muggy-NixOS)

A high-performance, modern NixOS configuration featuring **Niri** (Wayland compositor) and **GNOME** (as a robust fallback), optimized for gaming and productivity.

![Desktop Screenshot](https://github.com/user-attachments/assets/0ed74bc7-cd22-45a3-86f3-e17897266439)

## ✨ Key Features
- **UI/UX**: [Niri](https://github.com/YaLTeR/niri) (unstable) with a custom [Noctalia shell](https://github.com/Noctatia/noctalia) setup.
- **Kernel**: Optimized CachyOS Bore kernel for low-latency desktop performance.
- **Gaming**: Pre-configured Steam, GameMode, and AMD GPU optimizations.
- **Shell**: Fish shell equipped with Atuin (SQLite history) and Zoxide (smart navigation).
- **Tools**: Ghostty terminal, VSCode/Antigravity, and declarative Brave/Chromium policy management.
- **Portability**: Completely decoupled username and home paths for easy adoption.

---

## 🚀 Installation Guide

> [!NOTE]
> This guide is designed for a fresh NixOS installation. The script handles hardware configuration and enabling Flakes automatically.

### 2. Run the Installation Script
The `install.sh` script will automate everything for you (username detection, hardware configuration, and the first system build):
```bash
chmod +x install.sh
./install.sh
```

**What the script does:**
0.  **Personalization**: Automatically detects your username and prompts for your desired hostname, updating `flake.nix` and renaming host directories accordingly.
1.  **Hardware**: Generates a `hardware-configuration.nix` for your specific machine.
2.  **Flakes**: Ensures Flakes are supported for the initial build.
3.  **Hostname**: Sets your system hostname to your chosen value.
4.  **Build**: Performs the initial `nixos-rebuild switch`.

### 4. Final Steps
After the script finishes, **reboot** your system:
```bash
sudo reboot
```

---

## 🛠️ Maintenance & Common Commands

This config uses [**nh**](https://github.com/viperML/nh) for a faster and cleaner NixOS experience.

- **Apply changes**: `nos` (a built-in alias for `nh os switch`)
- **Update system**: `nix flake update` (then run `nos`)
- **Cleanup**: `nh clean all`

## 📁 Project Structure
- `hosts/`: Host-specific configurations (hostname: `muggy-nixos`).
- `modules/`: Reusable components (Brave, Shell, Gaming, etc.).
- `home.nix`: Main Home-Manager user configuration.
- `docs/`: Detailed guides for specific components (Brave extensions, Triple Relay workflow).

---
*Maintained by chandrahmuki. Built with ❄️ and Antigravity AI.*
</file>

<file path="modules/utils.nix">
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd # Used for the search function
    playerctl # MPRIS media player control (required for DMS media widget)
    nvd # Differenz between builds (shows package changes)
    manix # Fast Nix documentation searcher
    pamixer # CLI mixer for PulseAudio/PipeWire (volume control)
    pavucontrol # GUI volume control for PulseAudio/PipeWire
    pulseaudio # Provides pactl for volume control
    nodejs # For MCP servers and other node-based tools
    python3 # For advanced tools like the Kira scratchpad script
    repomix # Pack repository contents to single file for AI consumption
    qpdf # For decrypting PDFs
    jq # For parsing JSON (useful for flake.lock)
    matugen # Material You color generation tool
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris # MPRIS support for media player detection (DMS, playerctl)
    ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish.functions = {
    # Search function that searches from root (/)
    # Uses fd for speed, searching globally
    search = ''
      if test (count $argv) -eq 0
        echo "Usage: search <query>"
        return 1
      end

      # Launch fzf in interactive mode
      # --disabled: Do not let fzf filter the results, let fd handle it via reload
      # --query: Pre-fill with the user's argument
      # --bind: Reload fd whenever the query string changes
      # --preview: Optional but nice, shows file content with bat
      ${pkgs.fzf}/bin/fzf --disabled --query "$argv" \
        --bind "start:reload:${pkgs.fd}/bin/fd {q} / 2>/dev/null" \
        --bind "change:reload:${pkgs.fd}/bin/fd {q} / 2>/dev/null" \
        --preview "${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 {}"
    '';

    # Audio-only playback with mpv
    mpno = "mpv --no-video $argv";

    # Quick flake update with input name
    nfu = "nix flake update $argv";

    # Sync dynamic colors using Matugen
    upc = "matugen -c ~/nixos-config/templates/matugen.toml image \$(cat ~/.cache/noctalia/wallpapers.json | jq -r .defaultWallpaper) && makoctl reload";
  };
}
</file>

<file path="nvim/lua/plugins/snacks.lua">
return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
███╗   ███╗██╗   ██╗ ██████╗  ██████╗ ██╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗ ████║██║   ██║██╔═══██╗██╔═══██╗██║   ██║██║   ██║██║████╗ ████║
██╔████╔██║██║   ██║██║   ██║██║   ██║██║   ██║██║   ██║██║██╔████╔██║
██║╚██╔╝██║██║   ██║██║   ██║██║   ██║╚██╗ ██╔╝╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝╚██████╔╝ ╚████╔╝  ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚═╝ ╚═════╝  ╚═════╝  ╚═════╝   ╚═══╝    ╚═══╝  ╚═╝╚═╝     ╚═╝
                        ✨ Welcome to MuggyVim ✨
        ]],
      },
    },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Top Level (Essential)
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Find File" },
    { "<leader>,",       function() Snacks.picker.buffers() end, desc = "Switch Buffer" },
    { "<leader>.",       function() Snacks.explorer() end, desc = "Browse Files" },
    { "<leader>/",       function() Snacks.picker.grep() end, desc = "Search" },
    { "<leader>:",       function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>e",       function() Snacks.explorer() end, desc = "File Explorer" },

    -- [f]ile / find
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers (Alternative)" },
    { "<leader>fe", function() Snacks.explorer() end, desc = "Explorer" },

    -- [g]it
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },

    -- [s]earch
    { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },

    -- [u]i / util
    { "<leader>uz", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>u.", function() Snacks.scratch() end, desc = "Scratch Buffer" },
    { "<leader>uS", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<c-/>",     function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },
}
</file>

<file path="nvim/lua/plugins/whichkey.lua">
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "classic",
    win = {
      border = "none",
      padding = { 1, 2 },
    },
    layout = {
      spacing = 3,
      align = "center",
    },
    icons = {
      separator = "➜",
      group = "+",
      mappings = true, -- Réactiver pour autoriser mes icônes manuelles
      rules = false,   -- Désactiver les règles auto qui mettent des "bonbons" (emojis)
    },
    spec = {
      { "<leader>b", group = "buffer", icon = "󰓩 " },
      { "<leader>f", group = "file", icon = "󰈔 " },
      { "<leader>g", group = "git", icon = "󰊢 " },
      { "<leader>q", group = "quit/session", icon = "󰗼 " },
      { "<leader>s", group = "search", icon = " " },
      { "<leader>u", group = "ui", icon = "󰙵 " },
      { "<leader>w", group = "window", icon = "󰖲 " },
      -- Top-level
      { "<leader><space>", icon = " " },
      { "<leader>,",       icon = "󰓩 " },
      { "<leader>.",       icon = "󰉋 " },
      { "<leader>/",       icon = "󰍉 " },
      { "<leader>:",       icon = " " },
      { "<leader>e",       icon = "󰙅 " },
      -- Sous-menus [f]ile
      { "<leader>ff", icon = " " },
      { "<leader>fr", icon = " " },
      { "<leader>fg", icon = "󰊢 " },
      { "<leader>fb", icon = "󰓩 " },
      { "<leader>fe", icon = "󰉋 " },
      { "<leader>fs", icon = "󰆓 " },
      -- Sous-menus [g]it
      { "<leader>gs", icon = "󰊢 " },
      { "<leader>gl", icon = "󰗀 " },
      -- Sous-menus [s]earch
      { "<leader>sn", icon = "󰵙 " },
      { "<leader>sb", icon = "󰈙 " },
      { "<leader>sg", icon = "󰍉 " },
      { "<leader>sh", icon = "󰞋 " },
      { "<leader>sk", icon = "󰌌 " },
      { "<leader>sm", icon = "󰈚 " },
      -- Sous-menus [u]i
      { "<leader>uz", icon = "󰙵 " },
      { "<leader>u.", icon = "󰈚 " },
      { "<leader>uS", icon = "󰒙 " },
    },
  },
  config = function(_, opts)
    require("which-key").setup(opts)
    -- Harmoniser la couleur des groupes (+) avec les descriptions (pas de blanc)
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "WhichKeyDesc" })
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
</file>

<file path="flake.lock">
{
  "nodes": {
    "antigravity": {
      "inputs": {
        "flake-utils": "flake-utils",
        "nixpkgs": [
          "nixpkgs"
        ]
      },
      "locked": {
        "lastModified": 1771198383,
        "narHash": "sha256-mOq7ks7gdWyVStIUAp7U8wztanYKt0GgCnIZtPUJ6n8=",
        "owner": "jacopone",
        "repo": "antigravity-nix",
        "rev": "703d29149cc127d1ec7c1885ff14f85d4e6a01ce",
        "type": "github"
      },
      "original": {
        "owner": "jacopone",
        "repo": "antigravity-nix",
        "type": "github"
      }
    },
    "cachyos-kernel": {
      "flake": false,
      "locked": {
        "lastModified": 1771263855,
        "narHash": "sha256-akyds1g8cb742d2OrnQ4YciscpynsQ0+0YD2a8aZdvo=",
        "owner": "CachyOS",
        "repo": "linux-cachyos",
        "rev": "5ece16c7b4a7d1261da68153cafc318a60b78ce8",
        "type": "github"
      },
      "original": {
        "owner": "CachyOS",
        "repo": "linux-cachyos",
        "type": "github"
      }
    },
    "cachyos-kernel-patches": {
      "flake": false,
      "locked": {
        "lastModified": 1771246613,
        "narHash": "sha256-GftqKiyIgMcSgVkbNqXQq7oNnoL1+EB9V71XG4lPBRs=",
        "owner": "CachyOS",
        "repo": "kernel-patches",
        "rev": "cb320a13e3c92f32ada27acb1fba8a828a22ae60",
        "type": "github"
      },
      "original": {
        "owner": "CachyOS",
        "repo": "kernel-patches",
        "type": "github"
      }
    },
    "flake-compat": {
      "flake": false,
      "locked": {
        "lastModified": 1767039857,
        "narHash": "sha256-vNpUSpF5Nuw8xvDLj2KCwwksIbjua2LZCqhV1LNRDns=",
        "owner": "NixOS",
        "repo": "flake-compat",
        "rev": "5edf11c44bc78a0d334f6334cdaf7d60d732daab",
        "type": "github"
      },
      "original": {
        "owner": "NixOS",
        "repo": "flake-compat",
        "type": "github"
      }
    },
    "flake-parts": {
      "inputs": {
        "nixpkgs-lib": "nixpkgs-lib"
      },
      "locked": {
        "lastModified": 1769996383,
        "narHash": "sha256-AnYjnFWgS49RlqX7LrC4uA+sCCDBj0Ry/WOJ5XWAsa0=",
        "owner": "hercules-ci",
        "repo": "flake-parts",
        "rev": "57928607ea566b5db3ad13af0e57e921e6b12381",
        "type": "github"
      },
      "original": {
        "owner": "hercules-ci",
        "repo": "flake-parts",
        "type": "github"
      }
    },
    "flake-utils": {
      "inputs": {
        "systems": "systems"
      },
      "locked": {
        "lastModified": 1731533236,
        "narHash": "sha256-l0KFg5HjrsfsO/JpG+r7fRrqm12kzFHyUHqHCVpMMbI=",
        "owner": "numtide",
        "repo": "flake-utils",
        "rev": "11707dc2f618dd54ca8739b309ec4fc024de578b",
        "type": "github"
      },
      "original": {
        "owner": "numtide",
        "repo": "flake-utils",
        "type": "github"
      }
    },
    "home-manager": {
      "inputs": {
        "nixpkgs": [
          "nixpkgs"
        ]
      },
      "locked": {
        "lastModified": 1771269455,
        "narHash": "sha256-BZ31eN5F99YH6vkc4AhzKGE+tJgJ52kl8f01K7wCs8w=",
        "owner": "nix-community",
        "repo": "home-manager",
        "rev": "5f1d42a97b19803041434f66681d5c44c9ae62e3",
        "type": "github"
      },
      "original": {
        "owner": "nix-community",
        "repo": "home-manager",
        "type": "github"
      }
    },
    "niri": {
      "inputs": {
        "niri-stable": "niri-stable",
        "niri-unstable": "niri-unstable",
        "nixpkgs": [
          "nixpkgs"
        ],
        "nixpkgs-stable": "nixpkgs-stable",
        "xwayland-satellite-stable": "xwayland-satellite-stable",
        "xwayland-satellite-unstable": "xwayland-satellite-unstable"
      },
      "locked": {
        "lastModified": 1771308899,
        "narHash": "sha256-kb/4oSHB261GOLhVGgrzTOqo/ImeCi/WS25q2ujtHGc=",
        "owner": "sodiboo",
        "repo": "niri-flake",
        "rev": "f3e98ba073bd7e2717a07d622f9b737c461a97b9",
        "type": "github"
      },
      "original": {
        "owner": "sodiboo",
        "repo": "niri-flake",
        "type": "github"
      }
    },
    "niri-stable": {
      "flake": false,
      "locked": {
        "lastModified": 1756556321,
        "narHash": "sha256-RLD89dfjN0RVO86C/Mot0T7aduCygPGaYbog566F0Qo=",
        "owner": "YaLTeR",
        "repo": "niri",
        "rev": "01be0e65f4eb91a9cd624ac0b76aaeab765c7294",
        "type": "github"
      },
      "original": {
        "owner": "YaLTeR",
        "ref": "v25.08",
        "repo": "niri",
        "type": "github"
      }
    },
    "niri-unstable": {
      "flake": false,
      "locked": {
        "lastModified": 1771305475,
        "narHash": "sha256-lqweVTwHhYc+9T33cysp38gVwxaibGJHriOPZXWyhCY=",
        "owner": "YaLTeR",
        "repo": "niri",
        "rev": "a2a52911757cb3b497db9407592f9b4c439571ea",
        "type": "github"
      },
      "original": {
        "owner": "YaLTeR",
        "repo": "niri",
        "type": "github"
      }
    },
    "nix-cachyos": {
      "inputs": {
        "cachyos-kernel": "cachyos-kernel",
        "cachyos-kernel-patches": "cachyos-kernel-patches",
        "flake-compat": "flake-compat",
        "flake-parts": "flake-parts",
        "nixpkgs": "nixpkgs"
      },
      "locked": {
        "lastModified": 1771265142,
        "narHash": "sha256-5N57t2nBVIsXRWelOQvYLuT9Of4SlEqeCFfSGXaIiBY=",
        "owner": "xddxdd",
        "repo": "nix-cachyos-kernel",
        "rev": "cba6866d1709590134120eefdc0a1a9854e7447e",
        "type": "github"
      },
      "original": {
        "owner": "xddxdd",
        "ref": "release",
        "repo": "nix-cachyos-kernel",
        "type": "github"
      }
    },
    "nixpkgs": {
      "locked": {
        "lastModified": 1771218441,
        "narHash": "sha256-BZ2vjG1LMwWoLTRb+OJksrTyLo5xbo3Vs9TiB+ozarY=",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "007d7747527cde542ffec2a4011d17658d2c6ab2",
        "type": "github"
      },
      "original": {
        "owner": "NixOS",
        "ref": "nixos-unstable-small",
        "repo": "nixpkgs",
        "type": "github"
      }
    },
    "nixpkgs-lib": {
      "locked": {
        "lastModified": 1769909678,
        "narHash": "sha256-cBEymOf4/o3FD5AZnzC3J9hLbiZ+QDT/KDuyHXVJOpM=",
        "owner": "nix-community",
        "repo": "nixpkgs.lib",
        "rev": "72716169fe93074c333e8d0173151350670b824c",
        "type": "github"
      },
      "original": {
        "owner": "nix-community",
        "repo": "nixpkgs.lib",
        "type": "github"
      }
    },
    "nixpkgs-master": {
      "locked": {
        "lastModified": 1771351578,
        "narHash": "sha256-0G0QhkIpi0h/V+Ha83rlg7oHTohqGwnnTLFTdb0uDdM=",
        "owner": "nixos",
        "repo": "nixpkgs",
        "rev": "1fa09357b2947765f3031109d95d5e641f1bb1cc",
        "type": "github"
      },
      "original": {
        "owner": "nixos",
        "ref": "master",
        "repo": "nixpkgs",
        "type": "github"
      }
    },
    "nixpkgs-stable": {
      "locked": {
        "lastModified": 1771208521,
        "narHash": "sha256-X01Q3DgSpjeBpapoGA4rzKOn25qdKxbPnxHeMLNoHTU=",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "fa56d7d6de78f5a7f997b0ea2bc6efd5868ad9e8",
        "type": "github"
      },
      "original": {
        "owner": "NixOS",
        "ref": "nixos-25.11",
        "repo": "nixpkgs",
        "type": "github"
      }
    },
    "nixpkgs_2": {
      "locked": {
        "lastModified": 1771008912,
        "narHash": "sha256-gf2AmWVTs8lEq7z/3ZAsgnZDhWIckkb+ZnAo5RzSxJg=",
        "owner": "nixos",
        "repo": "nixpkgs",
        "rev": "a82ccc39b39b621151d6732718e3e250109076fa",
        "type": "github"
      },
      "original": {
        "owner": "nixos",
        "ref": "nixos-unstable",
        "repo": "nixpkgs",
        "type": "github"
      }
    },
    "noctalia": {
      "inputs": {
        "nixpkgs": [
          "nixpkgs"
        ]
      },
      "locked": {
        "lastModified": 1771340206,
        "narHash": "sha256-IanPDIuEft3uxOorgp5Sk1e5Vil2DYWL5FwN4zh4LF0=",
        "owner": "noctalia-dev",
        "repo": "noctalia-shell",
        "rev": "c2629c3c2fadb47695e8e3deb37d7a416644bf3e",
        "type": "github"
      },
      "original": {
        "owner": "noctalia-dev",
        "repo": "noctalia-shell",
        "type": "github"
      }
    },
    "root": {
      "inputs": {
        "antigravity": "antigravity",
        "home-manager": "home-manager",
        "niri": "niri",
        "nix-cachyos": "nix-cachyos",
        "nixpkgs": "nixpkgs_2",
        "nixpkgs-master": "nixpkgs-master",
        "noctalia": "noctalia"
      }
    },
    "systems": {
      "locked": {
        "lastModified": 1681028828,
        "narHash": "sha256-Vy1rq5AaRuLzOxct8nz4T6wlgyUR7zLU309k9mBC768=",
        "owner": "nix-systems",
        "repo": "default",
        "rev": "da67096a3b9bf56a91d16901293e51ba5b49a27e",
        "type": "github"
      },
      "original": {
        "owner": "nix-systems",
        "repo": "default",
        "type": "github"
      }
    },
    "xwayland-satellite-stable": {
      "flake": false,
      "locked": {
        "lastModified": 1755491097,
        "narHash": "sha256-m+9tUfsmBeF2Gn4HWa6vSITZ4Gz1eA1F5Kh62B0N4oE=",
        "owner": "Supreeeme",
        "repo": "xwayland-satellite",
        "rev": "388d291e82ffbc73be18169d39470f340707edaa",
        "type": "github"
      },
      "original": {
        "owner": "Supreeeme",
        "ref": "v0.7",
        "repo": "xwayland-satellite",
        "type": "github"
      }
    },
    "xwayland-satellite-unstable": {
      "flake": false,
      "locked": {
        "lastModified": 1771195969,
        "narHash": "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=",
        "owner": "Supreeeme",
        "repo": "xwayland-satellite",
        "rev": "536bd32efc935bf876d6de385ec18a1b715c9358",
        "type": "github"
      },
      "original": {
        "owner": "Supreeeme",
        "repo": "xwayland-satellite",
        "type": "github"
      }
    }
  },
  "root": "root",
  "version": 7
}
</file>

<file path="install.sh">
#!/usr/bin/env bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     NixOS Configuration - Post-Installation Setup           ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root!"
    print_info "Run as your regular user: ./install.sh"
    exit 1
fi

print_header

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_HOSTNAME=$(hostname)
CONFIG_HOSTNAME="muggy-nixos"
FLAKE_NAME="muggy-nixos"

print_info "Starting post-installation setup..."
print_info "Script location: $SCRIPT_DIR"
print_info "Current hostname: $CURRENT_HOSTNAME"

# Step 0: Personalize username
# ... (already there, skipping to next part in actual file)

# Step 0.5: Personalize hostname
print_info "\nStep 0.5: Personalizing hostname..."
read -p "Enter your desired hostname (default: $CONFIG_HOSTNAME): " FINAL_HOSTNAME
if [ -z "$FINAL_HOSTNAME" ]; then
    FINAL_HOSTNAME="$CONFIG_HOSTNAME"
fi

if [ "$FINAL_HOSTNAME" != "$CONFIG_HOSTNAME" ]; then
    if [ -d "$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME" ]; then
        print_info "Renaming host configuration from '$CONFIG_HOSTNAME' to '$FINAL_HOSTNAME'..."
        
        # Rename directory
        mv "$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME" "$SCRIPT_DIR/hosts/$FINAL_HOSTNAME"
        
        # Update all file references
        print_info "Updating file references..."
        sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/flake.nix"
        sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/modules/nh.nix"
        sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/modules/terminal.nix"
        sed -i "s/$CONFIG_HOSTNAME/$FINAL_HOSTNAME/g" "$SCRIPT_DIR/hosts/$FINAL_HOSTNAME/default.nix"
    else
        print_warning "Directory hosts/$CONFIG_HOSTNAME not found. Skipping rename (maybe already done?)"
    fi
    
    # Update script variables for the rest of the execution
    CONFIG_HOSTNAME="$FINAL_HOSTNAME"
    FLAKE_NAME="$FINAL_HOSTNAME"
    print_success "Hostname personalization complete!"
else
    print_info "Using default hostname: $CONFIG_HOSTNAME"
fi

# Step 1: Generate hardware configuration
print_info "\nStep 1: Generating hardware configuration..."
HARDWARE_CONFIG="$SCRIPT_DIR/hosts/$CONFIG_HOSTNAME/hardware-configuration.nix"

if [ -f "$HARDWARE_CONFIG" ]; then
    print_warning "hardware-configuration.nix already exists!"
    read -p "Overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing hardware configuration"
    else
        sudo nixos-generate-config --show-hardware-config > "$HARDWARE_CONFIG"
        print_success "Hardware configuration regenerated!"
    fi
else
    sudo nixos-generate-config --show-hardware-config > "$HARDWARE_CONFIG"
    print_success "Hardware configuration generated!"
fi

# Step 2: Check if flakes are supported
print_info "\nStep 2: Checking flakes configuration..."
EXTRA_FLAGS="--extra-experimental-features 'nix-command flakes'"

# Try to use nix flake command
if nix flake metadata "$SCRIPT_DIR" $EXTRA_FLAGS &>/dev/null; then
    print_success "Flakes are supported!"
else
    print_error "Nix command not found or not working properly!"
    exit 1
fi

# Step 3: Verify hostname
print_info "\nStep 3: Verifying hostname..."
if [ "$(hostname)" != "$CONFIG_HOSTNAME" ]; then
    print_warning "Hostname mismatch!"
    print_info "Current: $CURRENT_HOSTNAME"
    print_info "Config:  $CONFIG_HOSTNAME"
    print_info "The hostname will be changed to '$CONFIG_HOSTNAME' after rebuild."
    echo ""
    read -p "Continue? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Aborted by user."
        exit 0
    fi
fi

# Step 4: Build and switch
print_info "\nStep 4: Building and switching to new configuration..."
print_warning "This may take a while on first build..."
echo ""

BUILD_CMD="sudo nixos-rebuild switch --flake $SCRIPT_DIR#$FLAKE_NAME $EXTRA_FLAGS"

print_info "Running: $BUILD_CMD"
echo ""

if eval $BUILD_CMD; then
    print_success "\n✨ Configuration successfully applied!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review any warnings or errors above"
    echo "2. Reboot to ensure all changes take effect:"
    echo -e "   ${YELLOW}sudo reboot${NC}"
    echo ""
    print_success "Setup completed successfully! 🎉"
else
    print_error "Failed to rebuild system configuration!"
    print_info "Check the errors above and fix any issues."
    print_info "You can manually retry with:"
    echo -e "   ${YELLOW}$BUILD_CMD${NC}"
    exit 1
fi
</file>

<file path="modules/noctalia.nix">
{ config, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configuration du fond d'écran pour Noctalia
  home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
    defaultWallpaper = "${config.home.homeDirectory}/Pictures/wallpaper/wallpaper.png";
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true; # Auto-start avec Niri/Wayland

    # Configuration Noctalia (basée sur la doc)
    settings = {
      bar = {
        position = "left"; # Barre sur le côté gauche
        barType = "floating"; # Style flottant
        floating = true;
        backgroundOpacity = 0.5; # Transparence 50%
        useSeparateOpacity = true;
        monitors = [ "DP-2" ]; # Afficher uniquement sur l'écran 2K (AOC)
        margin = 10;
        marginVertical = 10;
        marginHorizontal = 10;

        # Widgets sans le Launcher
        widgets = {
          left = [
            # { id = "Launcher"; }  # Retiré !
            { id = "Clock"; }
            { id = "SystemMonitor"; }
            { id = "ActiveWindow"; }
            { id = "MediaMini"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "Tray"; }
            # { id = "NotificationHistory"; } # Retiré à la demande de l'utilisateur
            { id = "Battery"; }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "ControlCenter"; }
          ];
        };
      };

      general = {
        animationSpeed = 1.5; # Plus rapide (x1.5)
        radiusRatio = 1.0;
      };

      notifications = {
        enabled = false;
      };

      colorSchemes = {
        darkMode = true;
        schemeType = "vibrant"; # Couleurs plus éclatantes extraites du wallpaper
        useWallpaperColors = true; # Support matugen/dynamic theming
      };
    };

    # On peut aussi définir des plugins ici si besoin
    # plugins = { ... };
  };
}
</file>

<file path="wm/niri.nix">
{ pkgs, ... }:
{
  imports = [
    ./binds.nix
    ./style.nix
  ];

  # jq est nécessaire pour certains scripts niri
  home.packages = [ pkgs.jq ];

  programs.niri.settings = {

    # deactivate niri hotkey pannel at startup
    hotkey-overlay.skip-at-startup = true;

    input.keyboard.xkb = {
      layout = "us";
      model = "pc104";
      variant = "intl";
    };

    prefer-no-csd = true;

    spawn-at-startup = [
      # { command = [ "sleep 15; systemctl --user restart swaybg" ]; }
      { command = [ "xwayland-satellite" ]; }
    ];

    debug = {
      # Permet le focus même si le token d'activation est "imparfait" (ex: via une notification)
      honor-xdg-activation-with-invalid-serial = true;
      # Corrige les soucis de focus pour les apps Chromium/Electron
      deactivate-unfocused-windows = true;
    };

    environment."DISPLAY" = ":0";

    layout.default-column-width = {
      proportion = 1. / 2.;
    };

    layout.preset-column-widths = [
      { proportion = 1. / 3.; }
      { proportion = 1. / 2.; }
      { proportion = 2. / 3.; }
    ];

    layout.preset-window-heights = [
      { proportion = 1.; }
      { proportion = 1. / 3.; }
      { proportion = 1. / 2.; }
      { proportion = 2. / 3.; }
    ];

    # Configuration des écrans
    # DP-2 (2K) à gauche, HDMI-A-1 (4K) à droite
    outputs = {
      "DP-2" = {
        # Écran 2K AOC (à gauche, avec 75Hz)
        mode = {
          width = 2560;
          height = 1440;
          refresh = 74.968;
        };
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
      };
      "HDMI-A-1" = {
        # Écran 4K LG (à droite)
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        scale = 2.0; # Scale 2x pour 4K
        position = {
          x = 2560; # Juste après le 2K
          y = 0;
        };
      };
    };

  };
}
</file>

<file path="home.nix">
{ username, ... }: # <-- N'oublie pas d'ajouter { config, pkgs, ... }: en haut !

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  # On importe ici les fichiers qu'on va créer dans le dossier modules
  imports = [
    ./modules/btop.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/fastfetch.nix
    ./modules/brave.nix
    ./modules/vscode.nix
    ./wm/niri.nix
    ./modules/fuzzel.nix
    ./modules/music-menu.nix
    ./modules/noctalia.nix
    ./modules/nh.nix
    ./modules/parsec.nix
    ./modules/antigravity.nix
    ./modules/direnv.nix
    ./modules/yt-dlp.nix
    ./modules/yazi.nix
    ./modules/utils.nix
    ./modules/neovim.nix
    ./modules/discord.nix
    ./modules/xdg.nix
    ./modules/tealdeer.nix
    ./modules/atuin.nix
    ./modules/pdf.nix
    ./modules/notifications.nix
  ];

  programs.home-manager.enable = true;
}
</file>

<file path="modules/notifications.nix">
{ config, pkgs, lib, ... }:

{
  # notify-send est fourni par libnotify
  home.packages = [ pkgs.libnotify ];
  # Mako : daemon de notification léger avec support natif xdg-activation
  # Quand on clique une notification, Mako envoie un token d'activation
  # au compositeur (Niri) qui change automatiquement de workspace et focus la fenêtre
  services.mako = {
    enable = true;
    # La configuration est gérée dynamiquement par sync-colors.py via un lien symbolique
  };

  home.file.".config/mako/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/generated/mako";
}
</file>

<file path=".agent/workflows/auto-doc.md">
---
description: Automatisation de la documentation et de la synchronisation après un changement.
---

Ce workflow permet de boucler une tâche proprement en minimisant la recherche aveugle des sous-agents.

// turbo-all
// turbo-all
1. Synchronisation Git chirurgicale (sans Repomix pour la vitesse)
```bash
git add . && git commit -m "docs: synchronization and context update" && git push
```

2. Instructions pour l'agent suivant (Relais Triple)
Ouvrez une nouvelle session avec un nouvel agent et tapez simplement :

- **`/audit`** : Pour lancer une revue de code (Auditeur).
- **`/archive`** : Pour capitaliser le savoir (Archiviste).

Le dépôt est prêt pour le relais. À bientôt ! 💎🦾

Le dépôt est maintenant prêt pour la capitalisation. À bientôt ! 💎🦾
</file>

<file path="modules/antigravity.nix">
{ config, pkgs, lib, ... }:

let
  # Extensions VSCode pour le support Nix
  nixExtensions = [
    pkgs.vscode-extensions.bbenoist.nix
    pkgs.vscode-extensions.jnoortheen.nix-ide
  ];

  # Helper pour créer les liens symboliques d'extensions dans le dossier Antigravity
  mkExtensionSymlink = ext: {
    # Format attendu par Antigravity : publisher.name-version-platform
    name = ".antigravity/extensions/${ext.vscodeExtPublisher}.${ext.vscodeExtName}-${ext.version}-universal";
    value = {
      source = "${ext}/share/vscode/extensions/${ext.vscodeExtPublisher}.${ext.vscodeExtName}";
    };
  };
in
{
  home.packages = [
    pkgs.google-antigravity
    pkgs.nil # Language Server for Nix
    pkgs.nixfmt # Formatter for Nix
  ];

  # Fichiers et configurations Antigravity
  home.file = (builtins.listToAttrs (map mkExtensionSymlink nixExtensions)) // {
    # Configuration mutable liée au dépôt git (pour permettre à l'agent d'écrire dedans si nécessaire)
    # Géré via le script d'activation plus bas pour éviter le verrouillage en lecture seule
    # ".config/Antigravity/User/settings.json".source = ...

    # Gestion persistante de la config MCP
    ".gemini/antigravity/mcp_config.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/mcp_config.json";
  };

  # Activation Script : Force Brute pour le settings.json
  # Home Manager a tendance à verrouiller ce fichier en lecture seule ou à casser le lien.
  # On force ici un lien symbolique direct vers notre fichier mutable après l'activation.
  home.activation.linkAntigravitySettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p $HOME/.config/Antigravity/User
    run rm -f $HOME/.config/Antigravity/User/settings.json
    run ln -sf $HOME/nixos-config/modules/antigravity-settings.json $HOME/.config/Antigravity/User/settings.json
  '';

  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code";
  };
}
</file>

<file path="modules/brave.nix">
{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--unlimited-storage"
      # Force le mode sombre pour l'UI du navigateur et le contenu des pages web
      "--enable-features=UseOzonePlatform,WebContentsForceDark"
      "--ozone-platform=wayland" # Force l'utilisation native de Wayland
      "--force-dark-mode"
    ];
  };

  # Écrase complètement com.brave.Browser.desktop pour qu'il soit caché mais valide pour xdg-open
  home.file.".local/share/applications/com.brave.Browser.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Brave Browser
    Exec=brave %U
    Terminal=false
    NoDisplay=true
    Categories=Network;WebBrowser;
    MimeType=text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
  '';
}
</file>

<file path="modules/terminal.nix">
{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "Dracula";
      font-family = "Hack Nerd Font";
      font-size = 18;
      background-opacity = 0.9;
      window-padding-x = 15;
      window-padding-y = 15;
      window-decoration = false;

      # Raccourcis Zoom
      keybind = [
        "ctrl+plus=increase_font_size:1"
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+0=reset_font_size"

        # User request: Shift+Alt+Wheel
        # Note: Mouse binding support in Ghostty is experimental/limited.
        # If wheel doesn't work, use the Shift+Alt+Plus/Minus shortcuts below.
        "shift+alt+plus=increase_font_size:1"
        "shift+alt+minus=decrease_font_size:1"
      ];
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true; # Crée automatiquement les alias ls, ll, etc.
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
  # On active Starship
  programs.starship = {
    enable = true;
    # On peut le configurer ici, mais les réglages par défaut sont déjà top
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      # Affiche une icône NixOS quand tu es dans un shell Nix
      nix_shell = {
        symbol = "❄️ ";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  # Configuration de FISH
  programs.fish = {
    enable = true;
    # Ton shell sera tout de suite prêt à l'emploi
    interactiveShellInit = ''
      set -g fish_greeting ""

      if status is-interactive
        # Fonction pour les outils visuels (Starship, Fastfetch)
        # On les regroupe pour plus de clarté
        function setup_visual_tools
          starship init fish | source
          atuin init fish | source
        end

        # On ne lance les outils visuels que si on n'est pas dans un terminal "dumb"
        # Cela évite de bloquer l'agent AI ou les commandes distantes
        if test "$TERM" != "dumb"
          setup_visual_tools
        end

        # Mode Vim pour Fish
        fish_vi_key_bindings
        
        # Configuration du curseur pour les modes Vi (premium touch)
        set -g fish_cursor_default block
        set -g fish_cursor_insert line
        set -g fish_cursor_replace_one underscore
        set -g fish_cursor_visual block

        # Raccourci jk pour sortir du mode insertion (Esc)
        function fish_user_key_bindings
          bind -M insert -m default jk backward-char force-repaint
        end

        # Complétion pour nfu (nix flake update)
        # On extrait les inputs du flake.lock et on exclut ceux déjà présents sur la ligne de commande
        complete -c nfu -f -a "(
          if test -f flake.lock
            set -l inputs (cat flake.lock | jq -r '.nodes.root.inputs | keys[]' 2>/dev/null)
            set -l current_args (commandline -opc)
            for i in \$inputs
              if not contains \$i \$current_args
                echo \$i
              end
            end
          end
        )"
      end
    '';
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake .#muggy-nixos";
    };

  };
}
</file>

<file path="GEMINI.md">
# Règles pour l'Assistant IA

> [!NOTE]
> Je dispose de compétences spécialisées (Skills) situées dans `.agent/skills/`. Elles complètent ces règles de base.


## Git / Gestion de version
- Pour ce projet, après chaque modification fonctionnelle :
  - Exécuter `git add .`
  - Exécuter `git commit` avec un message descriptif approprié.

## Compilation et déploiement
- J'utilise `nos` pour compiler et déployer les modifications. C'est un alias pour `nh os switch` (voir `modules/nh.nix`).
- **Important** : Je lance `nos` moi-même dans un terminal externe. Ne pas l'exécuter depuis l'éditeur (nécessite sudo).

## Mise à jour du flake
- Pour tout mettre à jour SAUF le kernel CachyOS : `nix flake update nixpkgs home-manager niri noctalia antigravity`
- Pour mettre à jour uniquement le kernel : `nix flake update nix-cachyos`

## Commentaires et Clarté
- **Toujours commenter le code** : Chaque ajout ou modification complexe doit être accompagné de commentaires explicatifs pour faciliter la compréhension de la configuration.

## Recherche et Stratégie (NixOS / Nixpkgs)
- **Priorité aux Outils MCP** : Pour toute recherche sur des options NixOS, des packages nixpkgs ou des paramètres Home Manager, utiliser **OBLIGATOIREMENT** l'outil `mcp_nix-search_nix` au lieu de recherches web génériques.
- **Utilisation de Fetch** : Si une recherche web est nécessaire malgré tout, utiliser l'outil de fetch (ou `mcp_fetch`) pour extraire le contenu proprement.
- **Précision** : Ne jamais deviner une option. Toujours la vérifier via le MCP pour garantir la compatibilité avec la version système.

## Contexte LLM / Repomix / Diff
- J'utilise `repomix` pour avoir une vision globale du projet.
- Avant toute analyse globale, je devrais consulter `repomix-nixos-config.md` s'il existe.
- **Pour une analyse rapide des changements récents**, je dois prioriser `git log --stat` et `git show --stat` au lieu de scanner tous les fichiers un par un.
- Si des changements structurels majeurs sont faits, il est recommandé de mettre à jour le fichier repomix avec `repomix --output repomix-nixos-config.md`.
- J'utilise le workflow `/auto-doc` pour automatiser la documentation rapide.
- J'utilise le workflow `/full-index` pour les mises à jour majeures du contexte (Repomix).

## Répartition des Rôles (Relais Triple)
- **Codeur (Toi)** : Focus 100% sur l'implémentation et la vérification fonctionnelle (tests).
- **Auditeur (Revue)** : Focus 100% sur la qualité, la propreté du code (Audit) et la conformité aux règles. Ne fait aucune modification.
- **Archiviste (Savoir)** : Focus 100% sur la documentation et les **Knowledge Items**.
- **Mode Relais** : Le Codeur passe le témoin à l'Auditeur ou à l'Archiviste via le workflow `/auto-doc`.

## Vitesse & Focus Chirurgical (Anti-Lag)
- **Priorité aux outils natifs** : J'utilise `list_dir` et `view_file` au lieu de `ls` ou `cat` dans le terminal. C'est instantané et ça ne "bloque" jamais.
- **Budget Turn-R/W** : Une tâche de documentation ne doit pas dépasser 5-10 appels d'outils. Si l'analyse devient complexe, je demande d'abord.
- **Zéro historique profond** : Interdiction de naviguer dans le `git log` au-delà du dernier commit (`-n 1`) sans demande explicite. 
- **Surgical Metadata Only** : Dans un workflow `/auto-doc`, je me contente de `git show --stat`. Je ne lis QUE les fichiers modifiés.
- **Pas de boucles infinies** : Si une commande ne répond pas après 2 tentatives de `command_status`, je demande l'avis de l'utilisateur au lieu de bloquer.

## Gestion du Savoir (Knowledge)
- **Différence Doc vs Knowledge** : 
    - `./docs/` est pour les humains (fiches, guides).
    - `~/.gemini/antigravity/knowledge/` est pour la mémoire IA (Knowledge Items).
- **Consommation Obligatoire** : Avant de rédiger quoi que ce soit, **VÉRIFIER** si un KI existe déjà sur le sujet pour le mettre à jour au lieu d'en créer un nouveau.
- **Priorité KI** : Pour toute modification technique structurelle, la création/mise à jour d'un **Knowledge Item** est LA priorité absolue par rapport à la doc Markdown classique.
</file>

<file path="modules/yazi.nix">
{ config, pkgs, lib, ... }:

{
  # Configuration du gestionnaire de fichiers Yazi
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y"; # Supprime le warning de deprecation

    settings = {
      manager = {
        show_hidden = true; # Afficher les fichiers cachés par défaut
        sort_by = "modified"; # Trier par date de modification
        sort_dir_first = true; # Afficher les dossiers en premier
      };

      # Définition des "openers" (applications pour ouvrir les fichiers)
      opener = {
        # 'listen' : lance mpv dans le terminal sans fenêtre vidéo pour l'audio
        listen = [
          {
            run = ''${pkgs.mpv}/bin/mpv --audio-display=no --no-video "$@"'';
            block = true; # Bloque yazi et affiche mpv dans le terminal (permet le contrôle clavier)
            desc = "Listen";
          }
        ];
      };

      # Règles d'ouverture des fichiers
      open = {
        # prepend_rules : ces règles s'appliquent AVANT les règles par défaut de yazi
        prepend_rules = [
          {
            name = "*.m3u";
            use = "listen";
          }
          {
            mime = "audio/*";
            use = "listen";
          } # Tous les types audio
          {
            name = "*.m4a";
            use = "listen";
          }
          {
            name = "*.mp3";
            use = "listen";
          }
          {
            name = "*.flac";
            use = "listen";
          }
          {
            name = "*.wav";
            use = "listen";
          }
          {
            # Catch m3u specifically by extension, even if mime is text
            name = "*.m3u"; 
            mime = "text/*";
            use = "listen";
          }
          {
            # Catch m3u by extension generally
            name = "*.m3u";
            use = "listen";
          }
          {
            # Catch by specific mime type
            mime = "audio/x-mpegurl";
            use = "listen";
          }
        ];
      };
    };
  };

  home.file.".config/yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/generated/yazi.toml";
}
</file>

<file path="hosts/muggy-nixos/default.nix">
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/font.nix
    ../../modules/steam.nix
    ../../modules/lact.nix
    ../../modules/brave-system.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Keep only 5 generations in boot menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Automatic garbage collection (weekly, keep 5 days of builds)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  #AMD
  boot.initrd.kernelModules = [ "amdgpu" ];

  #Manage backup for config in home manager
  home-manager.backupFileExtension = "backup";

  #Steam and games
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  #Activate KornFlakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Use latest kernel via Chaotic Nyx definition below
  # boot.kernelPackages = pkgs.linuxPackages_latest; # Removed to favor CachyOS kernel

  networking.hostName = "muggy-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Désactivation totale d'IBus pour supprimer la notification
  i18n.inputMethod.enable = false;

  # Empêcher GNOME de tirer IBus et de le lancer via autostart
  environment.gnome.excludePackages = [ pkgs.ibus ];

  # Force l'utilisation d'un module IM simple pour éviter que GNOME ne cherche IBus
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-im-module='gtk-im-context-simple'
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GDM Customization (HiDPI scaling)
  programs.dconf.profiles.gdm.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          scaling-factor = lib.gvariant.mkUint32 2; # 2x scale for HiDPI
          text-scaling-factor = 1.25; # Slightly larger text
        };
        "org/gnome/login-screen" = {
          banner-message-enable = false;
          disable-user-list = false; # Show user list
        };
      };
    }
  ];

  # Make GDM monitor configuration permanent
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - /home/${username}/.config/monitors.xml"
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #default to fish !
  programs.fish.enable = true;
  # Indispensable pour les binaires
  programs.nix-ld = {
    enable = true;
    libraries = [
      pkgs.stdenv.cc.cc
      pkgs.zlib
      pkgs.fuse3
      pkgs.icu
      pkgs.nss
      pkgs.openssl
      pkgs.curl
      pkgs.expat
      # Bibliothèques X11 explicites (xorg.*) pour éviter les warnings de dépréciation
      pkgs.xorg.libX11
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.libXcomposite
      pkgs.xorg.libXcursor
      pkgs.xorg.libXdamage
      pkgs.xorg.libXext
      pkgs.xorg.libXfixes
      pkgs.xorg.libXi
      pkgs.xorg.libXrandr
      pkgs.xorg.libXrender
      pkgs.xorg.libXtst
      pkgs.xorg.libxcb
      pkgs.xorg.libxshmfence
      pkgs.xorg.libxkbfile
    ];
  };

  # Empêche les jeux de "s'endormir" ou de tomber en FPS quand le workspace change
  environment.sessionVariables = {
    vk_xwayland_wait_ready = "false";
    MESA_SHADER_CACHE_MAX_SIZE = "16G";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    shell = pkgs.fish;

    packages = with pkgs; [
      #  thunderbird
    ];
  };
  # niri setup using unstable
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # XDG Desktop Portal is handled by Sodiboo's Niri module
  # We specify the default configuration to use gnome and gtk portals for Niri session
  xdg.portal = {
    enable = true;
    config.niri.default = [ "gnome" "gtk" ];
    extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
  };

  # Polkit for niri using the gnome one.
  security.polkit.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    xwayland-satellite
    nvtopPackages.amd
  ];

  # --- OPTIMIZATIONS ---

  # 1. Memory Management (ZRAM)
  zramSwap.enable = true;

  # 2. SSD Maintenance (Trim)
  services.fstrim.enable = true;

  # 3. Store Optimization (Deduplication)
  nix.settings.auto-optimise-store = true;

  # 4. Gaming & GPU
  programs.gamemode.enable = true;

  # 5. Kernel Scheduler (SCX - CachyOS-like)
  services.scx = {
    enable = true;
    scheduler = "scx_lavd"; # Retour vers LAVD, plus stable pour les transitions de focus
  };

  # 7. Advanced: CachyOS Latest Kernel via xddxdd
  nix.settings = {
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos.packages.x86_64-linux.linux-cachyos-bore;

  # 8. Advanced: Build in RAM (tmpfs) - 62GB RAM required
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "75%"; # Use up to 75% of RAM for build

  # 9. Advanced: TCP Optimizations (Standard stable)
  # On repasse sur fq_codel/cubic car CAKE/BBR demandent trop de CPU pendant les downloads Steam sur HDD
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "cubic";
  };
  boot.kernelParams = [ "amdgpu.gttsize=16384" ];
  boot.kernelModules = [ "ntsync" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
</file>

</files>
