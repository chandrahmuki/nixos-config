{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username} = {
    config,
    lib,
    ...
  }: {
    programs.helix = {
      enable = true;

      settings = {
        editor = {
          line-number = "relative";
          mouse = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
        };
        keys.insert = {
          j = { k = "normal_mode"; };
        };
      };

      languages = {
        language-server = {
          typescript-language-server = {
            command = "bunx";
            args = [ "--bun" "typescript-language-server" "--stdio" ];
          };
          nixd = {
            command = "nixd";
            config = {
              nixd = {
                nixpkgs = {
                  expr = "import <nixpkgs> { }";
                };
                options = {
                  nixos = {
                    expr = "(builtins.getFlake \"/home/david/nixos-config\").nixosConfigurations.muggy-nixos.options";
                  };
                  home-manager = {
                    expr = "(builtins.getFlake \"/home/david/nixos-config\").nixosConfigurations.muggy-nixos.options.home-manager.users.type.getSubOptions [ ]";
                  };
                };
              };
            };
          };
        };

        language = [
          {
            name = "rust";
            auto-format = true;
          }
          {
            name = "typescript";
            language-servers = [ "typescript-language-server" ];
            auto-format = true;
          }
          {
            name = "tsx";
            language-servers = [ "typescript-language-server" ];
            auto-format = true;
          }
          {
            name = "javascript";
            language-servers = [ "typescript-language-server" ];
            auto-format = true;
          }
          {
            name = "jsx";
            language-servers = [ "typescript-language-server" ];
            auto-format = true;
          }
          {
            name = "nix";
            language-servers = [ "nixd" ];
            formatter = {
              command = "alejandra";
            };
            auto-format = true;
          }
        ];
      };

      extraPackages = with pkgs; [
        rust-analyzer
        rustc
        cargo
        typescript-language-server
        nixd
        alejandra
      ];
    };
  };
}
