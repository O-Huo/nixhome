{ programs, ... }: {
  programs.noctalia-shell.settings.location = {
    name = "Pittsburgh, United States";
  };
  wayland.windowManager.hyprland.extraConfig = "
    monitor=DP-6, 3840x2160@240, 0x0, 1.5
    ";
}
