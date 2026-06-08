{ programs, ... }:
{
  programs.niri.settings = {
    cursor = {
      theme = "Nordic-cursors";
      size = 48;
    };
    outputs."DP-3" = {
      scale = 1.5;
      # max-bpc = 10;
      variable-refresh-rate = true;
      mode = {
        width = 3840;
        height = 2160;
        refresh = 119.999;
      };
    };
  };
}
