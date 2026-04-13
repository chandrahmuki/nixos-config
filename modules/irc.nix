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

        [xfer]
        file.download_dir = "~/Downloads/manga"
      '';

      xdg.userDirs = {
        download = "${config.home.homeDirectory}/Downloads";
      };

      home.file."Downloads/manga/.keep" = {
        text = "";
        force = true;
      };

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/xdccq.py" = {
        source = pkgs.fetchurl {
          url = "https://weechat.org/files/scripts/xdccq.py";
          sha256 = "1qshy6bdw2ypwlaylfdn2j90ib0jv90myf8is4g3qamwwq2famas";
        };
        executable = true;
      };

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autojoin.py" = {
        source = pkgs.fetchurl {
          url = "https://weechat.org/files/scripts/autojoin.py";
          sha256 = "10y71ciiankinwi83b19fj8452vxgi1hasnwca64l0lrjgmbnrai";
        };
        executable = true;
      };

      home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoconnect.py" = {
        source = pkgs.fetchurl {
          url = "https://weechat.org/files/scripts/autoconnect.py";
          sha256 = "1va0k8304kqkv2jxkrhrfbq347pcf04fp8jwqwqz4qw2xb5zxv3m";
        };
        executable = true;
      };
    };
}
