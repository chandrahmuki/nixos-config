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
    };
}
