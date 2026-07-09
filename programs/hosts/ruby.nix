{ programs, ... }:
{
  programs.niri.settings = {
    cursor = {
      theme = "Nordic-cursors";
      size = 48;
    };
    # Adjust scale/mode once the panel is known (`niri msg outputs`).
    outputs."eDP-1" = {
      scale = 1.5;
    };
  };
}
