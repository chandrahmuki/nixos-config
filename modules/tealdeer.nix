{ pkgs, ... }:

{
  # tealdeer est une implémentation rust de tldr (pages d'aide simplifiées)
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
        use_pager = true;
      };
      updates = {
        auto_update = true;
      };
    };
  };
}
