{pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
  ];
  imports = [
    inputs.noctalia.nixosModules.default
  ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  services.noctalia-shell.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "0";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "0";
  };
  services.gnome.gnome-keyring.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.makeBinPath [ pkgs.greetd.tuigreet ]}/tuigreet --time --remember --remember-session --sessions ${pkgs.hyprland}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };
}
