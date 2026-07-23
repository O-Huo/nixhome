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
  ];

  # IPU7 camera HAL stack from nixpkgs PR #542085; remove together with
  # ./ipu7 once the PR is merged.
  nixpkgs.overlays = [ (import ./ipu7/overlay.nix) ];

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  networking.hostName = "ruby";

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
    pkgs.docker-compose
  ];
  services.udev.packages = [ pkgs.brightnessctl ];

  powerManagement.powertop.enable = true;
  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";

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
  '';
}
