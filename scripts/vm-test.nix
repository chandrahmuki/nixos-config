{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 6;
      diskSize = 16384;
      graphics = false;
      resolution = {
        x = 1920;
        y = 1080;
      };
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
      # Home-Manager links Quickshell's config out of the store to this
      # checkout, so the guest needs it at the same path.
      fileSystems."/home/${username}/nixos-config" = {
        device = "nixos-config";
        fsType = "9p";
        options = ["trans=virtio" "version=9p2000.L" "ro" "msize=1048576" "nofail"];
      };
      # Muggy checkout (desktop app tests): read-only, copy it to the guest
      # disk before running, node_modules and vite need a writable tree.
      fileSystems."/home/${username}/muggy-src" = {
        device = "muggy-src";
        fsType = "9p";
        options = ["trans=virtio" "version=9p2000.L" "ro" "msize=1048576" "nofail"];
      };
      qemu.options = [
        "-virtfs"
        "local,path=/home/${username}/nixos-config,mount_tag=nixos-config,security_model=none,readonly=on,id=nixoscfg"
        "-virtfs"
        "local,path=/home/${username}/Projects/muggy,mount_tag=muggy-src,security_model=none,readonly=on,id=muggysrc"
        "-vnc"
        "unix:/tmp/muggy-vm/vnc.sock"
        "-vga"
        "std"
        "-device"
        "usb-kbd"
        "-qmp"
        "unix:/tmp/muggy-vm/qmp.sock,server=on,wait=off"
      ];
    };

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
    boot.initrd.kernelModules = lib.mkForce [];
    boot.extraModulePackages = lib.mkForce [];
    boot.kernelModules = lib.mkForce [];
    services.xserver.videoDrivers = lib.mkForce [];
    services.scx-loader.enable = lib.mkForce false;

    # Muggy desktop (Electron UI) is exercised in the guest; bun, git, socat
    # and bubblewrap are already in the system config. ripgrep is not on PATH
    # in a default NixOS and the skill sandbox refuses to run without it.
    environment.systemPackages = [pkgs.electron pkgs.ripgrep];

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PermitEmptyPasswords = "yes";
      };
    };
    security.pam.services.sshd.allowNullPassword = true;
    users.users.${username} = {
      initialHashedPassword = lib.mkForce null;
      initialPassword = lib.mkForce "vm";
    };
    users.users.root.initialHashedPassword = lib.mkForce "";

    # Autologin would otherwise start Hyprland before Home-Manager has written
    # hyprland.lua, so hyprland.start (which launches Quickshell) never runs.
    systemd.services.greetd = {
      after = ["home-manager-${username}.service"];
      wants = ["home-manager-${username}.service"];
    };

    services.greetd.settings = lib.mkForce {
      terminal.vt = 1;
      default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/hyprland-uwsm.desktop";
        user = username;
      };
    };
  };
}
