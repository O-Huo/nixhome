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

  # Let the session (noctalia idle via mouse-inhibit) suppress mouse input while
  # monitors are powered off, so only the keyboard wakes the screen.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="input[0-9]*", ENV{ID_INPUT_MOUSE}=="1", RUN+="${pkgs.coreutils}/bin/chgrp input /sys%p/inhibited", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys%p/inhibited"
  '';
  users.users.aoli.extraGroups = [ "input" ];
  networking.firewall.allowedTCPPorts = [ 8211 ];
  networking.firewall.allowedUDPPorts = [ 8211 ];
}
