{ programs, ... }: {
  programs.noctalia-shell.settings.location = {
    name = "Pittsburgh, United States";
  };
  wayland.windowManager.hyprland.extraConfig = "
    monitor=HDMI-A-4, 2560x1440@60, 0x0, 1
    monitor=DP-6, 2560x1440@60, 2560x0, 1, 
    ";
}
