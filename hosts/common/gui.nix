{
  pkgs,
  inputs,
  withNvidia ? false,
  ...
}:
let
  kernelPackages = pkgs.linuxPackages_cachyos;
in
{
  imports = [
    ./niri.nix
  ];

  boot.kernelPackages = kernelPackages;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.ignoreUserConfig = false; # see modules/home/fcitx5.nix
    fcitx5.waylandFrontend = true; # NOT to set GTK_IM_MODULE=fcitx
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-configtool
      # fcitx5-chinese-addons
      (fcitx5-rime.override {
        rimeDataPkgs = with pkgs.nur.repos.linyinfeng.rimePackages; withRimeDeps [ rime-ice ];
      })
      fcitx5-gtk
    ];
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-code-pro
      hack-font
      jetbrains-mono
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # https://wiki.nixos.org/wiki/NVIDIA
  hardware.graphics.enable = true;
  # Must be the CachyOS-specific driver; the generic nvidiaPackages.* are not
  # built against this kernel's LTO toolchain.
  hardware.nvidia.package = pkgs.nvidia_cachyos;
  services.xserver.videoDrivers = if withNvidia then [ "nvidia" ] else [ ];
  # Chaotic only prebuilds the open modules for the CachyOS kernel; the closed
  # ones are uncached and fail their reference check since 610.57.04.
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = withNvidia;
  boot.blacklistedKernelModules = pkgs.lib.optionals withNvidia [ "amdgpu" ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services.colord.enable = true;
  services.pcscd.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  environment.systemPackages = [
    pkgs.udiskie
  ]
  ++ pkgs.lib.optionals withNvidia [ pkgs.mangohud ];
  systemd.user.services.udiskie = {
    description = "udiskie removable media automounter";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie --automount --notify --tray";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  programs.steam = {
    enable = withNvidia;
  };

  # Opt in per game with `gamemoderun %command%` in its Steam launch options.
  programs.gamemode = {
    enable = withNvidia;
    settings.general = {
      renice = 10;
      # xdg-screensaver is X11-only; under niri it just logs errors.
      inhibit_screensaver = 0;
    };
  };
}
