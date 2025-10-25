{ pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.noctalia.nixosModules.default
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
  ];
  services.noctalia-shell.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };
  services.gnome.gnome-keyring.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.makeBinPath [ pkgs.greetd.tuigreet ]}/tuigreet --time --remember --cmd ${pkgs.niri-unstable}/bin/niri-session";
        user = "greeter";
      };
    };
  };
}
