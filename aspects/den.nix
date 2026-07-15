{
  inputs,
  den,
  lib,
  ...
}: {
  imports = [inputs.den.flakeModule];

  den = {
    schema.user.classes = lib.mkDefault ["homeManager"];
    default.homeManager.home.stateVersion = "25.11";

    hosts.x86_64-linux.muggy-nixos.users.david = {};

    aspects.muggy-nixos.includes = [den.batteries.hostname];

    aspects.david.includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];
  };
}
