{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Install LACT (Linux AMDGpu Control Tool)
  environment.systemPackages = with pkgs; [
    lact
  ];

  # Enable the lactd daemon service required for applying settings
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Unlock advanced AMDGPU features (overclocking, fan control, voltage)
  # ppfeaturemask=0xffffffff enables all features
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
}
