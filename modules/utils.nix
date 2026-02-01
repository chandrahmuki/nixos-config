{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd # Used for the search function
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.mpv = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish.functions = {
    # Search function that searches from root (/)
    # Uses fd for speed, searching globally
    search = ''
      if test (count $argv) -eq 0
        echo "Usage: search <query>"
        return 1
      end

      # Use sudo if permission denied issues are annoying, 
      # but standard fd handles errors gracefully usually.
      # Searching / can be noisy with permission denied, 
      # so we redirect stderr to null or use fd's built-in ignore.
      ${pkgs.fd}/bin/fd $argv / 2>/dev/null
    '';

    # Alternative if they want to fzf the results:
    # search_interactive = "fd . / 2>/dev/null | fzf";
  };
}
