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
    nix-flake-maintainer/
      SKILL.md
    nixos-architect/
      references/
        gaming/
          gaming-expertise.md
        nvme/
          nvme-transition.md
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
    auto-doc.md
    git-sync.md
.direnv/
  bin/
    nix-direnv-reload
docs/
  tealdeer.md
hosts/
  muggy-nixos/
    default.nix
    hardware-configuration.nix
modules/
  antigravity.nix
  brave.nix
  btop.nix
  direnv.nix
  discord.nix
  fastfetch.nix
  font.nix
  fuzzel.nix
  git.nix
  lact.nix
  neovim.nix
  nh.nix
  noctalia.nix
  parsec.nix
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

<file path="modules/brave.nix">
{ pkgs, ... }:

{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--unlimited-storage"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  # Écrase complètement com.brave.Browser.desktop pour qu'il soit caché
  home.file.".local/share/applications/com.brave.Browser.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Brave Browser (Hidden)
    NoDisplay=true
    Hidden=true
  '';
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

<file path="modules/git.nix">
{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    
# On utilise 'settings' pour tout ce qui concerne l'identité et les alias
    settings = {
      user = {
        name = "david";
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

<file path="modules/nh.nix">
{ _pkgs, ... }:

{
  programs.nh = {
    enable = true;

    # Chemin vers votre flake NixOS
    # Adaptez ce chemin selon votre configuration
    flake = "/home/david/nixos-config";

    # Nettoyage automatique des anciennes générations
    clean = {
      enable = true;
      # Garde les générations des 7 derniers jours
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  programs.fish.functions = {
    nos = ''
      cd /home/david/nixos-config
      nh os switch . --hostname muggy-nixos
    '';
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

<file path="modules/yt-dlp.nix">
{ pkgs, inputs, ... }:

{
  programs.yt-dlp = {
    enable = true;
    package = inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.yt-dlp;
    settings = {
      embed-thumbnail = true;
      add-metadata = true;
      output = "%(title)s.%(ext)s";
    };
  };

  programs.fish.functions = {
    yt = "yt-dlp -x --audio-format m4a $argv";
  };
}
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
print_info "Target hostname: $CONFIG_HOSTNAME"
print_info "Flake configuration: $FLAKE_NAME"

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

# Step 2: Check if flakes are enabled
print_info "\nStep 2: Checking flakes configuration..."
TEMP_CONFIG="/etc/nixos/configuration.nix"
EXTRA_FLAGS=""

# Try to use nix flake command - if it works, flakes are enabled
if nix flake metadata "$SCRIPT_DIR" &>/dev/null; then
    print_success "Flakes are enabled!"
else
    print_warning "Flakes not detected in system configuration!"
    print_info "Flakes are required to build this configuration."
    print_info "Please add to /etc/nixos/configuration.nix:"
    echo -e "${YELLOW}  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];${NC}"
    print_info "Then run: ${YELLOW}sudo nixos-rebuild switch${NC}"
    exit 1
fi

# Step 3: Verify hostname
print_info "\nStep 3: Verifying hostname..."
if [ "$CURRENT_HOSTNAME" != "$CONFIG_HOSTNAME" ]; then
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

BUILD_CMD="sudo nixos-rebuild switch --flake $SCRIPT_DIR#$FLAKE_NAME"

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

<file path=".agent/workflows/auto-doc.md">
---
description: Automatisation de la documentation et de la synchronisation après un changement.
---

Ce workflow permet de boucler une tâche proprement en minimisant la recherche aveugle des sous-agents.

// turbo-all
1. Exécution chirurgicale (Context + Git + Push) en une seule étape
```bash
repomix --output repomix-nixos-config.md && git add . && git commit -m "docs: synchronization and context update" && git push
```

2. Instructions pour l'agent suivant
Copiez ce message pour l'agent Archiviste :
> "Analyse le dernier commit avec `git show --stat`. Ton objectif final est de créer un **Knowledge Item** (mémoire IA) ou un fichier Markdown dans `./docs` (mémoire humaine). Ne te contente pas de remplir ton scratchpad : produit un document utile et durable."
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

<file path="nvim/lua/core/keymaps.lua">
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Basic keymaps
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- Clipboard paste
map("i", "<C-S-v>", '<Esc>"+pa', opts)
map("c", "<C-S-v>", '<C-R>+', opts)


-- Window navigation
map("n", "<leader>h", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>l", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>j", "<C-w>j", { desc = "Move to lower window" })
map("n", "<leader>k", "<C-w>k", { desc = "Move to upper window" })
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
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/",       function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:",       function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>e",       function() Snacks.explorer() end, desc = "File Explorer" },

    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },

    -- git
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },

    -- search
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },

    -- Other
    { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<c-/>",     function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },
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

<file path="nvim/lua/plugins/whichkey.lua">
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
  },
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

<file path="nvim/.stylua.toml">
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
</file>

<file path="wm/binds.nix">
{ config, ... }:
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+B".action = spawn [
      "rofi"
      "-show"
      "run"
    ];
    "Mod+D".action = spawn "fuzzel";
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

<file path=".gitignore">
# Secrets
modules/mcp_config.json

# Build results
result
result-*
</file>

<file path="README.md">
My first NixOs config - it is pretty much WIP but it is already functionaly with niri + dms and gnome as a backup !
<img width="2560" height="1440" alt="Screenshot from 2026-02-01 23-24-22" src="https://github.com/user-attachments/assets/0ed74bc7-cd22-45a3-86f3-e17897266439" />
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

<file path="modules/discord.nix">
{ pkgs, ... }:

{
  # Installation de Vesktop (client Discord alternatif optimisé pour Wayland)
  home.packages = with pkgs; [
    vesktop # Supporte le partage d'écran audio/vidéo sous Wayland et inclut Vencord
  ];
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

  # Configuration de FISH
  programs.fish = {
    enable = true;
    # On installe les plugins ici
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
    ];
    # Ton shell sera tout de suite prêt à l'emploi
    interactiveShellInit = ''
      fastfetch
      starship init fish | source
      set -g fish_greeting ""
    '';
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake .#muggy-nixos";
    };

  };
}
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

<file path="modules/fuzzel.nix">
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme # Fallback for apps missing in Papirus
    hicolor-icon-theme # Base icon theme (fallback)
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=18";
        terminal = "${pkgs.ghostty}/bin/ghostty";
        prompt = "'❯ '";
        layer = "overlay";
        icons-enabled = "yes";
        icon-theme = "Papirus-Dark";
        width = 40;
        lines = 15;
      };

      colors = {
        background = "282a36ff"; # Dracula Background
        text = "f8f8f2ff"; # Dracula Foreground
        match = "8be9fdff"; # Dracula Cyan (for matches)
        selection = "44475aff"; # Dracula Selection
        selection-text = "ffffffff";
        border = "bd93f9ff"; # Dracula Purple
      };

      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  # Symlinks pour les icônes manquantes dans les thèmes standards
  home.file.".local/share/icons/hicolor/scalable/apps/io.github.ilya_zlobintsev.LACT.svg".source =
    "${pkgs.lact}/share/pixmaps/io.github.ilya_zlobintsev.LACT.svg";

  # Pour Antigravity, on essaie de pointer vers son icône si elle est packagée
  # Note: Si l'icône n'est pas trouvée, HM ignorera ou on ajustera.
  home.file.".local/share/icons/hicolor/scalable/apps/antigravity.svg".source = "${
    pkgs.antigravity-unwrapped or pkgs.antigravity
  }/share/icons/hicolor/scalable/apps/antigravity.svg";
}
</file>

<file path="modules/yazi.nix">
{ pkgs, ... }:

{
  # Configuration du gestionnaire de fichiers Yazi
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

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
        ];
      };
    };
  };

  # Fonction Fish 'y' : wrapper pour Yazi
  # Permet de naviguer dans Yazi et de rester dans le dossier final en quittant
  programs.fish.functions.y = {
    body = ''
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      yazi $argv --cwd-file="$tmp"
      if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    '';
  };
}
</file>

<file path="home.nix">
{ ... }: # <-- N'oublie pas d'ajouter { config, pkgs, ... }: en haut !

{
  home.username = "david";
  home.homeDirectory = "/home/david";
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
  ];

  programs.home-manager.enable = true;
}
</file>

<file path="modules/antigravity.nix">
{ config, pkgs, ... }:

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
    # Configuration du LSP nil et du formateur dans l'éditeur Antigravity
    ".config/Antigravity/User/settings.json".text = builtins.toJSON {
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
          };
        };
      };
      "editor.formatOnSave" = true;
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "security.workspace.trust.untrustedFiles" = "open";
    };

    # Gestion persistante de la config MCP
    ".gemini/antigravity/mcp_config.json".source =
      config.lib.file.mkOutOfStoreSymlink "/home/david/nixos-config/modules/mcp_config.json";
  };

  home.sessionVariables = {
    ANTIGRAVITY_EDITOR = "code";
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

## Contexte LLM / Repomix / Diff
- J'utilise `repomix` pour avoir une vision globale du projet.
- Avant toute analyse globale, je devrais consulter `repomix-nixos-config.md` s'il existe.
- **Pour une analyse rapide des changements récents**, je dois prioriser `git log --stat` et `git show --stat` au lieu de scanner tous les fichiers un par un.
- Si des changements structurels majeurs sont faits, il est recommandé de mettre à jour le fichier repomix avec `repomix --output repomix-nixos-config.md`.
- J'utilise le workflow `/auto-doc` pour automatiser la documentation après une tâche.

## Stabilité et Rapidité (Anti-Lag)
- **Priorité aux outils natifs** : J'utilise `list_dir` et `view_file` au lieu de `ls` ou `cat` dans le terminal. C'est instantané et ça ne "bloque" jamais.
- **Stratégie Async** : Pour les commandes longues, j'utilise un `WaitMsBeforeAsync` de 0 ou 500ms pour rendre la main tout de suite.
- **Pas de boucles infinies** : Si une commande ne répond pas après 2 tentatives de `command_status`, je demande l'avis de l'utilisateur au lieu de bloquer.
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
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel";
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
    {
      nixosConfigurations.muggy-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
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
            home-manager.users.david = import ./home.nix;

            # Optionnel : passe les 'inputs' du flake au fichier home.nix
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
}
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

    # Alternative if they want to fzf the results:
    # search_interactive = "fd . / 2>/dev/null | fzf";
  };
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
        "lastModified": 1770196631,
        "narHash": "sha256-neRXwIILc8BUFHeT0UM2Mj8Wt1oo4UPpmm4NkfBwQOY=",
        "owner": "jacopone",
        "repo": "antigravity-nix",
        "rev": "acc9baf089a67ef7456117ef31285e34c3294984",
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
        "lastModified": 1770052877,
        "narHash": "sha256-Ejj9F2obMjVoy0Jsugw6txHFaR9ziuErYIt58cIJqzE=",
        "owner": "CachyOS",
        "repo": "linux-cachyos",
        "rev": "1f8a79ffeac6f319a8c0fc3abad27a3ec7762abf",
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
        "lastModified": 1770051966,
        "narHash": "sha256-udCJTbUAEZm5zBrr4zVVjpBLQtCC/vQlkIOLnEGr5Ik=",
        "owner": "CachyOS",
        "repo": "kernel-patches",
        "rev": "bfa4ff5231408610ffcc92898cd1e4c9bd55e452",
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
        "lastModified": 1770263241,
        "narHash": "sha256-R1WFtIvp38hS9x63dnijdJw1KyIiy30KGea6e6N7LHs=",
        "owner": "nix-community",
        "repo": "home-manager",
        "rev": "04e5203db66417d548ae1ff188a9f591836dfaa7",
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
        "lastModified": 1770271466,
        "narHash": "sha256-Pyc3p/V7ruQplnU31r+umLSNlSGwOOoHzhWfzfLmiiw=",
        "owner": "sodiboo",
        "repo": "niri-flake",
        "rev": "76e1d271485b00a5d98aeb1dd76408594741c039",
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
        "lastModified": 1770092965,
        "narHash": "sha256-++K1ftjwPqMJzIO8t2GsdkYQzC2LLA5A1w21Uo+SLz4=",
        "owner": "YaLTeR",
        "repo": "niri",
        "rev": "189917c93329c86ac2ddd89f459c26a028d590ba",
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
        "lastModified": 1770055712,
        "narHash": "sha256-VpbF4JDFPSW2crh0tP5EiegnuTkj3fACs0SLWDhlfPM=",
        "owner": "xddxdd",
        "repo": "nix-cachyos-kernel",
        "rev": "220dce3edcb81188ecb896382699884243d1c2e3",
        "type": "github"
      },
      "original": {
        "owner": "xddxdd",
        "repo": "nix-cachyos-kernel",
        "type": "github"
      }
    },
    "nixpkgs": {
      "locked": {
        "lastModified": 1770030960,
        "narHash": "sha256-b9kW8RiZYQjSYKcFRYwc2vPB08F8xjaTS85tv+lP0YA=",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "0fe992afb42c8f9077ba77d1bb9795492cc7a4b3",
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
        "lastModified": 1770056648,
        "narHash": "sha256-hsM96Z1KmiFuCe57iOIapJMPTCM2XxfvZKl8JdHGQRE=",
        "owner": "nixos",
        "repo": "nixpkgs",
        "rev": "d844a3bc280fee349c892033977bb109dcdd543a",
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
        "lastModified": 1770136044,
        "narHash": "sha256-tlFqNG/uzz2++aAmn4v8J0vAkV3z7XngeIIB3rM3650=",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "e576e3c9cf9bad747afcddd9e34f51d18c855b4e",
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
        "lastModified": 1770197578,
        "narHash": "sha256-AYqlWrX09+HvGs8zM6ebZ1pwUqjkfpnv8mewYwAo+iM=",
        "owner": "nixos",
        "repo": "nixpkgs",
        "rev": "00c21e4c93d963c50d4c0c89bfa84ed6e0694df2",
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
        "lastModified": 1770294810,
        "narHash": "sha256-qmODFANi4drhxDNld7NeNl0y9HQvESaby9yJeGsf0Q8=",
        "owner": "noctalia-dev",
        "repo": "noctalia-shell",
        "rev": "f13bc738be5c10d29683a5041383b4739eeb97d1",
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
        "lastModified": 1770167989,
        "narHash": "sha256-rE2WTxKHe3KMG/Zr5YUNeKHkZfWwSFl7yJXrOKnunHg=",
        "owner": "Supreeeme",
        "repo": "xwayland-satellite",
        "rev": "0947c4685f6237d4f8045482ce0c62feab40b6c4",
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

<file path="modules/noctalia.nix">
{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configuration du fond d'écran pour Noctalia
  home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
    defaultWallpaper = "/home/david/Pictures/wallpaper/wallpaper.png";
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

<file path="modules/fastfetch.nix">
{ pkgs, ... }:
{
  home.packages = [ pkgs.chafa ];

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/david/Pictures/nixos.png";
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

<file path="hosts/muggy-nixos/default.nix">
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/font.nix
    ../../modules/steam.nix
    ../../modules/lact.nix
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
    "L+ /run/gdm/.config/monitors.xml - - - - /home/david/.config/monitors.xml"
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
  programs.nix-ld.enable = true;

  # Empêche les jeux de "s'endormir" ou de tomber en FPS quand le workspace change
  environment.sessionVariables = {
    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
    vk_xwayland_wait_ready = "false";
    MESA_SHADER_CACHE_MAX_SIZE = "16G";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.david = {
    isNormalUser = true;
    description = "David";
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
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];

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
