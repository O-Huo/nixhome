{ pkgs
, lib
, ...
}: {
  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      cursor_shape = "block";
      font_family = "Fira Code";  
      font_size = lib.mkDefault (if pkgs.stdenv.isDarwin then 16 else 14);
      kitty_mod = "ctrl+shift";
      scrollback_lines = -1;
      shell = ".";
      window_border_width = 0;
    };
  };
}
