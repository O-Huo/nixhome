{pkgs, inputs, ...}: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = true;
    })
    ../common/hao.nix
    ../common/aoli.nix
    ./hardware-configuration.nix
    ./china-proxy.nix
  ];
  networking.hostName = "xiangpeng-pittsburgh";
  security.sudo.wheelNeedsPassword = false;

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

  # bbtree's perf workflow (.github/workflows/perf.yml in bbtree), which counts
  # instructions, branches and cache misses with perf, and so needs bare
  # metal. It runs pull requests' code, so it keeps the module's sandbox: a
  # throwaway user that sees no home directory and no docker. The workflow
  # brings its toolchain and perf itself, with `nix develop`.
  services.github-runners.bbtree-perf = {
    enable = true;
    url = "https://github.com/XiangpengHao/bbtree";
    # A runner registration token, as the liquid-cache runner above has:
    #   gh api -X POST repos/XiangpengHao/bbtree/actions/runners/registration-token --jq .token
    # It lasts an hour, enough to register; the runner keeps its
    # registration after that. A change to this runner's options registers
    # it again, and so does GitHub deleting a runner that has been offline
    # for two weeks: both need a fresh token in the file.
    tokenFile = "/etc/github-runner/bbtree-perf-token";
    name = "pittsburgh-perf";
    replace = true;
    extraLabels = [ "bbtree-perf" ];
  };

  # The runner's perf counts user space unprivileged, which needs this at 2
  # or below. 2 is the kernel's default; this keeps it there.
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 2;
}
