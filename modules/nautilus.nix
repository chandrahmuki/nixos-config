{
  pkgs,
  ...
}:

{
  # Enable GVfs for mounting drives (required for Nautilus sidebar)
  services.gvfs.enable = true;

  # Enable Tumbler for thumbnails (images and videos)
  services.tumbler.enable = true;

  # Enable Sushi for quick file previews (spacebar)
  services.gnome.sushi.enable = true;

  # Enable portals integration for Niri
  programs.niri.useNautilus = true;

  # Optional: terminal integration for Nautilus
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty"; # David uses ghostty (seen in terminal.nix)
  };

  environment.systemPackages = with pkgs; [
    nautilus # File manager
    nautilus-python # Extensions
  ];
}
