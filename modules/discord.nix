{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop # Custom Discord client with Vencord built-in (Wayland support, screen sharing, etc.)
  ];
}
