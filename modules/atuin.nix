{ pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = false; # Desactivé pour éviter les blocages de l'agent
    settings = {
      auto_sync = true;
      update_check = false;
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };
}
