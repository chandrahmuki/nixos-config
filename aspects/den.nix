{
  inputs,
  den,
  lib,
  settings,
  ...
}: {
  imports = [inputs.den.flakeModule];

  den = {
    schema.user.classes = lib.mkDefault ["homeManager"];
    default.homeManager.home.stateVersion = "25.11";

    hosts.${settings.system}.desktop.users.${settings.username} = {};

    aspects.desktop.includes = [den.batteries.hostname]
      ++ map (name: den.aspects.${name}) settings.profiles.desktop
      ++ map (name: den.aspects.${name}) settings.profiles.personalDesktop
      ++ map (name: den.aspects.${name}) settings.profiles.machineDesktop;

    aspects.${settings.username}.includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ] ++ map (name: den.aspects.${name}) settings.profiles.user
      ++ map (name: den.aspects.${name}) settings.profiles.personalUser;
  };
}
