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
        Preferences."browser.taskbarTabs.enabled" = true;
        ExtensionSettings."uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };
  };
}
