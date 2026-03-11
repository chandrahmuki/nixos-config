{ pkgs, ... }:

{
  programs.obsidian = {
    enable = true;
    
    # Configuration par défaut pour les futurs vaults
    defaultSettings = {
      communityPlugins = [
        {
          enable = true;
          pkg = pkgs.obsidian-plugins.calendar;
        }
      ];
      corePlugins = {
        file-explorer.enable = true;
        global-search.enable = true;
      };
    };
  };
}
