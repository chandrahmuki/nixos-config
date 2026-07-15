{den, ...}: {
  den.aspects.compatibility.nixos.imports = [
    ../modules/ai.nix
    ../modules/backup.nix
    ../modules/cliamp.nix
    ../modules/fuzzel.nix
    ../modules/gnome.nix
    ../modules/helix.nix
    ../modules/irc.nix
    ../modules/media.nix
    ../modules/neovim.nix
    ../modules/niri.nix
    ../modules/performance-tuning.nix
    ../modules/secrets.nix
    ../modules/stylix.nix
    ../modules/terminal.nix
    ../modules/theme.nix
    ../modules/utils.nix
    ../modules/vscode.nix
    ../modules/walker.nix
    ../modules/zellij.nix
  ];

  den.aspects.muggy-nixos.includes = [den.aspects.compatibility];
}
