{den, ...}: {
  den.aspects.imv.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.imv];
    xdg.mimeApps.defaultApplications = {
      "image/png" = ["imv.desktop"];
      "image/jpeg" = ["imv.desktop"];
      "image/gif" = ["imv.desktop"];
      "image/webp" = ["imv.desktop"];
      "image/bmp" = ["imv.desktop"];
      "image/tiff" = ["imv.desktop"];
      "image/svg+xml" = ["imv.desktop"];
    };
  };
}
