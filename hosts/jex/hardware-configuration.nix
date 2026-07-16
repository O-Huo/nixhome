# Raspberry Pi 4 booted from the official NixOS aarch64 SD image, which
# labels its root partition NIXOS_SD. Regenerate with nixos-generate-config
# after install if the disk layout changes.
{ lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # Firmware/bootloader partition, managed by nixos-raspberrypi on rebuilds.
  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "noatime"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=1min"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
