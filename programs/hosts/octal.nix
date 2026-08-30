{ ... }:
{
  wayland.windowManager.niri.settings = {
    cursor.xcursor-size = 32;
    _children = [
      {
        output = {
          _args = [ "DP-3" ];
          scale = 1.5;
          # max-bpc = 10;
          variable-refresh-rate = { };
          mode = "3840x2160@119.999";
        };
      }
    ];
  };
}
