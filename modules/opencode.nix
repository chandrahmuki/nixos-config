{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.opencode
      pkgs.opencode-claude-auth
    ];
  };
}
