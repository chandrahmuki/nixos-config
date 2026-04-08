{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      programs.git = {
        enable = true;

        # Les nouvelles options utilisent la structure 'settings'
        # pour correspondre au format du fichier .gitconfig
        settings = {
          user = {
            name = username;
            email = "amouyaljerome@gmail.com";
          };

          # Les alias sont maintenant sous settings.alias
          alias = {
            s = "status";
            a = "add";
            c = "commit";
            cm = "commit -m";
            p = "push";
            lg = "log --graph --oneline --all"; # Une jolie vue de ton historique
          };

          # Configuration extra (anciennement extraConfig)
          init.defaultBranch = "main";
          pull.rebase = true; # Plus propre pour éviter les commits de "merge" inutiles
        };
      };
    };
}
