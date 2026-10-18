{ pkgs, inputs, ... }:
{
  imports = [
    (import ../common {
      inherit pkgs inputs;
      # Ryzen 9 9950X integrated Radeon graphics (1002:13c0).
      withNvidia = false;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];

  networking.hostName = "calmee";
  system.stateVersion = "26.05";
  boot.initrd.systemd.enable = true;
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;

  services.gnome.gcr-ssh-agent.enable = false;
  programs.firefox = {
    enable = true;
    preferences."media.webrtc.camera.allow-pipewire" = false;
  };
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "aoli" ];
  };
  environment.etc."1password/custom_allowed_browsers" = {
    text = ".firefox-wrapped\n";
    mode = "0755";
  };

  services.resolved.enable = true;
  services.resolved.settings.Resolve.ResolveUnicastSingleLabel = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.tailscale.extraSetFlags = [
    "--accept-dns=true"
    "--accept-routes=true"
  ];

  services.kanata = {
    enable = true;
    keyboards.realforce = {
      devices = [ "/dev/input/by-id/usb-Topre_REALFORCE_87_US-event-kbd" ];
      extraDefCfg = ''
        linux-output-device-name "kanata realforce"
        linux-output-device-bus-type USB
      '';
      config = ''
        (defsrc caps lalt lmet)
        (deflayer base lctl lmet lalt)
      '';
    };
  };
}
