{
  pkgs,
  lib,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    settings = {
      cursor.style.shape = "Block";
      font = {
        normal.family = "FiraCode Nerd Font";
        size = 14;
      };
      scrolling.history = 10000;
      window.padding = {
        x = 0;
        y = 0;
      };
    };
  };
}
