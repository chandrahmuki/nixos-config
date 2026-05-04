{ config, lib, pkgs, username, inputs, ... }:

{
  home-manager.users.${username} = { config, lib, pkgs, ... }:
    let
      colors = (import ../lib/colors.nix).tokyonight;
    in
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;
        policies = {
          DisableAppUpdate = true;
          DisableTelemetry = true;
          Preferences = {
            "browser.shell.checkDefaultBrowser" = false;
          };
        };
      };
    };
}