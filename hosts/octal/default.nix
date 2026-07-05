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

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1532", ATTR{power/wakeup}="disabled"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{power/wakeup}="enabled"
  '';
}
