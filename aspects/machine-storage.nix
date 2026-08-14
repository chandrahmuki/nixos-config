{den, ...}: {
  den.aspects.machine-storage.nixos = {
    config,
    lib,
    username,
    ...
  }: let
    storageMounts = [
      "/mnt/storage"
      "/mnt/games"
      "/mnt/backup"
    ];
    configuredStorageMounts = builtins.filter (mountPoint: builtins.hasAttr mountPoint config.fileSystems) storageMounts;
    btrfsFileSystems = builtins.filter (mountPoint: (config.fileSystems.${mountPoint}.fsType or null) == "btrfs") (["/"] ++ configuredStorageMounts);
    hasGames = builtins.hasAttr "/mnt/games" config.fileSystems;
    hasStorage = builtins.hasAttr "/mnt/storage" config.fileSystems;
    hasBackup = builtins.hasAttr "/mnt/backup" config.fileSystems;
  in {
    services.btrfs.autoScrub = lib.mkIf (btrfsFileSystems != []) {
      enable = true;
      interval = "weekly";
      fileSystems = btrfsFileSystems;
    };

    home-manager.users.${username} = {config, ...}: {
      home.file = lib.optionalAttrs hasGames {
        "Games".source = config.lib.file.mkOutOfStoreSymlink "/mnt/games";
      } // lib.optionalAttrs hasStorage {
        "Storage".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage";
      } // lib.optionalAttrs hasBackup {
        "backups".source = config.lib.file.mkOutOfStoreSymlink "/mnt/backup";
      };
    };
  };
}
