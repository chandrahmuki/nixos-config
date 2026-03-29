import os
import re

HM_ONLY = [
    "modules/antigravity.nix", "modules/btop.nix", "modules/direnv.nix",
    "modules/discord.nix", "modules/gemini.nix", "modules/microfetch.nix",
    "modules/music-menu.nix", "modules/nautilus.nix", "modules/neovim.nix",
    "modules/noctalia.nix", "modules/notifications.nix", "modules/obsidian.nix",
    "modules/pdf.nix", "modules/tealdeer.nix", "modules/terminal.nix",
    "modules/theme.nix", "modules/utils.nix", "modules/vscode.nix",
    "modules/walker.nix", "modules/xdg.nix", "modules/yazi.nix",
    "modules/yt-dlp.nix", "modules/yt-search.nix", "modules/zellij.nix",
    "modules/parsec.nix", "modules/secrets.nix", "modules/git.nix"
]

NIXOS_ONLY = [
    "modules/backup.nix", "modules/bluetooth.nix", "modules/font.nix",
    "modules/lact.nix", "modules/performance-tuning.nix", "modules/steam.nix"
]

MIXED = [
    "modules/brave.nix", "modules/nh.nix"
]

def refactor_file(filepath):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return

    with open(filepath, 'r') as f:
        content = f.read()

    # Match the header and body
    # This regex is a bit loose but should work for most of our files
    # It looks for the first { ... }: and then the rest as body
    match = re.match(r'^\s*\{([^{}]*)\}\s*:\s*\n*(.*)', content, re.DOTALL)
    if not match:
        print(f"Could not parse {filepath}")
        return

    args_str = match.group(1).strip()
    body = match.group(2).strip()

    # Determine new args
    # For HM/Mixed, we need username
    new_args_hm = "{ config, lib, pkgs, username, ... }"
    new_args_nixos = "{ config, lib, pkgs, ... }"

    if filepath in HM_ONLY:
        # Wrap body
        # Usually body is { ... }
        if body.startswith('{') and body.endswith('}'):
            inner = body[1:-1].strip()
            # Indent inner content
            indented_inner = "\n  ".join(inner.splitlines())
            new_body = "{\n  home-manager.users.${username} = {\n    " + indented_inner.replace('\n', '\n    ') + "\n  };\n}"
            # Cleanup indentation a bit (remove trailing spaces on empty lines)
            new_body = re.sub(r' +$', '', new_body, flags=re.MULTILINE)
            result = f"{new_args_hm}:\n\n{new_body}\n"
        else:
            # Body might not have braces if it was a direct attrset?
            # But in our cat output they all had braces.
            result = f"{new_args_hm}:\n\n{{\n  home-manager.users.${{username}} = {body};\n}}\n"
        
    elif filepath in NIXOS_ONLY:
        # Just ensure header
        result = f"{new_args_nixos}:\n\n{body}\n"

    elif filepath in MIXED:
        if filepath == "modules/brave.nix":
            # Already partially wrapped, but uses config.username
            body = body.replace("${config.username}", "${username}")
            result = f"{new_args_hm}:\n\n{body}\n"
        elif filepath == "modules/nh.nix":
            # Split body into NixOS and HM
            # This is hard to do generically, so I'll do it specifically for nh.nix
            # programs.nh is NixOS, programs.fish.functions is HM
            # Actually, let's just wrap the whole thing and let HM handle it if it can,
            # but wait, programs.nh is NixOS.
            # I'll manually handle mixed files if needed, or try a simple split.
            # For nh.nix, let's just wrap fish.functions in HM block.
            lines = body.splitlines()
            nixos_lines = []
            hm_lines = []
            in_fish_functions = False
            brace_count = 0
            
            # This is too complex for a quick script. 
            # I'll just hardcode the result for the 2 mixed files.
            pass
        
    else:
        print(f"Unknown category for {filepath}")
        return
    
    # Manual overrides for Mixed and special cases
    if filepath == "modules/nh.nix":
        result = """{
  config,
  lib,
  pkgs,
  username,
  hostname,
  ...
}:

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

  home-manager.users.${username} = {
    programs.fish.functions = {
      nos = ''
        cd ${config.home.homeDirectory}/nixos-config
        nh os switch . --hostname ${hostname} --ask -L --diff always
      '';
    };
  };
}
"""
    if filepath == "modules/git.nix":
        # git.nix body has { programs.git = { ... }; }
        # The script above should handle it if it starts/ends with braces.
        pass

    with open(filepath, 'w') as f:
        f.write(result)
    print(f"Refactored {filepath}")

for f in HM_ONLY + NIXOS_ONLY + MIXED:
    refactor_file(f)
