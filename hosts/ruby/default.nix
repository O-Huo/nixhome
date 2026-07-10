{ config, pkgs, inputs, ... }: {
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
    (config.boot.kernelPackages.callPackage ./ipu-bridge.nix { })
  ];
  boot.extraModprobeConfig = ''
    softdep intel_ipu7 pre: usbio gpio_usbio i2c_usbio intel_cvs intel_skl_int3472_discrete
  '';

  # The ov08x40's 2-lane binned mode (1928x1088) is broken on IPU7: every
  # frame completes with INSYS_MSG_ERR_CAPTURE_HW_ERR_BAD_FRAME_DIM and the
  # stream crawls at 3.6 fps. The full-res mode streams clean at 28.6 fps,
  # so capture at 4K (full sensor mode, full FoV) and downscale on the CPU.
  # The leaky queue drops frames instead of building latency when the
  # scale/convert stage falls behind.
  services.v4l2-relayd.instances.mipi-camera = {
    enable = true;
    cardLabel = "Built-in Front Camera";
    extraPackages = [ pkgs.libcamera ];
    input.pipeline = "libcamerasrc ! video/x-raw,width=3840,height=2160 ! queue max-size-buffers=2 leaky=downstream ! videoscale ! video/x-raw,width=1280,height=720 ! videoconvert n-threads=4 ! video/x-raw,format=YUY2 ! videorate";
  };

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
