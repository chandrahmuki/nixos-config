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
      onboarding = false

      [terminal]
      default_shell = "${pkgs.fish}/bin/fish"

      [session]
      resume_agents_on_restore = true

      [experimental]
      pane_history = true
    '';
  };
}
