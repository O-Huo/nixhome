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
      withNvidia = true;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  networking.hostName = "octal";

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos-lts;
  hardware.nvidia.package = lib.mkForce (
    let
      driver = pkgs.nvidia_cachyos-lts;
    in
    driver
    // {
      # Candidate fix for NVIDIA #801: wait for both hardware heads before
      # reporting flip completion on high-refresh-rate merged displays.
      open = driver.open.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../../patches/nvidia-flip-completion.patch ];
      });
    }
  );

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="input[0-9]*", ENV{ID_INPUT_MOUSE}=="1", RUN+="${pkgs.coreutils}/bin/chgrp input /sys%p/inhibited", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys%p/inhibited"
  '';
  # gamemode: required for the renice configured in gui.nix to apply.
  users.users.aoli.extraGroups = [
    "input"
    "gamemode"
  ];

  # sched-ext userspace scheduler tuned for gaming/interactivity; the CachyOS
  # kernel ships sched-ext support, and lavd is what CachyOS defaults to.
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
  networking.firewall.allowedTCPPorts = [ 8211 ];
  networking.firewall.allowedUDPPorts = [ 8211 ];
}
