{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:

{
  home-manager.users.${username} =
    { config, lib, ... }:
    {
      home.packages = [
        pkgs.weechat
      ];

      xdg.configFile."weechat/weechat.conf".text = ''
        [irc]
        channels = "#kanadi"
        server_default = "rizon"

        [irc.server.rizon]
        addresses = "irc.rizon.net/6697"
        tls = on
        autojoin = "#kanadi"
        username = "${username}"
        realname = "${username}"
      '';
    };
}
