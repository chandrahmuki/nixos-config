{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        recolor = true; # Dark mode by default
        recolor-keephue = true;
      };
    };
  };
}
