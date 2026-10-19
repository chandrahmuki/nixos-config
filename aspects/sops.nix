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

      # The secrets are encrypted for an age key derived from the SSH key (the same one sops-nix
      # uses), which sops cannot read from the SSH key file directly: derive it on the fly.
      programs.fish.functions.sops = "env SOPS_CONFIG=$HOME/.config/nixos-secrets/.sops.yaml SOPS_AGE_KEY=(nix run nixpkgs#ssh-to-age -- -private-key -i $HOME/.ssh/id_ed25519) nix run nixpkgs#sops -- $argv";
    };
  };
}
