{ pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXHOME_PATH = builtins.toString ./../..;
  };
  services.gnome.gnome-keyring.enable = true;
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "niri";
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
    };
  };
}
