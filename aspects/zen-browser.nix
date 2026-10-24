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
        ExtensionSettings."{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };
    # Only web types: setAsDefaultBrowser would also take text/plain, JSON and mailto.
    xdg.mimeApps.defaultApplications = {
      "text/html" = ["zen-beta.desktop"];
      "text/xml" = ["zen-beta.desktop"];
      "application/xhtml+xml" = ["zen-beta.desktop"];
      "x-scheme-handler/http" = ["zen-beta.desktop"];
      "x-scheme-handler/https" = ["zen-beta.desktop"];
    };
    home.sessionVariables.BROWSER = "zen-beta";
  };
}
