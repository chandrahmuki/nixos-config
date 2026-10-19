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
        };
      };

      programs.fish.functions.sops = "env SOPS_CONFIG=~/.config/nixos-secrets/.sops.yaml SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519 nix run nixpkgs#sops -- $argv";
    };
  };
}
