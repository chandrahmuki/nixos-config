{den, ...}: {
  den.aspects.sops.nixos = {
    inputs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];

      sops = {
        defaultSopsFile = ../secrets/secrets.yaml;
        age.sshKeyPaths = ["/home/${username}/.ssh/id_ed25519"];
        secrets = {
          github_token.path = "/home/${username}/.config/sops/github_token";
          opencode_api_key.path = "/home/${username}/.config/sops/opencode_api_key";
          cliamp_client_id = {};
          cliamp_client_secret = {};
        };

        templates."cliamp-config.toml" = {
          path = "${config.home.homeDirectory}/.config/cliamp/config.toml";
          content = ''
            volume = 0
            repeat = "off"
            shuffle = false
            mono = false
            seek_large_step_sec = 30
            eq_preset = "Flat"
            eq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            visualizer = "Bars"
            compact = false
            theme = "Tokyo Night"
            log_level = "info"
            provider = "ytmusic"

            [ytmusic]
            client_id = "${config.sops.placeholder.cliamp_client_id}"
            client_secret = "${config.sops.placeholder.cliamp_client_secret}"
          '';
        };
      };

      programs.fish.functions.sops = "SOPS_CONFIG=~/.config/nixos-secrets/.sops.yaml SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519 nix run nixpkgs#sops -- $argv";
    };
  };
}
