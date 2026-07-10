{ config, lib, pkgs, inputs, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = false;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];

 boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  networking.hostName = "ruby";

  boot.initrd.systemd.enable = true;

  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ./intel-cvs.nix { })
  ];
  boot.extraModprobeConfig = ''
    softdep intel_ipu7 pre: usbio gpio_usbio i2c_usbio intel_cvs intel_skl_int3472_discrete
    blacklist intel_ipu7_psys
  '';


  # Swap Alt/Super and make Caps Lock an extra Ctrl.
  services.kanata = {
    enable = true;
    keyboards.internal = {
      devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
      config = ''
        (defsrc
          caps lalt lmet
        )
        (deflayer base
          lctl lmet lalt
        )
      '';
    };
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";
}
