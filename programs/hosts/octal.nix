{ programs, ... }: {
  programs.noctalia-shell.settings.location = {
    name = "Pittsburgh, United States";
  };
  # wayland.windowManager.hyprland.extraConfig = "
  #   monitor=DP-6, 3840x2160@240, 0x0, 1.5
  #   ";
  programs.niri.settings = {
    cursor = {
        theme = "Nordic-cursors";
        size = 48;
      };
    outputs."DP-3" = {
      scale = 1.5;
      mode = {
        width = 3840;
        height = 2160;
        refresh = 240.016;
      };
    };
  };
}
