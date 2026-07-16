{
  pkgs,
  inputs,
  withNvidia ? false,
  ...
}:
{
  imports = [
    ./niri.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_7_1;

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
  hardware.nvidia.package = pkgs.linuxPackages_7_1.nvidiaPackages.latest;
  services.xserver.videoDrivers = if withNvidia then [ "nvidia" ] else [ ];
  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = withNvidia;
  boot.blacklistedKernelModules = pkgs.lib.optionals withNvidia [ "amdgpu" ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services.colord.enable = true;
  services.pcscd.enable = true;

  programs.steam = {
    enable = withNvidia;
  };

  # allowUnfree is set globally in flake.nix.
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];
}
