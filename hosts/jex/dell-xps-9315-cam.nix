# Dell XPS 9315 Cam
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # load missing patch
  int3472-kernel-module = pkgs.callPackage ./kernel-patch-int3472.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  # for older apps use custom serivce
  # start and stop manuall
  # systemctl stop camera-bridge.service

  # build our patched int4372 module which now supports 0x02 gpio for our camera sensor
  # i think the official kernel 6.16 is already patched, test when availbe
  # Build v4l2loopback as extra kernel module
  boot.extraModulePackages = [
    (int3472-kernel-module.overrideAttrs (_: {
      patches = [ ./intel-int3472-gpio-type.patch ];
    }))
    config.boot.kernelPackages.v4l2loopback
  ];

  # Ensure ipu6 firmware is available
  hardware.ipu6.enable = true;
  hardware.ipu6.platform = "ipu6ep";
  # default service is corrupted
  # !IMPORTANT do NOT install any ipu6 camera related package
  # this will mess up the whole setup
  # they do NOT work for this device and somehow don't care to check for support sensor types
  # I will try to adress this issues on github
  services.v4l2-relayd.instances.ipu6.enable = lib.mkForce false;
  hardware.firmware = with pkgs; [
    ivsc-firmware
  ];

  hardware.enableRedistributableFirmware = true;

  environment.systemPackages =
    with pkgs;
    (with gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
      gst-vaapi
    ])
    ++ [ libcamera ];

  # Enable hardware acceleration
  hardware.graphics.enable = true;

  # Enable PipeWire with all features
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # WirePlumber configuration to disable V4L2 and use only libcamera
    wireplumber.extraConfig = {
      # Disable V4L2 monitor to avoid duplicate camera entries
      "monitor.v4l2" = {
        "monitor.v4l2.disable" = true;
      };

    };
  };

  # camera browser support
  # XDG Portal aktivieren
  xdg.portal = {
    enable = true;
    # Wichtig: wlr unterstützt KEINE Kameras!
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome # oder
    ];
  };

  # check your browser settings for pipewire
  # e.g.
  # Firefox mit Portal-Support
  #  programs.firefox = {
  #    enable = true;
  #    preferences = {
  #      "media.webrtc.camera.allow-pipewire" = true;
  #      "widget.use-xdg-desktop-portal.file-picker" = 1;
  #    };
  #  };
  # brave brave://flags/
  # same webrtc pipewire
  # and enable xdg

  ##  # Legacy support is below
  ##  # for old apps
  ##  boot.kernelModules = [ "v4l2loopback" ];
  ##    # Configure v4l2loopback module parameters
  ##  boot.extraModprobeConfig = ''
  ##    options v4l2loopback video_nr=40 card_label="libcamera Virtual" exclusive_caps=1
  ##  '';
  ##  # solution we need a loopback deivce
  ##  # now that we have a fixed target we can use:
  ##  # libcamerify gst-launch-1.0 v4l2src device=/dev/camera-active ! videoconvert ! autovideosink
  ##
  ##  systemd.services.camera-setup = {
  ##    description = "Setup camera device symlink";
  ##    wantedBy = [ "multi-user.target" ];
  ##    serviceConfig = {
  ##      Type = "oneshot";
  ##      Restart="on-failure";
  ##      RestartSec=5;
  ##      RemainAfterExit = true;
  ##      ExecStart = pkgs.writeShellScript "camera-setup" ''
  ##        # Wait for udev to settle
  ##        ${pkgs.systemd}/bin/udevadm settle --timeout=10
  ##
  ##        # Try multiple times to find camera
  ##        for attempt in {1..10}; do
  ##          # Find active camera device
  ##          ACTIVE_DEVICE=$(${pkgs.v4l-utils}/bin/media-ctl --print-topology 2>/dev/null | \
  ##            ${pkgs.gnugrep}/bin/grep -B 3 "ENABLED" | \
  ##            ${pkgs.gnugrep}/bin/grep "device node name" | \
  ##            ${pkgs.gnugrep}/bin/grep -o "/dev/video[0-9]*" | head -1)
  ##
  ##          if [ -n "$ACTIVE_DEVICE" ]; then
  ##            # Create symlink to active device
  ##            ln -sf "$ACTIVE_DEVICE" /dev/camera-active
  ##            echo "Camera active device: $ACTIVE_DEVICE -> /dev/camera-active"
  ##            exit 0
  ##          else
  ##            echo "Attempt $attempt: No active camera found, waiting..."
  ##            sleep 2
  ##          fi
  ##        done
  ##
  ##        echo "ERROR: No active camera found after 10 attempts"
  ##        exit 1
  ##      '';
  ##    };
  ##  };
  ##
  ##    # Camera bridge service - pipes libcamera to v4l2loopback#
  ##  systemd.services.camera-bridge = {
  ##    description = "libcamera to v4l2loopback bridge";
  ##    #wantedBy = [ "multi-user.target" ]; manual start stop
  ##    after = [ "camera-setup.service" "systemd-modules-load.service" "modprobe@v4l2loopback.service"];
  ##    requires = [ "camera-setup.service" "systemd-modules-load.service" "modprobe@v4l2loopback.service" ];
  ##
  ##    path = with pkgs; (with gst_all_1; [
  ##       gstreamer
  ##       gst-plugins-base
  ##       gst-plugins-good
  ##       gst-plugins-bad
  ##       gst-plugins-ugly
  ##       gst-libav
  ##       gst-vaapi
  ##      ])
  ##      ++
  ##      [ libcamera ];
  ##
  ##    environment = {
  ##      GST_PLUGIN_SYSTEM_PATH_1_0 = with pkgs; "${gst_all_1.gstreamer.out}/lib/gstreamer-1.0::${gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:/run/current-system/sw/lib/gstreamer-1.0";
  ##    };
  ##
  ##
  ##    serviceConfig = {
  ##      Type = "simple";
  ##      RemainAfterExit = false;
  ##      Restart = "on-failure";
  ##      RestartSec = 5;
  ##      KillMode = "control-group";  # Alle Prozesse der Gruppe beenden
  ##      TimeoutStopSec = 5;  # Max 10 Sekunden zum Beenden
  ##
  ##      # Wait for devices to be ready
  ##      ExecStartPre = pkgs.writeShellScript "camera-bridge-pre" ''
  ##        # Wait for camera device symlink
  ##        attempt=0
  ##        while [ $attempt -lt 30 ]; do
  ##          if [ -L /dev/camera-active ] && [ -e /dev/camera-active ]; then
  ##            echo "Found camera-active symlink pointing to $(readlink /dev/camera-active)"
  ##            break
  ##          fi
  ##          attempt=$((attempt + 1))
  ##          echo "Waiting for /dev/camera-active... ($attempt/30)"
  ##          sleep 1
  ##        done
  ##
  ##        if [ ! -L /dev/camera-active ]; then
  ##          echo "ERROR: /dev/camera-active not found after 30 seconds"
  ##          exit 1
  ##        fi
  ##
  ##        # Wait for loopback device
  ##        attempt=0
  ##        while [ $attempt -lt 30 ]; do
  ##          if [ -c /dev/video40 ]; then
  ##            echo "Found loopback device /dev/video40"
  ##            break
  ##          fi
  ##          attempt=$((attempt + 1))
  ##          echo "Waiting for /dev/video40... ($attempt/30)"
  ##          sleep 1
  ##        done
  ##
  ##        if [ ! -c /dev/video40 ]; then
  ##          echo "ERROR: /dev/video40 not found after 30 seconds"
  ##          exit 1
  ##        fi
  ##
  ##        # Verify actual camera device exists
  ##        CAMERA_DEVICE=$(readlink /dev/camera-active)
  ##        if [ ! -c "$CAMERA_DEVICE" ]; then
  ##          echo "ERROR: Camera device $CAMERA_DEVICE does not exist"
  ##          exit 1
  ##        fi
  ##
  ##        echo "All devices ready: $CAMERA_DEVICE -> /dev/video40"
  ##      '';
  ##
  ##      # Start the bridge
  ##      ExecStart = pkgs.writeShellScript "camera-bridge" ''
  ##        echo "DEBUG: "
  ##        echo $GST_PLUGIN_SYSTEM_PATH_1_0
  ##
  ##        # Read the actual device from symlink
  ##        CAMERA_DEVICE=$(readlink /dev/camera-active)
  ##        echo "Starting camera bridge: $CAMERA_DEVICE -> /dev/video40"
  ##
  ##        # Simple working pipeline - just replace autovideosink with v4l2sink
  ##        exec ${pkgs.gst_all_1.gstreamer}/bin/gst-launch-1.0 libcamerasrc ! queue ! videoscale ! video/x-raw,width=1920,height=1080 ! videoconvert ! video/x-raw,format=YUY2 ! queue ! v4l2sink device=/dev/video40
  ##      '';
  ##    };
  ##  };

  # ----------------
  #   debug plan
  # My journey into a deep dive about ipu6 hardware and the linux camera stack
  # ----------------
  # Dell XPS 9315 specific
  # what we know
  # two sensors
  # OVTI01A0 und OVTI01AB
  #
  # über USB LJCA - das ist eine USB-zu-I2C Bridge!
  # we got a IO error, i guess default is I2C and not somehow missing USB LJCA for our device?

  # driver is not set ?
  # ls -la /sys/bus/i2c/devices/i2c-OVTI01A0:00/
  # missing /driver path
  #  dmesg | grep -i int3472
  #[    4.372536] int3472-discrete INT3472:01: INT3472 seems to have no dependents.
  #[    4.379618] int3472-discrete INT3472:06: GPIO type 0x02 unknown; the sensor may not work

  # dmesg | tail -40 | grep -E "int3472|GPIO|ov01a10|OVTI"
  # looks there there is a patch in the linux kernel for this
  # 6.16 or newer should include it!

  # my custom patch fixes our io specification
  # ls -la /sys/bus/i2c/devices/i2c-OVTI01A0:00/
  # has a driver attached

  # now we have
  # [   14.918589] pci 0000:00:05.0: deferred probe pending: intel-ipu6: IPU6 bridge init failed
  # maybe we can ignore and everything will load later

  # media-ctl --print-topology
  # check [ENABLED] device
  # -> for me /dev/video17
  # v4l2-ctl -d /dev/video17 --list-formats-ext

  # vl4 is not able to communicate with our webcam - old / or / wrong interface
  # so we need a loopback setup

  # gstreamer with libcamera, WORKS!!

  # icamerasrc is blocking our cam
  # ps aux | grep v4l2-relayd
  # /nix/store/casf4h8k83k3615w39hka76929gh422c-v4l2-relayd-0.1.3/bin/v4l2-relayd -i icamerasrc -o appsrc name=appsrc caps=video/x-raw,format=NV12,width=1280,height=720,framerate=30/1 ! videoconvert ! video/x-raw,format=YUY2 ! queue ! v4l2sink name=v4l2sink device=/dev/video32
  # icamerasrc won't work in our setup and is messing everything up!
  # remove and use libcamera only

  ##  # GStreamer environment setup for plugin discovery
  ##  environment.variables = {
  ##    GST_PLUGIN_SYSTEM_PATH_1_0 = "${pkgs.gst_all_1.gstreamer.out}/lib/gstreamer-1.0::${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0";
  ##  };

  # If you wanna debug your relay use
  # see available formats at v4l2-ctl --device=/dev/camera-active --list-formats-ext
  # gst-launch-1.0 libcamerasrc ! videoconvert ! video/x-raw,format=YUY2,width=640,height=480 ! v4l2sink device=/dev/video40
  # ffplay /dev/video40 or vlc v4l2:///dev/video40

  # Now you can test formats and settings
  # keep in mind that a higher resolution will result in more compute consumption ( check hardware usage while video steam)
  # and more network traffic

  # what I figured out on my setup for video calls
  # gst-launch-1.0 libcamerasrc ! videoscale ! video/x-raw,width=1920,height=1080 ! videoconvert ! video/x-raw,format=YUY2 ! v4l2sink device=/dev/video40

}
