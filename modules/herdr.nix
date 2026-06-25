{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    home.packages = [
      inputs.herdr.packages.${pkgs.system}.default
    ];

    xdg.configFile."herdr/config.toml".text = ''
      [terminal]
      default_shell = "${pkgs.fish}/bin/fish"
    '';
  };
}
