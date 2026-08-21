{ pkgs, inputs, ... }: {
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

  # Build aarch64 derivations through qemu-user.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Let the session (noctalia idle via mouse-inhibit) suppress mouse input while
  # monitors are powered off, so only the keyboard wakes the screen.
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
