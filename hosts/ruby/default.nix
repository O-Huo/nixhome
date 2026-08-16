{ config, lib, pkgs, inputs, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = false;
    })
    ./xps-14-da14260
    ./ipu7/module.nix
    ./hardware-configuration.nix
    ../common/aoli.nix
    inputs.intel-lpmd-flake.nixosModules.default
  ];

  # IPU7 camera HAL stack from nixpkgs PR #542085; remove together with
  # ./ipu7 once the PR is merged.
  nixpkgs.overlays = [ (import ./ipu7/overlay.nix) ];

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  networking.hostName = "ruby";

  virtualisation.docker.enable = lib.mkForce false;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Required for browser-extension pairing and system-authentication unlock.
    polkitPolicyOwners = [ "aoli" ];
  };
  # nixpkgs' firefox runs as ".firefox-wrapped", which is not on 1Password's
  # built-in browser allowlist; Chrome ("chrome") is allowed by default.
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      .firefox-wrapped
    '';
    mode = "0755";
  };

  boot.initrd.systemd.enable = true;


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
    keyboards.realforce = {
      devices = [ "/dev/input/by-id/usb-Topre_REALFORCE_87_US-event-kbd" ];
      # kanata's uinput device defaults to bus i8042, which libinput's shipped
      # "MatchBus=ps2 -> AttrKeyboardIntegration=internal" quirk tags as the
      # built-in keyboard. libinput pairs the internal keyboard with the lid
      # switch, so a keypress while the lid reads closed is taken as proof the
      # switch is stuck and it forces the lid open -- relighting the internal
      # panel under a closed lid. Announce this external board as what it is.
      extraDefCfg = ''
        linux-output-device-name "kanata realforce"
        linux-output-device-bus-type USB
      '';
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

  # brightnessctl's rules chgrp the backlight to "video" and make it group-writable;
  # without them /sys/class/backlight/intel_backlight/brightness is root-only.
  environment.systemPackages = [
    pkgs.brightnessctl
  ];
  services.udev.packages = [ pkgs.brightnessctl ];

  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];
  boot.extraModprobeConfig = "options snd_hda_intel power_save=1";
  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 1500;
    "kernel.nmi_watchdog" = 0;
  };

  networking.networkmanager.wifi.powersave = false;

  services.intel-lpmd = {
    enable = true;
    # Panther Lake config with CachyOS's intel-lpmd@9c8739c applied:
    # Balanced/Powersaver use auto LPM instead of force-off.
    config.custom = {
      filename = "intel_lpmd_config_F6_M204.xml";
      content =
        builtins.replaceStrings
          [ "<BalancedDef>-1</BalancedDef>" "<PowersaverDef>-1</PowersaverDef>" ]
          [ "<BalancedDef>0</BalancedDef>" "<PowersaverDef>0</PowersaverDef>" ]
          (builtins.readFile "${inputs.intel-lpmd-flake.packages.${pkgs.system}.default}/share/xml/intel_lpmd_config_F6_M204.xml");
    };
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    IdleAction = "ignore";
  };

  # power-profiles-daemon has no built-in AC/battery switching, so drive it from
  # the AC adapter's udev events (and once at boot, when udev coldplugs it).
  systemd.services."power-profile@" = {
    description = "Set power profile to %I";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set %i";
    };
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-profile@power-saver.service"
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-profile@balanced.service"

    ACTION=="add|change", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ACTION=="add|change", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{bDeviceClass}!="09", ATTR{power/control}="on"

    # SVP7500 camera bridge: firmware used to wedge on autosuspend resume;
    # set back to "on" if the camera or face unlock stops enumerating.
    ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="0701", ATTR{power/autosuspend}="2", ATTR{power/control}="auto"
  '';
}
