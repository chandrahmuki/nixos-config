{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # Enable greetd for a minimal and customized login experience
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Customized tuigreet with Tokyonight colors, custom greeting, padding, and centered text
        command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%A, %d %B %Y | %H:%M:%S' --remember --asterisks --width 50 --window-padding 3 --container-padding 2 --prompt-padding 1 --greet-align center --greeting 'Welcome to muggy-nixos' --theme 'border=blue;text=cyan;prompt=blue;time=magenta;input=cyan;button=magenta;action=magenta;error=red' --cmd niri-session";
        user = "greeter";
      };
    };
  };
}
