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
    {
      config,
      lib,
      ...
    }:
    {
      home.packages = [
        pkgs.weechat
      ];

      xdg.configFile."weechat/python/autoload/setup_rizon.py" = {
        force = true;
        text = ''
          import weechat

          def setup_rizon_cb(data, buffer, args):
              servers = weechat.infolist_get("irc_server", "", "")
              rizon_exists = False
              while weechat.infolist_next(servers):
                  if weechat.infolist_string(servers, "name") == "rizon":
                      rizon_exists = True
                      break
              weechat.infolist_free(servers)

              if not rizon_exists:
                  weechat.command("", "/server add rizon irc.rizon.net/6697 -tls")
                  weechat.command("", "/set irc.server.rizon.autoconnect on")
                  weechat.command("", "/set irc.server.rizon.autojoin #kanadi")
                  weechat.command("", "/set irc.server.rizon.nicks ${username}")
                  weechat.command("", "/set irc.server.rizon.username ${username}")
                  weechat.command("", "/set irc.server.rizon.realname ${username}")
                  weechat.command("", "/set xfer.file.download_directory ~/Downloads/manga")
                  weechat.command("", "/save")

              weechat.command("", "/script remove setup_rizon")
              return weechat.WEECHAT_RC_OK

          weechat.register("setup_rizon", "${username}", "1.0", "MIT", "Setup Rizon server", "", "")
          weechat.hook_timer(1000, 0, 1, "setup_rizon_cb", "")
        '';
      };

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
