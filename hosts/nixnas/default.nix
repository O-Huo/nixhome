{ pkgs, inputs, config, lib, modulesPath, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = false;
    })
    ../common/hao.nix
    ./hardware-configuration.nix
    (modulesPath + "/image/repart.nix")
  ];

  networking.hostName = "nixnas";

  # VM-specific settings
  services.qemuGuest.enable = true;

  # Image generation settings for TrueNAS
  image.repart = {
    name = "nixnas";
    partitions = {
      "esp" = {
        contents = {
          "/EFI/BOOT/BOOTX64.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootx64.efi";
          "/EFI/systemd/systemd-bootx64.efi".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootx64.efi";
          "/loader/loader.conf".source = pkgs.writeText "loader.conf" ''
            timeout 3
            default nixos.conf
          '';
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "ESP";
          SizeMinBytes = "512M";
        };
      };
      "root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "nixos";
          Minimize = "guess";
        };
      };
    };
  };
}
