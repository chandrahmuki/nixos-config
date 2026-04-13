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
    };
}
