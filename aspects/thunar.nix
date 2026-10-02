{den, ...}: {
  den.aspects.thunar.nixos = {
    pkgs,
    username,
    ...
  }: {
    services = {
      gvfs.enable = true;
      tumbler.enable = true;
    };
    environment.systemPackages = with pkgs; [
      thunar
      thunar-archive-plugin
      file-roller
      p7zip
      unrar
    ];

    # Without this, xdg-open sends folders to VS Code (code.desktop registers
    # inode/directory), including the folder link in the screenshot notification.
    home-manager.users.${username}.xdg.mimeApps.defaultApplications."inode/directory" = ["thunar.desktop"];
  };
}
