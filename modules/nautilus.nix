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

  environment.systemPackages = with pkgs; [
    nautilus # File manager
  ];
}
