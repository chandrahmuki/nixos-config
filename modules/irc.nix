{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.weechat
      (pkgs.writeShellScriptBin "weechat-setup" ''
        weechat -r "\
          /server add rizon irc.rizon.net/6697 -tls;\
          /set irc.server.rizon.autoconnect on;\
          /set irc.server.rizon.autojoin #kanadi;\
          /set irc.server.rizon.nicks ${username};\
          /set irc.server.rizon.username ${username};\
          /set irc.server.rizon.realname ${username};\
          /set xfer.file.download_directory ~/Downloads/manga;\
          /connect rizon;\
          /save;\
          /quit"
      '')
    ];

    home.file."Downloads/manga/.keep" = {
      text = "";
      force = true;
    };

    home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoload/xdccq.py" = {
      source = pkgs.fetchurl {
        url = "https://weechat.org/files/scripts/xdccq.py";
        sha256 = "1qshy6bdw2ypwlaylfdn2j90ib0jv90myf8is4g3qamwwq2famas";
      };
      executable = true;
    };

    home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoload/autojoin.py" = {
      source = pkgs.fetchurl {
        url = "https://weechat.org/files/scripts/autojoin.py";
        sha256 = "10y71ciiankinwi83b19fj8452vxgi1hasnwca64l0lrjgmbnrai";
      };
      executable = true;
    };

    home.file."${config.home.homeDirectory}/.local/share/weechat/python/autoload/autoconnect.py" = {
      source = pkgs.fetchurl {
        url = "https://weechat.org/files/scripts/autoconnect.py";
        sha256 = "1va0k8304kqkv2jxkrhrfbq347pcf04fp8jwqwqz4qw2xb5zxv3m";
      };
      executable = true;
    };
  };
}
