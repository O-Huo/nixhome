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

  # GitHub Actions Runner
  services.github-runners.pittsburgh = {
    enable = true;
    url = "https://github.com/XiangpengHao/liquid-cache";
    tokenFile = "/etc/github-runner/token";
    name = "pittsburgh";
    user = "hao";
    extraLabels = [ "nixos" "pittsburgh" ];
    workDir = "/home/hao/github-runner/work";
    extraPackages = with pkgs; [
      git
      docker
      nodejs
      curl
      wget
      jq
      python3 
      gcc
    ];
    serviceOverrides = {
      ProtectHome = false;
    };
  };
}
