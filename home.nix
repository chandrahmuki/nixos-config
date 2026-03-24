{ username, hostname, ... }: # <-- N'oublie pas d'ajouter { config, pkgs, ... }: en haut !

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  # On importe ici les fichiers qu'on va créer dans le dossier modules
  imports = [
    ./modules/btop.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/microfetch.nix
    ./modules/brave.nix
    ./modules/vscode.nix
    ./wm/niri.nix
    ./modules/walker.nix
    ./modules/music-menu.nix
    ./modules/noctalia.nix
    ./modules/nh.nix
    ./modules/parsec.nix
    ./modules/antigravity.nix
    ./modules/direnv.nix
    ./modules/yt-dlp.nix
    ./modules/yt-search.nix
    ./modules/yazi.nix
    ./modules/utils.nix
    ./modules/obsidian.nix
    ./modules/neovim.nix
    ./modules/discord.nix
    ./modules/xdg.nix
    ./modules/tealdeer.nix
    ./modules/pdf.nix
    ./modules/notifications.nix
    ./modules/gemini.nix
    ./modules/secrets.nix
    ./modules/theme.nix
    ./modules/zellij.nix
  ];

  programs.home-manager.enable = true;
}
