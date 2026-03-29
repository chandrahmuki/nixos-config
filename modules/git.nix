{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    programs.git = {
      enable = true;
      userName = username;
      userEmail = "email@exemple.com";

      # Des raccourcis qui vont te faire gagner un temps fou
      aliases = {
        s = "status";
        a = "add";
        c = "commit";
        cm = "commit -m";
        p = "push";
        lg = "log --graph --oneline --all"; # Une jolie vue de ton historique
      };

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true; # Plus propre pour éviter les commits de "merge" inutiles
      };
    };
  };
}
