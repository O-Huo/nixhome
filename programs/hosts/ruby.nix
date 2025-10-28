{ programs, ... }: {
  programs.noctalia-shell.settings.location = {
    name = "Pittsburgh, United States";
  };
  programs.niri.settings = {
    outputs."HDMI-A-4" = {
      scale = 1;
      mode = {
        width = 2560;
        height = 1440;
        refresh = 60.000;
      };
    };
    outputs."DP-6" = {
      scale = 1;
      mode = {
        width = 2560;
        height = 1440;
        refresh = 60.000;
      };
    };
  };
}
