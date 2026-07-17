{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    (import ../common {
      inherit pkgs inputs;
      headless = true;
    })
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    inputs.nixos-raspberrypi.nixosModules.trusted-nix-caches
    ../common/aoli.nix
    ../common/hao.nix
    ./hardware-configuration.nix
    ./home-assistant.nix
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "jex";

  age.identityPaths = [ "/etc/agenix/key" ];

  security.sudo.wheelNeedsPassword = false;

  nix.settings.trusted-users = [ "@wheel" ];

  services.vscode-server.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    libraspberrypi
    raspberrypi-eeprom
  ];
}
