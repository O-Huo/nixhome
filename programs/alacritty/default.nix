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
        normal.family = "Fira Code";
        size = lib.mkDefault (if pkgs.stdenv.isDarwin then 14 else 12);
      };
      # Alacritty does not support truly infinite scrollback.
      scrolling.history = 100000;
      window.padding = {
        x = 0;
        y = 0;
      };
    };
  };
}
