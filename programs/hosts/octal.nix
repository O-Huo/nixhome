{ programs, ... }: {
  programs.noctalia-shell.settings.location = {
    name = "Pittsburgh, United States";
  };
  # wayland.windowManager.hyprland.extraConfig = "
  #   monitor=DP-6, 3840x2160@240, 0x0, 1.5
  #   ";
  programs.niri.settings = {
    outputs."DP-6" = {
      scale = 1.5;
      mode = {
        width = 3840;
        height = 2160;
        refresh = 240.016;
      };
    };
  };
}
