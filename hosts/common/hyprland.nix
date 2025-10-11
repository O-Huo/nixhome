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
    settings = rec {
      tuigreet_session =
        let
          session = "uwsm start hyprland.desktop";
          tuigreet = "${lib.makeBinPath [ pkgs.greetd.tuigreet ]}/tuigreet";
        in
          {
          command = "${tuigreet} --time --remember --cmd ${session}";
          user = "greeter";
        };
      default_session = tuigreet_session;
    };
  };
}
