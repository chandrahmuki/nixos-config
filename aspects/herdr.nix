{
  den,
  inputs,
  ...
}: {
  den.aspects.herdr.homeManager = {pkgs, ...}: {
    home.packages = [
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
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

  den.aspects.david.includes = [den.aspects.herdr];
}
