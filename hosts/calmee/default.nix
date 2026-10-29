{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
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

  # Keep calmee awake for SSH, including when no graphical session is running.
  # Override the sleep targets enabled in common/headless.nix.
  systemd.targets.sleep.enable = lib.mkForce false;
  systemd.targets.suspend.enable = lib.mkForce false;
  systemd.targets.hibernate.enable = lib.mkForce false;
  systemd.targets.hybrid-sleep.enable = lib.mkForce false;
  systemd.targets.suspend-then-hibernate.enable = lib.mkForce false;

  system.stateVersion = "26.05";
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;

  # Docker's containerd image store mounts container filesystems again for copies.
  # Indexing rejects those overlapping mounts with "device or resource busy".
  boot.extraModprobeConfig = ''
    options overlay index=off
  '';

  # The Thelio Io controller needs its driver and temperature-based fan daemon.
  boot.extraModulePackages = [ config.boot.kernelPackages.system76-io ];
  boot.kernelModules = [ "system76-thelio-io" ];
  hardware.system76.power-daemon.enable = true;

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

  # Avoid failed roaming to Incalmo's 6 GHz radio, which stalls SSH.
  systemd.services.NetworkManager.postStart = ''
    ${pkgs.networkmanager}/bin/nmcli connection modify Incalmo 802-11-wireless.band a
  '';

  virtualisation.docker.daemon.settings.default-address-pools = [
    {
      base = "10.128.0.0/12";
      size = 24;
    }
  ];

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
