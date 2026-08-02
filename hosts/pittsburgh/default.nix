{pkgs, inputs, ...}: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = true;
    })
    ../common/hao.nix
    ../common/aoli.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "xiangpeng-pittsburgh";

  nixpkgs.overlays = [
    (final: prev: {
      homebridge-config-ui-x = prev.homebridge-config-ui-x.override {
        nodejs_22 = final.nodejs_24;
      };
    })
  ];
  services.homebridge = {
    enable = true;
    openFirewall = true;
  };

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
