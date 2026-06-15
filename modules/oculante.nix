{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    home.packages = [pkgs.oculante];

    xdg.mimeApps.defaultApplications = {
      "image/png" = ["oculante.desktop"];
      "image/jpeg" = ["oculante.desktop"];
      "image/gif" = ["oculante.desktop"];
      "image/webp" = ["oculante.desktop"];
      "image/bmp" = ["oculante.desktop"];
      "image/tiff" = ["oculante.desktop"];
      "image/svg+xml" = ["oculante.desktop"];
    };
  };
}
