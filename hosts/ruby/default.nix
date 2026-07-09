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

  # PSR wake-up latency makes the 120 Hz eDP panel feel laggy.
  boot.kernelParams = [
    "xe.enable_psr=0"
    "xe.enable_panel_replay=0"
  ];

  boot.initrd.systemd.enable = true;

  # MIPI camera (OV08X40 behind the Panther Lake IPU7). Needs the
  # out-of-tree intel_cvs driver, and the USBIO stack must be up before
  # the IPU7 probes or the sensor never enumerates.
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ./intel-cvs.nix { })
  ];
  boot.extraModprobeConfig = ''
    softdep intel_ipu7 pre: usbio gpio_usbio i2c_usbio intel_cvs intel_skl_int3472_discrete
  '';

  # The MIPI camera is only reachable through libcamera/PipeWire, but Zoom
  # (and other V4L2-only apps) can't use that. Relay the libcamera feed into
  # a v4l2loopback device they can open. The relay only grabs the sensor
  # while a client has the loopback device open.
  services.v4l2-relayd.instances.mipi-camera = {
    enable = true;
    cardLabel = "Built-in Front Camera";
    extraPackages = [ pkgs.libcamera ];
    input.pipeline = "libcamerasrc ! videoconvert ! videoscale ! videorate";
  };

  # Swap Alt/Super and make Caps Lock an extra Ctrl.
  services.kanata = {
    enable = true;
    keyboards.internal = {
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
