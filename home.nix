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
    ./modules/atuin.nix
  ];

  programs.home-manager.enable = true;
}
