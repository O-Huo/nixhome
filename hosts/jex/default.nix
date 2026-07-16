{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (import ../common {
      inherit pkgs inputs;
      headless = true;
    })
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    # Adds nixos-raspberrypi.cachix.org to this host's substituters.
    inputs.nixos-raspberrypi.nixosModules.trusted-nix-caches
    ../common/aoli.nix
    ../common/hao.nix
    ./hardware-configuration.nix
    ./home-assistant.nix
  ];

  networking.hostName = "jex";

  # Both users are in wheel; let them sudo without a password.
  security.sudo.wheelNeedsPassword = false;

  # Kernel, firmware and bootloader (U-Boot + managed /boot/firmware
  # partition) come from nixos-raspberrypi's raspberry-pi-4 module.

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    libraspberrypi
    raspberrypi-eeprom
  ];
}
