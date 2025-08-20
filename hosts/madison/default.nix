{pkgs, ...}: {
  imports = [
    (import ../common {
      inherit pkgs;
      withNvidia = true;
    })
    ../common/hao.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "xiangpeng-madison";
  time.timeZone = "America/Chicago";


  # Mount additional data disks at boot
  fileSystems."/mnt/slow-ssd" = {
    device = "/dev/disk/by-uuid/a02dcb2e-9ed8-4536-8eb9-206fac9a0357"; # sda2 (WDC 1TB)
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=0" ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/09aae6ee-28dd-44e1-997c-d48f8a87e9cc"; # sdb1 (Seagate 2TB)
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=0" ];
  };

  fileSystems."/mnt/pcie5ssd" = {
    device = "/dev/disk/by-uuid/bc2f2425-ff24-4d63-9114-b087f90f7797"; # nvme1n1 (Samsung 2TB)
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=0" ];
  };
}
