{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Dependencies for lazy.nvim, mason, and common plugins
    extraPackages = with pkgs; [
      # Build tools
      gcc
      gnumake
      unzip
      wget
      curl
      git

      # Runtime dependencies
      ripgrep
      fd
      fzf
      nodejs
      python3
      lua-language-server
      stylua # For stylua.toml in your config
    ];
  };

  # Link the personal configuration from the internal nixos-config folder
  home.file.".config/nvim" = {
    source = ./../nvim;
    recursive = true;
  };
}
