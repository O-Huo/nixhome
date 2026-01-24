{ pkgs, inputs, config, lib, modulesPath, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = false;
    })
    ../common/hao.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixnas";

  # VM-specific settings
  services.qemuGuest.enable = true;
}
