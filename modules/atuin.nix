{ pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = true;
      update_check = false;
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };
}
