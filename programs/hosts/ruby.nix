{ pkgs, ... }:
{
  home.packages = [
    pkgs.teams-for-linux
    pkgs.google-cloud-sdk
    pkgs.librepods
    pkgs.powertop
  ];

  wayland.windowManager.niri.settings = {
    cursor.xcursor-size = 32;
    _children = [
      {
        output = {
          _args = [ "eDP-1" ];
          scale = 1.5;
          variable-refresh-rate = { };
          position._props = {
            x = 320;
            y = 1440;
          };
        };
      }
      {
        output = {
          _args = [ "Dell Inc. DELL U2722D 3GH2ZG3" ];
          scale = 1;
          position._props = {
            x = 0;
            y = 0;
          };
        };
      }
      {
        output = {
          _args = [ "DP-1" ];
          scale = 1.5;
          position._props = {
            x = 0;
            y = 0;
          };
          mode = "3840x2160@120";
        };
      }
      {
        output = {
          _args = [ "ASUSTek COMPUTER INC PG32UCDM S3LMQS114886" ];
          scale = 1.5;
          # max-bpc = 10;
          variable-refresh-rate = { };
          mode = "3840x2160@240.016";
          position._props = {
            x = 0;
            y = 0;
          };
        };
      }
    ];
  };
}
