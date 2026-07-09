{ programs, ... }:
{
  programs.niri.settings = {
    cursor = {
      theme = "Nordic-cursors";
      size = 48;
    };
    outputs."eDP-1" = {
      scale = 1.5;
    };
  };
}
