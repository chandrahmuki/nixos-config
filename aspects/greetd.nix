{den, ...}: {
  den.aspects.greetd.nixos = {
    host,
    config,
    pkgs,
    ...
  }: {
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = let
          sessionsDir = "${config.services.displayManager.sessionData.desktops}/share";
        in "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%A, %d %B %Y | %H:%M:%S' --remember --asterisks --width 50 --window-padding 3 --container-padding 2 --prompt-padding 1 --greet-align center --greeting 'Welcome to ${host.hostName}' --theme 'border=blue;text=cyan;prompt=blue;time=magenta;input=cyan;button=magenta;action=magenta;error=red' --sessions ${sessionsDir}/wayland-sessions:${sessionsDir}/xsessions --remember-session";
        user = "greeter";
      };
    };
    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter -"
    ];
  };

  den.aspects.muggy-nixos.includes = [den.aspects.greetd];
}
