{
  den,
  inputs,
  ...
}: {
  den.aspects.zen-browser.homeManager = {
    imports = [inputs.zen-browser.homeModules.beta];
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = false;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        Preferences."browser.shell.checkDefaultBrowser" = false;
      };
    };
  };

  den.aspects.david.includes = [den.aspects.zen-browser];
}
