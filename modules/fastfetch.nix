{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    # On utilise 'settings' qui générera automatiquement le config.jsonc
    settings = {
      display = {
        separator = " ➜  ";
      };
      modules = [
        "title"
        {
          type = "os";
          key = "  OS";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "  ⚙ ";
          keyColor = "magenta";
        }
        {
          type = "shell";
          key = "  󱆃 ";
          keyColor = "yellow";
        }
        {
          type = "gpu";
          key = "  󰢮 ";
          keyColor = "green";
        }
        "break"
        "colors"
      ];
    };
  };
}
