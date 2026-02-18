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
            name = "*.m3u";
            use = "listen";
          }
        ];
      };
    };
  };

  home.file.".config/yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/generated/yazi.toml";
}
