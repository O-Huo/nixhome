# Bootable SD card image for jex. Build with:
#   nix build .#images.jex
# then write it with:
#   sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M conv=fsync status=progress
# On first boot the root partition is expanded to fill the card automatically.
{ inputs, ... }:
{
  imports = [
    inputs.nixos-raspberrypi.nixosModules.sd-image
  ];

  # Emit a raw .img that can be dd'ed directly instead of a .img.zst.
  sdImage.compressImage = false;

  # The installer base profile pulls in zfs support; we never import a zfs
  # root here, and false becomes the default in 26.11 anyway.
  boot.zfs.forceImportRoot = false;
}
