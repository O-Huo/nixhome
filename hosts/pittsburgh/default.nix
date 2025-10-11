{pkgs, inputs, ...}: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = true;
    })
    ../common/hao.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "xiangpeng-pittsburgh";
  time.timeZone = "America/New_York";
}
